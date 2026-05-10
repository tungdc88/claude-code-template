# CLAUDE.md — <PROJECT_NAME>

> **State**: `docs/SYSTEM_STATE.md` | **Branch**: `<MAIN_BRANCH>`
> **Stack**: <TECH_STACK e.g. Python 3.11, PostgreSQL, FastAPI>

## Commands

```bash
# Test (narrow → cumulative)
<TEST_COMMAND e.g. python3 -m pytest tests/ -v>

# Lint / Format
<LINT_COMMAND e.g. ruff check . && ruff format --check .>

# Run dev
<DEV_COMMAND e.g. uvicorn main:app --reload>

# Build
<BUILD_COMMAND e.g. docker build -t app .>
```

## Architecture

```
<BRIEF_DIAGRAM — 4-6 lines max. Vd:>
src/
  api/        ← HTTP layer (FastAPI routers)
  services/   ← Business logic
  models/     ← SQLAlchemy ORM
  utils/      ← Shared helpers
tests/        ← pytest, mirrors src/ structure
```

## Critical Rules

- Type hints on ALL function signatures
- `logging` module only — never `print()` in production
- Catch specific exceptions: `except ValueError as e:` not bare `except:`
- Only change what's requested — no unrelated cleanup
- For large refactors: "find all references to X and update them" > "refactor everywhere" — semantic precision reduces hallucinations
- Multi-step tasks: state `1. [step] → verify: [check]` plan before coding, not after
- <PROJECT_RULE_1 e.g. "All DB queries use SQLAlchemy ORM, never raw SQL strings">
- <PROJECT_RULE_2 e.g. "Config via pydantic-settings, never os.environ directly">

## SSOT Files

| File | Role |
|------|------|
| `<PATH>` | <ROLE e.g. shared/config.py — all constants, no duplication> |
| `<PATH>` | <ROLE> |

## Common Traps

| Trap | Thực tế |
|------|---------|
| <TRAP_1> | <REALITY_1 e.g. "TimezoneName is UTC not local — always use utc_now()"> |
| <TRAP_2> | <REALITY_2> |

<!-- FILL GUIDE:
- Target ≤100 lines total
- Only add lines Claude will FORGET or do WRONG without them
- Architecture diagrams: 4-6 lines max, no full module listings
- After any repeated mistake: add 1 line to Common Traps
- Detailed conventions: move to .claude/rules/<lang>.md with paths: glob
- Remove any line Claude handles correctly without being told
-->
