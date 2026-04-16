

<!-- ori-bridge:opencode -->
# Ori Mnemos - OpenCode Bridge

## Session Rhythm
Every session: Orient → Work → Persist

### Orient (always first)
- - Ori injects identity via `ORIENT.md` loaded at session start automatically
- Call `ori_orient` MCP tool for session briefing (daily + goals + reminders + vault status)
- Use `ori_orient brief=false` for full context including identity and methodology
- Read `ori://identity` or `ori://goals` resources for specific context

### Work
- Use `ori_query_ranked` to find related notes before creating new ones
- Use `ori_add` to capture insights to inbox/
- NEVER write to notes/ directly — use `ori add` then `ori_promote`

### Persist
- Use `ori_update` file=daily to mark completed items
- Use `ori_update` file=goals to update active threads
- Run `ori validate` on notes you create
- Keep notes atomic and link to maps
- At session end, run `/memory capture` to log learnings to inbox
