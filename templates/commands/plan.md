---
description: Create a PLAN.md for a project or track. Reads codebase state + asks 4 questions → generates structured plan draft ready to commit. Does NOT start implementing.
argument-hint: <plan-name e.g. "auth-refactor" or "v2-migration">
---

Create a plan document for: `$ARGUMENTS`

**Step 1 — Read current state**

```bash
git log --oneline -5
git status --short
```

Also scan top-level directory structure (1 level deep) to understand scope.

**Step 2 — Ask 4 questions** (skip any already clear from context or $ARGUMENTS)

1. Goal trong 1-2 câu?
2. Timeline: 1 session / vài ngày / vài tuần?
3. Explicitly out of scope là gì?
4. Known risks hoặc hard constraints?

**Step 3 — Generate plan document**

Save to `docs/<name>_PLAN.md` (create `docs/` if not exists).

Structure bắt buộc — 6 sections:
1. **Success Criteria** — verifiable (test/metric/output). Reject "make it work" phrasing.
2. **Scope** — in + out-of-scope explicit
3. **Milestones** — mỗi milestone có deliverable cụ thể, không chỉ task description
4. **Technical Approach** — key decisions table + 3-5 dòng notes
5. **Risks** — likelihood / impact / mitigation
6. **Session Log** — để trống, `/end-session` skill sẽ fill sau mỗi session

**Step 4 — Verify review checklist** trước khi báo user commit:

- [ ] Success criteria test được pass/fail rõ ràng?
- [ ] Mỗi milestone có deliverable (file/test/metric), không phải vague task?
- [ ] Out-of-scope liệt kê tường minh?
- [ ] Decisions có rationale?
- [ ] Estimates realistic (không optimistic)?
- [ ] Risks có mitigation?

Nếu bất kỳ check nào fail → sửa ngay trong plan trước khi report.

**Step 5 — Report**

```
✅ Plan created: docs/<name>_PLAN.md

Goal    : <1-line summary>
Horizon : <timeline>
Milestones: M1 (<Nh>) → M2 (<Nh>) → M3 (<Nh>)
Est. total: <Nh>

Review checklist: 6/6 ✓

Next: review plan → `git add docs/<name>_PLAN.md && git commit -m "plan: <name>"`
Start first session: `/end-session M1` khi M1 xong.
```

**Rules:**
- Không bắt đầu implement — plan only
- Không tạo thêm file ngoài `docs/<name>_PLAN.md`
- Nếu $ARGUMENTS trống và context không rõ → hỏi thêm trước khi generate
