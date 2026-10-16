// End-to-end test of the relay on `wrangler dev` (dev mode: no FCM — the
// fake phone below polls /phone/work instead of being woken by a push).
import { test, before, after } from "node:test";
import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { writeFileSync, rmSync } from "node:fs";
import { setTimeout as sleep } from "node:timers/promises";

const PORT = 8799;
const BASE = `http://127.0.0.1:${PORT}`;
const SECRET = "test-secret-0123456789abcdef";
const TOKEN = "test-mcp-token";
let dev;

before(async () => {
  writeFileSync(".dev.vars", `RELAY_SECRET=${SECRET}\nMCP_TOKEN=${TOKEN}\n`);
  rmSync(".wrangler/state", { recursive: true, force: true });
  dev = spawn("npx", ["wrangler", "dev", "--port", String(PORT), "--ip", "127.0.0.1"], {
    stdio: "ignore",
  });
  for (let i = 0; i < 120; i++) {
    try {
      if ((await fetch(BASE)).ok) return;
    } catch {}
    await sleep(500);
  }
  throw new Error("wrangler dev did not start");
});

after(() => {
  dev?.kill();
  rmSync(".dev.vars", { force: true });
});

let nextId = 1;
async function rpc(method, params) {
  const res = await fetch(`${BASE}/mcp/${TOKEN}`, {
    method: "POST",
    headers: { "content-type": "application/json", accept: "application/json, text/event-stream" },
    body: JSON.stringify({ jsonrpc: "2.0", id: nextId++, method, params }),
  });
  assert.equal(res.status, 200);
  return (await res.json()).result;
}

const phone = (path, body) =>
  fetch(`${BASE}/phone/${path}`, {
    method: body ? "POST" : "GET",
    headers: { authorization: `Bearer ${SECRET}`, "content-type": "application/json" },
    body: body ? JSON.stringify(body) : undefined,
  }).then((r) => r.json());

/** A fake phone: answers every waiting call until stopped. */
function fakePhone(answer) {
  let running = true;
  const seen = [];
  (async () => {
    while (running) {
      const work = await phone("work");
      for (const call of [...work.inflight, ...work.queued]) {
        seen.push(call);
        await phone("result", { reqId: call.reqId, ...answer(call) });
      }
      await sleep(150);
    }
  })();
  return { seen, stop: () => (running = false) };
}

test("secrets guard both doors", async () => {
  assert.equal((await fetch(`${BASE}/mcp/wrong`, { method: "POST", body: "{}" })).status, 404);
  assert.equal((await fetch(`${BASE}/phone/work`)).status, 401);
});

test("initialize + tools/list", async () => {
  const init = await rpc("initialize", {
    protocolVersion: "2025-06-18",
    capabilities: {},
    clientInfo: { name: "test", version: "0" },
  });
  assert.equal(init.protocolVersion, "2025-06-18");
  assert.ok(init.capabilities.tools);
  assert.match(init.instructions, /phone/);
  const notif = await fetch(`${BASE}/mcp/${TOKEN}`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ jsonrpc: "2.0", method: "notifications/initialized" }),
  });
  assert.equal(notif.status, 202);
  const { tools } = await rpc("tools/list", {});
  assert.deepEqual(tools.map((t) => t.name).sort(), [
    "add_to_reminders", "append_to_note", "archive_note", "create_note",
    "get_note", "list_recent", "search_notes",
  ]);
  assert.ok(!tools.some((t) => /delete/.test(t.name)));
});

test("unpaired phone → clear error", async () => {
  const r = await rpc("tools/call", { name: "search_notes", arguments: { query: "x" } });
  assert.equal(r.isError, true);
  assert.match(r.content[0].text, /not paired/);
});

test("call goes to the phone and the answer comes back", async () => {
  assert.deepEqual(await phone("register", { token: "fake-fcm-token" }), { ok: true });
  const p = fakePhone((call) => ({ ok: true, result: { echo: call.tool, args: call.args } }));
  const r = await rpc("tools/call", { name: "search_notes", arguments: { query: "ışık" } });
  p.stop();
  assert.equal(r.isError, undefined);
  assert.deepEqual(JSON.parse(r.content[0].text), { echo: "search_notes", args: { query: "ışık" } });
});

test("phone-side error is passed through as isError", async () => {
  const p = fakePhone(() => ({ ok: false, error: "Not bulunamadı: x" }));
  const r = await rpc("tools/call", { name: "get_note", arguments: { id: "x" } });
  p.stop();
  assert.equal(r.isError, true);
  assert.equal(r.content[0].text, "Not bulunamadı: x");
});

test("selftest round-trip", async () => {
  const p = fakePhone(() => ({ ok: true, result: { pong: true } }));
  const r = await phone("selftest", {});
  p.stop();
  assert.equal(r.ok, true);
  assert.ok(r.ms >= 0);
});

test("silent phone: write is queued, read errors; queue drains", { timeout: 90_000 }, async () => {
  await sleep(400); // let the previous fake phone stop
  const [write, read] = await Promise.all([
    rpc("tools/call", { name: "create_note", arguments: { text: "kuyruk testi" } }),
    rpc("tools/call", { name: "search_notes", arguments: { query: "x" } }),
  ]);
  assert.match(write.content[0].text, /queued/);
  assert.equal(write.isError, undefined);
  assert.equal(read.isError, true);
  assert.match(read.content[0].text, /25 s/);

  const work = await phone("work");
  assert.equal(work.inflight.length, 0);
  assert.equal(work.queued.length, 1);
  assert.equal(work.queued[0].tool, "create_note");
  await phone("result", { reqId: work.queued[0].reqId, ok: true, result: { id: "n1" } });
  assert.equal((await phone("work")).queued.length, 0);
});
