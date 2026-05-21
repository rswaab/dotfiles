#!/bin/bash
# @raycast.schemaVersion 1
# @raycast.title AI Playground
# @raycast.mode silent
# @raycast.packageName Dev
# @raycast.icon 🧠
# @raycast.description Open WezTerm attached to tmux session "ai-playground" with three panes side-by-side (ila-app, ~/Dev/projects, ~/Dev/projects).

set -e

SESSION="ai-playground"

# Make sure tmux is reachable from Raycast's PATH
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# Create the session with the 3-pane layout only if it doesn't already exist.
# If it does exist, we just attach — existing panes are left untouched.
if ! tmux has-session -t "=$SESSION" 2>/dev/null; then
  tmux new-session -d -s "$SESSION" -c "$HOME/Dev/projects/ila-app"
  tmux split-window -h -t "$SESSION" -c "$HOME/Dev/projects"
  tmux split-window -h -t "$SESSION" -c "$HOME/Dev/projects"
  tmux select-layout -t "$SESSION" even-horizontal
  tmux select-pane -t "$SESSION":0.0
fi

open -na WezTerm --args start -- tmux attach -t "$SESSION"
