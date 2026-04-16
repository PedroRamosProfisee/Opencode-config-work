# Session Log — OpenCode Export Bundle

**Date**: 2026-04-16  
**Purpose**: Bundle OpenCode agents/skills/tools/MCP env for reuse across OpenCode installs

---

## Summary

This session produced a reusable export bundle for OpenCode installations, including:

- **34 canonical active agents** (with Not hooked flags)
- **14 unified skills** (7 opencode + 7 global)
- **MCP environment annex** (Godot, Codesight, Ori)
- **MM-router flow documentation**
- **Regeneration scripts** (Node.js + PowerShell)

**GitHub Repo**: https://github.com/R0flC0pter/Opencode-config-personal

---

## 1. Export Contents

### data/agents.json
- **32 active agents**: All canonical MM-swarm pipeline agents
- **5 archived duplicates**: Preserved for history (swarm-*)
- **2 not_hooked**: debug, local-implementor (flagged, not wired to pipeline)

### data/skills.json
- **14 unified skills** with origin tags:
  - Opencode (7): antivibe, context, context7, graphify, ori-memory, smart-router-skill, task-management
  - Global (7): caveman, caveman-commit, caveman-compress, caveman-help, caveman-review, find-skills, ui-ux-pro-max

### data/mcp-env-annex.json
- **Godot**: GODOT_EXECUTABLE path
- **Codesight**: npx codesight --mcp
- **Ori**: ORI_VAULT, ORI_BRIDGE, VAULT_MOUNT paths

### docs/agent-flow.md
- MM-router-driven agent hierarchy
- Phase mapping: Research → Investigate → Handoff → Review → Implement → Test
- Not hooked flag rationale

### docs/dupe-cleanup.md
- Aggressive pruning policy
- Archive strategy

### Scripts
- `generate-export.js` — Node.js regen script
- `refresh-export.ps1` — PowerShell regen script

---

## 2. AntiVibe Skill — Full Documentation

> **Learn what AI writes, not just accept it.**

### Purpose

AntiVibe generates **learning-focused explanations** of AI-written code. Not generic summaries — actual educational content that helps developers understand:

- **What** the code does (functionality)
- **Why** it was written this way (design decisions)
- **When** to use these patterns (context)
- **What alternatives** exist (broader knowledge)

### When to Use

Use AntiVibe when:

1. **Manual invocation**: User types `/antivibe` or any trigger phrase
2. **Post-task learning**: After a feature/phase completes, user wants to learn from it
3. **Proactive**: User says "explain what AI wrote", "learn from this code", or "understand what AI wrote"
4. **Planning**: User explicitly wants an educational deep dive on specific code

### What AntiVibe Produces

Output saved to `.deep-dive/` folder as markdown:

```
.deep-dive/
├── auth-system-2026-04-15.md
├── api-layer-2026-04-15.md
└── database-models-2026-04-15.md
```

Each file contains:

- **Overview**: What this code does and why it exists
- **Code Walkthrough**: File-by-file explanation with key components
- **Concepts Explained**: Design patterns, algorithms, CS concepts used
- **Learning Resources**: Curated docs, tutorials, videos
- **Related Code**: Links to other files in the codebase
- **Next Steps**: Suggested learning path

### Workflow

#### Step 1: Identify Code to Analyze

- Check for explicit file list in user request
- Or check git diff for recently modified/created files
- Or ask user which files/components they want to understand

#### Step 2: Analyze Code Structure

For each file:

- Identify main purpose and responsibilities
- Note key functions, classes, modules
- Identify design patterns used (factory, singleton, observer, etc.)
- Find any complex logic or algorithms

#### Step 3: Explain Concepts

For each concept/pattern found:

- **What**: Plain-language explanation
- **Why**: Why this approach was chosen over alternatives
- **When**: When to use this pattern (with context)
- **Alternatives**: Other approaches and trade-offs

#### Step 4: Find External Resources

Search for and include:

- Official documentation for libraries/frameworks used
- Quality tutorials or blog posts
- Video resources (if available)
- Related concepts for further learning

#### Step 5: Generate Output

Create markdown file in `.deep-dive/` folder:

- Name format: `[component]-[YYYY-MM-DD].md`
- Follow the template in `templates/deep-dive.md`
- Include code snippets where helpful
- Make it educational, not just descriptive

### Auto-Trigger Hooks

> **Note**: OpenCode does not natively support Claude Code hooks. Manual invocation is required.

#### Hook System Design

The hooks.json documents the design for a future hook system:

```json
{
  "session_tracker": "Track files modified during session",
  "proactive_offer": "After implementation, offer learning"
}
```

#### Current Workaround

To trigger AntiVibe:

- Type `/antivibe` or any trigger phrase
- Ask explicitly: "Can you explain what you wrote?"
- Request: "I want to learn from this code"

#### Future Implementation (Feasible via OpenCode)

A hook monitor subagent could:

1. **Track session files**: Store modified file list after each task
2. **End-of-session offer**: "I noticed X files were modified. Deep dive?"
3. **Post-task prompt**: After subagent completes, suggest invoking AntiVibe

This requires no changes to OpenCode core — just a session-tracking subagent.

### Principles

1. **Why over what** - Always explain design decisions
2. **Context matters** - Explain when/why to use patterns
3. **Curated resources** - Quality links, not random Google results
4. **Phase-aware** - Group by implementation phase
5. **Learning path** - Suggest next steps for deeper study
6. **Concept mapping** - Connect code to underlying CS concepts

### Helper Scripts

The `scripts/` folder contains PowerShell equivalents for code analysis:

| Script | Purpose |
|--------|---------|
| `analyze-code.ps1` | Parse code structure and identify patterns |
| `generate-deep-dive.ps1` | Generate markdown output template |
| `find-resources.ps1` | Search for external resources |

These are helpers — you can also do everything via direct code analysis.

### Reference Files

| File | Purpose |
|------|---------|
| `reference/language-patterns.md` | Framework patterns explained |
| `reference/resource-curation.md` | Curated learning resources |
| `templates/deep-dive.md` | Output template |

### Examples

**Input**: "Explain the auth system you wrote"
**Output**: `.deep-dive/auth-system-2026-04-15.md` containing:

- JWT structure explanation
- Password hashing rationale
- Session management concepts
- Learning resources for auth patterns

**Input**: "I want to understand this API layer"
**Output**: `.deep-dive/api-layer-2026-04-15.md` containing:

- REST design decisions
- Middleware explanation
- Error handling patterns
- Further reading on API design

### Integration with Other Skills

- **caveman**: Use after compress to understand compressed content
- **caveman-review**: Complementary — focuses on code quality
- **context**: Can pull from existing context files
- **find-skills**: Can discover related skills

---

## 3. Obsidian × MM Swarm Framework — Phase 1

> **Status**: Architecture finalized, implementation pending

### Run Reference

- **Run ID**: 20260416-obsidian-research-v2
- **Location**: `C:\Users\ramos\.config\.runs\20260416-obsidian-research-v2`
- **Phase**: 1 (architecture) complete, Phase 2 (implementation) pending

### Key Deliverables

| File | Description |
|------|-------------|
| `research-analysis.json` | mm-researcher findings |
| `phase1-architecture-finalized.md` | System topology, schemas, folder guardrails |
| `phase1-data-model-spec.json` | JSON Schema spec |
| `PoC-plan.md` | 4-week milestone plan |
| `risk-report.md` | Risk matrix, mitigations |

### System Topology

```
~/.config/.runs/           ← Swarm artifact source (READ by converter)
│
└── {runId}/
    ├── research-analysis.json
    └── ...

        swarm2vault.js (ONE-WAY, STATELESS)
            ↓
~/second-brain/                   ← Obsidian vault root (SYNCED)
│
├── swarm_output/                  ← CONVERTER WRITES HERE
│   └── {runId}/
│       ├── research.md
│       └── _source/
├── notes/                         ← HUMAN WRITES HERE
├── projects/                      ← HUMAN WRITES HERE
└── daily/                         ← HUMAN WRITES HERE

~/.ori-memory/                     ← Ori vault (UNCHANGED, NEVER SYNCED)
```

### Three Schemas

1. **Ori-memory Note** (existing, unchanged)
2. **Swarm Artifact Note** (NEW — converter output with extended frontmatter)
3. **Human Note** (standard Obsidian)

### Key Decisions

- **Variant 1**: One-way CLI converter (recommended for PoC)
- **No bidirectional sync** in Phase 1
- **Syncthing** for cross-device sync (P2P, no cloud)
- **Ori isolation**: `.ori/` never synced

### Implementation Roadmap (4 Weeks)

| Week | Milestone |
|------|----------|
| 1 | Vault setup + converter skeleton |
| 2 | All artifact types + sync |
| 3 | Post-run hook + workflow docs |
| 4 | Hardening + evaluation |

### Next Steps

- Build `swarm2vault.js` (~150 lines, zero npm deps)
- Test with existing `.runs/` artifacts
- Set up Syncthing for cross-device sync

---

## 4. Git History

| Commit | Message |
|--------|---------|
| `fd933a7` | feat(export): prune duplicates, unify skills, add MM-router flow, MCP env annex (Not hooked flagged) |
| `165304a` | feat(export): add regenerate script |

---

## 5. Quick Reference

### Regenerate Export
```bash
node generate-export.js
git add -A
git commit -m "chore: regenerate export"
git push origin main
```

### Clone Bundle
```bash
git clone https://github.com/R0flC0pter/Opencode-config-personal.git
cd Opencode-config-personal
```

### AntiVibe Invocation
- Type `/antivibe` or trigger phrase
- Ask: "Can you explain what you wrote?"
- Request: "I want to learn from this code"

---

*Session completed 2026-04-16*