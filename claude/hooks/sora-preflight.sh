#!/bin/bash
# Sora pre-flight check
# Runs automatically on every Claude Code session start (and after context compaction).
# Output is injected into the AI's context — the AI cannot skip this.
#
# CHANGE LOG:
#   2026-02-25: Added deterministic kernel injection (brain.md + personality.md + recipes.md).
#               Previously these loaded via model compliance ("Read brain.md before first response")
#               which failed ~70% of sessions when project CLAUDE.md files competed for attention.
#               Now the kernel is injected directly — model has identity, voice, and recipes
#               without needing to choose to read them.
#               TO REVERT: Remove the "Sora System Kernel" section (lines marked KERNEL-START
#               to KERNEL-END) and restore the old CLAUDE.md boot instruction.
#               Old CLAUDE.md line 5 was:
#                 "You are Sora. User: Rob Swaab (Melbourne). Read `~/Dev/projects/sora/system/brain.md`
#                  before your first response — it tells you what to load next. Do not respond until
#                  brain.md is loaded."

SORA_DIR="$HOME/Dev/projects/sora"
TODAY=$(date +%Y-%m-%d)
YESTERDAY=$(date -v-1d +%Y-%m-%d)

DAY_FILE="$SORA_DIR/core-loop/days/$TODAY.md"
YESTERDAY_DAY_FILE="$SORA_DIR/core-loop/days/$YESTERDAY.md"
YESTERDAY_JOURNAL="$SORA_DIR/evidence/journal/$YESTERDAY.md"
STAGING="$SORA_DIR/evidence/staging.md"

OUTPUT=""

# --- Date/calendar grounding (prevents LLM day-of-week errors) ---
TODAY_DOW=$(date "+%A")
TODAY_FULL=$(date "+%A %-d %B %Y")
OUTPUT+="CALENDAR GROUNDING: Today is ${TODAY_FULL}."
OUTPUT+=$'\n'
OUTPUT+="Date-to-day lookup (system clock, always correct — NEVER calculate days of the week, use this table):"
OUTPUT+=$'\n'
for i in $(seq -3 21); do
  if [ "$i" -ge 0 ]; then
    D=$(date -v+"${i}"d "+%-d %b = %A")
  else
    D=$(date -v"${i}"d "+%-d %b = %A")
  fi
  if [ "$i" -eq 0 ]; then
    OUTPUT+="  ${D} ← TODAY"
  elif [ "$i" -eq 1 ]; then
    OUTPUT+="  ${D} ← tomorrow"
  elif [ "$i" -eq -1 ]; then
    OUTPUT+="  ${D} ← yesterday"
  else
    OUTPUT+="  ${D}"
  fi
  OUTPUT+=$'\n'
done
OUTPUT+=$'\n'
# Monthly calendar grid
OUTPUT+="$(cal) "
OUTPUT+=$'\n'
# If we're in the last 7 days of the month, also show next month
DAY_OF_MONTH=$(date "+%-d")
DAYS_IN_MONTH=$(date -v1d -v+1m -v-1d "+%-d")
if [ "$DAY_OF_MONTH" -gt $((DAYS_IN_MONTH - 7)) ]; then
  NEXT_MONTH=$(date -v+1m "+%m %Y")
  OUTPUT+="$(cal $NEXT_MONTH) "
  OUTPUT+=$'\n'
fi
OUTPUT+=$'\n'

# --- Status dashboard (awareness only — do NOT load files based on this) ---
OUTPUT+="SORA STATUS (awareness only — recipes decide what to load, not this dashboard):"
OUTPUT+=$'\n'

# Daily plan
if [ ! -f "$DAY_FILE" ]; then
  OUTPUT+="  Plan: none for today"
else
  PHASE=$(grep 'Phase' "$DAY_FILE" | head -1 | sed 's/.*: //')
  OUTPUT+="  Plan: exists (${PHASE})"
fi
OUTPUT+=$'\n'

# Yesterday
if [ -f "$YESTERDAY_DAY_FILE" ]; then
  YESTERDAY_PHASE=$(grep 'Phase' "$YESTERDAY_DAY_FILE" | head -1 | sed 's/.*: //')
  if echo "$YESTERDAY_PHASE" | grep -qiv "reflected"; then
    OUTPUT+="  Yesterday: not reflected"
    OUTPUT+=$'\n'
  fi
fi

if [ ! -f "$YESTERDAY_JOURNAL" ]; then
  OUTPUT+="  Journal: no entry for yesterday"
  OUTPUT+=$'\n'
fi

# Staging
if [ -f "$STAGING" ]; then
  AFTER_SEPARATOR=$(awk '/^---$/{found=1; next} found{print}' "$STAGING" | grep -v '^\s*$' | wc -l | tr -d ' ')
  if [ "$AFTER_SEPARATOR" -gt 0 ]; then
    OUTPUT+="  Staging: ${AFTER_SEPARATOR} untriaged item(s)"
    OUTPUT+=$'\n'
  fi
fi

# --- KERNEL-START: Deterministic Sora kernel injection ---
# These three files ARE the Sora operating system. Injecting them here means the model
# always has identity, voice, and recipe knowledge — no model decision required.
BRAIN="$SORA_DIR/system/brain.md"
PERSONALITY="$SORA_DIR/system/personality.md"
RECIPES="$SORA_DIR/system/recipes.md"

OUTPUT+=$'\n'
OUTPUT+="═══ SORA SYSTEM KERNEL (deterministic injection — do NOT re-read these files) ═══"
OUTPUT+=$'\n'
OUTPUT+=$'\n'
OUTPUT+="You are Sora. The following three files define who you are, how you speak, and how you load context."
OUTPUT+=" They are injected automatically — steps 1-3 of the boot sequence in brain.md are already complete."
OUTPUT+=" Continue from step 4: read the user's first message, classify, select a recipe, load its files, then respond."
OUTPUT+=$'\n'

if [ -f "$BRAIN" ]; then
  OUTPUT+=$'\n'
  OUTPUT+="--- brain.md ---"
  OUTPUT+=$'\n'
  OUTPUT+="$(cat "$BRAIN")"
  OUTPUT+=$'\n'
fi

if [ -f "$PERSONALITY" ]; then
  OUTPUT+=$'\n'
  OUTPUT+="--- personality.md ---"
  OUTPUT+=$'\n'
  OUTPUT+="$(cat "$PERSONALITY")"
  OUTPUT+=$'\n'
fi

if [ -f "$RECIPES" ]; then
  OUTPUT+=$'\n'
  OUTPUT+="--- recipes.md ---"
  OUTPUT+=$'\n'
  OUTPUT+="$(cat "$RECIPES")"
  OUTPUT+=$'\n'
fi

OUTPUT+=$'\n'
OUTPUT+="═══ END SORA SYSTEM KERNEL ═══"
OUTPUT+=$'\n'
# --- KERNEL-END ---

# Session marker for reads log
LOG_DIR="$HOME/.claude/logs"
mkdir -p "$LOG_DIR"
echo "--- Session Start: $(date '+%Y-%m-%d %H:%M:%S') ---" >> "$LOG_DIR/reads-$(date +%Y-%m-%d).log"

if [ -n "$OUTPUT" ]; then
  echo "$OUTPUT"
fi

exit 0
