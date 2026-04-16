---
description: "Bootstrap a new feature or task — loads context, surfaces past decisions, and scaffolds a todo list before touching any code"
---

# Start Feature

Bootstrap a new feature or task end-to-end. Given a feature name or description, this command searches existing memory, reads active notes, discovers relevant context files, then scaffolds a structured todo list so you are fully prepared before writing a single line of code.

**Feature / Task:** $ARGUMENTS

---

## Step 1 — Search Existing Memory

Use `ctx_search` to surface anything already known about this feature area.

Run **two searches** to maximize recall:
1. Search with the full feature description as the query
2. Search with 2–3 extracted keywords from the description

For each result, note:
- Related past decisions or constraints
- Known file paths or locations
- Prior implementation patterns
- Any warnings or gotchas recorded from previous sessions

---

## Step 2 — Read Current Notes

Call `ctx_note(action="read")` to surface all active session notes and any smart notes whose conditions are now met.

Scan the results for anything relevant to this feature: unresolved decisions, deferred intentions, or constraints flagged in earlier sessions.

---

## Step 3 — Discover Context Files via ContextScout

Use the `task` tool with `subagent_type: "ContextScout"` to find context files relevant to this feature. Pass the full feature description as the query.

Ask ContextScout to return:
- Relevant architecture docs, README files, or design notes
- Related source files or modules
- Configuration files that may be affected
- Any existing tests or spec files in scope

Fetch and read the most relevant files returned.

---

## Step 4 — Synthesize What Was Found

Produce a concise **Context Summary** in this format:

```
## Context Summary for: <feature name>

### Memories Surfaced
- <memory 1>
- <memory 2>
(or "None found" if nothing relevant)

### Context Files Loaded
- <file path> — <one-line relevance note>
(or "None found")

### Active Notes & Smart Notes
- <note content>
(or "None")

### Known Constraints & Risks
- <constraint or risk>
(or "None identified")
```

---

## Step 5 — Scaffold a Todo List

Use `todowrite` to create an initial task breakdown. Derive the tasks from both the feature description ($ARGUMENTS) and anything discovered in Steps 1–3.

Use this default breakdown as a starting point — adjust based on what was discovered:

| Priority | Task | Status |
|----------|------|--------|
| high | Research: review existing code/docs relevant to this feature | `in_progress` |
| high | Design: outline the approach and identify touch-points | `pending` |
| high | Implement: build the feature | `pending` |
| medium | Test: write or run tests covering the new behavior | `pending` |
| medium | Review: self-review diff, check for edge cases and regressions | `pending` |
| low | Document: update any READMEs, memory, or notes affected | `pending` |

Rules:
- Mark the **first task** as `in_progress`
- Add or remove tasks based on context discovered (e.g. if design docs already exist, skip or collapse the design step)
- If the feature description implies specific sub-tasks (e.g. "add API endpoint + UI component"), break those out as explicit todos
- Keep task titles short and actionable

---

## Step 6 — Output a "Ready to Start" Summary

After the todo list is created, output a final **Ready to Start** block:

```
## ✅ Ready to Start: <feature name>

### What's Loaded
- <N> memories surfaced
- <N> context files loaded
- <N> notes reviewed

### Plan
<bullet list of todos just created, in order>

### Important Constraints
<any constraints or risks to keep in mind while working>

### Next Step
<restate the first in_progress task so it's obvious what to do now>
```

---

**Notes:**
- If $ARGUMENTS is empty or very short, ask the user for a clearer feature description before proceeding
- If ContextScout returns no results, note it in the summary and proceed — don't block on it
- If memory search surfaces a constraint that conflicts with the requested feature, call it out explicitly in the "Important Constraints" section
- Save any newly discovered file paths or architectural decisions to `ctx_memory` during or after this workflow so future sessions benefit
