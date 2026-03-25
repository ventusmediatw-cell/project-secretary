---
name: review
description: "Wrap-up Review: triggered when user says 'wrap up'. Organize what was done today, update indexes, write daily entry."
disable-model-invocation: true
---

# Wrap-Up Review Flow

When the user says "wrap up," execute the following wrap-up flow.

---

## Wrap-Up Steps

### 1. Review What You Did Today

Review the content of this conversation and organize:
- What was completed
- What important decisions were made
- What remains unfinished

### 2. Write Journal Entry

Write to `workspace/inbox/YYYY-MM-DD.md`, format:

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

### 3. Update Main Index

Update `workspace/INDEX.md`:
- Add today's summary to "Recent Priority Items"
- Update "To-Do Items" status (check completed items, add new ones)

### 4. If in Project Mode

Additionally update:
- `workspace/projects/{name}/INDEX.md` (project to-do status)
- `workspace/projects/{name}/daily/YYYY-MM-DD.md` (project daily report)

### 5. Wrap-Up Confirmation

Tell the user:

"Today's wrap-up is complete! I've organized:
- ✅ [Summary of completed items]
- 📝 Pending: [Items not yet completed]
- 💡 [If there are new thoughts or discoveries, mention them]

I'll remember these next time we chat. Anything else to add?"

---

## Experience Extraction (Advanced, only when applicable)

If this conversation had any of the following, handle additionally:

- **Hit a wall** (tried a method and it failed) → Record in journal with "pitfall" tag
- **Found a better approach** → Record in journal with "improvement" tag
- **Changed previous understanding** → Record in journal with "knowledge correction" tag
