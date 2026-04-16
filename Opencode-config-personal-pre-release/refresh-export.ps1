# Refresh export: prune duplicates, unify skills, add MM-router flow, MCP env annex
# Note: This creates data/ and docs/ directories if missing, then overwrites five target files.

# 1) Define repo root
$repoRoot = Get-Location

# 2) Create target directories if they don't exist
$dataDir = Join-Path $repoRoot "data"
$docsDir = Join-Path $repoRoot "docs"
if (-not (Test-Path $dataDir)) { New-Item -ItemType Directory -Path $dataDir -Force | Out-Null }
if (-not (Test-Path $docsDir)) { New-Item -ItemType Directory -Path $docsDir -Force | Out-Null }

# 3) Define target file paths
$agentsPath = Join-Path $dataDir "agents.json"
$agentFlowPath = Join-Path $docsDir "agent-flow.md"
$skillsPath = Join-Path $dataDir "skills.json"
$mcpAnnexPath = Join-Path $dataDir "mcp-env-annex.json"
$dupeCleanupPath = Join-Path $docsDir "dupe-cleanup.md"

# 4) Active agents (32 canonical)
$activeAgents = @(
  [pscustomobject]@{ name="bug-fix-coordinator"; path="C:\Users\ramos\.config\opencode\agents\bug-fix-coordinator.md"; status="active"; origin="opencode" },
  [pscustomobject]@{ name="cc-implementor"; path="C:\Users\ramos\.config\opencode\agents\cc-implementor.md"; status="active"; origin="opencode" },
  [pscustomobject]@{ name="cc-planner"; path="C:\Users\ramos\.config\opencode\agents\cc-planner.md"; status="active"; origin="opencode" },
  [pscustomobject]@{ name="cc-reviewer"; path="C:\Users\ramos\.config\opencode\agents\cc-reviewer.md"; status="active"; origin="opencode" },
  [pscustomobject]@{ name="cc-tester"; path="C:\Users\ramos\.config\opencode\agents\cc-tester.md"; status="active"; origin="opencode" },
  [pscustomobject]@{ name="cheap-cloud-implementor"; path="C:\Users\ramos\.config\opencode\agents\cheap-cloud-implementor.md"; status="active"; origin="opencode" },
  [pscustomobject]@{ name="cost-tracking"; path="C:\Users\ramos\.config\opencode\agents\cost-tracking.md"; status="active"; origin="opencode" },
  [pscustomobject]@{ name="docs-coordinator"; path="C:\Users\ramos\.config\opencode\agents\docs-coordinator.md"; status="active"; origin="opencode" },
  [pscustomobject]@{ name="fb-implementor"; path="C:\Users\ramos\.config\opencode\agents\fb-implementor.md"; status="active"; origin="opencode" },
  [pscustomobject]@{ name="fb-validator"; path="C:\Users\ramos\.config\opencode\agents\fb-validator.md"; status="active"; origin="opencode" },
  [pscustomobject]@{ name="fc-implementor"; path="C:\Users\ramos\.config\opencode\agents\fc-implementor.md"; status="active"; origin="opencode" },
  [pscustomobject]@{ name="fc-planner"; path="C:\Users\ramos\.config\opencode\agents\fc-planner.md"; status="active"; origin="opencode" },
  [pscustomobject]@{ name="fc-reviewer"; path="C:\Users\ramos\.config\opencode\agents\fc-reviewer.md"; status="active"; origin="opencode" },
  [pscustomobject]@{ name="fc-tester"; path="C:\Users\ramos\.config\opencode\agents\fc-tester.md"; status="active"; origin="opencode" },
  [pscustomobject]@{ name="free-cloud-implementor-basic"; path="C:\Users\ramos\.config\opencode\agents\free-cloud-implementor-basic.md"; status="active"; origin="opencode" },
  [pscustomobject]@{ name="free-cloud-implementor"; path="C:\Users\ramos\.config\opencode\agents\free-cloud-implementor.md"; status="active"; origin="opencode" },
  [pscustomobject]@{ name="ideation-coordinator"; path="C:\Users\ramos\.config\opencode\agents\ideation-coordinator.md"; status="active"; origin="opencode" },
  [pscustomobject]@{ name="media-interpreter"; path="C:\Users\ramos\.config\opencode\agents\media-interpreter.md"; status="active"; origin="opencode" },
  [pscustomobject]@{ name="migration-coordinator"; path="C:\Users\ramos\.config\opencode\agents\migration-coordinator.md"; status="active"; origin="opencode" },
  [pscustomobject]@{ name="mm-handoff-writer"; path="C:\Users\ramos\.config\opencode\agents\mm-handoff-writer.md"; status="active"; origin="opencode" },
  [pscustomobject]@{ name="mm-investigator"; path="C:\Users\ramos\.config\opencode\agents\mm-investigator.md"; status="active"; origin="opencode" },
  [pscustomobject]@{ name="mm-planner"; path="C:\Users\ramos\.config\opencode\agents\mm-planner.md"; status="active"; origin="opencode" },
  [pscustomobject]@{ name="mm-researcher"; path="C:\Users\ramos\.config\opencode\agents\mm-researcher.md"; status="active"; origin="opencode" },
  [pscustomobject]@{ name="mm-reviewer"; path="C:\Users\ramos\.config\opencode\agents\mm-reviewer.md"; status="active"; origin="opencode" },
  [pscustomobject]@{ name="mm-router"; path="C:\Users\ramos\.config\opencode\agents\mm-router.md"; status="active"; origin="opencode" },
  [pscustomobject]@{ name="mm-scene-tester"; path="C:\Users\ramos\.config\opencode\agents\mm-scene-tester.md"; status="active"; origin="opencode" },
  [pscustomobject]@{ name="mm-test-writer"; path="C:\Users\ramos\.config\opencode\agents\mm-test-writer.md"; status="active"; origin="opencode" },
  [pscustomobject]@{ name="multimodel-architect"; path="C:\Users\ramos\.config\opencode\agents\multimodel-architect.md"; status="active"; origin="opencode" },
  [pscustomobject]@{ name="qa-coordinator"; path="C:\Users\ramos\.config\opencode\agents\qa-coordinator.md"; status="active"; origin="opencode" },
  [pscustomobject]@{ name="security-coordinator"; path="C:\Users\ramos\.config\opencode\agents\security-coordinator.md"; status="active"; origin="opencode" },
  [pscustomobject]@{ name="test-writer"; path="C:\Users\ramos\.config\opencode\agents\test-writer.md"; status="active"; origin="opencode" },
  [pscustomobject]@{ name="uiux-coordinator"; path="C:\Users\ramos\.config\opencode\agents\uiux-coordinator.md"; status="active"; origin="opencode" }
)

# 5) Archived duplicates (5)
$archivedAgents = @(
  [pscustomobject]@{ name="swarm-implementor"; archivedPath="C:\Users\ramos\.config\opencode\.archive\2026-04-11-token-reduction\agents\swarm-implementor.md"; note="Archived duplicate to prune active surface" },
  [pscustomobject]@{ name="swarm-manager"; archivedPath="C:\Users\ramos\.config\opencode\.archive\2026-04-11-token-reduction\agents\swarm-manager.md"; note="Archived duplicate to prune active surface" },
  [pscustomobject]@{ name="swarm-planner"; archivedPath="C:\Users\ramos\.config\opencode\.archive\2026-04-11-token-reduction\agents\swarm-planner.md"; note="Archived duplicate to prune active surface" },
  [pscustomobject]@{ name="swarm-reviewer"; archivedPath="C:\Users\ramos\.config\opencode\.archive\2026-04-11-token-reduction\agents\swarm-reviewer.md"; note="Archived duplicate to prune active surface" },
  [pscustomobject]@{ name="swarm-tester"; archivedPath="C:\Users\ramos\.config\opencode\.archive\2026-04-11-token-reduction\agents\swarm-tester.md"; note="Archived duplicate to prune active surface" }
)

# 6) Not hooked (2)
$notHooked = @(
  [pscustomobject]@{ name="debug"; reason="Auxiliary utility not integrated into MM-router flow" },
  [pscustomobject]@{ name="local-implementor"; reason="Local helper not wired to pipeline stages" }
)

# Write agents.json
$payload = [pscustomobject]@{ active=$activeAgents; archived=$archivedAgents; not_hooked=$notHooked }
$payload | ConvertTo-Json -Depth 6 | Out-File -FilePath $agentsPath -Encoding utf8 -Force

# 7) Write agent-flow.md
$agentFlow = @"
# Agent flow hierarchy rooted at MM-router

This document defines the canonical agent flow MM-router orchestrates, from intake to execution, with Not hooked flags for non-flow items.

MM-Router → Phase 1: Research
- Hooked: mm-researcher
- Visual UX hook (optional): media-interpreter
- Output artifacts: research-analysis.json, phase-summary.json, run.status.json

Phase 2: Investigate
- Hooked: mm-investigator
- Optional: codesight (codebase analysis)

Phase 3: Handoff
- Hooked: multimodel-architect (planning)
- Hooked: mm-handoff-writer (handoff metadata)

Phase 4: Review
- Hooked: mm-reviewer

Phase 5: Implement
- Hooked: cc-implementor, fc-implementor, fb-implementor (depending on model tier)
- Optional: fc-planner

Phase 6: Test
- Hooked: mm-scene-tester or mm-tester

Not-hooked agents (example): debug, local-implementor
- Reasons: auxiliary/unsupported in canonical MM-router flow

ASCII diagram
      +----------- MM-Router --------------
      |                                   |
      v                                   v
  mm-researcher -> mm-investigator -> multimodel-architect -> mm-handoff-writer -> mm-reviewer -> cc-implementor/fc-implementor/fb-implementor -> mm-tester
      |______________________________________________^

End of flow document
"@
$agentFlow | Out-File -FilePath $agentFlowPath -Encoding utf8 -Force

# 8) Write skills.json (14 items)
$skills = @(
  [pscustomobject]@{ name="antivibe"; origin="opencode"; path="C:\Users\ramos\.config\opencode\skills\antivibe"; notes="Anti-vibecoding learning framework" },
  [pscustomobject]@{ name="context"; origin="opencode"; path="C:\Users\ramos\.config\opencode\skills\context"; notes="Context management" },
  [pscustomobject]@{ name="context7"; origin="opencode"; path="C:\Users\ramos\.config\opencode\skills\context7"; notes="Documentation-oriented context" },
  [pscustomobject]@{ name="graphify"; origin="opencode"; path="C:\Users\ramos\.config\opencode\skills\graphify"; notes="Knowledge graph from code/docs" },
  [pscustomobject]@{ name="ori-memory"; origin="opencode"; path="C:\Users\ramos\.config\opencode\skills\ori-memory"; notes="Ori-memory MCP tools" },
  [pscustomobject]@{ name="smart-router-skill"; origin="opencode"; path="C:\Users\ramos\.config\opencode\skills\smart-router-skill"; notes="Smart routing behavior" },
  [pscustomobject]@{ name="task-management"; origin="opencode"; path="C:\Users\ramos\.config\opencode\skills\task-management"; notes="Task management toolkit" },
  [pscustomobject]@{ name="caveman"; origin="global"; path="C:\Users\ramos\.agents\skills\caveman"; notes="Ultra-efficient communication" },
  [pscustomobject]@{ name="caveman-commit"; origin="global"; path="C:\Users\ramos\.agents\skills\caveman-commit"; notes="Compact commit messages" },
  [pscustomobject]@{ name="caveman-compress"; origin="global"; path="C:\Users\ramos\.agents\skills\caveman-compress"; notes="Memory compression" },
  [pscustomobject]@{ name="caveman-help"; origin="global"; path="C:\Users\ramos\.agents\skills\caveman-help"; notes="Caveman quick reference" },
  [pscustomobject]@{ name="caveman-review"; origin="global"; path="C:\Users\ramos\.agents\skills\caveman-review"; notes="Ultra-compressed code review" },
  [pscustomobject]@{ name="find-skills"; origin="global"; path="C:\Users\ramos\.agents\skills\find-skills"; notes="Skill discovery" },
  [pscustomobject]@{ name="ui-ux-pro-max"; origin="global"; path="C:\Users\ramos\.agents\skills\ui-ux-pro-max"; notes="UI/UX design intelligence" }
)
$skills | ConvertTo-Json -Depth 4 | Out-File -FilePath $skillsPath -Encoding utf8 -Force

# 9) Write MCP env annex
$mcpAnnex = @(
  [pscustomobject]@{ Name="Godot"; GODOT_EXECUTABLE="C:\Users\ramos\tools\godot\Godot_v4.6.1-stable_mono_win64.exe" },
  [pscustomobject]@{ Name="Codesight"; CMD="npx codesight --mcp" },
  [pscustomobject]@{ Name="Ori"; ORI_VAULT="C:\Users\ramos\.ori-memory"; ORI_BRIDGE="C:\tmp\ori-bridge\dist\index.js"; VAULT_MOUNT="C:\Users\ramos\.ori-memory" }
)
$mcpAnnex | ConvertTo-Json -Depth 4 | Out-File -FilePath $mcpAnnexPath -Encoding utf8 -Force

# 10) Write dupe-cleanup.md
$dupeContent = @"
# Dupe-cleanup plan (aggressive pruning)

- Rationale: prune active duplicates to a single canonical source per role; preserve history in archived after patch.
- Action: move archived duplicates into an archived/ folder and mark as archived in the manifest.
- Outcome: 32 active agents, 5 archived duplicates, no functional loss to pipeline.
- How to audit: compare active vs archived lists, verify MM-router flow still reaches the intended agents.
"@
$dupeContent | Out-File -FilePath $dupeCleanupPath -Encoding utf8 -Force

Write-Host "Export refreshed. Review changes, commit, and push."