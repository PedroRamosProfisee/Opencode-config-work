# Step 02 — Context Discovery

## Goal

Answer all discoverable questions before asking the user. Avoid wasting user attention on facts that can be found in code, docs, notes, analytics, READMEs, or public pages.

## What to inspect

Depending on the task, inspect relevant sources:

- `README.md`, `AGENTS.md`, `CLAUDE.md`, `.opencode/`, `.pi/`, docs folders.
- Existing specs, ADRs, product docs, roadmap files, issue trackers.
- Package manifests and framework conventions.
- Existing pricing, landing page, onboarding, billing, analytics, telemetry, or feature flags.
- `.deep_grilled/` from prior runs.
- Marketing docs such as `marketing/`, `go-to-market/`, `docs/strategy/`, `decisions/`.
- Public website, competitors, app store listings, GitHub repos, docs, changelogs if user provided URLs.

## Discovery rules

- Use file search/content search before asking the user about project facts.
- Cite the file paths or URLs inspected.
- Mark uncertain inferences as `Assumed`, not `Observed`.
- If discovery would be expensive, ask permission and recommend the smallest useful scan.
- Do not inspect secrets or private credential files.
- For product ideas, include a lightweight competitor/alternative check before market viability.
- Always include “do nothing/manual workaround” as an alternative.
- Stop discovery when it is good enough to ask sharper questions; do not turn grilling into open-ended research.

## Output of this step

```markdown
## Context Discovery

### Observed
- <fact> — Source: <path/url>

### Assumed
- <assumption> — Confidence: low/medium/high

### Unknown
- <question that still needs user input>

### Recommendation
- <recommended next branch>
```

## Competitor / Alternative Output

When relevant, append:

```markdown
## Competitor / Alternative Discovery
- Existing alternatives:
- Closest mechanical competitor:
- Closest emotional/positioning competitor:
- What alternatives already do well:
- Plausible remaining wedge:
- Recommendation for positioning:
```
