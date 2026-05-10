---
name: end-session
description: End-of-session protocol — tests + gate + 2 commits (impl + docs) + state update + report với "Next session" block. Adapt cho project cụ thể bằng cách override các <PLACEHOLDER> fields.
when_to_use: User gõ "/end-session <milestone>" hoặc "session done <milestone>" hoặc khi Claude detect impl xong + tests pass + sẵn sàng commit. SKIP nếu tests còn fail.
argument-hint: <milestone-id> [finding-ids-comma-list]
allowed-tools: Read, Edit, Write, Bash
---

# End-of-Session Protocol

Args: `$ARGUMENTS` — milestone ID + optional finding IDs.
Infer từ memory + `git log` + `git status` nếu rỗng.

---

## Step 0 — Model check

Echo cho user:
```
Session ran on: <model — gõ /status nếu chưa biết>
Recommended next session: <sonnet|opus|opusplan|haiku> — <1-line reason>
```

Không block protocol vì model check. Informational only.

---

## Step 1 — Validate scope

Read:
- `~/.claude/projects/<PROJECT_MEMORY_PATH>/memory/<TRACK>_state.md`
- `git log --oneline -5`
- `git status --short`

Confirm:
- Milestone ID khớp expected next per state file
- Changed files nằm trong expected scope

Nếu mismatch → STOP, báo user discrepancy.

---

## Step 2 — Run tests

```bash
# Narrow (chỉ tests liên quan đến milestone này)
<TEST_COMMAND> tests/<TRACK>/<MILESTONE_SLUG>* -v

# Cumulative (toàn bộ test suite của track)
<TEST_COMMAND> tests/<TRACK>/ -q 2>&1 | tail -3
```

Capture: `N/N pass` cumulative count.
STOP nếu fail — không commit.

---

## Step 3 — Run gate (optional, adapt for project)

```bash
# Ví dụ: parity gate cho trading bot
# python3 scripts/replay_golden.py --diff --strict 2>&1 | tail -5

# Ví dụ: lint gate
# ruff check . && ruff format --check .

# Ví dụ: type check
# mypy src/ --ignore-missing-imports
```

Nếu gate fail và là expected (math fix, intentional break):
→ Báo user, chờ confirm trước khi regenerate baseline.

---

## Step 4 — Verify diff allowlist

```bash
git status --short
```

Allowed files (adapt for project):
- `<SOURCE_DIR>/**` — production code
- `tests/<TRACK>/**` — new tests
- `docs/<TRACK>_FINDINGS.md`
- `docs/<TRACK>_DECISIONS.md`
- `docs/<TRACK>_PLAN.md`

Không allowed: files ngoài list trên → STOP, báo user quyết định.

---

## Step 5 — Compose impl commit message

```
<type>(<scope>): <finding-list> — <topic> (<milestone>)

<1-paragraph context — what this batch addresses>

<per-finding bullets>:
- <FINDING-ID> [S<n>] <module> <site>: <symptom>; fix: <approach>; decision <DECISION-ID>.

Tests: <N> files — <N> tests (<N>/<N> pass + <CUM>/<CUM> cumulative).
Gate: <result>.
Decisions: <DECISION-ID-list>.
```

---

## Step 6 — Stage impl files + commit

```bash
git add <prod_files> <new_test_files>
git commit -m "$(cat <<'EOF'
<message from Step 5>

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
```

Capture impl commit SHA.

> Cache split point: Steps 1-6 cần full reasoning.
> Steps 7-12 là mechanical docs update — nếu Opus quota thấp, user có thể
> `/model sonnet` ở đây; cache prefix vẫn hit vì state files không thay đổi.
>
> **Edit order: PLAN → FINDINGS → DECISIONS → state → MEMORY** (stable→volatile)
> Lý do: file stable (PLAN) được cache lâu hơn ở session sau; file volatile (DECISIONS, state)
> luôn cần fresh read nên để cuối.

---

## Step 7 — Update PLAN doc

Edit `docs/<TRACK>_PLAN.md`:
- Mark milestone row: `pending` → `✅ done <date>`
- Update Session Log table (nếu có): append row `| #<N> | <date> | <milestone> ✅ | <impl-sha> | <N>/<N> |`

---

## Step 8 — Update FINDINGS doc

Edit `docs/<TRACK>_FINDINGS.md`:
- Flip finding rows: `open` → `✅ fixed`
- Append change log row:
  ```
  | <date> | #<N> (<milestone>) | <FINDING-IDs> closed; <N>/<N> tests; <gate>; <decisions>. |
  ```

---

## Step 9 — Update DECISIONS doc

Edit `docs/<TRACK>_DECISIONS.md`, append:

```markdown
---

## Session #<N> (<milestone>) — <YYYY-MM-DD>

### <DECISION-ID>: <module> — <label>

**Tier**: T1 (mechanical) | T2 (judgment) | T3 (user-confirmed)
**Context**: <2-3 sentences>
**Decision**: <code/config excerpt>
**Rationale**: <why this, why not alternative>
**Reversibility**: HIGH | MED | LOW

### Session #<N> summary
**Closed**: <N> — <list>. **Tests**: <N>/<N> + <CUM>/<CUM>. **Gate**: <result>.
**Cumulative**: <X>/<TOTAL> fixed (<pct>%).
```

> Cache hygiene: nếu DECISIONS.md > 2000 dòng → freeze sang `DECISIONS_PHASE<N>.md`,
> active file ≤ 200 dòng. CẤM full-read frozen docs — dùng `grep -A 30 "Session #N" file`.

---

## Step 10 — Update state file

Edit `~/.claude/projects/<PROJECT_MEMORY_PATH>/memory/<TRACK>_state.md`:

> ⚠️ State file BẮT BUỘC ≤ 150 dòng. Nếu vượt → archive split:
> copy detail-heavy sections → `<TRACK>_phase<N>_archive.md` (FREEZE) + trim state ≤ 100 dòng.

**Last session block:**
```
**Session #<N>** (<date>) — **<milestone> ✅ DONE** (<topic>).
- HEADs: impl `<sha>` + docs `<sha>`.
- Closed: <FINDING-IDs> (<N> findings).
- Tests: <N>/<N> + <CUM>/<CUM> cumulative. Gate: <result>.
- Decisions: <DECISION-IDs>.
**Cumulative**: <X>/<TOTAL> fixed (<pct>%).
```

**Next session block (snippet embedding — key pattern):**
```
**How to resume** (auto-sequence cho session sau):
1. Read this state file (status + next session block)
2. Check PLAN §milestones — confirm next milestone + recommend `/model <X>`
3. `grep -A 30 "Session #<N>" docs/<TRACK>_FINDINGS.md` (lazy-load, không full-read)
4. `tail -200 docs/<TRACK>_DECISIONS.md` (lazy-load)
5. Báo user: scope + estimate + model recommendation
6. T1/T2 tasks: auto-start. T3: pause + ask user.

**Session #<N+1> (<next-milestone>) — ready**:
- **<FINDING-ID>** [S<n>] <module>: <claim>. File: `<path:line>`.
  Fix: <approach 1-2 lines — đủ context để impl không cần re-read FINDINGS>.
  Pattern: <DECISION-ID nếu kế thừa>.
- ...

Tests: ~<N>. Gate: <prediction>.
**Recommended model**: `<sonnet|opus|opusplan>` — <reason>.
**Session prep**: /clear | /compact | no-action — <reason>.
**Triggers**: `start <next-milestone>` / `session done <next-milestone>`.
After <next>: echo `start <next+1>`.
```

---

## Step 11 — Update MEMORY.md index

Edit `~/.claude/projects/<PROJECT_MEMORY_PATH>/memory/MEMORY.md`:
Update track line (≤300 chars):
```
- [<Track> state](<track>_state.md) — Session #<N> <milestone> ✅. <X>/<TOTAL> fixed. **Next: <next>** (~<N>h). Trigger: `start <next>`.
```

---

## Step 12 — Stage docs + commit

```bash
git add docs/<TRACK>_PLAN.md docs/<TRACK>_FINDINGS.md docs/<TRACK>_DECISIONS.md
git commit -m "$(cat <<'EOF'
<track>-status: <FINDING-IDs> open→fixed (<milestone> at <impl-sha>)

FINDINGS: <N> findings closed, change log row #<N> appended.
DECISIONS: <DECISION-IDs> logged, session #<N> summary.
PLAN: <milestone> row → ✅ done.
Cumulative: <X>/<TOTAL> fixed (<pct>%).
EOF
)"
```

---

## Step 13 — Tag (if phase milestone)

Chỉ tag khi milestone là phase boundary (define list per project):
```bash
git tag -a <TRACK>-phase<N>-baseline \
  -m "Phase <N> closure — <N> sessions, <X>/<TOTAL> findings fixed" \
  <docs-commit-sha>
```

---

## Session hygiene — /clear vs /compact vs no-action

Evaluate BEFORE composing Step 14 report. Fill in `**Session prep**` field accordingly.

| Condition | Action |
|-----------|--------|
| Model đổi ở session tiếp theo (e.g. opus → sonnet) | `/clear` — cache dies anyway, fresh start tốt hơn |
| Task cluster khác nhau (chuyển sang feature khác) | `/clear` — old context = noise |
| Cùng cluster, gap > 5 phút | `/compact` — cache miss, compact giữ continuity |
| Context > 70% | `/compact` — trước khi auto-compact 95% cắt đột ngột |
| Cùng cluster, gap < 5 phút, context < 70% | no-action — cache warm, tiếp tục luôn |

> Auto-compact fires at 95% (system safety net). Target 60% proactively — don't wait.

---

## Step 14 — Report to user (BẮT BUỘC)

```
Session #<N> <milestone> ✅ DONE

### Output
- Impl `<sha>`: <topic>
- Docs  `<sha>`: <findings/decisions/plan updated>

### Tests + Gate
- <N>/<N> <milestone> tests pass; <CUM>/<CUM> cumulative.
- Gate: <result>.
- Decisions: <DECISION-IDs>.

### Cumulative progress
**<X>/<TOTAL> fixed (<pct>%)**

### Next session
**Session #<N+1> <next-milestone>** (~<N>h):
- <FINDING-ID> <module> — <one-line>
- ...

**Recommended model**: `<model>` — <reason>.
**Session prep**: `/clear` | `/compact` | no-action — <reason>.
**Trigger**: `start <next-milestone>` / `session done <next-milestone>`.
```

KHÔNG end nếu chưa làm Step 14.
KHÔNG end nếu "Next session" block còn trống.
