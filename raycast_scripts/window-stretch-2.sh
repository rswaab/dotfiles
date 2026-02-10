#!/bin/zsh
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Window - Stretch 2 Screens (Left + Center)
# @raycast.mode silent
# @raycast.packageName Window Tools

osascript <<'EOF'
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

tell application "System Events"
    set frontApp to name of first application process whose frontmost is true
    tell application process frontApp
        if (count of windows) > 0 then
            set mainWin to my getLargestWindow(frontApp)
            set position of mainWin to {-1920, 0}
            set size of mainWin to {3840, 1080}
        else
            display dialog "No window found for " & frontApp & "."
        end if
    end tell
end tell
EOF
