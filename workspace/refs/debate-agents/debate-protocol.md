# Debate Protocol

**Last updated**: 2026-03-25
**Version**: 1.0

---

## Overview

AI secretary launches a Debate mechanism at critical project decision points, inviting two subagents (Advocate and Challenger) to engage in multi-round strategy exchange, helping user make more robust decisions.

This protocol applies to all debate scenarios, ensuring consistent flow and output quality.

---

## Core Principles

| Item | Description |
|---|---|
| **Topic count** | Max 3 per debate, split into multiple debates if more than 3 |
| **Interaction format** | Multi-round dialogue, not two independent reports |
| **Moderator** | Secretary controls flow, enforces word limits, drives process |
| **Goal** | Identify strategy's strengths, risks, blind spots, decision rationale |

---

## Role Definitions

### Advocate (Proponent)
- Actively propose and advance strategy
- Respond to Challenger's challenges, revise arguments
- Explain strategy's rationale and advantages

### Challenger (Questioner)
- Question assumptions, point out risks, propose alternatives
- Not opposing for opposition's sake, but to make strategy more robust
- Focus on execution difficulty, market risk, resource constraints

### Secretary (Moderator)
- Opening: List topic checklist
- Control: Ensure both sides each speak 2-3 rounds
- Word limit: Enforce strictly
- Off-topic: Stop directly, pull back to core
- Fast consensus: Skip remaining rounds, move to next topic
- Summary output: Organize consensus, disagreement, pending decision items

---

## Word Limits (Chinese characters)

| Stage | Limit | Description |
|---|---|---|
| Advocate opening | 200-300 chars | Complete statement of strategy and reasoning |
| Each round exchange | 100-150 chars | One challenge or response |
| Secretary convergence | 100 chars | Record consensus, disagreement, pending |
| **Total debate output** | 2000-3000 chars | Complete dialogue record |

---

## Flow

### Step 0: Secretary Opening
- Explain debate background and decision points
- List 3 topics (numbered: ① ② ③)
- Announce depth (complete/simplified), user chooses
  - **Complete**: 3-round exchange, detailed argument
  - **Simplified**: 2-round exchange, quick conclusion

### Steps 1-3: Each Topic Flow

**Topic ① (and subsequent topics follow same pattern)**

#### Advocate Opening (200-300 chars)
- Complete statement of position
- Explain reasoning and expected effects
- Pre-emptively address common objections

#### Challenger Challenge (100-150 chars)
- Point out 1-2 main risks or assumption flaws
- Propose alternative or improvement
- Don't raise 5 challenges at once

#### Advocate Response (100-150 chars)
- Directly respond to Challenger's specific challenges
- Revise or strengthen argument
- Explain why own approach still superior

#### Challenger Second Challenge (optional, 100-150 chars)
- Activate when first round has structural contradiction
- Point to more fundamental assumption error or feasibility issue
- If both approaching consensus, secretary can skip

#### Secretary Convergence (100 chars)
- Record both sides' consensus points (✓)
- Record disagreement points (✗)
- Mark pending user decision items (❓)
- Transition to next topic

### Step 4: Secretary Summary
- Aggregate three topics' core consensus
- List all disagreements and fundamental assumption differences
- Consolidate all ❓ questions
- Give decision recommendation (if clear leaning)

---

## Special Markers

### ❓ User Decision Items
When encountering **only boss/user can answer** questions, mark with ❓.

**Examples**:
- What's product vision? (Business strategy question)
- Acceptable risk ceiling? (Risk tolerance question)
- Which market more important? (Priority question)

Consolidate in summary for user to decide.

### ✓ Consensus Points
Both sides agree, mark ✓.

### ✗ Disagreement Points
Irreconcilable positions, mark ✗.

---

## Stop and Accelerate Conditions

| Situation | Secretary Action |
|---|---|
| Both agree on first round | Converge immediately, skip to next topic |
| Over 3 rounds with no progress | Confirm fundamental disagreement, mark ✗, move to next topic |
| Over scheduled time | Warn then stop forcefully, enter summary |
| Off-topic speech | Interrupt, pull back to core topic |

---

## Storage Architecture

```
projects/{project}/debates/{YYYY-MM-DD}-{topic}/
├── transcript.md     ← Complete dialogue record (by round)
├── summary.md        ← Secretary summary (consensus + disagreement + ❓ items)
└── metadata.md       ← Timestamps, participants, decision results (update later)
```

### transcript.md Format
```markdown
# Debate Dialogue Record — {Topic}

**Date**: 2026-03-25
**Depth**: Complete / Simplified

## Topic ① {Topic Name}

### Advocate Opening
[200-300 char position statement]

### Challenger Challenge R1
[100-150 char challenge]

### Advocate Response R1
[100-150 char response]

### Challenger Challenge R2
[If second round exists]

### Secretary Convergence
✓ Consensus: ...
✗ Disagreement: ...
❓ Pending: ...

---

## Topic ② ...
```

### summary.md Format
```markdown
# Debate Summary

**Date**: 2026-03-25
**Topics**: 3 items

## Core Consensus
- ✓ Consensus 1
- ✓ Consensus 2

## Key Disagreements
- ✗ Disagreement 1: Advocate thinks A, Challenger thinks B
- ✗ Disagreement 2: ...

## User Decision Items
- ❓ Question 1: ...
- ❓ Question 2: ...

## Decision Recommendation
[If clear leaning, secretary recommends]
```

---

## v0 Lessons (First test 2026-03-25)

| Issue | Solution |
|---|---|
| Two independent reports, no exchange | **Force multi-round dialogue format** |
| Length out of control (~1900 lines) | **Word limits** + **max 3 topics** |
| Advocate can't respond to Challenger | **Guarantee Advocate has response chance** |
| High decision cost | **Secretary summary focuses on key points** |

---

## Cross-Platform Compatibility

- This protocol written in markdown, both Cowork and Claude Code can read
- Persona files (advocate.persona.md, challenger.persona.md) also markdown
- **Not reliant on** .claude/agents/ (Cowork doesn't support)
- Source of truth: Files under refs/debate-agents/

---

## Quick Checklist for Secretary

- [ ] Opening clearly lists 3 topics
- [ ] Announce debate depth, user chooses
- [ ] Each topic respects round limits (2-3 rounds)
- [ ] Each speech respects word limits
- [ ] Mark ✗ on disagreement, ❓ on decision points
- [ ] Skip remaining rounds on quick consensus
- [ ] transcript.md records by round completely
- [ ] summary.md consolidates consensus, disagreement, ❓ questions
- [ ] Files stored in projects/{project}/debates/{date}-{topic}/
