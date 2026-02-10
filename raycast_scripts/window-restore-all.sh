#!/bin/zsh
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Window - Restore All to Defaults
# @raycast.mode silent
# @raycast.packageName Window Tools

# Restores all configured apps to their default positions.
# Only touches apps that are currently running. Fire-and-forget.
# Targets the largest window per app to avoid notification popups.

CONFIG="$HOME/.config/stretch-windows.conf"

if [[ ! -f "$CONFIG" ]]; then
    echo "No config found at $CONFIG"
    exit 1
fi

# Get list of running apps once, rather than querying per-app
RUNNING=$(osascript -e 'tell application "System Events" to get name of every application process whose visible is true' 2>/dev/null)

while IFS=, read -r app x y w h; do
    [[ "$app" =~ ^#.*$ || -z "$app" ]] && continue
    # Skip apps that aren't running
    echo "$RUNNING" | grep -q "$app" || continue
    osascript <<APPLESCRIPT 2>/dev/null &
tell application "System Events"
    tell application process "$app"
        set mainWin to my getLargestWindow("$app")
        set position of mainWin to {$x, $y}
        delay 0.3
        set size of mainWin to {$w, $h}
        delay 0.3
        set position of mainWin to {$x, $y}
        delay 0.3
        set size of mainWin to {$w, $h}
    end tell
end tell

on getLargestWindow(appName)
    tell application "System Events"
        tell application process appName
            set wCount to count of windows
            if wCount is 0 then error "No windows"
            if wCount is 1 then return window 1
            set bestWindow to window 1
            set {bw, bh} to size of window 1
            set bestArea to bw * bh
            repeat with i from 2 to wCount
                set {cw, ch} to size of window i
                set currentArea to cw * ch
                if currentArea > bestArea then
                    set bestWindow to window i
                    set bestArea to currentArea
                end if
            end repeat
            return bestWindow
        end tell
    end tell
end getLargestWindow
APPLESCRIPT
done < "$CONFIG"
