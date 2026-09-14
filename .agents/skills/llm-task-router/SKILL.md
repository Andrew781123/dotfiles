---
name: llm-task-router
description: >-
  Routes a coding task to the best LLM and reasoning effort level from the user's available models.
  Use when the user asks "which model for X", "pick model for X", "what LLM should I use for X",
  "/llm-route X", or wants to choose the right model + effort for a given task.
  Reads llm-list.yaml and recommends the model and its exact effort variant.
---

# llm-task-router — Model & Effort Router

You recommend which model to use and at what reasoning effort for a given coding task. The two are **independent knobs**: pick a model, then pick the effort value *that model actually accepts*.

## Trigger

`/llm-task-router` or: "which model for X", "pick a model for X", "what LLM for X", "route this task: X".

## Workflow

### 1. Load the model list

Read `llm-list.yaml` from this skill's directory (`~/.agents/skills/llm-task-router/llm-list.yaml`). If missing, ask the user for their models.

### 2. Two signals only

**Complexity** — how hard is the task? Drives *effort*.
- `simple` — mechanical: rename, typo, config edit, formatting, small doc change.
- `normal` — a typical change: single-file feature, straightforward bug fix, tests, refactor.
- `complex` — cross-cutting, uncertain, or reasoning-heavy: architecture, multi-file redesign, concurrency, hard debugging, novel algorithms.

**Capability** — hard constraints that filter *models*, not effort:
- context size (large repo / huge file → prefer 1M-context models)
- vision (image/screenshot input → model must accept images)
- sensitivity (proprietary or secret code → exclude any model without `privacy: private`)

### 3. Complexity → effort

| Complexity | Effort | Examples |
|-----------|--------|----------|
| simple | **low** | renames, config, formatting, docs |
| normal | **medium** | single-file features, standard bug fixes, tests |
| complex | **high** | architecture, cross-system debugging, hard concurrency |

Overrides (win over the table):
- Any bug in **production** → at least `normal`.
- **Security-sensitive** code → `complex` (high effort).
- User says "quick"/"just" → `simple`; "careful"/"thorough" → `complex`.

Effort is not free: high effort costs latency and tokens and can make simple tasks *worse*. Default to the table; do not reach for max unless the task is complex.

### 4. Effort → the model's own vocabulary

Each model accepts a different set of effort values (`effort:` in the YAML). Translate, don't emit a value the model rejects:
- **low** → `low`, `minimal`, or off (whichever the model allows)
- **medium** → `medium` if present; otherwise the nearest allowed value — prefer `high` for coding, and say so
- **high** → `high`, `max`, or `xhigh`

If a model's `effort` is `off` (no reasoning control), keep it for simple/normal tasks only and say effort is not adjustable.

### 5. Pick the model

Filter by the **capability** constraints from step 2, then choose the best `tier` match:
- simple → **light**
- normal → **standard**
- complex → **heavy**

Within a tier, prefer the lower-cost model that fits; if two tie, prefer the faster one. Give 1–2 alternatives. This is a best-model recommendation — it does **not** track your live quota (the router has no usage feed). If the pick is quota-blocked, fall back to its `also_on` provider or the next alternative.

### 6. Free-model guard

Models with `privacy:` other than `private` (the whole `opencode/` free tier, the `*-contributor` tiers, CommandCode's `:free` models) may log or train on your input. If the code is proprietary or secret, exclude them and say why.

### 7. Output

```
Task: <one line>
Tier: light | standard | heavy
Model: <provider>/<id>
Effort: <translated value>
Why: <one sentence>
Alternatives:
- <model> — <tradeoff>
- <model> — <tradeoff>
```

No command syntax — the user assembles the flags. If the task is borderline, add one line: "If this gets harder than expected, escalate to <heavier model + effort>."

## Examples

| Task | Complexity | Tier | Model + effort |
|------|-----------|------|----------------|
| Rename `getUserById` | simple | light | free model or `mimo-v2.5`, no/low effort |
| Add validation to signup | normal | standard | `deepseek-v4.1-flash`, effort `high` |
| Write unit tests for utils | normal | standard | `deepseek-v4.1-flash`, effort `high` |
| Fix production race in payment | complex | heavy | `deepseek-v4-pro`, effort `max` |
| Design new auth architecture | complex | heavy | `grok-4.6` or `qwen3.8-max`, effort `high` |
| Debug memory leak, need vision of flamegraph | complex | heavy | `qwen3.8-flash` (image) or `deepseek-v4-flash-vision-exp`, effort `high` |

## Keeping the list fresh

`llm-list.yaml` rots: models appear, get retired, and change their effort values and prices. When the list looks stale, refresh it from live data instead of guessing:

- `opencode models` — current model IDs per provider (`opencode-go/`, `opencode/` free, `commandcode/`).
- `~/.cache/opencode/models.json` — per-model `cost`, `limit.context`, `modalities`, and `reasoning_options` (the allowed effort values).

Rewrite `llm-list.yaml` from those two sources. Prices are per 1M tokens; the light/standard/heavy bands follow blended agentic cost (cache-read dominates), not input price alone.

## Edge cases

- **Ambiguous**: ask one clarifying question; don't guess.
- **No model fits capability**: name the closest and state the gap.
- **User pushes back**: respect it, offer the alternative with a one-line reason.
