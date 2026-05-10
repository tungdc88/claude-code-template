---
name: setup
description: Bootstrap Claude Code template cho project mới — detect stack, fill CLAUDE.md placeholders, adapt settings.json permissions. Chạy 1 lần duy nhất khi tạo project mới.
when_to_use: User gõ "/setup" trong project directory mới. Cũng trigger khi user nói "setup project", "init claude", "bootstrap project này".
argument-hint: (không cần argument — chạy từ project root)
allowed-tools: Read, Edit, Write, Bash
---

# /setup — New Project Bootstrap

Chạy từ project root directory. Bootstrap Claude Code template + auto-fill theo codebase thực tế.

---

## Step 0 — Guard check

```bash
pwd
ls .claude/ 2>/dev/null && echo "CLAUDE_EXISTS" || echo "CLAUDE_NEW"
git rev-parse --show-toplevel 2>/dev/null || echo "NOT_GIT"
```

- Nếu `.claude/` đã tồn tại → hỏi user: **overwrite** (chạy lại bootstrap) hay **skip** (chỉ fill placeholders)?
- Nếu không phải git repo → chạy `git init .` trước rồi tiếp tục.
- Capture `PROJECT_ROOT` = `pwd` kết quả.

---

## Step 1 — Run bootstrap

```bash
bash ~/.claude/templates/bootstrap.sh .
```

Confirm output "Done." không có lỗi. Nếu fail → báo user, stop.

---

## Step 2 — Detect stack

```bash
# Language markers
for f in pyproject.toml requirements.txt setup.py package.json go.mod Cargo.toml pom.xml build.gradle; do
  [ -f "$f" ] && echo "FOUND: $f"
done

# Python details
[ -f pyproject.toml ] && grep -E "^(name|dependencies|tool.pytest)" pyproject.toml | head -10 || true
[ -f requirements.txt ] && head -15 requirements.txt || true

# Node details
[ -f package.json ] && python3 -c "
import json, sys
d = json.load(open('package.json'))
deps = list({**d.get('dependencies',{}), **d.get('devDependencies',{})}.keys())
scripts = d.get('scripts', {})
print('deps:', deps[:15])
print('scripts:', list(scripts.items()))
" 2>/dev/null || true

# Go details
[ -f go.mod ] && head -5 go.mod || true
```

Từ output, xác định:
- `LANGUAGE`: `python` | `node` | `go` | `rust` | `java` | `unknown`
- `FRAMEWORK`: fastapi | django | flask | express | nextjs | gin | actix | spring | none
- `TECH_STACK_LINE`: chuỗi ngắn, ví dụ `"Python 3.11, FastAPI, PostgreSQL, pytest"`

---

## Step 3 — Detect commands

**Python:**
```bash
# Test
python3 -m pytest --version 2>/dev/null && echo "TEST=python3 -m pytest tests/ -v" || echo "TEST=python3 -m unittest discover"
# Lint
(grep -q "ruff" pyproject.toml 2>/dev/null || [ -f .ruff.toml ]) && echo "LINT=ruff check . && ruff format --check ." || echo "LINT=flake8 ."
# Dev entry point
find . -maxdepth 2 -name "main.py" -o -name "app.py" -o -name "run.py" 2>/dev/null | grep -v __pycache__ | head -3
```

**Node:**
```bash
[ -f package.json ] && python3 -c "
import json
s = json.load(open('package.json')).get('scripts', {})
for k in ['test','lint','dev','build','start']:
    if k in s: print(f'{k.upper()}={s[k]}')
" 2>/dev/null || true
```

**Go / Rust:**
```bash
[ -f go.mod ] && echo "TEST=go test ./... -v" && echo "BUILD=go build ./..."
[ -f Cargo.toml ] && echo "TEST=cargo test" && echo "BUILD=cargo build"
```

Xác định: `TEST_COMMAND`, `LINT_COMMAND`, `DEV_COMMAND`, `BUILD_COMMAND`.

---

## Step 4 — Read directory structure

```bash
find . -maxdepth 2 -type d \
  | grep -vE "\.(git|venv|env|next|cache)|node_modules|__pycache__|dist/|build/" \
  | sort | head -25
ls -1 | head -20
```

Từ output, tạo **architecture diagram 4-6 dòng** phản ánh cấu trúc thực tế. Ví dụ:
```
src/
  api/        ← HTTP routers
  services/   ← Business logic
  models/     ← Data models
tests/        ← pytest, mirrors src/
scripts/      ← Utility scripts
```

---

## Step 5 — Detect SSOT files

```bash
find . -maxdepth 3 \( -name "config.py" -o -name "settings.py" -o -name "constants.py" \
  -o -name "config.ts" -o -name "constants.ts" -o -name "config.go" \) \
  | grep -vE "__pycache__|node_modules" | head -5
```

Lấy tối đa 2-3 file quan trọng nhất cho SSOT table.

---

## Step 6 — Fill CLAUDE.md

```bash
PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")
MAIN_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|.*/||' \
  || git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
```

Edit `CLAUDE.md`, thay thế toàn bộ `<PLACEHOLDER>`:

| Placeholder | Thay bằng |
|-------------|-----------|
| `<PROJECT_NAME>` | `$PROJECT_NAME` |
| `<MAIN_BRANCH>` | `$MAIN_BRANCH` |
| `<TECH_STACK ...>` | `TECH_STACK_LINE` |
| `<TEST_COMMAND ...>` | `TEST_COMMAND` |
| `<LINT_COMMAND ...>` | `LINT_COMMAND` |
| `<DEV_COMMAND ...>` | `DEV_COMMAND` |
| `<BUILD_COMMAND ...>` | `BUILD_COMMAND` |
| Architecture diagram block | 4-6 dòng từ Step 4 |
| `<PATH>` rows trong SSOT table | Files từ Step 5 (hoặc xóa row nếu không tìm thấy) |
| `<PROJECT_RULE_1>` | Language-specific default (xem bảng bên dưới) |
| `<PROJECT_RULE_2>` | Language-specific default thứ 2 |
| `<TRAP_1>`, `<TRAP_2>` | Xóa sample rows — user tự append sau |

**Language-specific default rules:**

| Language | Rule 1 | Rule 2 |
|----------|--------|--------|
| Python | `All DB queries via ORM, never raw SQL strings` (nếu có sqlalchemy) | `Config via pydantic-settings, never os.environ directly` (nếu có pydantic) |
| Python (generic) | `logging module only — never print() in production` | `Type hints on all function signatures` |
| Node/TS | `All async functions use async/await, never .then() chains` | `Zod for runtime validation at system boundaries` |
| Go | `All errors must be handled, never _` | `Context propagation: always pass ctx as first arg` |
| Rust | `Prefer ? operator for error propagation, avoid unwrap() in production` | `Document public APIs with /// comments` |

---

## Step 7 — Adapt .claude/settings.json permissions

Read `.claude/settings.json`. Thêm language-appropriate allow patterns vào mảng `permissions.allow`:

**Python:**
```json
"Bash(python3 -m pytest *)",
"Bash(ruff *)",
"Bash(mypy *)",
"Bash(pip install *)",
"Bash(python3 scripts/*)"
```

**Node/TS:**
```json
"Bash(npm test *)",
"Bash(npm run *)",
"Bash(npx *)",
"Bash(node *)",
"Bash(tsc *)"
```

**Go:**
```json
"Bash(go test *)",
"Bash(go build *)",
"Bash(go run *)",
"Bash(gofmt *)",
"Bash(golangci-lint *)"
```

**Rust:**
```json
"Bash(cargo test *)",
"Bash(cargo build *)",
"Bash(cargo fmt *)",
"Bash(cargo clippy *)"
```

Edit `.claude/settings.json` → merge vào `permissions.allow` array (giữ nguyên entries cũ).

---

## Step 8 — Handle empty project (LANGUAGE = unknown)

Nếu Step 2 không detect được language, hỏi user 3 câu:

1. "Project dùng ngôn ngữ/framework gì? (vd: Python/FastAPI, TypeScript/Next.js, Go, Rust)"
2. "Test command là gì? (vd: pytest tests/, go test ./...)"
3. "Dev run command là gì? (vd: uvicorn main:app --reload, npm run dev)"

Dùng câu trả lời để fill CLAUDE.md và settings.json thủ công.

---

## Step 9 — Git initial commit

```bash
git add .claude/ CLAUDE.md .mcp.json .gitignore
git status --short
```

Hỏi user: "Commit bootstrap files ngay không? (y/n)"
Nếu y:
```bash
git commit -m "chore: bootstrap Claude Code template

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Step 10 — Report

```
✅ Claude Code setup complete: <PROJECT_NAME>

### Bootstrapped files
- .claude/settings.json   — permissions cho <LANGUAGE>
- .claude/hooks/          — session-start, pre-tool-use, post-write, notify
- .claude/agents/         — debugger
- .claude/commands/       — /fix, /test, /ship, /review
- .claude/skills/         — /end-session
- .claude/rules/          — python|database|security
- CLAUDE.md               — <N> placeholders filled

### Detected
- Stack : <TECH_STACK_LINE>
- Test  : `<TEST_COMMAND>`
- Lint  : `<LINT_COMMAND>`
- Dev   : `<DEV_COMMAND>`

### Còn cần manual
- [ ] CLAUDE.md → SSOT table: thêm file constants/config quan trọng của project
- [ ] CLAUDE.md → Common Traps: append khi phát hiện mistake sau này
- [ ] .claude/skills/end-session/SKILL.md → replace <PLACEHOLDER> fields
- [ ] .claude/rules/*.md → review, bỏ rule không áp dụng
- [ ] .mcp.json → enable MCP servers cần thiết

### Next
Start coding. Khi kết thúc session: `/end-session <milestone>`
```
