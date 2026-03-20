#!/bin/bash
# Sora session-end hook
# Fires on every Claude Code session exit (including abrupt closes).
# Reads the transcript, calls Haiku for a summary, appends to today's daily plan.
# Writes hook input to a temp file so the background process doesn't depend on stdin.

VENV_PYTHON="$HOME/Dev/projects/sora/tools/knowledge-extractor/.venv/bin/python3"
SCRIPT="$HOME/Dev/projects/sora/tools/session-logger/session_logger.py"

if [ ! -f "$SCRIPT" ] || [ ! -f "$VENV_PYTHON" ]; then
  exit 0
fi

# Write stdin to temp file immediately (small JSON metadata blob)
TMPFILE=$(mktemp /tmp/sora-session-end.XXXXXX.json)
cat > "$TMPFILE"

# Run the logger in background from the temp file, clean up after
nohup bash -c "\"$VENV_PYTHON\" \"$SCRIPT\" < \"$TMPFILE\"; rm -f \"$TMPFILE\"" >/dev/null 2>&1 &
disown

exit 0
