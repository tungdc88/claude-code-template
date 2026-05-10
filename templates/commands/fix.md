---
description: Fix a bug. Read error → identify root cause → propose fix + success criteria → apply → verify.
argument-hint: <error message or failing test name>
---

Fix the bug described by `$ARGUMENTS`.

Steps:
1. Read the error message or failing test carefully
2. Identify the root cause (grep for related code, read relevant files)
3. State: what is wrong, why, what the fix is, how to verify — BEFORE editing
4. Apply the fix (minimal change — do not refactor surrounding code)
5. Run the failing test to verify: `!<test command> $ARGUMENTS`
6. Report: file:line changed, root cause, verification result

Rules:
- One root cause per fix — do not bundle unrelated changes
- If the root cause is unclear after reading 3 files, say so and ask
- Do not add error handling for scenarios that cannot happen
