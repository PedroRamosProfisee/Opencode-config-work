---
description: "Guided memory hygiene workflow — list, flag, and clean up stale or duplicate project memories"
---

# /memory-review

Run a full memory hygiene session. List all persisted memories, identify stale or redundant entries, and walk the user through keeping, updating, or deleting each flagged item.

**Request:** $ARGUMENTS

---

## Step 1 — List All Memories

Call `ctx_memory(action="list", limit=100)` to retrieve every persisted memory.

Display results **grouped by category** using this format:

```
## ENVIRONMENT (N)
[id: 1] Some environment fact...
[id: 7] Another environment fact...

## WORKFLOW_RULES (N)
[id: 3] Always use scripts/release.sh...

## CONSTRAINTS (N)
...

## PATTERNS (N)
...

## KNOWN_ISSUES (N)
...

## OTHER / UNCATEGORIZED (N)
...
```

Print a summary line at the top:
> 📦 **Total memories found: N** across K categories

---

## Step 2 — Flag Candidates for Review

After displaying all memories, analyze them and flag entries that match **any** of these criteria:

| Signal | Examples |
|--------|----------|
| **Duplicate or near-duplicate** | Two memories with nearly identical content, even in different categories |
| **Version-pinned** | References a specific version number, tag, or release (e.g. `v1.4.2`, `node 18`) |
| **Branch or PR reference** | Mentions a branch name, PR number, or issue number |
| **Narrow / task-specific** | Describes a one-off workaround or a step from a completed task rather than a durable fact |
| **Contradictory** | Two memories that appear to conflict with each other |
| **Vague / low-signal** | Very short or generic content that adds little value |

Present flagged items as a clearly marked block:

```
## 🔍 Flagged for Review (N items)

⚠️  [id: 4]  WORKFLOW_RULES
    "Use branch feature/old-refactor for the new pipeline"
    → Reason: references a specific branch name that may no longer exist

⚠️  [id: 9]  CONSTRAINTS
    "Dashboard Tauri build needs node v18.12.0"
    → Reason: version-pinned — may have changed

⚠️  [id: 2]  ENVIRONMENT
    "OpenCode source is at ~/Work/OSS/opencode"
    → Reason: possible duplicate of [id: 6] "Source repo lives at ~/Work/OSS/opencode"
```

If **no items** are flagged, say so clearly and skip to Step 5.

---

## Step 3 — Walk Through Flagged Items

Process flagged items **one category group at a time** (not one by one, to avoid excessive back-and-forth).

For each group, present the flagged items and ask the user to respond with one action per ID:

```
For each item below, reply with:
  keep N        — leave it unchanged
  update N      — I'll ask for the new content
  delete N      — remove it permanently

Items to review (WORKFLOW_RULES):
  [id: 4]  "Use branch feature/old-refactor for the new pipeline"
  [id: 11] "Run npm ci before every build in CI"
```

Wait for the user's reply before proceeding to the next group.

If the user says **update N**, ask:
> ✏️ What should the new content for memory [id: N] be?

Then confirm before writing:
> Ready to update [id: N] to: "{new content}" — confirm? (yes/no)

---

## Step 4 — Execute Decisions

For each decision, call the appropriate tool:

- **Delete:** `ctx_memory(action="delete", id=N)`
- **Update:** `ctx_memory(action="update", id=N, content="<new content>")`
- **Keep:** no action required — acknowledge with ✅

After executing each batch, confirm:
> ✅ Done — deleted [4, 9], updated [2], kept [11]

---

## Step 5 — Final Report

Once all flagged items are resolved, output a clean summary:

```
## 🧹 Memory Review Complete

| Metric                  | Value |
|-------------------------|-------|
| Total memories reviewed | 24    |
| Flagged for review      | 6     |
| ✅ Kept as-is           | 2     |
| ✏️ Updated              | 1     |
| 🗑️ Deleted              | 3     |
| Remaining memories      | 21    |

### Category Health

✅ ENVIRONMENT     — looks healthy (3 entries, no flags)
✅ PATTERNS        — looks healthy (5 entries, no flags)
⚠️  WORKFLOW_RULES  — had duplicates; now cleaned up
⚠️  CONSTRAINTS     — had version-pinned entries; review again after next upgrade
✅ KNOWN_ISSUES    — looks healthy (2 entries, no flags)
```

Close with an encouragement note if memory count dropped significantly:
> 💡 Tip: leaner memory = faster, more accurate context injection. Consider running `/memory-review` again after major milestones or dependency upgrades.

---

## Notes

- Never delete a memory without explicit user confirmation — always show the content before acting.
- If the user passes arguments (e.g. `/memory-review CONSTRAINTS`), scope the review to that category only — still follow all steps above but filter to matching entries.
- If `ctx_memory` returns no results, inform the user:
  > 📭 No persisted memories found. Nothing to review!
- This command is read-safe in Steps 1–2; only Steps 3–4 mutate data.
