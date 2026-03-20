#!/bin/bash
# Log all Read tool calls to a per-day file for boot sequence verification.
# Registered as a PostToolUse hook with matcher "Read" in settings.json.

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | /usr/bin/python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null)

if [ -n "$FILE_PATH" ] && [ -f "$FILE_PATH" ]; then
  LOG_DIR="$HOME/.claude/logs"
  TIMESTAMP=$(date "+%H:%M:%S")
  # Estimate tokens: ~4 chars per token
  CHARS=$(wc -c < "$FILE_PATH" | tr -d ' ')
  TOKENS=$(( CHARS / 4 ))
  echo "$TIMESTAMP | ~${TOKENS}t | $FILE_PATH" >> "$LOG_DIR/reads-$(date +%Y-%m-%d).log"
elif [ -n "$FILE_PATH" ]; then
  LOG_DIR="$HOME/.claude/logs"
  TIMESTAMP=$(date "+%H:%M:%S")
  echo "$TIMESTAMP | ?t | $FILE_PATH" >> "$LOG_DIR/reads-$(date +%Y-%m-%d).log"
fi
