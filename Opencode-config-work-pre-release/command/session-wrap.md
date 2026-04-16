---
description: "End-of-session wrap-up: persist discoveries to memory, dismiss resolved notes, and commit the opencode config directory."
---

# /session-wrap

Run this command at the end of any working session to capture what was learned, clean up stale notes, and commit the opencode config so context survives into future sessions.

**Session title (optional):** $ARGUMENTS

---

## Step 1 — Search for existing memories before writing

Before persisting anything, search to avoid duplicates. Run `ctx_search` for the key topics discovered this session (file paths, commands, decisions, constraints). Note which topics already have memories so you can skip or update them rather than create duplicates.

---

## Step 2 — Review the conversation for persist-worthy items

Scan the full conversation for:

- **File paths / locations** found after searching (source dirs, config files, DB paths, etc.)
- **Architectural decisions or constraints** that shaped what was built or avoided
- **Non-obvious commands or workarounds** (build scripts, test flags, env quirks)
- **API patterns or configuration details** that took effort to discover
- **Known issues or gotchas** that future sessions should be aware of
- **Anything that would save re-discovery time** — if you had to search or experiment to find it, it belongs in memory

Ignore transient details (one-off log output, throwaway test values, etc.).

---

## Step 3 — Write worthy items to `ctx_memory`

For each item identified in Step 2 that is **not already covered** by existing memories, call:

```
ctx_memory(action="write", category="<CATEGORY>", content="<concise, actionable fact>")
```

Use these categories:

| Category | Use for |
|---|---|
| `ENVIRONMENT` | File paths, repo locations, tool versions, env vars |
| `WORKFLOW_RULES` | Build/test/release commands, process steps |
| `CONSTRAINTS` | Hard limits, "never do X", platform requirements |
| `PATTERNS` | Code/config patterns, API conventions, naming rules |
| `KNOWN_ISSUES` | Bugs, workarounds, things that are broken or fragile |

Write one memory per distinct fact. Keep content concise and actionable (1–2 sentences max). If an existing memory is outdated rather than missing, note it in the summary — do not silently duplicate it.

---

## Step 4 — Read and triage current notes

Call `ctx_note(action="read")` to retrieve all active session notes.

For each note, decide:

- **Dismiss** (`ctx_note(action="dismiss", note_id=N)`) if the work is done, the concern is resolved, or the note is no longer relevant.
- **Keep** if it describes ongoing work, a deferred intention, or a future reminder that still applies.

---

## Step 5 — Auto-commit the opencode config directory

Check for uncommitted changes in the opencode config:

```bash
git -C "C:/Users/pedroni/.config/opencode" status --porcelain
```

**If changes exist:**

1. Stage all changes:
   ```bash
   git -C "C:/Users/pedroni/.config/opencode" add -A
   ```

2. Commit with a descriptive message (include session title if `$ARGUMENTS` was provided):
   ```bash
   git -C "C:/Users/pedroni/.config/opencode" commit -m "🧠 chore: session wrap - persist context $(date +'%Y-%m-%d')"
   ```
   If a session title was given via `$ARGUMENTS`, append it:
   ```
   🧠 chore: session wrap - <session title> [YYYY-MM-DD]
   ```

3. Push:
   ```bash
   git -C "C:/Users/pedroni/.config/opencode" push
   ```

**If no changes exist:** Note "config already clean — nothing to commit."

---

## Step 6 — Output a session wrap summary

Print a clean summary in this format:

```
## 🧠 Session Wrap Summary
**Session:** <title or "untitled">
**Date:** <today>

### Memories Written
- [CATEGORY] <content>   ← one line per new memory
- (none)                 ← if nothing was worth persisting

### Memories Skipped (already exist)
- <topic> — covered by existing memory

### Notes Dismissed
- Note #N: "<content>"
- (none)

### Notes Kept
- Note #N: "<content>"

### Config Commit
- ✅ Committed & pushed: "<commit message>"
- ⏭️  Nothing to commit (config was clean)
- ❌ Error: <details>
```

---

## Examples

```bash
# Basic end-of-session wrap with no title
/session-wrap

# Wrap with a descriptive session title
/session-wrap "Profisee REST API integration"

# Wrap after a focused debugging session
/session-wrap "Debug golden record merge issue"
```

---

## Notes

- Always search before writing — duplicate memories add noise and dilute signal.
- Prefer updating a stale memory over writing a second overlapping one (flag it in the summary).
- If `git push` fails (e.g. no remote configured), report the error but do not block the rest of the wrap.
- This command is safe to run multiple times in a session; deduplication in Step 1 prevents redundant writes.
