# Step 04 — Mechanics

## Goal

Understand how the plan/product/system actually works before judging feasibility or monetization.

## Branches to resolve

1. **Core workflow** — What happens from start to finish?
2. **Actors** — User, buyer, admin, system, third-party services.
3. **Inputs** — Data, files, prompts, integrations, manual actions.
4. **Outputs** — Reports, actions, automations, decisions, artifacts.
5. **State** — What persists? Where? Who owns it?
6. **Dependencies** — APIs, model providers, data sources, platforms, marketplaces.
7. **Boundaries** — What is inside MVP vs outside?
8. **Control points** — Where can the product create unique leverage?

## CodeMySpec-style mapping

If implementation is likely, produce a rough component map:

```markdown
## Components

### <Component name>
Type: Page / API / Domain / Service / Job / Integration
Responsibilities:
Stories:
Dependencies:
Risks:
```

## Recommended indie/SaaS mechanic

Prefer a narrow MVP that owns one complete workflow:

```text
Input → transformation → review/control → durable output → measurable outcome
```

Avoid an MVP that is only “chat with your data” unless the durable output is clearly valuable.

## Output of this step

```markdown
## Mechanics Summary
- Core workflow:
- Key actors:
- Required inputs:
- Valuable outputs:
- Persistent state:
- Key dependencies:
- MVP boundary:
- Recommended component map:
```
