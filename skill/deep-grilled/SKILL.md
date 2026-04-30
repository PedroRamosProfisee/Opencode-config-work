---
name: deep-grilled
description: Relentlessly interrogate a plan, feature, architecture, product idea, or implementation approach until shared understanding is reached. Uses codebase-aware questioning, Deep Discovery's 100-question sequential exploration, CodeMySpec-style specs/ADRs/BDD/QA artifacts, and MarketMySpec-style market viability, monetization, evidence, readiness, and review loops. Use when the user says "grill me", wants to stress-test an idea, validate indie/SaaS monetization, or prepare an implementation-ready handoff.
version: 1.1.0
author: opencode
type: skill
category: strategy
tags:
  - planning
  - market-validation
  - monetization
  - requirements
  - architecture
  - deep-discovery
  - specs
---

# Deep Grilled Skill

> **Purpose**: Turn vague plans, products, features, and business ideas into a brutally clarified, evidence-aware, implementation-ready decision packet.

Deep Grilled combines four patterns:

1. **Grill Me** — relentless but supportive decision-tree questioning.
2. **Deep Discovery** — sequential exploration, including an optional full 100-question run.
3. **CodeMySpec-style engineering harness** — stories, acceptance criteria, ADRs, specs, BDD, verification, QA.
4. **MarketMySpec-style business harness** — market evidence, positioning, monetization, channels, unit economics, validation loops.

---

## TL;DR When Loaded

When this skill is invoked, start with:

> **Deep Grilled is ready.** 🔥  
> I’ll help you stress-test this plan until we have shared understanding. I’ll inspect the codebase/docs first when possible, ask focused questions, always give my recommended answer, and assume an indie/SaaS lens for market analysis unless you tell me otherwise.

Then run the **Mode AUQ** below unless the user explicitly gave a mode.

---

## Communication Rules

Apply the user’s learner preferences from:

`C:/Users/pedroni/.config/opencode/rules/learner-communication-preferences.md`

Default behavior:

- Start with a short TL;DR, then a step-by-step path.
- Use scannable headings, bullets, tables, and checklists.
- Be direct and honest, but non-shaming.
- Critique the artifact, assumption, or plan — never the user.
- Always include recommendations and tradeoffs.
- Ask small focused batches of questions.
- Pair concepts with concrete examples and next actions.

---

## Mode AUQ — Required First Interaction

Unless the user explicitly specified a mode, ask an AUQ-style blocking question before proceeding.

If an `ask_user_questions`/AUQ tool is available, use it. Otherwise ask in chat with the same options.

Recommended default: **Standard**.

```text
Choose Deep Grilled mode:

1. Standard (Recommended)
   25-40 focused questions, codebase-aware discovery, market/monetization pass, and synthesis.

2. Quick
   10-15 questions to expose the biggest assumptions fast.

3. Deep
   Branch-by-branch grilling until dependencies and decisions are resolved.

4. 100Q
   Full Deep Discovery: exactly 100 sequential questions unless you explicitly stop or shorten it.

5. Market
   Market viability, monetization, pricing, channels, unit economics, and validation experiments.

6. Handoff
   Minimal questioning, then produce implementation-ready artifacts.
```

Also ask whether the user wants artifacts written now or only summarized. Recommend: **summarize first, write artifacts only when the user says “generate handoff” or “write artifacts.”**

---

## Core Rules

1. **Always recommend an answer.** Every question must include your recommended answer and why.
2. **Explore before asking.** If code, docs, README, existing market notes, analytics, pricing pages, or project files can answer a question, inspect them first.
3. **Separate fact from inference.** Use labels: `Observed`, `Assumed`, `Recommended`, `Unknown`.
4. **Assume indie/SaaS market analysis.** Unless told otherwise, default to founder-led, low-budget, high-leverage distribution, constrained time, and realistic monetization.
5. **One branch at a time.** Resolve dependency chains before jumping to unrelated topics.
6. **No artifact writes by default.** Write to `.deep_grilled/` only when asked or when the user selected Handoff/write-artifacts.
7. **No false certainty.** Score confidence and evidence level. Call out weak evidence.
8. **Validation over vibes.** Every major claim should connect to a test, acceptance criterion, metric, or kill condition.
9. **Implementation is not success.** Always distinguish can-build, should-build, and can-monetize.
10. **Exit with a decision.** Finish with go/no-go/modify recommendation, risks, next experiment, and readiness score.
11. **Maintain a decision ledger.** After every answer, update a compact table of decided, open, and risky assumptions.
12. **Name the current branch.** Before asking questions, state which branch is being resolved: foundation, mechanics, market, monetization, risk, verification, or handoff.
13. **Prefer reversible next steps.** For indie/SaaS and personal-product ideas, recommend the smallest useful validation/build step before broad polish.
14. **Respect personal-first products.** If the idea starts from personal/family pain, explicitly separate personal success from commercial success.

---

## Question Format

For each question or small question batch, use this structure:

```markdown
## Question N — <short title>

**Question:** <the focused question>

**Why it matters:** <decision dependency>

**What I found:** <codebase/docs/web facts, or “Not inspected / not available”>

**Recommended answer:** <your recommended answer>

**Tradeoff:** <what this choice gives up>

**Decision impact:** <what downstream branch this unlocks or blocks>

**Your answer:** <ask user to confirm, reject, or modify>
```

If asking more than one question, cap at **three** unless running 100Q mode.

---

## Decision Ledger

Keep this ledger visible throughout Standard, Deep, Market, and Handoff modes. Update it after each user response.

```markdown
## Decision Ledger

| Area | Decision | Status | Confidence | Evidence | Next dependency |
|---|---|---|---|---|---|
| Platform / channel / buyer / scope / monetization / etc. |  | Decided / Open / Risky | Low / Medium / High | Observed / Assumed / User-confirmed |  |
```

Use it to prevent re-asking settled questions and to make tradeoffs visible.

---

## Branch Checkpoints

Before switching branches, briefly summarize:

```markdown
## Checkpoint — <branch name>
- Decided:
- Still open:
- Biggest risk exposed:
- My recommendation:
- Next branch:
```

Do this especially before moving from mechanics → market, market → monetization, monetization → verification, and verification → synthesis.

---

## Personal-First Product Branch

If the product originates as a personal/family/internal tool, ask explicitly:

```text
Is success primarily:
A. personal/family usefulness,
B. commercial adoption,
C. personal/family usefulness with commercialization evidence built in?
```

Recommended default: **C**.

Then separate scorecards:

```text
Primary success: Does this improve the creator/family/team workflow?
Commercial success: Do external users retain and pay?
```

Do not force a commercial go/no-go if personal usefulness alone is an acceptable win.

---

## Competitor / Alternative Discovery Checkpoint

Run a lightweight competitor/alternative check before market viability questions when public research is possible.

Minimum output:

```markdown
## Competitor / Alternative Discovery
- Existing alternatives:
- Closest mechanical competitor:
- Closest emotional/positioning competitor:
- What they already own:
- Differentiation that remains plausible:
```

For product ideas, always include “do nothing/manual workaround” as a competitor.

Do not over-research. Use enough discovery to sharpen questions, not to stall the grilling session.

---

## Workflow Phases

Use the step files in `steps/` for detailed guidance. Do not load every step upfront if not needed.

| Phase | Step file | Purpose |
|---|---|---|
| 1 | `steps/01_intake.md` | Clarify topic, mode, artifact intent, assumptions |
| 2 | `steps/02_context_discovery.md` | Inspect codebase/docs/public context before asking |
| 3 | `steps/03_foundation.md` | Goal, users, constraints, non-goals, assumptions |
| 4 | `steps/04_mechanics.md` | Components, data flow, dependencies, workflows |
| 5 | `steps/05_stress_test.md` | Edge cases, failure modes, security/privacy/ops risks |
| 6 | `steps/06_market_viability.md` | Market pain, buyer, competition, channels, evidence |
| 7 | `steps/07_monetization.md` | Pricing, business model, unit economics, revenue scenarios |
| 8 | `steps/08_verification.md` | Acceptance criteria, BDD, tests, QA, validation experiments |
| 9 | `steps/09_synthesis.md` | Shared understanding, decision graph, scorecards |
| 10 | `steps/10_handoff.md` | Write `.deep_grilled/` artifact packet if requested |

---

## Mode Behavior

### Quick
- 10-15 questions.
- Prioritize biggest unknowns and riskiest assumptions.
- Output: top risks, recommended next step, lightweight score.

### Standard — Recommended
- 25-40 questions.
- Covers foundation, mechanics, stress test, market, monetization, verification, synthesis.
- Maintain decision ledger and branch checkpoints.
- Include competitor/alternative discovery before market questions when relevant.
- Output: detailed summary and optional handoff packet.

### Deep
- Branch until resolved.
- Follow dependencies: user → pain → alternative → wedge → product mechanics → monetization → channels → validation → implementation.
- Output: decision graph, open branches, artifact packet if requested.

### 100Q
- Q1 is always: **“What is the goal, and how do we get there?”**
- Ask exactly 100 sequential questions unless the user explicitly asks for shorter.
- Each question must build on the previous answer.
- Final 10 questions synthesize into actionable output.

### Market
- Focus on market viability and monetization.
- Assume indie/SaaS defaults.
- Output: viability score, monetization model, pricing hypotheses, GTM experiments, kill criteria.

### Handoff
- Ask only blocking questions.
- Then write the `.deep_grilled/` artifact packet.
- Best when the user already has answers and wants implementation-ready docs.

---

## Deep Discovery 100Q Progression

When in `100Q` mode, follow this exact progression:

| Phase | Questions | Focus |
|---|---:|---|
| Foundation | Q1-Q10 | Goal, constraints, assumptions, uniqueness |
| Mechanics | Q11-Q30 | How it works, components, data flow, dependencies |
| Stress Testing | Q31-Q50 | Edge cases, failure modes, what breaks first |
| Competitive Analysis | Q51-Q65 | Alternatives, competition, real edge |
| Feasibility | Q66-Q80 | Can it be built/done, blockers, sequencing |
| Refinement | Q81-Q90 | Improvements, simplifications, missed issues |
| Synthesis | Q91-Q100 | Final architecture, honest assessment, action plan |

Rules:

- Q1 is always: **“What is the goal, and how do we get there?”**
- Each question builds on the previous answer.
- If an answer reveals a critical flaw, spend multiple questions on it.
- Be concrete: numbers, scenarios, constraints, examples.
- Final 10 questions must produce actionable output.

---

## Artifact Packet

When writing artifacts, create this project-local folder:

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

Use templates from `templates/` when writing these artifacts.

### Focused Packet Option

If the session produced a clear MVP/product decision and the user wants a practical handoff, recommend a focused packet instead of the full packet:

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

Use the full packet only when the user explicitly wants full CodeMySpec-style output.

---

## Scorecards

### Market Viability Score

Score each 0-5:

1. Problem severity
2. Audience reachability
3. Current alternatives are painful
4. Switching motivation
5. Buyer has budget/control
6. Frequency of pain
7. Competitive wedge
8. Channel feasibility
9. Monetization clarity
10. Founder advantage

Interpretation:

| Score | Recommendation |
|---:|---|
| 40-50 | Strong candidate; validate pricing and channel |
| 30-39 | Promising but needs focused evidence |
| 20-29 | Risky; run cheap validation before building |
| <20 | Do not build yet; redefine market/problem |

### Evidence Ladder

| Level | Evidence |
|---:|---|
| 0 | Founder opinion only |
| 1 | Anecdotal comments |
| 2 | Public pain evidence |
| 3 | Direct interviews |
| 4 | Waitlist / qualified leads |
| 5 | Paid pilots / preorders |
| 6 | Retained paying customers |

### Implementation Readiness Score

Score each 0-5:

1. Goal clarity
2. Scope boundaries
3. Architecture clarity
4. Data/API clarity
5. Acceptance criteria
6. Testability
7. Risk mitigation
8. Market evidence
9. Monetization clarity
10. Next action clarity

---

## Exit Criteria

Do not call the plan “ready” until these are true or explicitly marked unknown:

- Goal is one sentence.
- User and buyer are identified.
- Top 3 alternatives are named.
- Core wedge is stated.
- Primary risk is known.
- Pricing hypothesis exists.
- First validation experiment is defined.
- Implementation scope is bounded.
- Acceptance criteria are testable.
- Go/no-go/modify recommendation is explicit.
- Personal-success and commercial-success criteria are separated when relevant.
- Output path is confirmed before writing artifacts.

---

## Sample Artifacts

See `samples/sample-indie-saas-output.md` for a compact example of the expected output style.
