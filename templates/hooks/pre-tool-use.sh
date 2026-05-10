#!/bin/bash
# Blocks destructive commands before execution.
# Exit 2 = block + deny. Exit 0 = allow.
[[ ",${CLAUDE_DISABLE_HOOKS}," == *",pre-tool-use,"* ]] && exit 0

COMMAND=$(jq -r '.tool_input.command // ""' < /dev/stdin)
[ -z "$COMMAND" ] && exit 0

BLOCKED=0
REASON=""

if echo "$COMMAND" | grep -qE '\brm\s+-rf\b'; then
  BLOCKED=1; REASON="rm -rf blocked (use rm -r with explicit path)"
fi

if echo "$COMMAND" | grep -qE '\bgit\s+push\s+(--force|-f)\b'; then
  BLOCKED=1; REASON="force push blocked (confirm with user first)"
fi

if echo "$COMMAND" | grep -qE '\bgit\s+reset\s+--hard\b'; then
  BLOCKED=1; REASON="git reset --hard blocked (confirm with user first)"
fi

if echo "$COMMAND" | grep -qiE '\bDROP\s+TABLE\b|\bDROP\s+DATABASE\b'; then
  BLOCKED=1; REASON="DROP TABLE/DATABASE blocked (confirm with user first)"
fi

if echo "$COMMAND" | grep -qE '>\s*/dev/sd[a-z]|>\s*/dev/nvme'; then
  BLOCKED=1; REASON="direct disk write blocked"
fi

if [ "$BLOCKED" -eq 1 ]; then
  jq -n --arg reason "$REASON" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
  exit 2
fi

exit 0
