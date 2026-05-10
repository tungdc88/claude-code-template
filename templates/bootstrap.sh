#!/bin/bash
# Bootstrap a new project with Claude Code template.
# Usage: bash ~/.claude/templates/bootstrap.sh [project-dir]

set -e

TEMPLATE_DIR="$HOME/.claude/templates"
PROJECT_DIR="${1:-.}"

if [ ! -d "$PROJECT_DIR" ]; then
  echo "Error: directory '$PROJECT_DIR' not found" >&2
  exit 1
fi

echo "Bootstrapping Claude Code in: $PROJECT_DIR"

# Create .claude directory structure
mkdir -p "$PROJECT_DIR/.claude/hooks" \
         "$PROJECT_DIR/.claude/rules" \
         "$PROJECT_DIR/.claude/commands" \
         "$PROJECT_DIR/.claude/agents" \
         "$PROJECT_DIR/.claude/skills"

# Copy shared settings (committed to repo)
cp "$TEMPLATE_DIR/settings.json" "$PROJECT_DIR/.claude/settings.json"
echo "  ✓ .claude/settings.json"

# Copy settings.local template (gitignored)
cp "$TEMPLATE_DIR/settings.local.json" "$PROJECT_DIR/.claude/settings.local.json"
echo "  ✓ .claude/settings.local.json (gitignored)"

# Copy hooks
for hook in pre-tool-use post-write session-start notify; do
  cp "$TEMPLATE_DIR/hooks/${hook}.sh" "$PROJECT_DIR/.claude/hooks/${hook}.sh"
  chmod +x "$PROJECT_DIR/.claude/hooks/${hook}.sh"
done
echo "  ✓ .claude/hooks/ (4 hooks, executable)"

# Copy rules
cp "$TEMPLATE_DIR/rules/"*.md "$PROJECT_DIR/.claude/rules/"
echo "  ✓ .claude/rules/ (python, database, security)"

# Copy commands
cp "$TEMPLATE_DIR/commands/"*.md "$PROJECT_DIR/.claude/commands/"
echo "  ✓ .claude/commands/ (fix, test, ship, review, plan)"

# Copy agents
cp "$TEMPLATE_DIR/agents/"*.md "$PROJECT_DIR/.claude/agents/"
echo "  ✓ .claude/agents/ (debugger)"

# Copy end-session skill
mkdir -p "$PROJECT_DIR/.claude/skills/end-session"
cp "$TEMPLATE_DIR/skills/end-session/SKILL.md" "$PROJECT_DIR/.claude/skills/end-session/SKILL.md"
echo "  ✓ .claude/skills/end-session/"

# Copy MCP template if no .mcp.json exists
if [ ! -f "$PROJECT_DIR/.mcp.json" ]; then
  cp "$TEMPLATE_DIR/.mcp.json" "$PROJECT_DIR/.mcp.json"
  echo "  ✓ .mcp.json (template — edit before use)"
fi

# Copy CLAUDE.md template if none exists
if [ ! -f "$PROJECT_DIR/CLAUDE.md" ]; then
  cp "$TEMPLATE_DIR/CLAUDE.md" "$PROJECT_DIR/CLAUDE.md"
  echo "  ✓ CLAUDE.md (template — fill in <PLACEHOLDERS>)"
fi

# Add gitignore entries
GITIGNORE="$PROJECT_DIR/.gitignore"
if [ -f "$GITIGNORE" ]; then
  if ! grep -q "settings.local.json" "$GITIGNORE"; then
    cat "$TEMPLATE_DIR/.gitignore.additions" >> "$GITIGNORE"
    echo "  ✓ .gitignore updated"
  else
    echo "  - .gitignore already has Claude entries"
  fi
else
  cp "$TEMPLATE_DIR/.gitignore.additions" "$GITIGNORE"
  echo "  ✓ .gitignore created"
fi

echo ""
echo "Done. Next steps:"
echo "  1. Edit CLAUDE.md — fill in <PLACEHOLDERS> (target ≤100 lines)"
echo "  2. Edit .claude/settings.json — tune permissions for this project"
echo "  3. Edit .claude/settings.local.json — add worktree-specific permissions"
echo "  4. Edit .mcp.json — enable needed MCP servers"
echo "  5. Adapt .claude/skills/end-session/SKILL.md — fill in <TRACK>, <TEST_COMMAND>, etc."
echo "  6. git add .claude/settings.json .claude/hooks/ .claude/rules/ .claude/commands/ .claude/agents/ .claude/skills/ CLAUDE.md .mcp.json"
