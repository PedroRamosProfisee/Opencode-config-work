# Step 10 — Handoff

## Goal

Write a durable `.deep_grilled/` artifact packet when the user asks for artifacts, handoff, or implementation readiness docs.

## Write location

Create project-local artifacts under:

```text
.deep_grilled/
```

If not in a project or write location is unclear, ask before writing.

If the project lives on another machine or no repo path is available, recommend a temp path:

```text
<OS temp>/deep-grilled-<slug>/.deep_grilled/
```

Clearly report the absolute path after writing.

## Recommended handoff packet

```text
.deep_grilled/
  artifact-index.md
  shared-understanding.md
  decision-graph.md
  open-questions.md
  assumptions.md
  risks.md
  stories.md
  acceptance-criteria.md
  architecture-map.md
  spec-stubs.md
  market-viability.md
  customer-evidence.md
  competitor-matrix.md
  monetization-model.md
  pricing-hypotheses.md
  channel-scorecard.md
  unit-economics.md
  validation-plan.md
  kill-criteria.md
  adr-candidates/
  bdd-scenarios.md
  verification-plan.md
  readiness-score.md
  go-no-go-recommendation.md
```

## Minimal packet option

If the user wants lighter output, recommend:

```text
.deep_grilled/
  shared-understanding.md
  market-viability.md
  monetization-model.md
  validation-plan.md
  readiness-score.md
  go-no-go-recommendation.md
```

## Focused product/MVP packet

If the session produced a concrete product/MVP direction, recommend this focused packet:

```text
.deep_grilled/
  artifact-index.md
  shared-understanding.md
  go-no-go-recommendation.md
  market-viability.md
  monetization-model.md
  architecture-map.md
  validation-plan.md
  readiness-score.md
  risks.md
  assumptions.md
  open-questions.md
  acceptance-criteria.md
```

## Handoff rules

- Include source/evidence references where available.
- Mark assumptions explicitly.
- Do not pretend unknowns are resolved.
- Keep implementation instructions separate from market validation.
- Include a clear next action and owner.
- Include sample BDD/acceptance criteria only when implementation scope exists.
- Prefer focused packet unless the user explicitly asks for full artifact set.
- Include a “best file to read first” recommendation.
- If generated from a test run, include a short “what changed because of the grilling” summary in `shared-understanding.md` or `go-no-go-recommendation.md`.

## Final response after writing

```markdown
## Deep Grilled handoff created

Artifacts written to `.deep_grilled/`.

Most important file to read first: `.deep_grilled/go-no-go-recommendation.md`

My recommendation: <Go / Modify / Validate first / Do not build yet>

Next step: <concrete action>
```
