---
name: project-setup
description: "Project setup six-step flow: background confirmation → architecture creation → external research → assumption challenge (Debate) → user decision → execution start. Includes branching logic (complete/simplified/quick versions), tool chain exploration SOP, prioritization by importance."
---

# Project Setup Flow

When the user decides to launch a new project, the secretary executes this six-step flow. Not every project needs all six steps—choose a branch based on project type.

---

## Six-Step Flow Overview

| Step | Content | Output |
|---|---|---|
| **Step 1** | Background confirmation | Confirm basic project info, check for historical data |
| **Step 2** | Architecture creation | Create project folder + INDEX.md + update main list |
| **Step 3** | External research | Domain knowledge + tool chain exploration + security check |
| **Step 4** | Assumption challenge | Debate protocol (max 3 topics) |
| **Step 5** | User decision | Record decisions + confirm key assumptions |
| **Step 6** | Begin execution | Create execution plan + launch first action item |

---

## Step 1: Background Confirmation

### Scan Historical Data

1. Search `workspace/` to see if related files already exist (project name, keywords, person names)
2. If discovering lots of historical data → **Launch subagent for deep excavation**, don't do shallow scan
3. Scan `workspace/inbox/`, `projects/`, `refs/` for related discussion records

### Confirm Basic Information with User

- Project name, English alias
- Project type (business decision / infrastructure / learning experiment / pure execution)
- Brief background (3-5 sentences)
- Key stakeholders
- Preliminary time range (milestones, deadlines)

### Determine Branch Version

At Step 1 end, recommend branching; user selects.

---

## Step 2: Architecture Creation

### Create Folder Structure

```
workspace/projects/{category}/{name}/
├── INDEX.md           ← Project core index
├── memory.md          ← Accumulated knowledge (create later)
├── daily/             ← Daily report directory
├── refs/              ← Research data, reference files
└── debates/           ← Debate dialogue records (Step 4 use)
```

**Folder naming rules**:
- `{category}`: Project category (e.g., `ecommerce`, `marketing`, `infra`, `learning`)
- `{name}`: kebab-case, English shorthand (e.g., `【Your project shorthand】`)

### Write INDEX.md Template

```markdown
# {Project Name}

## Identity
- Type: [Business decision / Infrastructure / Learning experiment / Pure execution]
- Owner: 【Your name】
- Status: Pre-launch setup

## Overview
[3-5 sentence background + goals]

## Key Decisions
(Fill in Step 5)

## Timeline
- Launch date: [date]
- Expected completion: [date]
- Key milestones:

## To-Do Items
- [ ] Step 3: External research
- [ ] Step 4: Debate (if needed)
- [ ] User decision
- [ ] Begin execution

## Navigation
- Daily reports: `daily/`
- Research data: `refs/`
- Debate records: `debates/` (if exists)
```

### Update Main INDEX.md

Add new project to "Active Projects" list in `workspace/INDEX.md`:
```markdown
- **[{Project Name}](projects/{category}/{name}/INDEX.md)**: Brief description — Status (Pre-launch setup)
```

---

## Step 3: External Research

**Research depth is suggested by secretary, chosen by user. Offer complete / simplified / skip options.**

### Branch A: Domain Knowledge Research

| Research Item | Complete Version | Simplified Version |
|---|---|---|
| Market size / trends | Thorough verification | Quick scan |
| Competitor analysis | 3-5 in-depth | Top 2-3 |
| Regulations / compliance | Complete mapping | Key points only |
| Customer research | Deep interview prep | Quick survey |

### Branch B: Tool Chain Exploration (New)

1. **Search official resources**
   - MCP Registry (`notion://mcp-registry/`)
   - Plugin Marketplace (if applicable)
   - Official documentation

2. **Search open source solutions**
   - GitHub high-star repos (filter: ⭐ count, update frequency, issue response speed)
   - Community discussions (Reddit, Product Hunt, Discord)

3. **Security check**
   - Reference `workspace/refs/security-checklist.md`
   - Checklist: source code openness, maintainer reputation, known vulnerabilities

4. **Integration decision**
   - List candidate tools + security assessment results
   - User makes final choice

### Deep Option Template

Secretary provides to user:

> **Domain Knowledge Research**: This project type recommends "complete version"
> - Estimated time: 2-3 hours
> - Covers: market, competitors, regulations, customers
> - Excludes: deep model training, paper reading
>
> **Tool Chain Exploration**: This type recommends "simplified version"
> - Estimated time: 1-2 hours
> - Covers: MCP Registry, top GitHub repos, initial security assessment
> - Excludes: complete competitive evaluation, tutorial watching
>
> What would you prefer? (Complete / Simplified / Skip)

---

## Step 4: Assumption Challenge (Debate)

**Trigger condition**: Business decision / high-importance projects **must do**; other types optional.

### Process Overview

1. **Secretary opening**: List 3 core topics + announce depth (complete / simplified)
2. **Multi-round exchange**: Advocate proposes → Challenger questions → Advocate responds (2-3 rounds)
3. **Secretary converges**: Record consensus ✓, disagreement ✗, pending ❓ items
4. **Secretary Summary**: Aggregate core conclusions + user decision items list

### Topic Selection Criteria

Topics should focus on **decision points**, not data collection:

❌ "How many competitors exist?" → ✅ "Should we prioritize Market A or Market B?"
❌ "How do we use tool X?" → ✅ "Should we build custom or buy off-the-shelf?"

### Debate Storage Location

```
workspace/projects/{category}/{name}/debates/{YYYY-MM-DD}-{topic}/
├── transcript.md   ← Complete dialogue record
└── summary.md      ← Secretary summary (consensus + disagreement + ❓)
```

Refer to `workspace/refs/debate-agents/debate-protocol.md`.

---

## Step 5: User Decision

### Organize Decision Items

Gather Debate's ❓ questions into centralized list, invite user for final decision:

```markdown
## Decision Items (User's Call)

❓ Question 1: [Content]
- Secretary's suggestion: [Leaning]
- User's decision: [Pending]

❓ Question 2: [Content]
- Secretary's suggestion: [Leaning]
- User's decision: [Pending]
```

### Record Decisions to INDEX.md

After user confirms, update project `INDEX.md`'s "Key Decisions" section:

```markdown
## Key Decisions (Decided 2026-03-25)

1. **Market choice**: 【Your decision】(reason: X)
2. **Cost model**: 【Your decision】(reason: Y)
3. **Risk tolerance**: 【Your decision】(reason: Z)
```

---

## Step 6: Begin Execution

### Create Execution Plan

Based on decision results:

1. **Break down milestones**: 3-6 month timeframe, one key milestone per month
2. **List first week tasks**: 3-5 specific action items
3. **Assign owners** (if multi-person collaboration)

### Launch First Action Item

- Create first daily report under `daily/`
- Update main `INDEX.md` to-do items
- Announce project entering "execution" state

---

## Branching Logic

Not every project needs complete six steps. Secretary judges and recommends branching after Step 1.

| Project Type | Recommended Flow | Reason | Example |
|---|---|---|---|
| **Business decision / High priority** | Full six steps (1-2-3 complete-4-5-6) | Decision risk high, impact deep | 【Your business decision example】 |
| **Infrastructure / Systems** | 1-2-3simplified-6 (skip Debate) | Technical route clearer, fewer design decisions | 【Your systems example】 |
| **Learning / Experiment / Low risk** | 1-2-6 (skip 3 and 4) | Trial-and-error cost low, knowledge focus | 【Your learning example】 |
| **Already clear direction** | 1-2-5-6 (skip deep research and Debate) | Direction set, quick launch | 【Your execution example】 |

**User's final confirmation**: Secretary recommends, user confirms which version, then continue.

---

## Secretary Checklist

After setup completion, self-check:

- [ ] Did I read all relevant historical data (use subagent for large data)?
- [ ] Did I create complete folder structure and INDEX.md?
- [ ] Did I update main INDEX.md's active projects list?
- [ ] Is Step 3 depth matching project importance (complete / simplified / skip)?
- [ ] If Debate, did I follow protocol and limit topics ≤ 3?
- [ ] Did I consolidate all decision items (❓) for user decision?
- [ ] Did I record decision results to INDEX.md "Key Decisions"?
- [ ] Did I create first week execution plan with 3-5 specific action items?

---

## Coordination with Other Skills

- **secretary Skill**: Read main INDEX.md, determine mode switching
- **debate-protocol.md**: Reference when executing Debate in Step 4
- **review Skill**: After setup complete, if involving new tools/platforms, update secretary Skill tool preferences during wrap-up
- **handoff Skill**: If setup involves cross-platform collaboration, create handoff files
