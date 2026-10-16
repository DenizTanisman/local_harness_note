#!/usr/bin/env bash
# Deploys the Claude relay and prints:
#   1. the pairing code   → Not app › Ayarlar › Claude bağlantısı
#   2. the MCP server URL → claude.ai › Settings › Connectors › Add custom connector
#
# Usage: ./setup.sh <google-services.json> <firebase-service-account.json>
#   google-services.json         Firebase console › Project settings › Your apps
#                                (Android app, package dev.deniz.local_harness_not)
#   firebase-service-account.json Firebase console › Project settings ›
#                                Service accounts › Generate new private key
#
# Re-running keeps the same secrets (pairing.json), so the phone and Claude
# stay connected.
set -euo pipefail
cd "$(dirname "$0")"

GS=${1:?google-services.json yolu gerekli}
SA=${2:?service account JSON yolu gerekli}
PACKAGE=dev.deniz.local_harness_not

[ -x node_modules/.bin/wrangler ] || npm install --no-fund --no-audit
if ! npx wrangler whoami 2>/dev/null | grep -q "associated with"; then
  echo "Cloudflare'e giriş yapılmamış. Önce: (cd worker && npx wrangler login)" >&2
  exit 1
fi

if [ -f pairing.json ]; then
  RELAY_SECRET=$(python3 -c "import json;print(json.load(open('pairing.json'))['secret'])")
  MCP_TOKEN=$(python3 -c "import json;print(json.load(open('pairing.json'))['mcp_token'])")
else
  RELAY_SECRET=$(openssl rand -hex 24)
  MCP_TOKEN=$(openssl rand -hex 24)
fi

echo "› Worker yayınlanıyor…"
URL=$(npx wrangler deploy 2>&1 | tee /dev/stderr | grep -o 'https://[^ ]*workers\.dev' | head -1)
[ -n "$URL" ] || { echo "Worker adresi bulunamadı (yukarıdaki çıktıya bak)." >&2; exit 1; }

echo "› Gizli anahtarlar yazılıyor…"
printf '%s' "$RELAY_SECRET" | npx wrangler secret put RELAY_SECRET >/dev/null
printf '%s' "$MCP_TOKEN" | npx wrangler secret put MCP_TOKEN >/dev/null
npx wrangler secret put FCM_SERVICE_ACCOUNT < "$SA" >/dev/null

python3 - "$GS" "$SA" "$URL" "$RELAY_SECRET" "$MCP_TOKEN" "$PACKAGE" <<'PY'
import json, sys
gs_path, sa_path, url, secret, token, package = sys.argv[1:]
gs = json.load(open(gs_path))
sa = json.load(open(sa_path))
client = next(
    (c for c in gs["client"]
     if c["client_info"]["android_client_info"]["package_name"] == package),
    None,
)
if client is None:
    sys.exit(f"google-services.json içinde {package} uygulaması yok")
if sa.get("project_id") != gs["project_info"]["project_id"]:
    sys.exit("service account ile google-services.json farklı projelere ait")
firebase = {
    "apiKey": client["api_key"][0]["current_key"],
    "appId": client["client_info"]["mobilesdk_app_id"],
    "messagingSenderId": gs["project_info"]["project_number"],
    "projectId": gs["project_info"]["project_id"],
}
json.dump(
    {"url": url, "secret": secret, "mcp_token": token, "firebase": firebase},
    open("pairing.json", "w"),
    indent=1,
)
code = json.dumps({"url": url, "secret": secret, "firebase": firebase},
                  separators=(",", ":"))
print("\n1) Telefondaki bağlantı kodu (Ayarlar › Claude bağlantısı):\n")
print(code)
print("\n2) Claude'a eklenecek MCP adresi (claude.ai › Ayarlar › Bağlayıcılar › Özel bağlayıcı ekle):\n")
print(f"{url}/mcp/{token}")
print("\nBu iki değer gizlidir; pairing.json git'e girmez.")
PY

if command -v pbcopy >/dev/null; then
  python3 -c "import json;d=json.load(open('pairing.json'));print(json.dumps({k:d[k] for k in ('url','secret','firebase')},separators=(',',':')),end='')" | pbcopy
  echo "(Bağlantı kodu panoya da kopyalandı.)"
fi
