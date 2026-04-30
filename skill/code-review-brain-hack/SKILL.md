---
name: code-review-brain-hack
description: Personal code-review operating system for Active-Visual-Kinesthetic review, retention, and structured diff walkthroughs
version: 1.0.0
author: pedroni
type: skill
category: development
tags:
  - code-review
  - learning
  - retention
  - checklist
  - active-learning
  - visual-thinking
---

# Code Review Brain Hack Skill

> **Purpose**: Review code in a way that fits an Active-7 / Intuitive-1 / Visual-5 / Sequential-3 and VARK Visual+Kinesthetic workflow: see the structure, act on the code, explain the reasoning, and retain one reusable lesson.

---

## When to Use This Skill

Load this skill when the user asks to:

- review a PR or diff using their preferred review flow
- understand changes an agent made
- retain learnings from a review
- walk through code review step by step
- produce a visual/structural review map
- convert a review into reusable heuristics or notes

Example triggers:

- "Use my review brain-hack skill on this diff"
- "Review this PR with my Active/Visual/VK flow"
- "Walk me through this code review and help me retain it"
- "Give me a visual map, active probe, and lesson learned"

---

## Evidence Stance

Do **not** claim that learning-style matching is scientifically proven. Treat Felder-Soloman and VARK as preference/friction signals.

The real mechanisms to leverage are:

- retrieval practice
- spacing
- dual coding
- self-explanation / elaboration
- generation effect
- deliberate practice
- checklists

Use the profile as a practical scaffold: the user tends to engage best when they can **see**, **do**, **sequence**, and **explain**.

---

## Core Review Loop

Always structure non-trivial reviews as:

1. **Map it** — intent, blast radius, changed files, execution order.
2. **Touch it** — run tests/app, debug, inspect logs, reproduce, or create an adversarial probe.
3. **Check it** — correctness, tests, security/privacy, performance, operability, maintainability.
4. **Explain it** — summarize what changed and why.
5. **Retain it** — capture one reusable lesson or heuristic.

For trivial changes, compress this to: intent -> risk -> finding -> lesson.

---

## Required Output Format

When applying this skill, respond using this structure unless the user asks otherwise:

```md
# Review Map

## 1. Intent & Blast Radius
- Goal:
- Changed areas:
- Risk level:
- Review order:

## 2. Visual / Structural Map
- Files by execution order:
- Call/data flow:
- Suspicious scope creep:

## 3. Active Probe
- One thing to run:
- One breakpoint/manual check:
- One adversarial test/input:

## 4. Review Findings
### Blockers
- ...

### Suggestions
- ...

### Nits
- ...

## 5. Context-Specific Pass
### AI-generated diff checks
- Hallucinated APIs/framework behavior:
- Prompt drift:
- Unnecessary abstraction/churn:
- Missing edge cases:

### Human PR checks
- Constructive questions:
- Clarifying asks:
- Suggested wording:

## 6. Retention Capture
- One reusable lesson:
- One heuristic:
- Obsidian/Anki note:
```

If no diff/code is available, produce a **review plan** in the same shape and ask for the diff/PR/files.

---

## Review Checklist

Use this checklist for every non-trivial review:

- [ ] Sketch before/after architecture or flow.
- [ ] Review tests first when possible.
- [ ] Review files in execution/dependency order, not alphabetical order.
- [ ] Run tests/app or identify the fastest useful command.
- [ ] Step through one critical path mentally or in debugger.
- [ ] Check stated intent vs actual implementation.
- [ ] Look for edge cases: null, empty, invalid, duplicate, timeout, retry, concurrency, auth, permission, data loss.
- [ ] Separate blockers, suggestions, and nits.
- [ ] Capture one reusable lesson.

---

## Prompt to Prepare a Diff for This User

When asking an AI/reviewer assistant to prepare a diff, use:

```md
Before I review this code, prepare it for my Active/Visual/Kinesthetic review flow.

Provide:
1. A mermaid call-flow or data-flow diagram of the changed components.
2. Files grouped by execution order: entry point -> logic -> data -> tests.
3. One sentence per file: what changed and why.
4. Top 3 risk areas.
5. Tests added, changed, removed, or missing.
6. One active probe I should run locally.
7. One adversarial test/input that might break this change.
8. One reusable lesson I should retain from this diff.
```

---

## Retention Ritual

After a meaningful review, perform the 3-minute retention capture:

1. Close the diff.
2. Recall from memory:
   - what changed
   - top risks
   - what you verified
3. Sketch the change quickly.
4. Explain aloud in one paragraph.
5. Save one note:

```md
## Review Lesson: <short title>

- Context:
- Pattern/smell:
- Why it matters:
- How to catch it next time:
- Example:
- Tags: #code-review #lesson
```

---

## Behavior Rules

- Prefer visual maps and ordered passes over long prose.
- Always include at least one concrete action the user can take.
- Do not over-index on style/nits before correctness and tests.
- For AI-generated diffs, be adversarial.
- For human PRs, be constructive and socially aware.
- End with a retention artifact whenever possible.
