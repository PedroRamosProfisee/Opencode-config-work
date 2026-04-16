# Magic Context Setup Guide

**Purpose**: Portable setup guide for installing and configuring the Magic Context plugin for OpenCode — replaces homegrown context compaction and memory consolidation with automatic, cross-session context management.

**Last Updated**: 2026-04-08

---

## What Magic Context Does

[`@cortexkit/opencode-magic-context`](https://github.com/cortexkit/opencode-magic-context) (MIT, v0.7.4+) provides:

- **Historian**: Background context compaction — automatically summarizes conversation history to stay within token limits
- **Dreamer**: Overnight background agent that consolidates, deduplicates, verifies, and archives memories
- **Cross-session Memory**: SQLite-backed persistent memories with semantic search (`ctx_memory`, `ctx_search`)
- **Surgical Context Drops**: Tag-based (`§N§`) per-message context management via `ctx_reduce`
- **Session Notes**: Deferred intentions that survive compaction via `ctx_note`
- **Compartment Expansion**: Decompress compacted history via `ctx_expand`

**Replaces**: Homegrown `context-compact` skill, `memory-consolidate` skill, and OpenCode's built-in compaction.

---

## Prerequisites

- OpenCode installed and working
- npm or bun available in the global config directory (`~/.config/opencode/`)
- A GitHub Copilot subscription (or other model provider) — historian/dreamer calls are absorbed by subscription

---

## Installation

### Step 1: Install the npm package

```bash
cd ~/.config/opencode
npm install @cortexkit/opencode-magic-context
```

### Step 2: Update `opencode.json`

Add the plugin and disable built-in compaction:

```jsonc
{
  // ... existing config ...
  "plugin": [
    // ... other plugins ...
    "@cortexkit/opencode-magic-context"
  ],
  "compaction": {
    "auto": false,
    "prune": false
  }
}
```

> **Important**: Built-in compaction MUST be disabled — Magic Context's historian replaces it entirely. Running both causes conflicts.

### Step 3: Create `magic-context.jsonc`

Create this file at `~/.config/opencode/magic-context.jsonc`:

```jsonc
{
  "$schema": "https://raw.githubusercontent.com/cortexkit/opencode-magic-context/master/assets/magic-context.schema.json",
  "enabled": true,

  "historian": {
    "model": "github-copilot/claude-sonnet-4.5",
    "fallback_models": ["github-copilot/gpt-5.4"]
  },

  "dreamer": {
    "enabled": true,
    "model": "github-copilot/claude-sonnet-4.5",
    "fallback_models": ["github-copilot/gpt-5.4"],
    "schedule": "02:00-06:00",
    "tasks": ["consolidate", "verify", "archive-stale", "improve"]
  },

  "embedding": {
    "provider": "local"
  },

  "memory": {
    "enabled": true,
    "injection_budget_tokens": 4000,
    "auto_promote": true
  },

  "sidekick": {
    "enabled": false
  }
}
```

### Step 4: Restart OpenCode

The plugin loads on startup. Restart to activate.

---

## Configuration Reference

| Setting | Value | Why |
|---------|-------|-----|
| `historian.model` | `claude-sonnet-4.5` | Fast, cheap, good at summarization |
| `historian.fallback_models` | `gpt-5.4` | Backup if primary unavailable |
| `dreamer.enabled` | `true` | Automatic overnight memory maintenance |
| `dreamer.schedule` | `02:00-06:00` | Runs when machine is idle |
| `dreamer.tasks` | 4 tasks | consolidate, verify, archive-stale, improve |
| `embedding.provider` | `local` | No external API calls for embeddings |
| `memory.injection_budget_tokens` | `4000` | Max tokens of memories injected per session |
| `memory.auto_promote` | `true` | Historian auto-promotes learnings to memory |
| `sidekick.enabled` | `false` | Optional co-pilot feature — disabled to reduce noise |

---

## What Gets Removed

When installing Magic Context, remove these if they exist:

| Asset | Type | Reason |
|-------|------|--------|
| `skill/context-compact/` | Skill | Replaced by historian |
| `skill/memory-consolidate/` | Skill | Replaced by dreamer + ctx_memory |
| `command/compact.md` | Command | Replaced by historian + `/ctx-flush` |
| `command/consolidate.md` | Command | Replaced by dreamer + `/ctx-dream` |

> **Keep** the `skill/context/` (context-manager) skill — it handles context file CRUD operations, which is a different concern from context compaction.

---

## Tools Available After Installation

| Tool | Purpose |
|------|---------|
| `ctx_reduce` | Drop tagged content (`§N§`) you no longer need |
| `ctx_expand` | Decompress a compartment to see original transcript |
| `ctx_note` | Save deferred intentions that survive compaction |
| `ctx_memory` | Write/delete persistent cross-session memories |
| `ctx_search` | Search across memories, session facts, and history |

## Commands Available

| Command | Purpose |
|---------|---------|
| `/ctx-status` | Show plugin health, token usage, memory stats |
| `/ctx-flush` | Force historian compaction now |
| `/ctx-recomp` | Recompact existing compartments |
| `/ctx-aug` | Augment context with relevant memories |
| `/ctx-dream` | Trigger dreamer manually |

---

## Storage

- **SQLite database**: `~/.local/share/opencode/storage/plugin/magic-context/context.db`
- **17 tables** for memories, sessions, compartments, embeddings, etc.
- **Backup**: Copy `context.db` to preserve all memories when migrating

---

## Verification

After installation, verify everything works:

1. **Start a new OpenCode session**
2. **Run `/ctx-status`** — confirm:
   - Plugin: enabled
   - Historian: active with correct model
   - Memory: enabled with token budget
   - Dreamer: enabled with schedule
   - No error warnings
3. **Test memory write**: `ctx_memory(action="write", category="TEST", content="Test memory")`
4. **Test memory search**: `ctx_search(query="test memory")`
5. **Test memory cleanup**: `ctx_memory(action="delete", id=<id from step 3>)`

---

## Migration Notes

### Existing `learned-patterns.md`

If you have a `learned-patterns.md` rules file with accumulated session learnings, you have two options:

1. **Keep as passive rules file** (recommended) — the agent reads rules on startup, so knowledge is still available. Over time the historian promotes entries to proper memories, and the file becomes redundant.
2. **Bulk migrate** — call `ctx_memory(action="write", ...)` for each entry with appropriate categories: `ARCHITECTURE_DECISIONS`, `PREFERENCES`, `CONSTRAINTS`, `CONFIG_DEFAULTS`.

### Transferring to Another Machine

To replicate this setup on another machine:

1. Copy `~/.config/opencode/` to the target machine's `~/.config/opencode/`
2. Run `cd ~/.config/opencode && npm install` to restore node_modules
3. Optionally copy `~/.local/share/opencode/storage/plugin/magic-context/context.db` to transfer memories
4. Restart OpenCode

---

## Risk Notes

| Risk | Level | Mitigation |
|------|-------|------------|
| Single maintainer (`ualtinok`) | 🟡 Medium | MIT license — can fork if abandoned |
| SQLite durability | 🟡 Medium | Periodic backup of `context.db` |
| Model cost | 🟢 Low | GitHub Copilot subscription absorbs historian/dreamer calls |
| OpenCode compatibility | 🟢 Low | No conflicts with other plugins |
| Rollback effort | 🟢 Low | Re-enable built-in compaction, rewrite ~130 lines of skills |
