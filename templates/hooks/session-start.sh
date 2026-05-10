#!/bin/bash
# Injects dynamic git context at session start.
[[ ",${CLAUDE_DISABLE_HOOKS}," == *",session-start,"* ]] && exit 0

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
WORKTREE=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo ".")
UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
LAST_COMMIT=$(git log -1 --oneline 2>/dev/null || echo "none")
AHEAD=$(git rev-list --count origin/"$BRANCH".."$BRANCH" 2>/dev/null || echo "?")

# Detect active track from branch name (adapt patterns for your project)
case "$BRANCH" in
  main|master)          TRACK="main" ;;
  feat/*)               TRACK="${BRANCH#feat/}" ;;
  fix/*)                TRACK="fix/${BRANCH#fix/}" ;;
  *)                    TRACK="$BRANCH" ;;
esac

jq -n \
  --arg worktree "$WORKTREE" \
  --arg track "$TRACK" \
  --arg branch "$BRANCH" \
  --arg uncommitted "$UNCOMMITTED" \
  --arg last_commit "$LAST_COMMIT" \
  --arg ahead "$AHEAD" \
  '{
    hookSpecificOutput: {
      hookEventName: "SessionStart",
      additionalContext: "Worktree: \($worktree) | Track: \($track) | Branch: \($branch) | Uncommitted: \($uncommitted) | Ahead: \($ahead) | Last: \($last_commit) | Run /status to confirm active model before complex tasks."
    }
  }'
