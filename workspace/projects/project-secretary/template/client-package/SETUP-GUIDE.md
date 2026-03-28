# AI Secretary System — Configuration and Usage Guide

> This document has two parts:
> **Part A** for the setup technician
> **Part B** for the end user

---

# Part A: Technician Setup Guide

## What You Need

1. **Claude Desktop App already installed** on user's computer
2. User already has **Claude Pro / Max subscription** (Cowork features need paid plan)
3. All files from this `client-package` folder

## Setup Steps

### Step 1: Create User Folder

On user's computer, pick a folder as the secretary system root. Recommend user's home folder:

- Mac: `/Users/username/`
- Windows: `C:\Users\username\`

### Step 2: Copy Files

Copy **all files and folders** from `client-package` to the root above. After copying, structure should be:

```
User folder/
├── CLAUDE.md                    ← CRITICAL! Must be in root
├── .claude/
│   └── skills/
│       ├── secretary/SKILL.md   ← Secretary core behavior
│       ├── review/SKILL.md      ← Wrap-up Review
│       ├── handoff/SKILL.md     ← Handoff protocol
│       ├── project-setup/SKILL.md ← Project launch flow
│       ├── tool-scout/SKILL.md  ← Tool scout
│       ├── subagent-guide/SKILL.md ← Sub Agent guide
│       ├── knowledge-base/SKILL.md ← Knowledge base pipeline
│       ├── chrome-sop/SKILL.md  ← [Optional] Chrome SOP
│       ├── gcp-ops/SKILL.md     ← [Optional] GCP SOP
│       └── github-ops/SKILL.md  ← [Optional] GitHub SOP
├── docs/
│   ├── quickstart.md            ← Quick start (detailed version)
│   ├── faq.md                   ← FAQ
│   └── lessons-learned.md       ← Pitfalls and lessons
└── workspace/
    ├── INDEX.md
    ├── BEGINNER-TIPS.md         ← Beginner tips
    ├── inbox/
    ├── projects/
    ├── handoff/
    │   ├── pending/
    │   └── done/
    ├── summaries/
    │   ├── weekly/
    │   └── monthly/
    └── refs/
        ├── debate-agents/       ← Debate protocol + personas
        └── security-checklist.md ← Tool security checklist
```

> ⚠️ `.claude` is a hidden folder (starts with ".").
> On Mac press `Cmd + Shift + .` to show hidden files.
> On Windows go File Explorer → View → Show hidden items.

### Step 3: Confirm CLAUDE.md Position

**Most critical step**: Confirm `CLAUDE.md` in the **root directory** of the folder user will mount.

If user mounts `/Users/alice/` in Cowork later, then `CLAUDE.md` should be at `/Users/alice/CLAUDE.md`.

### Step 4: Open Cowork

1. Open Claude Desktop App
2. Click top-left menu → **Cowork** (or find Cowork from main screen)
3. System asks which folder → **Select the user folder from Step 1**
4. Start chatting

### Step 5: Verify

After opening Cowork, AI secretary should auto-detect first use and start setup wizard. If you see greeting and language preference questions, setup succeeded.

If AI doesn't enter wizard mode, check:
- Is `CLAUDE.md` in correct location (folder root)?
- Does `workspace/INDEX.md` exist (should have just one title line)?

### If User Using Antigravity (Not Cowork)

Antigravity doesn't auto-read CLAUDE.md, needs manual trigger.

1. Confirm Antigravity can access user's folder (same structure as above)
2. Tell user, every new conversation, first message:

   **"Please read CLAUDE.md then start secretary mode"**

3. AI will follow CLAUDE.md flow (first setup or normal secretary mode)

---

# Part B: User Guide

## What Is AI Secretary?

Your AI secretary will help you:
- **Remember what you're working on**: Things you tell it, it remembers next time
- **Manage to-do items**: Track what's done, what's pending
- **Organize thoughts**: Anytime dump ideas, it categorizes and tracks
- **Project management**: Each project's progress, decisions, to-do all recorded

## How to Start?

### First Time

1. Open **Claude** app on your computer
2. Go to **Cowork** mode
3. Pick a folder (technician will tell you which)
4. AI secretary auto-greets, guides you through initial setup
5. Answer its questions, about 5 minutes to finish

### Daily Use

Every time you open Cowork, AI secretary auto-reads your previous data, you chat directly.

**Common commands:**

| You Say | Secretary Does |
|---|---|
| (Direct chat) | Records, answers, gives suggestions |
| "Enter project mode XXX" | Focus on that project, discuss only that project |
| "Return to secretary mode" | Return to global view |
| "Wrap up" | Organize what you did today, update records |
| "Help me start new project" | Create new project tracking |

### Tips

1. **Anytime dump ideas**: Even half-baked ideas, secretary stores in staging
2. **Say "wrap up" before ending**: Secretary organizes notes, next time seamless
3. **Don't worry about exact phrasing**: Secretary adapts to your normal speech
4. **Manage many things**: Work projects, personal plans, random notes, all trackable

## Common Questions

**Q: How long does secretary remember?**
A: All records preserved. Recent ones more detailed, old ones auto-summarized, but originals always there.

**Q: Can I use my phone?**
A: Cowork currently only on computer Claude app. Phone Claude can chat but no secretary memory.

**Q: If I tell secretary very private things?**
A: Your data in your computer's folder (`workspace/` files). Claude doesn't use your chats for training. If privacy concerned, anytime open folder to check or delete files.

**Q: What if secretary makes a mistake?**
A: Just tell it "that's wrong, should be XXX." It corrects records.
