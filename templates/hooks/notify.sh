#!/bin/bash
# Notifies user when Claude finishes a task.
# Also outputs context usage reminder as systemMessage (pattern từ Documents/.claude).
[[ ",${CLAUDE_DISABLE_HOOKS}," == *",notify,"* ]] && exit 0

# Context reminder via JSON systemMessage (displays in Claude transcript)
jq -n '{
  systemMessage: "Task complete. Check context usage — if >70%, run /compact before next task."
}' 2>/dev/null || true

# macOS desktop notification
if command -v osascript &>/dev/null; then
  osascript -e 'display notification "Task complete" with title "Claude Code"' 2>/dev/null
  exit 0
fi

# Linux desktop (notify-send)
if command -v notify-send &>/dev/null; then
  notify-send "Claude Code" "Task complete" 2>/dev/null
  exit 0
fi

# Terminal bell fallback
printf '\a'
exit 0
