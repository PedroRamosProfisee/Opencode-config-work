# opencode-config-work

A personal OpenCode configuration pack including custom agents, slash commands, skills, tools, plugins, and context libraries for C#/.NET and general software development workflows.

## What's Included

### 🤖 Agents (`agents/` and `agent/`)
- **Swarm suite**: planner, implementor, reviewer, tester — a full plan→build→review→test pipeline
- **architect** — C#/.NET microservice architecture planning (no code changes)
- **csharp-reviewer** — SOLID principles and best practices review
- **debug** — Root cause analysis and bug tracing
- **test-writer** — MSTest + Moq unit test generation
- **Subagents**: ContextScout, ContextManager, DomainAnalyzer, WorkflowDesigner, AgentGenerator, CommandCreator, DocWriter, DevOps specialist, and more

### ⚡ Slash Commands (`command/`)
- `/start-feature <description>` — bootstrap any new task with full context loading and todo scaffolding
- `/session-wrap [title]` — end-of-session memory promotion, note cleanup, and auto-commit
- `/memory-review [category]` — guided memory hygiene walkthrough
- `/commit` — conventional commits with emoji
- `/test` — run tests with structured reporting
- And more...

### 📚 Skills (`skill/`)
- **context-manager** — full context lifecycle management
- **task-management** — subtask tracking with dependencies and validation
- **graphify** — turn files into a navigable knowledge graph
- **smart-router-skill** — configurable themed workflows

### 🛠️ Tools (`tool/`)
- Gemini image generation and editing
- Environment variable helpers

### 🔌 Plugins (`plugin/`)
- **agent-validator** — validates agent behavior against defined rules
- **bash-safety** — guards against unsafe bash operations
- **notify** — session notifications
- **scratchpad** — temporary working memory

### 📁 Context Library (`context/`)
Rich context files organized by domain: core, development, data, product, UI, learning, and more.

### 👤 Profiles (`profiles/`)
Five profile tiers: essential, developer, advanced, business, full.

---

## Prerequisites

- [OpenCode](https://opencode.ai) installed
- Node.js or [Bun](https://bun.sh) installed
- A supported LLM provider configured (GitHub Copilot, Anthropic, OpenAI, etc.)

---

## Installation

See [INSTALL.md](./INSTALL.md) for platform-specific instructions.

---

## Configuration

After installing, review and customize:

- **`opencode.json`** — set your preferred model and provider
- **`plugin/`** — enable/disable plugins as needed
- **`profiles/`** — choose a profile that matches your workflow
- **MCP servers** — add your own `mcp` block to `opencode.json` if needed (not included — configure per your org)

---

## Slash Command Highlights

### `/start-feature <description>`
Bootstraps a new feature or task:
- Searches existing memory for related decisions
- Loads relevant context files via ContextScout
- Scaffolds a prioritized todo list

### `/session-wrap [title]`
End-of-session housekeeping:
- Promotes key discoveries to persistent memory
- Dismisses resolved notes
- Auto-commits and pushes this config repo

### `/memory-review [category]`
Periodic memory hygiene:
- Lists all memories by category
- Flags stale or duplicate entries
- Guided update/delete workflow
