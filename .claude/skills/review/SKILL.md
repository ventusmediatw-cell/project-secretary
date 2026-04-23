---
name: review
description: "Wrap-up Review: two-stage flow (project manager wrap-up → secretary review) with 13-item checklist (A: experience extraction, B: system updates, C: memory sync). Triggered when user says 'wrap up'."
disable-model-invocation: true
---

# Wrap-Up Review Flow

When the user says "wrap up," execute the two-stage wrap-up flow.

---

## Stage 1: Project Manager Wrap-Up

When user says "wrap up," execute immediately:

1. Write project daily report `workspace/projects/{name}/daily/YYYY-MM-DD.md`
2. Update project `INDEX.md` (to-do status, progress)
3. If there are important decisions or research conclusions → write to `memory.md`
4. Tell user: "Project wrap-up complete. Ready for secretary review."

> If session was purely in secretary mode, skip directly to Stage 2.

## Stage 2: Secretary Review

Execute when transitioning from project mode, or directly in secretary mode wrap-up.

### Determine Review Level

- **Simple version**: Minor file edits, no exploration → Only write inbox journal + update main INDEX
- **Full version**: Any trial-and-error, discoveries, changed understanding, **first time using new tool/platform** → Must run the full 13-item checklist below
- **Unsure** → Default to full version

---

## Full Version: 13-Item Checklist

⚠️ **Must go through each item; don't cherry-pick. Section A (experience extraction) and B (system updates) are the core value of secretary review — don't just do C (memory sync) and call it done.**

### A. Experience Extraction (review conversation, check each item)

1. **Pitfall record**: Tried a method that failed, then switched to another → `docs/lessons-learned.md`
2. **Knowledge correction**: Found a previous conclusion was wrong → correction note + `docs/lessons-learned.md`
3. **Better approach**: Found a better approach than expected → `docs/lessons-learned.md` or update existing SOP/Skill
4. **Collaboration friction**: Friction points in cross-agent collaboration → improve handoff protocol
5. **Synthesis Correction detection**: Did this session's real-world results overturn or correct existing conclusions in KB/synthesis? (e.g., Gemini research said an API was usable, but testing found otherwise; or a synthesis page's action recommendation proved ineffective in practice) → Tag `[synthesis-correction]` in inbox journal, format below

### B. System Updates (check if system files need updating)

6. **New tool / new platform**: Did this session use a tool, platform, or service **for the first time**? → Update corresponding Skill or create new Skill
7. **Tool preference change**: Did user make a new tool choice decision (e.g., "from now on use X not Y")? → Update secretary Skill tool preferences
8. **Process change**: Do handoff protocol, organization rhythm, model routing, or other system rules need adjustment? → Update corresponding Skill
9. **Template gap**: Did you repeatedly write a certain format of document this session, worth making a template? → Evaluate creating Skill or updating refs/

### C. Memory Sync (ensure indexes reflect latest state)

10. **Main INDEX** → Update recent priorities, to-do status; **clear this session's `[x]` completed items and `~~strikethrough~~` passages**
11. **Project INDEX** → Update project-internal decisions, to-do items
12. **Secretary journal** → `workspace/inbox/YYYY-MM-DD.md`
13. **Project daily report** → `workspace/projects/{name}/daily/YYYY-MM-DD.md`

### Self-Check Question

After completing the above, ask yourself: **"If a brand new Agent starts tomorrow, reading only CLAUDE.md + INDEX.md + Skills, can it recreate everything learned today?"** If not, something was missed.

---

## Journal Format

Write to `workspace/inbox/YYYY-MM-DD.md`:

```markdown
## HH:MM (Timezone)

### Completed Items
- ...

### Important Decisions
- ...

### Pending Items
- ...
```

> ⚠️ Timestamp is mandatory: run `date` before writing to get current time. Don't use vague terms like "evening" or "afternoon."

---

## Experience Extraction Tags (advanced, only when applicable)

Tag in journal entries:
- **Pitfall** → tried a method and it failed
- **Improvement** → found a better approach
- **Knowledge correction** → changed a previous understanding

These tags simultaneously trigger Section A (experience extraction) write actions.

### Synthesis Correction Annotation Format (when A5 triggers)

Add a `### [synthesis-correction]` section in the inbox journal, including: affected synthesis page path, original conclusion, real-world test result, and suggested correction. Attach related lesson number if available.

> Review only tags the correction — it does not directly modify synthesis. Digestion happens at weekly report Step 4 (see secretary Skill organization rhythm).

---

## PreCompact Hook Integration (Claude Code)

When Claude Code triggers auto-compact on long conversations, a PreCompact hook can run a minimal review to prevent information loss. This is a stripped-down version of the 13-item checklist — only the items that would be lost if not persisted before compaction.

### Compact-Before Checklist (3-5 items)

1. **INDEX freshness**: Are this session's key events reflected in main INDEX.md recent priorities?
2. **Inbox exists**: Does `workspace/inbox/YYYY-MM-DD.md` have today's entry? If not, write a minimal one (completed items + pending)
3. **Stale handoffs**: Any `handoff/pending/` files older than 3 days not yet flagged?
4. **Synthesis-correction**: Any real-world findings this session that contradict KB/synthesis conclusions? Tag `[synthesis-correction]` in inbox
5. **Project INDEX**: If in project mode, is the project INDEX.md up to date?

### Behavior Rules

- **Fail-open**: If the hook errors, do NOT block compaction. Data loss from failed compact is worse than a missed check
- **Speed over completeness**: This runs under time pressure. Skip anything requiring multi-file reads. Only write what's immediately known
- **No git**: Do not attempt git operations in the hook — save that for manual wrap-up

### Hook Configuration Example

```json
{
  "hooks": {
    "PreCompact": [{
      "type": "command",
      "command": "echo 'PreCompact: check INDEX + inbox + handoff staleness'"
    }]
  }
}
```

> The hook itself is a reminder prompt. The actual review logic is executed by the agent in response to the hook trigger, following the 5-item checklist above.

---

## Git Auto-Save

After C (memory sync) is complete: Claude Code runs `git add` + `git commit` directly; Cowork **does not attempt git** (mount lock will always fail) — write a git-commit handoff instead (format in `.claude/skills/handoff/templates.md`, "Git Commit Handoff" section).

---

## Wrap-Up Confirmation

Tell the user:

"Today's wrap-up is complete! I've organized:
- ✅ [Summary of completed items]
- 📝 Pending: [Items not yet completed]
- 💡 [If there are new thoughts or discoveries, mention them]
- 💾 Saved (git commit) — if applicable

I'll remember these next time we chat. Anything else to add?"
