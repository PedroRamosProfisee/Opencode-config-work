# Cost Tracking — Shared Reference

This document defines the **cost tracking schema** used across all pipeline subagents.
Every subagent result JSON **must** include a `cost` block.
Every coordinator **must** roll up costs into `run.status.json` and `cost-summary.json`.

---

## Model Pricing Registry

| Model ID | Provider | Input ($/1K tokens) | Output ($/1K tokens) | Tier |
|----------|----------|---------------------|----------------------|------|
| `github-copilot/gpt-4o` | OpenAI | $0.0000 | $0.0000 | Free |
| `github-copilot/gpt-4o` | OpenAI | $0.0000 | $0.0000 | Free |
| `github-copilot/gpt-4o` | OpenAI | $0.0000 | $0.0000 | Free |
| `github-copilot/claude-haiku-4.5` | Anthropic | $0.0008 | $0.004 | Cheap |
| `github-copilot/claude-sonnet-4.6` | Anthropic | $0.003 | $0.015 | Premium |
| `github-copilot/claude-opus-4.6` | Anthropic | $0.015 | $0.075 | Premium |

> **Note:** Free-tier models (gpt-4o) are billed $0.00 via GitHub Copilot quota.
> Haiku/Sonnet/Opus are estimated based on Anthropic public pricing per 1K tokens.
> Token counts are **estimates** — count input prompt length + output length.
>
> **Opus 4.6 Fallbacks:** Agents that use Opus 4.6 have automatic fallback chains defined in their
> `fallback_models` frontmatter field. If Opus 4.6 fails, the agent retries with the fallback model.
> The mm-router stores the user's `modelTier` choice ("standard" | "enhanced") in run.status.json
> so coordinators know which model each reasoning agent should use per-run.

---

## Token Estimation Rules

Since exact token counts are not always available, use these approximations:

- **1 token ≈ 4 characters** (English text)
- **Input tokens** = characters in prompt sent to subagent ÷ 4
- **Output tokens** = characters in response from subagent ÷ 4
- Round to nearest 100 for clarity

---

## Cost Block Schema (per subagent result)

Every subagent must include this block in its result JSON:

```json
"cost": {
  "model": "github-copilot/claude-sonnet-4.6",
  "tier": "premium",
  "inputTokens": 1200,
  "outputTokens": 800,
  "inputCostUSD": 0.0036,
  "outputCostUSD": 0.0120,
  "totalCostUSD": 0.0156,
  "note": "Estimates based on 4 chars/token approximation"
}
```

### Fields

| Field | Type | Description |
|-------|------|-------------|
| `model` | string | Full model ID used |
| `tier` | string | `free` \| `cheap` \| `premium` |
| `inputTokens` | number | Estimated input token count |
| `outputTokens` | number | Estimated output token count |
| `inputCostUSD` | number | inputTokens × (input rate / 1000) |
| `outputCostUSD` | number | outputTokens × (output rate / 1000) |
| `totalCostUSD` | number | inputCostUSD + outputCostUSD |
| `note` | string | Optional explanation or flag |

---

## Cost Rollup in run.status.json

Coordinators must accumulate costs from all subagents into `run.status.json`:

```json
"costRollup": {
  "totalCostUSD": 0.0412,
  "byAgent": {
    "cc-planner": 0.0156,
    "cc-implementor-task-1": 0.0000,
    "cc-implementor-task-2": 0.0000,
    "cc-tester": 0.0000,
    "cc-reviewer": 0.0256
  },
  "byTier": {
    "free": 0.0000,
    "cheap": 0.0256,
    "premium": 0.0156
  },
  "tokenTotals": {
    "inputTokens": 8400,
    "outputTokens": 3200
  }
}
```

---

## cost-summary.json (Written at End of Run)

Coordinators write this to `.runs/{runId}/cost-summary.json` on completion:

```json
{
  "schemaVersion": "2.0",
  "runId": "{runId}",
  "system": "cc",
  "completedAt": "ISO 8601",
  "totalCostUSD": 0.0412,
  "breakdown": [
    {
      "step": "planning",
      "agent": "cc-planner",
      "model": "github-copilot/claude-sonnet-4.6",
      "tier": "premium",
      "inputTokens": 1200,
      "outputTokens": 800,
      "costUSD": 0.0156
    },
    {
      "step": "implementation",
      "agent": "cc-implementor",
      "taskId": "task-1",
      "model": "github-copilot/gpt-4o",
      "tier": "free",
      "inputTokens": 2100,
      "outputTokens": 900,
      "costUSD": 0.0000
    },
    {
      "step": "testing",
      "agent": "cc-tester",
      "model": "github-copilot/gpt-4o",
      "tier": "free",
      "inputTokens": 800,
      "outputTokens": 400,
      "costUSD": 0.0000
    },
    {
      "step": "review",
      "agent": "cc-reviewer",
      "model": "github-copilot/claude-haiku-4.5",
      "tier": "cheap",
      "inputTokens": 2400,
      "outputTokens": 600,
      "costUSD": 0.0256
    }
  ],
  "byTier": {
    "free": 0.0000,
    "cheap": 0.0256,
    "premium": 0.0156
  },
  "insights": {
    "mostExpensiveStep": "review",
    "freeStepsCount": 3,
    "paidStepsCount": 2,
    "estimationMethod": "4-chars-per-token"
  }
}
```

---

## How Subagents Calculate Their Cost

### Step-by-step

1. **Record model used** — from your frontmatter
2. **Estimate input tokens** — length of prompt you received ÷ 4
3. **Estimate output tokens** — length of your response ÷ 4
4. **Look up rates** from the pricing registry above
5. **Calculate**:
   - `inputCostUSD = inputTokens * (inputRate / 1000)`
   - `outputCostUSD = outputTokens * (outputRate / 1000)`
   - `totalCostUSD = inputCostUSD + outputCostUSD`
6. **Add cost block** to your result JSON
7. **Report** cost in summary to Coordinator

### Free tier calculation

For `gpt-4o` — all rates = $0.00.
Still record token estimates for pipeline analysis (parallel efficiency, context sizing).

---

## How Coordinators Roll Up Costs

After each subagent completes:

1. Read result JSON
2. Extract `cost.totalCostUSD`
3. Add to running `costRollup.totalCostUSD`
4. Add to `costRollup.byAgent[agentName]`
5. Add to `costRollup.byTier[tier]`
6. Update `run.status.json` with latest `costRollup`

At end of run:
1. Compute final totals
2. Build `breakdown` array from all agent results
3. Identify `mostExpensiveStep`
4. Write `cost-summary.json`
