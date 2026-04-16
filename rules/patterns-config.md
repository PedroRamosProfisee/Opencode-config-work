# .config Repository Patterns

> Loaded only in .config workspace sessions.

## What This Repo Is

This repo holds your personal configuration, tooling, and agent scaffolding — not application code. Files here are tools and configs, not products.

## Important Conventions

- **NEVER commit secrets** — `.env`, `*.key`, `credentials.json`, `token*.json`, `*.pem` are all excluded
- **OpenCode tooling**: all custom tools live in `opencode/tools/` or `.opencode/tool/`
- **Skills**: all skills live in `opencode/skills/` or `.agents/skills/`
- **Rules**: domain patterns live in `opencode/rules/patterns-{name}.md`
- **MCP servers**: configured in `opencode.json`, not here

## OpenCode Tool Development

- Tools in `.opencode/tool/` are auto-discovered (description files + `.ts` source)
- Tools in `opencode/tools/` require the OpenCode plugin SDK (`@opencode-ai/plugin`)
- Bun is preferred for new tools (`// @bun` directive, uses `bun:sqlite`, `Bun.spawn`)
- Test new tools: `bun run path/to/tool.ts`

## Shell Scripts

- All shell scripts must be POSIX-compatible (no bashisms)
- Windows compatibility: wrap with `#!/bin/sh` and test with `sh` on WSL
- `shellcheck .shellcheckrc` at root — already configured
- No Dockerfiles here (hadolint not needed)

## Git Conventions

- This is a dotfiles repo — no formal git history cleanup needed
- When adding new tools, document install steps in the tool's own README
- The `.runs/` directory is for agent run artifacts — already gitignored
