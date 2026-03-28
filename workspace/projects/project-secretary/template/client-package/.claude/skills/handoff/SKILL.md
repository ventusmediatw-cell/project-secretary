---
name: handoff
description: "Handoff Protocol: write handoff report at end of session (secretary mode → inbox/, project mode → projects/daily/), cross-platform handoff to handoff/pending/. Handoff report format template, timestamp mandatory rules, memory sync checklist. Needed at end of every session."
---

# Handoff Protocol

At the end of each Agent session, **must leave a handoff record**. This applies even to brief sessions.

## Handoff Write Locations

| Operating Mode | Write Location |
|---|---|
| Secretary mode | `workspace/inbox/YYYY-MM-DD.md` |
| Project mode | `workspace/projects/{name}/daily/YYYY-MM-DD.md` |
| Cross-platform tasks | `workspace/handoff/pending/` (see format below) |

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

## ⚠️ Timestamp is Mandatory

Before writing handoff report, run `date` to get current time. Both title and body must include `HH:MM ~ HH:MM (Timezone)`. **Don't use vague terms like "evening" or "afternoon."**

## Cross-Platform Handoff (handoff/)

When a task needs another platform's Agent to take over, write to `workspace/handoff/pending/`.

### Folder Structure

```
workspace/handoff/
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

`handoff/done/` is just a receipt; real content is in project journal. Files in done/ older than 7 days can be manually or automatically cleaned.

## Multiple Agents Same Day

If multiple Agents write handoffs on the same day, **append to same journal file** (separate with `##` heading + time period), don't overwrite previous content.
