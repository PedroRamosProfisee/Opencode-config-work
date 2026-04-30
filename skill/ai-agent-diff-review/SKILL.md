---
name: ai-agent-diff-review
description: Adversarial review workflow for AI-agent-generated code changes, focused on hallucinations, prompt drift, shallow tests, and integration risk
version: 1.0.0
author: pedroni
type: skill
category: development
tags:
  - code-review
  - ai-generated-code
  - agents
  - testing
  - verification
  - hallucination-check
---

# AI Agent Diff Review Skill

> **Purpose**: Review AI-agent-generated code as plausible-but-untrusted output. Verify real behavior, project fit, tests, and integration boundaries before accepting the change.

---

## When to Use This Skill

Load this skill when reviewing code produced by:

- OpenCode agents
- Claude/Copilot/Cursor/ChatGPT/Codex-style coding agents
- automated refactoring agents
- AI-generated PRs or local diffs

Example triggers:

- "Review this agent diff"
- "Check the AI's changes"
- "Adversarially review this generated code"
- "Did the agent hallucinate anything?"
- "Validate this OpenCode agent output"

---

## Core Principle

AI code can be syntactically clean and semantically wrong.

Do not ask only:

> Is this code readable?

Ask:

> Does this actually solve the stated problem correctly, safely, minimally, and in this codebase's conventions?

---

## Required Output Format

```md
# AI-Agent Diff Review

## 1. Task vs Diff Alignment
- Original task:
- What the diff appears to do:
- Alignment verdict:

## 2. Changed-File Risk Map
| File | Role | Risk | Why |
|---|---|---|---|

## 3. Hallucination & Plausibility Checks
- Nonexistent APIs/imports/types:
- Framework behavior assumptions:
- Project convention mismatches:
- Suspicious generated patterns:

## 4. Integration Checks
- Config/DI/container:
- Migrations/schema/data compatibility:
- Auth/permissions/security:
- CI/build/test pipeline:
- Error handling/observability:

## 5. Test Quality Review
- Existing tests impacted:
- New tests quality:
- Shallow/assertion-free tests:
- Missing edge cases:

## 6. Active Verification Plan
- Command to run:
- Manual/debug path:
- One adversarial test:

## 7. Findings
### Blockers
- ...

### Suggestions
- ...

### Safe to ignore / nits
- ...

## 8. Retention Capture
- Agent failure pattern observed:
- Heuristic to remember:
```

---

## AI-Specific Checklist

Apply this checklist before approval:

- [ ] Every API/function/type/import exists in this codebase or official docs.
- [ ] The change solves the exact requested task, not a neighboring problem.
- [ ] No unrelated file churn or hidden refactor.
- [ ] No unnecessary abstraction, dependency, framework, or config change.
- [ ] Error paths are handled.
- [ ] Auth/security/permission boundaries are preserved.
- [ ] Null/empty/invalid/duplicate/timeout/retry/concurrency cases considered.
- [ ] Tests assert meaningful behavior, not just construction or snapshots.
- [ ] At least one adversarial test/input is proposed.
- [ ] Build/test command is known or requested.
- [ ] Existing project patterns are followed.

---

## Fast Review Prompt

Use this prompt when asking an assistant to review an AI diff:

```md
Adversarially review this AI-generated diff.

Prioritize:
- hallucinated APIs/imports/framework behavior
- task/diff mismatch or prompt drift
- plausible but wrong logic
- unnecessary abstraction or unrelated churn
- missing edge cases
- shallow tests
- config/DI/migration/CI integration gaps
- auth/security/error-path regressions

Output:
1. changed-file risk map
2. top blockers
3. top suggestions
4. one command/manual path to verify
5. one adversarial test to add
6. one reusable heuristic from this review
```

---

## Common AI Failure Patterns

Watch especially for:

- invented APIs that look idiomatic
- wrong overloads or wrong async behavior
- partial refactors that leave old call sites broken
- tests that assert mocks rather than behavior
- duplicated logic instead of using existing utilities
- over-generalized abstractions for one-off needs
- config/migration changes not reflected in deployment/CI
- silent catch blocks or swallowed errors
- security-sensitive defaults added without review

---

## Behavior Rules

- Be skeptical but not performative.
- Prefer verification over speculation.
- If code is unavailable, ask for diff/stat/files and original prompt.
- Always separate blocker from suggestion.
- Always include one active probe or adversarial test.
- End with one reusable agent-review heuristic.
