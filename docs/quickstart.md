# Quick Start Guide

> **First time here?** Read [`concept-guide.md`](concept-guide.md) first — it explains what this system is and why it exists (5 min).

Welcome to the AI Secretary system! This guide gets you set up in 5 minutes.

---

## Step One: Copy Template to Your Environment

1. Fork or clone this repo to your computer (Claude Code) or mount in Cowork
2. Mount (or point Claude Code to) the `workspace/` folder — it contains everything
3. Confirm `CLAUDE.md` is inside `workspace/`

---

## Step Two: First Launch

### Claude Code Users
```bash
cd ~/【Your folder】
# Open Claude Code, it auto-reads CLAUDE.md
```

### Cowork Users
```bash
# Mount this directory in Cowork
# Claude auto-loads CLAUDE.md and secretary Skill
```

### Other Platforms (Antigravity, etc.)
In conversation, manually run:
```
Please read CLAUDE.md, then start secretary mode
```

---

## Step Three: Initial Setup Wizard (First Time)

Secretary will ask you some questions:

1. **What language do you use?** → Example: "English"
2. **What's your main work?** → Example: "Software development and startups"
3. **What are you working on now?** → Example: "Project A, Project B, Task C"
4. **Confirm project list** → Secretary organizes into table, you confirm
5. **Done!** → `INDEX.md` auto-created

---

## Step Four: Daily Usage

### Secretary Mode (Default)
Chat anytime; secretary will:
- Record your thoughts
- Track to-do items
- Remind you of important deadlines

```
You: "I'm thinking whether I should start a new project"
Secretary: "Great idea! Want to start a project? I can set up the files"
```

### Enter Project Mode
```
You: "Enter project XXX mode"
Secretary: "Entering XXX project mode, now focused on this project"
```

### Wrap Up
End of day or week:
```
You: "Wrap up"
Secretary: "Did Review and organized everything"
```

---

## Key Files Overview

```
workspace/
├── CLAUDE.md                          ← System configuration (must read)
├── .claude/
│   └── skills/                        ← All Skills
│       ├── secretary/SKILL.md         ← Core rules
│       ├── review/SKILL.md            ← Wrap-up flow (13-item checklist)
│       ├── project-setup/SKILL.md     ← Project launch
│       ├── knowledge-base/SKILL.md    ← URL → summarize → synthesis → archive
│       ├── github-recon/SKILL.md      ← Paste GitHub URL → security check
│       └── ...（other Skills）
├── INDEX.md                            ← Main index (most important)
├── BEGINNER-TIPS.md                   ← Tips for beginners
├── inbox/                              ← Daily journals (auto-created)
├── projects/                           ← Project directory (auto-created)
├── summaries/                          ← Weekly/monthly summaries (auto-created)
├── knowledge-base/                     ← Personal knowledge base
│   ├── articles/                       ← Saved articles
│   ├── videos/                         ← Saved videos
│   ├── synthesis/                      ← Cross-article compiled pages (V0.5)
│   └── health-check/                  ← KB health reports
└── refs/                               ← Reference materials
    └── debate-agents/                 ← Debate protocol and personas
```

---

## Common Operations

| You Want... | You Say... |
|---|---|
| Start new project | "Start new project XXX" |
| Check this week's priorities | "What are this week's priorities" |
| Find old thought | "Check what I said about..." |
| Generate weekly report | "Generate weekly report" (secretary asks if there's anything new) |
| Return to secretary mode | "Return to secretary mode" |
| Save a link to knowledge base | "Save this: [URL]" |
| Security-check a GitHub repo | Paste a GitHub URL (auto-triggers recon) |
| Check memory status | "Secretary, what do you remember?" |

---

## Customize Your System

### Change Language
Edit `CLAUDE.md`, change `【Your language】` to desired language.

### Change Model
Edit `CLAUDE.md`, change `【Your model】` to Opus / Sonnet, etc.

### Add New Skill
Create new `{name}/SKILL.md` under `.claude/skills/`.

### Customize Memory Architecture
Edit secretary Skill's "Memory Architecture" section.

---

## Troubleshooting

### INDEX.md Shows Empty
**Problem**: Secretary says it can't find INDEX.md
**Solution**:
1. Confirm `INDEX.md` exists in this folder
2. If not, run first-time setup wizard
3. Secretary auto-creates it

### Skill Not Loading
**Problem**: Secretary says "don't know how to..."
**Solution**:
1. Claude Code / Cowork: Open new session
2. Other platforms: Manually read corresponding Skill file

### Memory Lost
**Problem**: Secretary says "what did you say last time?"
**Solution**:
1. Confirm files in this folder are not deleted
2. Use `git log` check if accidentally modified
3. Restore from backup (if available)

---

## Next Steps

- 📖 Read `BEGINNER-TIPS.md` for usage tips
- 📚 Read `docs/faq.md` for common questions
- 🎯 Start your first project!

---

## Need Help?

All Skills are listed in CLAUDE.md's table. Secretary auto-loads relevant Skill based on your needs.

Enjoy using your secretary!
