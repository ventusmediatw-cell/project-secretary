---
name: plan-discuss
description: "Multi-model independent plan review — send a work plan to several independent reviewers from different model families, have the original agent merge their feedback into a revised plan, then a separate session does a final check. Make sure to use this skill whenever the user says 'have everyone discuss this / run a discuss round / discuss this plan / multi-model review / cross-family review' — even when they describe the same intent without these exact words. Weak trigger: the secretary may proactively offer a discuss round once a plan has taken shape. Does NOT trigger on casual 'let's discuss' small talk. **Does NOT handle**: binary yes/no decision face-offs → use debate-protocol (complementary). Pairs with handoff (shares the pending/done file relay) and wrap-up (downstream final review)."
disable-model-invocation: true
---

# plan-discuss Skill

A cross-project mechanism: send a work plan to several independent reviewers, have the original agent merge their feedback into a revised version, then have a separate session vet it.

> The value of multi-model review is not "find the majority consensus" — it is **catching cross-family signals**: when reviewers trained on different data with different architectures point at the same doubt from different angles, that is an underrated blind spot, worth more than two same-family votes agreeing.

## When to trigger

**Strong triggers** (enter this skill automatically):
- "have everyone discuss this"
- "run a discuss round"
- "discuss this plan"

**Weak trigger**: when the secretary judges a plan has taken shape, proactively offer "want to run a discuss round?"

## When NOT to trigger

- Casual phrases like "let's discuss the schedule later" — not an automatic trigger
- Binary yes/no decision face-offs → use `debate-protocol` (complementary)
- Mid-task self-reflection inside a single session → use `wrap-up`

---

## Role binding

| Role | Principle |
|------|-----------|
| **Plan Owner (original agent)** | The session that owns project context: produces the plan → writes the request → collects reviews → synthesizes → executes per the conclusion. Also acts as Synthesizer. |
| **Reviewer** | An independent, **user-initiated** session that reads the request and writes a review file. A cold start is ideal, but a session that already has secretary context is OK too — guide it with the "external perspective" framing in the briefing. |
| **Final Checker** | Yet another independent session that runs a must-fix checklist over the synthesis. |

⚠️ **Role prohibitions**:
- **Synthesizer ≠ Reviewer** (self-merging is biased) — distinguish via frontmatter `synthesizer-id` vs `reviewer-id`
- **Final Checker ≠ Synthesizer** (self-vetting fails) — enforced by the user manually opening a separate session
- **A sub-agent is not an independent session** — the parent session's prompt biases the sub-agent's framing. Reviewers must be user-initiated.

---

## Reviewer pool: pick across model families

The core rule: **diverse families beat varied sizes within one family.** Same-family / different-size models share blind spots (tokenizer mismatch, shared training data). Choose 3–4 reviewers from *distinct* model families (one each from different frontier providers), plus the Synthesizer.

A workable default is **N=4**: the Synthesizer (your main model) + 3 reviewers, each from a different family. Escalate to **N=5** for critical, expensive, or irreversible decisions.

**Cautions when picking reviewers**:
- Avoid models with high **sycophancy** (they echo the user instead of critiquing) — a fatal flaw in a reviewer.
- Avoid heavily quantized or stale-cutoff models — they hallucinate confidently on recent topics.
- If a reviewer model has a "thinking" / reasoning mode, enable it — non-thinking mode fails on long-context cross-section reasoning.

**Position bias protection (required)**: LLMs prefer options presented first (a strong, well-documented bias). When a review request lists multiple options/plans, **randomize the order**, and give each reviewer a *different* randomization.

---

## Flow (file relay)

```
[original agent]
   │ writes request
   ▼
handoff/pending/discuss-{date}-{time}-{shortname}.md
   │
   ├─→ user opens reviewer session 1 (family A) → writes review-a
   ├─→ user opens reviewer session 2 (family B) → writes review-b
   └─→ user opens reviewer session 3 (family C) → writes review-c
   │
   ▼ user returns to the original agent (Synthesizer)
[original agent: synthesizer]
   │ reads request + reviews → produces synthesis + final-check handoff
   ▼
handoff/pending/discuss-{...}-synthesis.md
handoff/pending/discuss-{...}-final-check-handoff.md
   │
   ▼ user opens a new session (or lets handoff auto-scan pick it up)
[Final Checker]
   │ runs checklist → writes verdict
   ▼
handoff/pending/discuss-{...}-final-check-{model}.md
   │
   ▼ ship-ready → user returns to the original agent, executes, archives the round to done/
```

### What the user actually does
1. Tell the original agent "run a discuss round" (trigger)
2. Confirm two things in the request: what to focus on, and whether the reviewers are cross-family
3. Open reviewer sessions on **different model families**; tell each: "read `handoff/pending/discuss-{...}.md`, you are Reviewer X"
4. Back to the original agent: "the reviews are in, go synthesize"
5. (Optional) open a new session for the final check, or let handoff auto-scan pick it up

---

## File naming

| Stage | Naming |
|-------|--------|
| Request | `discuss-{date}-{time}-{shortname}.md` |
| Review | `discuss-{date}-{time}-{shortname}-review-{a\|b\|c}-{model}.md` |
| Synthesis | `discuss-{date}-{time}-{shortname}-synthesis.md` |
| Final-check handoff | `discuss-{date}-{time}-{shortname}-final-check-handoff.md` |
| Final-check result | `discuss-{date}-{time}-{shortname}-final-check-{model}.md` |
| Discarded | append `-discarded` to the filename at any stage, archive to done/ |

`time` reuses the request file's timestamp so you can grep one round. Round numbers (r1 / r1.5 / r2) go in frontmatter, not the filename.

---

## Merge rules (for the Synthesizer)

### Before merging: contamination check

| State of the reviews | Reading |
|----------------------|---------|
| All agree + cross-family | 🟢🟢 very high-confidence consensus |
| All agree + two share a family | 🟢 high, but discount the consensus items those two share |
| Two agree + 1 dissents | 🟡 weigh the dissent first — may be a minority-correct view |
| All three conflict | 🟢 more informative than agreement; needs deep synthesis |
| Any reviewer breaks discipline (peeked at others / same session) | 🔴 discard, rerun |
| Cross-family single vote (minority-correct candidate) | 🟢 adopt the direction if the logic is solid |

### Cross-family signal rules

1. **Cross-family consensus** (three different families converge from different abstraction levels) → 🟢🟢🟢 highest; a critical insight, fold into the core of the plan.
2. **A cross-family single vote outweighs a same-family double vote** — if a lone cross-family point is logically solid, treat it as minority-correct; don't down-weight it just because "it's only one vote."
3. **Same-family consensus (including the synthesizer's own family) is auto-discounted** — mark such "consensus" items 🟡 at most, no matter how strong they sound.

### During merge: forced checklist (prevents silent vetoes)
Before producing the merge, go through every reviewer suggestion and confirm each landed in one of three buckets — **consensus / conflict / rejected**. Anything not placed → **must be logged in the rejected bucket**; nothing silently dropped.

### After merge: two reverse guardrails
- **Guardrail A — Unanimous Override (24h delay)**: if two or more reviewers flag the same problem and the synthesizer wants to reject it → must open a reflection note in `inbox/` and wait 24h before formally rejecting. (Prevents the merger from rationalizing away a unanimous warning.)
- **Guardrail B — Quantity Override (24h delay)**: if the synthesizer rejects more than 50% of reviewer suggestions → pause the merge, revisit after 24h. (Prevents wholesale override of the reviewers.)

The two guardrails are parallel — they solve different problems and do not replace each other.

---

## Synthesis output format

Five sections: **consensus / conflict / rejected / final plan / change summary.** The final plan is what the Plan Owner executes; the change summary records what moved and why.

---

## Relationship to other Skills

| Skill | Relationship |
|-------|--------------|
| **debate-protocol** | Complementary. debate = binary yes/no decision face-off; discuss = iterative plan refinement |
| **handoff** | Shares the pending/done infrastructure, different templates |
| **wrap-up** | No overlap. wrap-up = a session's internal closing reflection; discuss = sending a plan out for external review |
