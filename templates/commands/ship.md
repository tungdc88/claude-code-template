---
description: Run tests → commit → push → open PR. Only run when implementation is complete.
argument-hint: <optional PR description hint>
---

Ship the current work as a PR.

Steps:
1. Check status: `!git status --short` and `!git diff --stat`
2. Run full test suite: `!<test command>` — STOP if any fail
3. Stage relevant files (specific files, not `git add -A`)
4. Commit with structured message:
   - Subject line: imperative mood, ≤72 chars (e.g. "fix(auth): token expiry not checked on refresh")
   - Body: what changed and why (not how)
   - Footer: `Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>`
5. Push: `!git push -u origin HEAD`
6. Create PR: `!gh pr create --title "<title>" --body "<summary>"`
7. Report PR URL

Rules:
- STOP before step 3 if tests fail — do not commit broken code
- Never use `git add -A` — stage only changed files
- Never `--no-verify` — if hooks fail, fix the issue
- PR description: what changed, why, how to test (not line-by-line)
