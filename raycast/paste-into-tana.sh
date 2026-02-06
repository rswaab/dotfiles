#!/bin/bash
# @raycast.schemaVersion 1
# @raycast.title Paste into Tana (Fixed Destination)
# @raycast.mode silent
# @raycast.icon 📝

DEST_URL="https://app.tana.inc?nodeid=7zTRnaU9AjNk"
CLIP=$(pbpaste)

if [[ "$CLIP" != %%tana%%* ]]; then
  /usr/bin/osascript -e 'display notification "Clipboard doesn’t start with %%tana%%" with title "Tana Paste"'
  exit 1
fi

/usr/bin/osascript <<APPLESCRIPT
open location "$DEST_URL"
delay 0.8
tell application "Tana" to activate
delay 0.2
tell application "System Events"
  keystroke "v" using {command down}
  delay 0.15
  key code 36 -- Return
end tell
APPLESCRIPT