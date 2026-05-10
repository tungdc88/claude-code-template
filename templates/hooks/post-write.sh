#!/bin/bash
# Auto-format file after Edit/Write. Silent on failure (non-blocking).
[[ ",${CLAUDE_DISABLE_HOOKS}," == *",post-write,"* ]] && exit 0

FILE=$(jq -r '.tool_input.file_path // .tool_input.path // ""' < /dev/stdin)
[ -z "$FILE" ] || [ ! -f "$FILE" ] && exit 0

case "$FILE" in
  *.py)
    command -v ruff &>/dev/null && ruff format "$FILE" 2>/dev/null
    ;;
  *.js|*.jsx|*.ts|*.tsx|*.json|*.css|*.html)
    command -v prettier &>/dev/null && prettier --write "$FILE" 2>/dev/null
    ;;
  *.go)
    command -v gofmt &>/dev/null && gofmt -w "$FILE" 2>/dev/null
    ;;
  *.rs)
    command -v rustfmt &>/dev/null && rustfmt "$FILE" 2>/dev/null
    ;;
esac

exit 0
