# AI Secretary System — Configuration and Usage Guide

> This document has two parts:
> **Part A** for the setup technician
> **Part B** for the end user

---

# Part A: Technician Setup Guide

## What You Need

1. **Claude Desktop App already installed** on user's computer
2. User already has **Claude Pro / Max subscription** (Cowork features need paid plan)
3. This repo cloned or downloaded

## Setup Steps

### Step 1: Clone the Repo

```bash
git clone https://github.com/your-username/project-secretary.git
```

### Step 2: Mount workspace/ Folder

Open Claude Desktop → Cowork (or Claude Code), and **mount the `workspace/` folder** from the cloned repo.

After mounting, AI will see this structure:

```
workspace/                          ← User mounts this folder
├── CLAUDE.md                       ← CRITICAL! AI reads this first
├── .claude/
│   └── skills/
│       ├── secretary/SKILL.md      ← Secretary core behavior
│       ├── wrap-up/SKILL.md        ← Wrap-up Review (13-item checklist)
│       ├── handoff/SKILL.md        ← Handoff protocol
│       ├── project-setup/SKILL.md  ← Project launch flow
│       ├── knowledge-base/SKILL.md ← Knowledge base pipeline
│       ├── tool-scout/SKILL.md     ← Tool discovery + security
│       ├── meta-skill/SKILL.md     ← Build / audit a single skill
│       ├── plan-discuss/SKILL.md   ← Multi-model plan review
│       └── audio-transcribe/SKILL.md ← Meeting / voice-note transcription
├── INDEX.md                        ← Main index (project list, to-dos)
├── BEGINNER-TIPS.md                ← Beginner tips
├── SETUP-GUIDE.md                  ← This file
├── inbox/                          ← Daily journals (auto-created)
├── projects/                       ← Project directory (auto-created)
├── handoff/
│   ├── pending/                    ← Cross-platform pending handoffs
│   └── done/                       ← Processed archive
├── summaries/
│   ├── weekly/                     ← Weekly reports
│   └── monthly/                    ← Monthly reports
├── knowledge-base/
│   ├── articles/                   ← Saved articles
│   ├── videos/                     ← Saved videos
│   └── inbox/fetch-queue.md        ← Batch processing queue
└── refs/
    ├── debate-agents/              ← Debate protocol + personas
    └── security-checklist.md       ← Tool security checklist
```

> `.claude` is a hidden folder (starts with ".").
> On Mac press `Cmd + Shift + .` to show hidden files.
> On Windows go File Explorer → View → Show hidden items.

> **Alternative (Claude Code — clone anywhere):** Instead of moving the repo to a fixed location, you can clone it **anywhere** and add a shell alias to jump straight into the workspace. Add to `~/.zshrc` (or `~/.bashrc`):
>
> ```bash
> alias secretary='cd /path/to/project-secretary/workspace'
> ```
>
> Then typing `secretary` drops you into the workspace from any directory. This keeps the repo wherever you cloned it — a second path that stands parallel to the mount-at-root approach above, whichever the user prefers.

### Step 3: Verify CLAUDE.md Position

**Most critical step**: Confirm `CLAUDE.md` is at the **root** of the mounted folder (i.e., directly inside `workspace/`).

If user mounts `workspace/` in Cowork, then CLAUDE.md should be at the top level of the mount.

### Step 4: Open Cowork

1. Open Claude Desktop App
2. Click top-left menu → **Cowork** (or find Cowork from main screen)
3. System asks which folder → **Select the `workspace/` folder**
4. Start chatting

### Step 5: Verify

After you select the folder and **send a first message** (e.g. "start" — no special command or keyword needed), the AI secretary detects first use and runs the setup wizard in its reply. If you see a greeting and language-preference questions, setup succeeded.

If AI doesn't enter wizard mode, check:
- Is `CLAUDE.md` in correct location (folder root)?
- Does `INDEX.md` exist (should have placeholder text)?

### ⚠️ Caution: Pre-existing Machine (not a fresh install)

If the user's computer has been used with Claude before, `~/.claude/projects/` may already hold data from **unrelated** past sessions. The first-use wizard must **not** silently treat that leftover data as identity clues about this user — doing so pulls in stale, wrong context. On a non-fresh machine:

- Check whether `~/.claude/projects/` already contains folders from prior use.
- If it does, say so to the user explicitly ("this machine already has Claude data from before") instead of passively inferring who they are from it.
- Treat the mounted `workspace/` repo as the **only** source of secretary identity — not leftover `~/.claude/` state.

### If User Using Antigravity (Not Cowork)

Antigravity doesn't auto-read CLAUDE.md, needs manual trigger.

1. Confirm Antigravity can access the `workspace/` folder (same structure as above)
2. Tell user, every new conversation, first message:

   **"Please read CLAUDE.md then start as my secretary"**

3. AI will follow CLAUDE.md flow (first-time setup or normal secretary operation)

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
3. Pick the **workspace/** folder (technician will tell you which)
4. Send a first message (e.g. "start"); the AI secretary reports in and guides you through initial setup
5. Answer its questions, about 5 minutes to finish

### Daily Use

Every time you open Cowork, send a first message and the AI secretary reads your previous data and reports in — then you chat as normal.

**Common commands:**

| You Say | Secretary Does |
|---|---|
| (Direct chat) | Records, answers, gives suggestions |
| "Focus on project XXX" | Focus on that project, discuss only that project |
| "Back to the global view" | Stop focusing on a specific project |
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
A: Your data stays in this folder's files. Claude doesn't use your chats for training. If privacy concerned, anytime open folder to check or delete files.

**Q: What if secretary makes a mistake?**
A: Just tell it "that's wrong, should be XXX." It corrects records.
