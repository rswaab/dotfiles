#!/bin/bash
# @raycast.schemaVersion 1
# @raycast.title Send → Inbox
# @raycast.mode silent
# @raycast.packageName Tana
# @raycast.icon 🛰️

WEBHOOK="http://127.0.0.1:8787"
API_KEY="change-me"          # must match WEBHOOK_API_KEY in .env
WORKSPACE="main"             # main | sandbox
DEST_KEY="inbox"             # your preset (inbox, studyclix, home, etc.)
CONNECT_OPTS="--connect-timeout 5 --max-time 10"

CLIP=$(pbpaste)

# Strip ```json fences
if [[ "$CLIP" == \`\`\`* ]]; then
  CLIP=$(printf "%s" "$CLIP" | sed -e '1s/^```[jJ][sS][oO][nN]\{0,1\}[[:space:]]*//' -e '$s/[[:space:]]*```$//')
fi

# Validate JSON
if ! python3 -c 'import json,sys; json.loads(sys.stdin.read())' <<<"$CLIP"; then
  /usr/bin/osascript -e 'display notification "Clipboard is not JSON." with title "Tana"'
  exit 1
fi

# Health check with auth
HC=$(curl -sS -o /dev/null -w "%{http_code}" $CONNECT_OPTS -H "Authorization: Bearer $API_KEY" "$WEBHOOK/health")
if [[ "$HC" != "200" ]]; then
  /usr/bin/osascript -e "display notification \"Webhook not reachable ($HC).\" with title \"Tana\""; exit 1
fi

# Wrap for webhook: workspace + destKey + payload
JSON=$(printf '{"workspace":"%s","destKey":"%s","payload":%s}' "$WORKSPACE" "$DEST_KEY" "$CLIP")

RESP=$(curl -sS $CONNECT_OPTS -w "HTTPSTATUS:%{http_code}" \
  -X POST "$WEBHOOK/tana/input" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  --data "$JSON")

BODY="${RESP%HTTPSTATUS:*}"
CODE="${RESP##*HTTPSTATUS:}"

if [[ "$CODE" == "200" || "$CODE" == "201" ]]; then
  # Expecting echo: { ok, workspace, destKey, targetNodeId, nodeCount }
  MSG=$(echo "$BODY" | python3 - <<'PY' 2>/dev/null || true
import json,sys
try:
  o=json.loads(sys.stdin.read())
  if isinstance(o,dict) and o.get("ok"):
    print(f"Sent → {o.get('workspace')}:{o.get('destKey')} ({o.get('nodeCount')} nodes)")
  else:
    print("Sent")
except Exception:
  print("Sent")
PY
  )
  /usr/bin/osascript -e "display notification \"$MSG\" with title \"Tana\""
else
  TMP="/tmp/tana_response_$$.txt"; printf "%s" "$BODY" | head -c 4096 > "$TMP"
  /usr/bin/osascript -e "display notification \"Error $CODE. See $TMP\" with title \"Tana\""
fi