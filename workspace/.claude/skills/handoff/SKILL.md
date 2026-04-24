---
name: handoff
description: "Handoff Protocol: write handoff record at end of session. Includes quick/formal triage, cross-platform handoff/pending/ queue, Git Commit Handoff. Required at end of every session."
---

# Handoff Protocol

At the end of each Agent session, **must leave a handoff record**. This applies even to brief sessions.

## Wrap-up Flow (trigger when user says "wrap up")

User says "wrap up" = run wrap-up Review, **not** code review / simplify.

### Step 1: Multi-Project Review

Review all projects touched in this session (including incidental changes in secretary mode), and for **each** one:

1. Write/append project daily log `projects/{name}/daily/YYYY-MM-DD.md` (**new session inserts at top of file**, after daily header, before previous section — latest on top)
2. Update project `INDEX.md` (two steps):
   - **2a Write**: Add this session's outputs, update progress description
   - **2b Compare existing to-dos**: Scan all `[ ]` items in INDEX — did this session's work complete, obsolete, or change the premise of any item? If yes → update status and note reason (e.g., `[x] ... → covered by paper trader (fdbd6cf)`, `Obsolete: premise changed, see daily 04-14`)
3. If there are important decisions or research conclusions → write to `memory.md`

### Step 2: Secretary Review Checklist

Read `.claude/skills/review/SKILL.md` and execute the full 13-item checklist (A Experience → B System Updates → C Memory Sync).

### Step 3: Write Handoff + Git Archive

Use the triage logic below to choose handoff method, then handle git by platform (Code: direct commit / Cowork: write git-commit handoff).

### Step 4: Wrap-up Confirmation

Tell the user: "Wrap-up complete! ✅ [completion summary] / 📝 Pending: [incomplete items] / 💡 [new findings] / 💾 Archived"

---

## Handoff Triage

### Quick Handoff

**Condition: the receiving end can act immediately after reading INDEX.md, no extra context needed.**

Typical cases: git push, run tests, install packages, change a specific path with a clear directive. The action itself is the complete instruction.

How:
- **Don't write a `handoff/pending/` file, no template needed**
- Note one line in inbox journal for reference (e.g., `- Quick handoff to Code: push workspace changes`)
- User can relay orally or copy-paste

### Formal Handoff

**Condition: task requires understanding background, involves design decisions, or contains multiple steps.**

How:
- Write to `handoff/pending/`
- Format: see `templates.md` in same folder

> When in doubt, ask: "If I only gave the receiver this one sentence, would they get it wrong?" Yes → formal handoff.

## Handoff Write Locations

| Operating Mode | Write Location |
|---|---|
| Secretary mode | `inbox/YYYY-MM-DD.md` |
| Project mode | `projects/{name}/daily/YYYY-MM-DD.md` |
| Cross-platform tasks (formal) | `handoff/pending/` (see `templates.md`) |
| Cross-platform tasks (quick) | Note one line in inbox, user relays orally |

## ⚠️ Timestamp is Mandatory

Before writing handoff report, run `date` to get current time. Both title and body must include `HH:MM ~ HH:MM (Timezone)`. **Don't use vague terms like "evening" or "afternoon."**

## Handoff Report Format

```markdown
## [Agent Name] — HH:MM ~ HH:MM (Timezone)

> **Executor**: Agent Name
> **Time**: HH:MM ~ HH:MM (Timezone)
> **Operating Mode**: Secretary mode / Project mode (Project name)

### ✅ Completed Items
- [x] Item 1: Brief description of completion

### ⏳ In Progress
- [ ] Item 1: Progress note, next steps direction

### ❌ Issues / Blockers
- Issue 1: Description (Impact level: High/Medium/Low)

### 👉 Suggestions for Next Agent
- Suggestion 1: Priority and reasoning

### Memory Sync Checklist
- [ ] Did I update main INDEX.md's to-do items/recent priorities?
- [ ] Did I update project INDEX.md (if in project mode work)?
- [ ] Any new important decisions or knowledge corrections?
```

## Cross-Platform Handoff (handoff/)

When a task needs another platform's Agent to take over, write to `handoff/pending/`.

### Folder Structure

```
handoff/
├── pending/    ← Tasks awaiting processing (other Agent picks it up)
└── done/       ← Completed (move here after finishing)
```

### Filename Format

`YYYY-MM-DD-HHMM-brief-summary.md`

Example: `2026-03-24-1735-task-complete.md`

### Handoff File Format

```markdown
---
from: cowork-opus / claude-code-opus / 【Your platform】(executor name)
to: claude-code / cowork / 【Target platform】(target platform)
priority: normal / urgent
project: Project name (if applicable)
created: YYYY-MM-DDTHH:MM+timezone
---

## Task
What specifically needs to be done (including paths, parameters, commands)

## Context
Why this needs to be done, background information

## After Completion
Where to write results, whether to notify the originator
```

### Processing Flow

1. Originator writes to `handoff/pending/`
2. Receiver opens session and scans `handoff/pending/`
3. Pick up task and execute
4. **Write processing results to project journal** (`projects/{name}/daily/YYYY-MM-DD.md`) to keep knowledge in project context
5. Move handoff file to `handoff/done/` (add completion timestamp) — done/ is just a receipt for closed tickets
6. If need to report results, write a new reply handoff file to `handoff/pending/`

## done/ Cleanup

`handoff/done/` is just a receipt; real content is in project journal. Files in done/ older than 7 days can be automatically cleaned by daily-secretary-review schedule or cleaned manually.

## Multiple Agents Same Day

If multiple Agents write handoffs on the same day, **insert at top of same journal file** (after daily header), separated with `##` heading + time period. Latest session always on top.

## Git Commit Handoff (Cowork → Code)

Cowork has lock restrictions on mounts; git operations will fail. **Cowork does not attempt git commit/push** — instead write a handoff for Claude Code to handle.

At wrap-up, if there are file changes to commit, write a handoff to `handoff/pending/`. Format: see "Git Commit Handoff" section in `templates.md`. Filename: `YYYY-MM-DD-git-commit.md`.

### Merge Rule

Multiple Cowork sessions on the same day **merge into one git handoff file** (append changed files to same file), to avoid Code running multiple commits.
