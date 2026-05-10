---
description: Request independent code review via reviewer subagent. Use after implementing a feature or fix.
argument-hint: <file, function, or "recent changes">
---

@reviewer review `$ARGUMENTS`

Focus on:
- Logic correctness and edge cases
- Security issues (OWASP Top 10 for auth/data paths)
- Missing test coverage
- Performance issues (N+1 queries, unnecessary loops)

Format each finding as:
`[CRITICAL|WARN|NOTE] file:line — issue — suggested fix`

No praise. Skip style comments if a linter is configured.
Check memory for patterns seen before in this codebase.
