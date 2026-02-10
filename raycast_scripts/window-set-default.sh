#!/bin/zsh
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Window - Set Default Position
# @raycast.mode silent
# @raycast.packageName Window Tools

# Saves the current position and size of the focused app as its default.
# Adds the app if not in config, updates it if already present.
# Targets the largest window to avoid capturing notification popups.

CONFIG="$HOME/.config/stretch-windows.conf"

if [[ ! -f "$CONFIG" ]]; then
    echo "# Default window positions: AppName,x,y,width,height" > "$CONFIG"
fi

# Get focused app name and geometry of its largest window
FRONT_APP=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true')
GEOMETRY=$(osascript <<APPLESCRIPT
tell application "System Events"
    tell application process "$FRONT_APP"
        set mainWin to my getLargestWindow("$FRONT_APP")
        set {x, y} to position of mainWin
        set {w, h} to size of mainWin
        return (x as text) & "," & (y as text) & "," & (w as text) & "," & (h as text)
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
)

if [[ "$GEOMETRY" == "" ]]; then
    osascript -e "display dialog \"No window found for $FRONT_APP.\""
    exit 1
fi

NEW_LINE="${FRONT_APP},${GEOMETRY}"

# Check if app already exists in config
if grep -q "^${FRONT_APP}," "$CONFIG"; then
    # Update existing entry
    sed -i '' "s|^${FRONT_APP},.*|${NEW_LINE}|" "$CONFIG"
    osascript -e "display notification \"Updated default for $FRONT_APP\" with title \"Window Tools\""
else
    # Append new entry
    echo "$NEW_LINE" >> "$CONFIG"
    osascript -e "display notification \"Saved default for $FRONT_APP\" with title \"Window Tools\""
fi
