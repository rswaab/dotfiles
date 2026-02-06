#!/bin/zsh
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Stretch Tana Across Two Screens (Left + Center)
# @raycast.mode silent
# @raycast.packageName Window Tools

osascript <<EOF
tell application "System Events"
    tell application process "Tana"
        if (count of windows) > 0 then
            set position of front window to {0, 0}
            set size of front window to {3840, 1080}
        else
            display dialog "No Tana window found."
        end if
    end tell
end tell
EOF
