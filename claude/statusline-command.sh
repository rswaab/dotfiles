#!/usr/bin/env bash
# Claude Code status line: model name + context usage
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

if [ -n "$used" ] && [ -n "$remaining" ]; then
  printf "%s  |  ctx: %d%% used  %d%% left" "$model" "$used" "$remaining"
else
  printf "%s" "$model"
fi
