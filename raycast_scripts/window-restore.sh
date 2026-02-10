#!/bin/zsh
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Window - Restore to Default
# @raycast.mode silent
# @raycast.packageName Window Tools

# Restores the focused app's window to its configured default position.

CONFIG="$HOME/.config/stretch-windows.conf"

if [[ ! -f "$CONFIG" ]]; then
    osascript -e 'display dialog "No config found at ~/.config/stretch-windows.conf"'
    exit 1
fi

FRONT_APP=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true')
MATCH=$(grep "^${FRONT_APP}," "$CONFIG" | head -1)

if [[ -n "$MATCH" ]]; then
    IFS=, read -r app x y w h <<< "$MATCH"
    # Move to target screen, then apply position+size twice.
    # First pass gets the window onto the correct screen.
    # Second pass applies the exact geometry now that macOS
    # knows which screen's constraints to use.
    # Uses largest window to avoid targeting notification popups.
    osascript <<APPLESCRIPT
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
else
    osascript -e "display dialog \"No default position configured for $FRONT_APP.\""
fi
