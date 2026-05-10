#!/bin/bash
# Set up a new git worktree with Claude Code config.
# Usage: bash ~/.claude/templates/worktree-setup.sh <worktree-path> <branch-name> [track-name]
#
# Example:
#   bash ~/.claude/templates/worktree-setup.sh ../myproject_feature feat/new-feature new-feature

set -e

WORKTREE_PATH="$1"
BRANCH="$2"
TRACK="${3:-$(basename "$BRANCH")}"

if [ -z "$WORKTREE_PATH" ] || [ -z "$BRANCH" ]; then
  echo "Usage: $0 <worktree-path> <branch-name> [track-name]" >&2
  exit 1
fi

echo "Creating worktree: $WORKTREE_PATH (branch: $BRANCH, track: $TRACK)"

# Create the git worktree
git worktree add "$WORKTREE_PATH" -b "$BRANCH" 2>/dev/null || \
  git worktree add "$WORKTREE_PATH" "$BRANCH"

echo "  ✓ git worktree created"

# .claude/ is inherited from the shared repo — only create settings.local.json
SETTINGS_LOCAL="$WORKTREE_PATH/.claude/settings.local.json"

cat > "$SETTINGS_LOCAL" << EOF
{
  "permissions": {
    "allow": [
      "Bash(python3 -m pytest tests/${TRACK}/ *)",
      "Bash(git -C $(realpath "$WORKTREE_PATH") *)"
    ]
  }
}
EOF

echo "  ✓ .claude/settings.local.json created for track '$TRACK'"

# Generate per-worktree CLAUDE.md with identity section (STANDARD §4.2)
MAIN_REPO=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
WORKTREE_ABS=$(realpath "$WORKTREE_PATH")
WORKTREE_CLAUDE="$WORKTREE_PATH/CLAUDE.md"

if [ ! -f "$WORKTREE_CLAUDE" ]; then
  cat > "$WORKTREE_CLAUDE" << EOF
## Worktree identity (read first)

**Project**: ${TRACK} on branch \`${BRANCH}\`
**Worktree path**: ${WORKTREE_ABS}
**Main repo**: ${MAIN_REPO}

**Entry point docs** (read after memory state):
- \`docs/${TRACK}_PLAN.md\`
- \`docs/${TRACK}_FINDINGS.md\`
- \`docs/${TRACK}_DECISIONS.md\`

**End-of-session**: \`/end-session <milestone>\`
**Resume trigger**: \`start <next-milestone>\` / \`tiếp tục ${TRACK}\`

**Cross-track regression gate** (run at each session end):
\`\`\`bash
# Add command to verify other tracks still pass, e.g.:
# python3 -m pytest tests/other_track/ -q
\`\`\`

---

<!-- Fill in project-specific content below (commands, architecture, critical rules) -->
EOF
  echo "  ✓ CLAUDE.md created with worktree identity section"
else
  echo "  - CLAUDE.md already exists — skipped"
fi

echo ""
echo "Worktree ready at: $WORKTREE_PATH"
echo "Next steps:"
echo "  1. Edit CLAUDE.md — fill cross-track regression gate + project-specific content"
echo "  2. Edit $SETTINGS_LOCAL — add track-specific permissions"
echo "  3. Create .claude/skills/${TRACK}-end/SKILL.md — copy from end-session template, adapt <PLACEHOLDERS>"
echo "  4. cd $WORKTREE_PATH && claude"
echo ""
echo "Note: All hooks, rules, commands, agents are SHARED from .claude/ in main repo."
echo "      settings.local.json and CLAUDE.md are worktree-specific."
