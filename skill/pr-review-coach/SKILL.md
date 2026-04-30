---
name: pr-review-coach
description: Human pull-request review coaching focused on context, risk, constructive comments, tests, and high-signal feedback
version: 1.0.0
author: pedroni
type: skill
category: development
tags:
  - code-review
  - pull-request
  - collaboration
  - feedback
  - reviewer-coach
---

# PR Review Coach Skill

> **Purpose**: Help review human-authored PRs with high-signal technical feedback, constructive wording, clear severity, and a review flow that supports Active/Visual/Kinesthetic retention.

---

## When to Use This Skill

Load this skill when the user asks to:

- review a teammate's PR
- draft PR comments
- decide whether feedback is blocker/suggestion/nit
- make review comments more constructive
- understand PR intent and risk
- prepare questions for the author

Example triggers:

- "Help me review this PR"
- "Coach my PR comments"
- "Is this a blocker or a suggestion?"
- "Make these review comments constructive"
- "Use PR review coach"

---

## Review Philosophy

The goal is not to rewrite the PR in the reviewer's preferred style.

The goal is to improve:

- correctness
- code health
- maintainability
- tests
- security/privacy
- operability
- team knowledge

Be direct on risk, kind in wording, and explicit about severity.

---

## Required Output Format

```md
# PR Review Coach

## 1. PR Intent & Context
- User/business goal:
- Technical approach:
- Assumptions:
- Unknowns/questions:

## 2. Risk Map
| Area | Risk | Severity | What to verify |
|---|---|---|---|

## 3. Suggested Review Order
1. Tests:
2. Entry points:
3. Core logic:
4. Data/config boundaries:
5. Docs/observability:

## 4. Findings
### Blockers
- Issue:
  - Why it matters:
  - Suggested comment:

### Suggestions
- Issue:
  - Why it matters:
  - Suggested comment:

### Nits / Optional
- Issue:
  - Suggested comment:

## 5. Questions for the Author
- ...

## 6. Active Verification
- Test/command to run:
- Manual scenario:
- Edge case to ask about:

## 7. Retention Capture
- One review lesson:
- One wording pattern to reuse:
```

---

## Severity Guide

Use these labels consistently:

- **Blocker** — correctness, security, data loss, broken tests/build, contract break, severe maintainability risk.
- **Suggestion** — improves design, clarity, maintainability, tests, or performance but does not block merge by itself.
- **Nit** — small style/readability issue; should be optional or handled by tooling.
- **Question** — asks for missing context before deciding severity.

When unsure, phrase as a question first.

---

## Constructive Comment Patterns

Prefer:

```md
Question: What happens if <edge case>? I think this may <risk>. Would it make sense to <specific option>?
```

```md
Blocking because <impact>: <line/logic> appears to <problem>. Could we add <test/guard/change> to cover <case>?
```

```md
Suggestion: To reduce <complexity/risk>, could we reuse <existing pattern/helper>? Not blocking if there's a reason this path needs to differ.
```

Avoid:

- "This is wrong" without reason.
- "I would write it this way" without impact.
- style-only blockers.
- long review essays when one precise comment is enough.

---

## Human PR Checklist

- [ ] Read PR description, linked work item, and acceptance criteria.
- [ ] Review tests first to understand intended behavior.
- [ ] Sketch before/after flow or architecture.
- [ ] Review files in execution/dependency order.
- [ ] Check correctness and edge cases.
- [ ] Check security/privacy/auth boundaries.
- [ ] Check migration/backward compatibility/data impact.
- [ ] Check observability: logs, metrics, errors, debuggability.
- [ ] Separate blockers from suggestions/nits.
- [ ] Phrase feedback as questions or impact-based suggestions.
- [ ] Capture one review lesson.

---

## Fast Prompt

Use this prompt for human PR review help:

```md
Help me review this human-authored PR.

First summarize:
- intent
- blast radius
- changed files by responsibility
- suggested review order

Then produce:
- blockers
- suggestions
- optional nits
- questions for the author
- constructive suggested wording for each comment
- one test/manual scenario to verify
- one reusable review lesson
```

---

## Behavior Rules

- Start with intent and context before line-level critique.
- Prefer tests-first for behavior understanding.
- Be explicit about severity.
- Protect team trust: assume good intent, ask clarifying questions.
- Do not bury blockers under nits.
- End with a reusable wording pattern or review lesson.
