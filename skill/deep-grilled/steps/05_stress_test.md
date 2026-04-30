# Step 05 — Stress Test

## Goal

Find what breaks first: technically, operationally, commercially, legally, and psychologically.

## Stress-test branches

1. **User failure** — User does not understand, trust, or complete the workflow.
2. **Data failure** — Input data is missing, messy, stale, biased, or inaccessible.
3. **Model failure** — AI output is wrong, slow, expensive, hallucinated, or inconsistent.
4. **Integration failure** — API limits, auth, platform changes, webhooks, billing failures.
5. **Economic failure** — Costs exceed willingness to pay.
6. **Distribution failure** — Buyer exists but cannot be reached affordably.
7. **Retention failure** — Useful once but not recurring.
8. **Competitive failure** — Incumbent adds feature, open source clone appears, switching cost too high.
9. **Trust/compliance failure** — Privacy, security, regulatory, reputational risk.
10. **Founder constraint failure** — Too much support, too much sales, too much maintenance.

## Recommended answer style

For each risk:

```markdown
Risk:
Likelihood: low/medium/high
Impact: low/medium/high
Evidence:
Mitigation:
Validation test:
Kill criterion:
```

## Default recommendation

For indie/SaaS, prioritize risks in this order:

1. Can we reach buyers?
2. Is the pain urgent enough to pay?
3. Can we deliver the promised outcome cheaply/reliably?
4. Will users repeat the behavior?
5. Can we defend or differentiate the wedge?

## Output of this step

```markdown
## Stress Test Summary
- Top risk:
- Second risk:
- Third risk:
- First cheap validation:
- Recommended mitigation:
- Current confidence:
```
