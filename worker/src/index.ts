// Not — Claude MCP relay (docs/second-brain-spec.md §8).
//
// Claude ──MCP──▶ this Worker ──FCM "wake"──▶ phone
//                     ▲                          │ GET /phone/work
//                     └────── POST /phone/result ┘
//
// Notes live only on the phone. The Durable Object keeps a call in memory
// until the phone answers (25 s at most); write calls the phone missed are
// queued and handed over on its next wake, then dropped.

import { DurableObject } from "cloudflare:workers";

export interface Env {
  RELAY: DurableObjectNamespace<Relay>;
  RELAY_SECRET: string;
  MCP_TOKEN: string;
  /** Firebase service-account JSON. Unset → dev mode (no push). */
  FCM_SERVICE_ACCOUNT?: string;
}

const TIMEOUT_MS = 25_000;
const WRITE_TOOLS = new Set([
  "create_note",
  "append_to_note",
  "archive_note",
  "add_to_reminders",
]);
const PROTOCOL_VERSIONS = ["2025-11-25", "2025-06-18", "2025-03-26", "2024-11-05"];

const INSTRUCTIONS = `These are the user's personal notes and ideas ("second brain"), stored only on their Android phone, mostly in Turkish.
Every call wakes the phone, so a call can take a few seconds; if the phone is offline you get an error after ~25 s.
To find something, call search_notes with a few keyword variants (search ignores Turkish diacritics and matches word prefixes), then get_note for the full text. list_recent shows what was written lately.
Notes the user marked private are never visible. There is no delete tool; archive_note hides a note from the inbox.
add_to_reminders puts a note on the user's reminder list (shown in order at 07:30, 14:00 and 20:00).`;

const TOOLS = [
  {
    name: "search_notes",
    title: "Search notes",
    description:
      "Full-text search over the user's notes. Words are prefix-matched and Turkish-insensitive (isik finds ışık). '#tag' words in the query filter by tag. Returns id, title, a snippet, tags and dates.",
    inputSchema: {
      type: "object",
      properties: {
        query: { type: "string", description: "Keywords; may include #tags" },
        tag: { type: "string", description: "Only notes with this tag (without #)" },
        since: { type: "string", description: "Only notes changed on/after YYYY-MM-DD" },
        include_archived: { type: "boolean", description: "Also search the archive" },
        limit: { type: "integer", minimum: 1, maximum: 30, description: "Default 20" },
      },
    },
    annotations: { readOnlyHint: true, openWorldHint: false },
  },
  {
    name: "list_recent",
    title: "Recent notes",
    description: "Inbox notes changed in the last N days, newest first, paginated.",
    inputSchema: {
      type: "object",
      properties: {
        days: { type: "integer", minimum: 1, description: "Default 7" },
        tag: { type: "string" },
        limit: { type: "integer", minimum: 1, maximum: 30 },
        cursor: { type: "string", description: "next_cursor from the previous page" },
      },
    },
    annotations: { readOnlyHint: true, openWorldHint: false },
  },
  {
    name: "get_note",
    title: "Read a note",
    description: "Full text, tags, status, dates and reminder flag of one note.",
    inputSchema: {
      type: "object",
      properties: { id: { type: "string" } },
      required: ["id"],
    },
    annotations: { readOnlyHint: true, openWorldHint: false },
  },
  {
    name: "create_note",
    title: "Create a note",
    description:
      "Saves a new note on the phone. Plain text; the first line is its title; put #tags inline. Use when the user asks you to note/remember something.",
    inputSchema: {
      type: "object",
      properties: { text: { type: "string" } },
      required: ["text"],
    },
    annotations: { readOnlyHint: false, destructiveHint: false, openWorldHint: false },
  },
  {
    name: "append_to_note",
    title: "Append to a note",
    description: "Adds text to the end of an existing note (separated by a blank line).",
    inputSchema: {
      type: "object",
      properties: { id: { type: "string" }, text: { type: "string" } },
      required: ["id", "text"],
    },
    annotations: { readOnlyHint: false, destructiveHint: false, openWorldHint: false },
  },
  {
    name: "archive_note",
    title: "Archive a note",
    description: "Moves a note to the archive (reversible in the app). Also takes it off the reminder list.",
    inputSchema: {
      type: "object",
      properties: { id: { type: "string" } },
      required: ["id"],
    },
    annotations: { readOnlyHint: false, destructiveHint: false, idempotentHint: true, openWorldHint: false },
  },
  {
    name: "add_to_reminders",
    title: "Add to reminders",
    description: "Appends a note to the user's ordered reminder list.",
    inputSchema: {
      type: "object",
      properties: { id: { type: "string" } },
      required: ["id"],
    },
    annotations: { readOnlyHint: false, destructiveHint: false, idempotentHint: true, openWorldHint: false },
  },
];

type Call = { reqId: string; tool: string; args: Record<string, unknown>; ts: number };
type PhoneResult = { reqId: string; ok: boolean; result?: unknown; error?: string };
type Outcome =
  | { kind: "ok"; result: unknown }
  | { kind: "error"; message: string }
  | { kind: "queued" };

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json" },
  });

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    const [head, tail] = url.pathname.split("/").filter(Boolean);
    const relay = env.RELAY.get(env.RELAY.idFromName("main"));

    if (head === "mcp") {
      if (!env.MCP_TOKEN || tail !== env.MCP_TOKEN) {
        return new Response("not found", { status: 404 });
      }
      return relay.fetch(new Request("https://relay/mcp", request));
    }
    if (head === "phone") {
      if (!env.RELAY_SECRET || request.headers.get("authorization") !== `Bearer ${env.RELAY_SECRET}`) {
        return new Response("unauthorized", { status: 401 });
      }
      return relay.fetch(new Request(`https://relay/phone/${tail ?? ""}`, request));
    }
    if (url.pathname === "/") return new Response("not-relay ok");
    return new Response("not found", { status: 404 });
  },
};

export class Relay extends DurableObject<Env> {
  private inflight = new Map<string, Call>();
  private waiters = new Map<string, (r: PhoneResult) => void>();
  private access?: { token: string; exp: number };

  async fetch(request: Request): Promise<Response> {
    const path = new URL(request.url).pathname;
    switch (path) {
      case "/mcp":
        return this.mcp(request);
      case "/phone/register": {
        const { token } = await request.json<{ token?: string }>();
        if (!token) return json({ ok: false, error: "token missing" }, 400);
        await this.ctx.storage.put("fcmToken", token);
        return json({ ok: true });
      }
      case "/phone/work":
        return json({
          inflight: [...this.inflight.values()],
          queued: (await this.ctx.storage.get<Call[]>("queue")) ?? [],
        });
      case "/phone/result": {
        const r = await request.json<PhoneResult>();
        this.waiters.get(r.reqId)?.(r);
        this.waiters.delete(r.reqId);
        this.inflight.delete(r.reqId);
        const queue = (await this.ctx.storage.get<Call[]>("queue")) ?? [];
        const rest = queue.filter((c) => c.reqId !== r.reqId);
        if (rest.length !== queue.length) await this.ctx.storage.put("queue", rest);
        return json({ ok: true });
      }
      case "/phone/selftest": {
        const started = Date.now();
        const outcome = await this.callPhone("ping", {});
        return outcome.kind === "ok"
          ? json({ ok: true, ms: Date.now() - started })
          : json({ ok: false, error: outcome.kind === "error" ? outcome.message : "queued" });
      }
    }
    return new Response("not found", { status: 404 });
  }

  // ------------------------------------------------------------------ MCP

  private async mcp(request: Request): Promise<Response> {
    if (request.method !== "POST") {
      return new Response(null, { status: 405, headers: { allow: "POST" } });
    }
    let body: unknown;
    try {
      body = await request.json();
    } catch {
      return json({ jsonrpc: "2.0", id: null, error: { code: -32700, message: "Parse error" } }, 400);
    }
    const batch = Array.isArray(body);
    const messages = (batch ? body : [body]) as Record<string, any>[];
    const replies = [];
    for (const m of messages) {
      const reply = await this.rpc(m);
      if (reply) replies.push(reply);
    }
    if (replies.length === 0) return new Response(null, { status: 202 });
    return json(batch ? replies : replies[0]);
  }

  private async rpc(m: Record<string, any>) {
    // Notifications (no id) need no answer.
    if (m.id === undefined || m.id === null) return null;
    const ok = (result: unknown) => ({ jsonrpc: "2.0", id: m.id, result });
    const fail = (code: number, message: string) => ({ jsonrpc: "2.0", id: m.id, error: { code, message } });

    switch (m.method) {
      case "initialize": {
        const asked = m.params?.protocolVersion;
        return ok({
          protocolVersion: PROTOCOL_VERSIONS.includes(asked) ? asked : PROTOCOL_VERSIONS[1],
          capabilities: { tools: { listChanged: false } },
          serverInfo: { name: "not-second-brain", title: "Not (telefon notları)", version: "1.0.0" },
          instructions: INSTRUCTIONS,
        });
      }
      case "ping":
        return ok({});
      case "tools/list":
        return ok({ tools: TOOLS });
      case "tools/call": {
        const name = m.params?.name;
        if (!TOOLS.some((t) => t.name === name)) return fail(-32602, `Unknown tool: ${name}`);
        const outcome = await this.callPhone(name, m.params?.arguments ?? {});
        switch (outcome.kind) {
          case "ok":
            return ok({ content: [{ type: "text", text: JSON.stringify(outcome.result, null, 1) }] });
          case "queued":
            return ok({
              content: [
                {
                  type: "text",
                  text: "The phone did not answer within 25 s, so this change was queued. It will be applied the next time the phone wakes up or the app is opened.",
                },
              ],
            });
          case "error":
            return ok({ isError: true, content: [{ type: "text", text: outcome.message }] });
        }
      }
    }
    return fail(-32601, `Method not found: ${m.method}`);
  }

  // ---------------------------------------------------------------- phone

  /** Wakes the phone and waits for its answer to one tool call. */
  async callPhone(tool: string, args: Record<string, unknown>): Promise<Outcome> {
    if (!(await this.ctx.storage.get<string>("fcmToken"))) {
      return { kind: "error", message: "The phone is not paired with this relay yet (Not app → Ayarlar → Claude bağlantısı)." };
    }
    const call: Call = { reqId: crypto.randomUUID(), tool, args, ts: Date.now() };
    this.inflight.set(call.reqId, call);
    const answered = new Promise<PhoneResult>((resolve) => this.waiters.set(call.reqId, resolve));

    try {
      await this.push();
    } catch (e) {
      this.inflight.delete(call.reqId);
      this.waiters.delete(call.reqId);
      return { kind: "error", message: `Could not wake the phone: ${e}` };
    }

    let timer: ReturnType<typeof setTimeout> | undefined;
    const timedOut = new Promise<null>((resolve) => {
      timer = setTimeout(() => resolve(null), TIMEOUT_MS);
    });
    const result = await Promise.race([answered, timedOut]);
    clearTimeout(timer);
    this.inflight.delete(call.reqId);
    this.waiters.delete(call.reqId);

    if (result) {
      return result.ok
        ? { kind: "ok", result: result.result }
        : { kind: "error", message: result.error ?? "The phone could not run this tool." };
    }
    if (WRITE_TOOLS.has(tool)) {
      const queue = (await this.ctx.storage.get<Call[]>("queue")) ?? [];
      await this.ctx.storage.put("queue", [...queue, call]);
      return { kind: "queued" };
    }
    return {
      kind: "error",
      message: "The phone did not answer within 25 s (off, offline, or asleep under battery saver). Try again later.",
    };
  }

  /** High-priority FCM data message: "wake up and check /phone/work". */
  private async push(): Promise<void> {
    const token = await this.ctx.storage.get<string>("fcmToken");
    if (!this.env.FCM_SERVICE_ACCOUNT) return; // dev mode: the test phone polls
    const sa = JSON.parse(this.env.FCM_SERVICE_ACCOUNT);
    const access = await this.accessToken(sa);
    const res = await fetch(
      `https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`,
      {
        method: "POST",
        headers: { authorization: `Bearer ${access}`, "content-type": "application/json" },
        body: JSON.stringify({
          message: {
            token,
            data: { wake: "1" },
            android: { priority: "HIGH", ttl: "30s", collapse_key: "wake" },
          },
        }),
      },
    );
    if (!res.ok) throw new Error(`FCM ${res.status}: ${(await res.text()).slice(0, 300)}`);
  }

  /** OAuth2 access token for FCM from the service account (JWT bearer). */
  private async accessToken(sa: { client_email: string; private_key: string }): Promise<string> {
    const now = Math.floor(Date.now() / 1000);
    if (this.access && this.access.exp > now + 60) return this.access.token;
    const b64url = (data: ArrayBuffer | string) =>
      btoa(typeof data === "string" ? data : String.fromCharCode(...new Uint8Array(data)))
        .replace(/\+/g, "-")
        .replace(/\//g, "_")
        .replace(/=+$/, "");
    const header = b64url(JSON.stringify({ alg: "RS256", typ: "JWT" }));
    const claims = b64url(
      JSON.stringify({
        iss: sa.client_email,
        scope: "https://www.googleapis.com/auth/firebase.messaging",
        aud: "https://oauth2.googleapis.com/token",
        iat: now,
        exp: now + 3600,
      }),
    );
    const pem = sa.private_key.replace(/-----[^-]+-----/g, "").replace(/\s+/g, "");
    const der = Uint8Array.from(atob(pem), (c) => c.charCodeAt(0));
    const key = await crypto.subtle.importKey(
      "pkcs8",
      der,
      { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
      false,
      ["sign"],
    );
    const signature = await crypto.subtle.sign(
      "RSASSA-PKCS1-v1_5",
      key,
      new TextEncoder().encode(`${header}.${claims}`),
    );
    const res = await fetch("https://oauth2.googleapis.com/token", {
      method: "POST",
      headers: { "content-type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams({
        grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
        assertion: `${header}.${claims}.${b64url(signature)}`,
      }),
    });
    if (!res.ok) throw new Error(`Google OAuth ${res.status}: ${(await res.text()).slice(0, 300)}`);
    const { access_token, expires_in } = await res.json<{ access_token: string; expires_in: number }>();
    this.access = { token: access_token, exp: now + expires_in };
    return access_token;
  }
}
