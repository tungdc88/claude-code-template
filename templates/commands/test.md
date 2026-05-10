---
description: Write tests for specified code. Read implementation → identify cases → write tests → run → verify all pass.
argument-hint: <file or function to test>
---

Write tests for `$ARGUMENTS`.

Steps:
1. Read the implementation to understand what it does and what can go wrong
2. List test cases before writing: happy path, edge cases, error cases
3. Write tests (mirror the source structure in tests/)
4. Run: `!<test command> <new test file>`
5. Fix any failures
6. Report: N tests written, cases covered, any cases explicitly NOT covered and why

Rules:
- Test behavior, not implementation — tests should survive refactoring
- One assertion per test where practical
- Test names describe the scenario: `test_<function>_<condition>_<expected>`
- Do not mock what you can use directly (real objects > fakes > mocks)
- If an edge case is impossible given current constraints, note it — don't write it
