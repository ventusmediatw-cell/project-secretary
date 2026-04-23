---
name: project-setup
description: "Project setup six-step flow: background confirmation → architecture creation → external research → assumption challenge (Debate) → user decision → execution start. Includes branching logic (complete/simplified/quick versions), tool chain exploration SOP, prioritization by importance."
---

# Project Setup Flow

When the user decides to launch a new project, secretary executes this six-step flow. Not every project needs all six steps — select branching based on project type.

---

## Six-Step Overview

| Step | Content | Output |
|---|---|---|
| **Step 1** | Background Confirmation | Confirm basic project info, check for historical data |
| **Step 2** | Architecture Creation | Create project folder + INDEX.md + update main list |
| **Step 3** | External Research | Domain knowledge + tool chain exploration + security checks |
| **Step 4** | Assumption Challenge | Debate protocol (max 3 topics) |
| **Step 5** | User Decision | Decision records + key assumption confirmation |
| **Step 6** | Start Execution | Create execution plan + launch first action item |

---

## Step 1: Background Confirmation

### Scan Historical Data

1. Search `workspace/` for existing related files (project name, keywords, people names)
2. If large amount of historical data found → **launch subagent for deep excavation**, don't do shallow scan
3. Scan `workspace/inbox/`, `projects/`, `refs/` for related discussion records

### Confirm Basic Info with User

- Project name, English alias
- Project type (business decision / infrastructure / learning experiment / pure execution)
- Brief background (3-5 sentences)
- Key stakeholders
- Initial timeline (milestones, deadlines)

### Determine Branching Version

Recommend branching at end of Step 1, user chooses.

---

## Step 2: Architecture Creation

### Create Folder Structure

```
workspace/projects/{category}/{name}/
├── INDEX.md           ← Project core index
├── memory.md          ← Accumulated knowledge (created later)
├── daily/             ← Daily log directory
├── refs/              ← Research materials, reference docs
└── debates/           ← Debate transcripts (Step 4)
```

**Folder naming rules**:
- `{category}`: Project category (e.g., `ecommerce`, `marketing`, `infra`, `learning`)
- `{name}`: kebab-case, English short name (e.g., `revenue-strategy`)

### Write INDEX.md

> INDEX.md template: see `templates.md` in same folder, "INDEX.md Template" section.

### Update Main INDEX.md

Add new project to `workspace/INDEX.md` "Active Projects" list:
```markdown
- **[{Project Name}](projects/{category}/{name}/INDEX.md)**: Brief description — Status (setup in progress)
```

---

## Step 3: External Research

**Research depth suggested by secretary, chosen by user. Offer complete / simplified / skip options.**

### Branch A: Domain Knowledge Research

| Research Item | Complete Version | Simplified Version |
|---|---|---|
| Market size / trends | Thorough verification | Quick overview |
| Competitor analysis | 3-5 deep dives | Top 2-3 |
| Regulation / compliance | Complete review | Key highlights |
| Customer research | Deep interview prep | Quick survey |

### Branch B: Tool Chain Exploration

1. **Search official resources**
   - MCP Registry
   - Plugin Marketplace (if applicable)
   - Official documentation

2. **Search open source solutions**
   - GitHub high-star repos (filter: ⭐ count, update frequency, issue response speed)
   - Community discussion (Reddit, Product Hunt, Discord)

3. **Security check**
   - Reference `workspace/refs/security-checklist.md`
   - Checklist: source code openness, maintainer reputation, known vulnerabilities

4. **Integrate decision**
   - List candidate tools + security assessment results
   - User makes final choice

### Depth Options Template

Secretary presents to user:

> **Domain Knowledge Research**: This project type recommends "complete version"
> - Estimated time: 2-3 hours
> - Covers: market, competitors, regulations, customers
> - Excludes: deep model training, paper reading
>
> **Tool Chain Exploration**: This type recommends "simplified version"
> - Estimated time: 1-2 hours
> - Covers: MCP Registry, GitHub top repos, quick security assessment
> - Excludes: full competitor evaluation, tutorial video watching
>
> Which do you prefer? (Complete / Simplified / Skip)

---

## Step 4: Assumption Challenge (Debate)

**Activation condition**: Business decisions / high-importance projects **must do**; others optional.

### Flow Summary

1. **Secretary opens**: List 3 core topics + announce depth (complete / simplified)
2. **Multi-round attack/defense**: Advocate proposes → Challenger questions → Advocate responds (2-3 rounds)
3. **Secretary converges**: Record consensus ✓, disagreements ✗, pending topics ❓
4. **Secretary summary**: Consolidate core conclusions + user decision item list

### Topic Selection Criteria

Topics should focus on **decision points**, not data collection:

❌ "How many competitors are there?" �� ✅ "Which market should we prioritize entering?"
❌ "How does tool X work?" → ✅ "Should we build custom or buy off-the-shelf?"

### Debate Storage Location

```
workspace/projects/{category}/{name}/debates/{YYYY-MM-DD}-{topic}/
├── transcript.md   ← Full conversation record
└── summary.md      ← Secretary summary (consensus + disagreements + ❓)
```

See `workspace/refs/debate-agents/debate-protocol.md` for details.

---

## Step 5: User Decision

### Organize Decision List

Consolidate Debate's ❓ questions, invite user to make final decisions.

> Decision list format and key decision record format: see `templates.md` in same folder.

### Record Decisions to INDEX.md

After user confirms, update project `INDEX.md`'s "Key Decisions" section (format in `templates.md`).

---

## Step 6: Start Execution

### Create Execution Plan

Based on decisions:

1. **Decompose milestones**: 3-6 month timeframe, one important milestone per month
2. **List first week tasks**: 3-5 specific action items
3. **Assign ownership** (if multi-person collaboration)

### Launch First Action Item

- Create first daily log in `daily/`
- Update main `INDEX.md` to-do items
- Announce project enters "Execution" status

---

## Branching Logic

Not every project needs all six steps. Secretary judges and recommends after Step 1.

| Project Type | Recommended Flow | Reason | Example |
|---|---|---|---|
| **Business decision / high importance** | Full six steps (1-2-3 complete-4-5-6) | High decision risk, far-reaching impact | Revenue strategy, market expansion |
| **Infrastructure / systems** | 1-2-3 simplified-6 (skip Debate) | Technical path clearer, fewer design decisions | System upgrades, DevOps infra |
| **Learning / experiment / low risk** | 1-2-6 (skip 3 and 4) | Low trial-and-error cost, knowledge accumulation primary | Learning clubs, experimental tool testing |
| **Already has mature direction** | 1-2-5-6 (skip deep research and Debate) | Direction settled, quick launch | Pure execution new features, confirmed market |

**User final confirmation**: Secretary recommends, user confirms which version, before proceeding.

---

## Secretary Checklist

After completing setup, self-check:

- [ ] Did I read all related historical data (use subagent for large volumes)?
- [ ] Did I create complete folder structure and INDEX.md?
- [ ] Did I update main INDEX.md's active project list?
- [ ] Does Step 3 depth match project importance (complete / simplified / skip)?
- [ ] If Debate was done, did I follow protocol and limit topics ≤ 3?
- [ ] Did I consolidate all pending decisions (❓) for user?
- [ ] Did I record decisions to INDEX.md's "Key Decisions"?
- [ ] Did I create first week execution plan with 3-5 specific action items?

---

## Coordination with Other Skills

- **secretary Skill**: Reads main INDEX.md, handles mode switching
- **debate-protocol.md**: Reference for Step 4 Debate execution
- **review Skill**: After setup, if involving new tools/platforms, updates tool preferences at wrap-up
- **handoff Skill**: If setup involves cross-platform collaboration, creates handoff files
