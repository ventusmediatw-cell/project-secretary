---
name: review
description: "Wrap-up Review: two-stage flow (project manager wrap-up → secretary review) with 12-item checklist (A: experience extraction, B: system updates, C: memory sync). Triggered when user says 'wrap up'."
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
- **Full version**: Any trial-and-error, discoveries, changed understanding, **first time using new tool/platform** → Must run the full 12-item checklist below
- **Unsure** → Default to full version

---

## Full Version: 12-Item Checklist

⚠️ **Must go through each item; don't cherry-pick. Section A (experience extraction) and B (system updates) are the core value of secretary review — don't just do C (memory sync) and call it done.**

### A. Experience Extraction (review conversation, check each item)

1. **Pitfall record**: Tried a method that failed, then switched to another → `docs/lessons-learned.md`
2. **Knowledge correction**: Found a previous conclusion was wrong → correction note + `docs/lessons-learned.md`
3. **Better approach**: Found a better approach than expected → `docs/lessons-learned.md` or update existing SOP/Skill
4. **Collaboration friction**: Friction points in cross-agent collaboration → improve handoff protocol

### B. System Updates (check if system files need updating)

5. **New tool / new platform**: Did this session use a tool, platform, or service **for the first time**? → Update corresponding Skill or create new Skill
6. **Tool preference change**: Did user make a new tool choice decision (e.g., "from now on use X not Y")? → Update secretary Skill tool preferences
7. **Process change**: Do handoff protocol, organization rhythm, model routing, or other system rules need adjustment? → Update corresponding Skill
8. **Template gap**: Did you repeatedly write a certain format of document this session, worth making a template? → Evaluate creating Skill or updating refs/

### C. Memory Sync (ensure indexes reflect latest state)

9. **Main INDEX** → Update recent priorities, to-do status
10. **Project INDEX** → Update project-internal decisions, to-do items
11. **Secretary journal** → `workspace/inbox/YYYY-MM-DD.md`
12. **Project daily report** → `workspace/projects/{name}/daily/YYYY-MM-DD.md`

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

---

## Git Auto-Save (optional)

After C (memory sync) is complete, optionally run git commit to save changes:

```bash
# Remove any lingering lock files (Cowork mount limitation)
mv .git/index.lock .git/index.lock.tmp 2>/dev/null

# Stage all tracked changes
git add .gitignore CLAUDE.md .claude/ workspace/

# Commit with date + summary as message
git commit -m "wrap-up: YYYY-MM-DD HH:MM — [one-line summary of this session]"
```

> If git is unavailable or commit fails, skip it — doesn't affect the wrap-up flow. Auto-save is extra insurance, not mandatory.

---

## Wrap-Up Confirmation

Tell the user:

"Today's wrap-up is complete! I've organized:
- ✅ [Summary of completed items]
- 📝 Pending: [Items not yet completed]
- 💡 [If there are new thoughts or discoveries, mention them]
- 💾 Saved (git commit) — if applicable

I'll remember these next time we chat. Anything else to add?"
