# FAQ (Frequently Asked Questions)

---

## Q1: What's the difference between memory.md and INDEX.md?

**A:** Simply put:
- **INDEX.md** = ID card (project name, status, to-do items)
- **memory.md** = Brain (key decisions, research conclusions, technical details)

**Specific differences**:

| Dimension | INDEX.md | memory.md |
|---|---|---|
| **Purpose** | Navigation and status tracking | Knowledge accumulation |
| **Content** | Project name, description, to-do list | Decision reasoning, tech verification, research findings |
| **Update frequency** | Weekly, at key milestones | Accumulate then write periodically |
| **Cold start use** | ❌ Too surface-level | ✅ Must read (get context) |
| **Audience** | Any Agent (cross-session) | Deep workers on same project |

**Example**:
- INDEX.md: "Brand revenue strategy — In progress — Finalized by month-end"
- memory.md: "Why chose Market A not Market B? Because [market analysis]... [decision record]..."

---

## Q2: Why not use Notion as memory layer?

**A:** Three reasons:

1. **Cross-platform consistency**
   - Markdown works on both Cowork and Claude Code
   - Notion needs API + extra auth, Cowork might not access

2. **Version control**
   - Markdown can git commit, full history
   - Notion changed is changed, can't rollback

3. **Offline available**
   - Markdown files on your computer
   - Notion down = can't see

**When to use Notion**: If only working on Claude Code (Mac), Notion works fine too. But this system prioritizes Markdown.

---

## Q3: What's the difference between Skill and SYSTEM.md?

**A:** SYSTEM.md is obsolete.

| Thing | Location | Description |
|---|---|---|
| **Skill (New)** | `.claude/skills/*/SKILL.md` | Has frontmatter (name, description), can auto-trigger |
| **SYSTEM.md (Old)** | `SYSTEM.md` | Plain text, no automation, manual read |

**Migration status**:
- ✅ Secretary core rules → secretary Skill
- ✅ Wrap-up flow → review Skill
- ✅ Handoff protocol → handoff Skill
- ✅ Chrome tool SOP → chrome-sop Skill
- ❌ SYSTEM.md deprecated, don't read

**If your old workspace still has SYSTEM.md**: Safe to delete, all content replaced by Skills.

---

## Q4: Do I have to do Debate?

**A:** Not necessarily. Depends on project type:

| Project Type | Debate? | Why |
|---|---|---|
| **Business decision** | ✅ **Must** | High risk, critical decision |
| **Infrastructure** | ⚠️ **Recommended** | If architectural disagreement |
| **Learning experiment** | ❌ **Can skip** | Low trial-and-error cost |
| **Pure execution** | ❌ **Can skip** | Direction already set |

**Quick judgment**:
- "This decision affects 6+ months of work" → **Do Debate**
- "This is just a side choice" → **Skip**

See project-setup Skill's branching logic.

---

## Q5: Cowork or Claude Code?

**A:** Simple comparison:

| | Claude Code | Cowork |
|---|---|---|
| **Device** | Your Mac / Linux | Cloud VM |
| **File access** | Anywhere on your machine | Mounted directories |
| **Tools** | Has gh CLI, gcloud, etc. | No CLI, Bash sandbox |
| **Token usage** | Uses your account | Separate billing (possibly better) |
| **Multi-location** | Only one machine | Anywhere, any device |
| **Secretary memory** | ✅ Identical | ✅ Identical (markdown) |

**Recommendation**:
- **Solo development** → Claude Code more comfortable
- **Need VM** → Cowork required
- **Distributed work** → Cowork more flexible
- **High volume** → Check token pricing

**This system supports seamless switching** ← Because memory all in markdown.

---

## Q6: How does cross-platform handoff work?

**A:** Use `handoff/` folder:

1. **Originator** (Claude Code) writes handoff file to `handoff/pending/`
   ```
   handoff/pending/2026-03-25-1430-urgent-task.md
   ```

2. **Receiver** (Cowork) opens session and scans `handoff/pending/`
   - Secretary auto-discovers new handoff task

3. **After completion**, receiver:
   - Write results to project journal
   - Move handoff file to `handoff/done/`

4. **Optional reply**:
   - If need to report back, write new handoff file to `pending/`

**Handoff file format**: See detailed explanation in handoff Skill.

---

## Q7: Too many projects, how to manage?

**A:** Use layers:

1. **INDEX.md lists only "active"** (keep to 3-5)
2. **In progress** → Started, monthly activity
3. **Paused** → Started, not progressing → Move to `projects/archived/`
4. **Completed** → Done → Move to `projects/done/`

**Organization rhythm**:
- **Weekly**: Check INDEX.md, confirm "activity"
- **Monthly**: Clean up, archive completed/paused projects

**Secretary reminder**: Over 5 active projects, secretary asks "want to organize?"

---

## Q8: How do I make AI remember what I said?

**A:** Three-layer memory:

| Layer | Storage | Load When |
|---|---|---|
| **Short-term** | Current dialogue context | Immediate (same session) |
| **Mid-term** | `projects/{name}/INDEX.md` | Enter project mode |
| **Long-term** | `projects/{name}/memory.md` | Cold start |

**What gets remembered**:
- ✅ Write to markdown file (remembered)
- ✅ Say "wrap up" (secretary auto-writes)
- ❌ Only say in dialogue (forgotten next session)

**Lesson**: Important things either write as files or record in INDEX.md. Don't rely only on voice.

---

## Q9: What if I run out of tokens?

**A:** Two strategies:

1. **Open new session**
   - Current session almost full → Say "wrap up"
   - Secretary auto-writes handoff
   - New session opens, secretary reads INDEX.md + journal, continue
   - **Zero memory loss**

2. **Downgrade model**
   - Some Skills can specify `model: sonnet` in frontmatter
   - Verification-type work doesn't need Opus, use Sonnet to save

3. **Cowork open Subagent**
   - Parallel tasks given to sub agent, each saves tokens
   - See subagent-guide Skill

**Best practice**:
- Deep thinking, decisions → Opus
- Information gathering, verification → Sonnet
- Parallel work → Sub Agent

---

## Q10: Is this system suitable for teams?

**A:** Current version is **not suitable for multi-person**, but has **partial support**:

| Scenario | Support | Description |
|---|---|---|
| **Solo project** | ✅ Full | Secretary serves you alone |
| **1 person leading + many supporting** | ⚠️ Partial | Use handoff/ mechanism to assign tasks |
| **Many people same project** | ❌ No | High git conflict risk, complex memory |
| **Distributed team** | ⚠️ Experimental | Via handoff/ and markdown |

**If startup team**:
1. Each person runs own secretary system
2. Use `handoff/` mechanism to hand off tasks
3. Keep "team shared memory" in Google Docs / Notion

**If multi-person work**:
- Wait for v1.0 team version (not planned, PR welcome)
- Or modify secretary Skill yourself to add collaboration mode

---

## Q11: How do I build a personal knowledge base?

**A:** Use the knowledge-base Skill:

1. **Save articles**: Share a URL in conversation → secretary fetches, summarizes, archives
2. **YouTube videos**: Same flow, extracts transcript if available
3. **Batch processing**: Drop URLs in `knowledge-base/inbox/fetch-queue.md`

**Where things go**:

| Content Type | Storage Path |
|---|---|
| Articles | `knowledge-base/articles/YYYY-MM-DD-slug.md` |
| Videos | `knowledge-base/videos/YYYY-MM-DD-slug.md` |
| Synthesis pages | `knowledge-base/synthesis/{topic}.md` |

**Project bridging** (the key differentiator):
- Each saved article gets tagged with related projects
- Secretary writes actionable digests to `projects/{name}/refs/kb-digest.md`
- Project agents read these on-demand for background knowledge

**Synthesis layer** (V0.5 new):
- When multiple articles share a topic, secretary compiles a **synthesis page** — a cross-article summary organized by theme
- Query uses **L1→L2→L3 tiered search**: first check the wiki index list (L1), then synthesis pages (L2), only open original articles (L3) when needed — saves tokens significantly
- Synthesis pages update continuously as new articles come in, so knowledge compounds over time

**Example workflow**:
```
You: "Save this: https://example.com/ai-marketing-guide"
Secretary: "Saved! Related to project Marketing-Strategy.
            Added digest to Marketing-Strategy/refs/kb-digest.md:
            - Key insight: [actionable summary]
            - Action item: [what to do next]"
```

---

## Q12: What is github-recon? When does it trigger?

**A:** github-recon is a **security reconnaissance Skill** that auto-triggers when you paste a GitHub repo URL in conversation.

**What it does**:
- Scans the repo's README, directory structure, dependencies, and commit patterns
- Produces a Red / Yellow / Green traffic-light assessment
- Checks a **red-flag list**: hardcoded secrets, suspicious install scripts, typosquatting package names, etc.

**Important distinction**: Recon ≠ source code review. Recon is a quick, read-only safety check before you clone or install anything. A full code review is a separate, deeper process.

**When to use**:
- Someone recommends a new tool or library → paste the URL, let recon run first
- Evaluating an MCP server or plugin → recon before installing

---

## Q13: What is "synthesis correction"?

**A:** When the review Skill runs the 13-item checklist, item A5 checks for **synthesis correction** — cases where new information contradicts or updates what's already in a synthesis page.

**Example**: Your synthesis page says "Tool X doesn't support feature Y," but today's article shows it now does. The secretary flags this, annotates the correction, and updates the synthesis page.

**Why it matters**: Without this, your compiled knowledge becomes stale. Synthesis correction keeps your knowledge base accurate as the world changes.

---

## Q14: How much does this cost?

**A:** Depends on your setup:

| Component | Cost | Required? |
|---|---|---|
| **Claude Max plan** | ~$100/month | Recommended (Opus access) |
| **Claude Pro plan** | ~$20/month | Works fine (Sonnet) |
| **Cloud VM** (GCP/AWS) | ~$5-10/month | Only if you need 24/7 cron jobs |
| **Gemini API** (Deep Research) | ~$0-5/month | Only if using Gemini for research |
| **The files themselves** | Free | Just Markdown on your computer |

**Minimum viable cost**: $20/month (Pro plan + local only). That gets you secretary mode, project management, knowledge base — everything except the most capable model.

**Author's setup**: ~$100/month (Max plan) + ~$7/month (GCP e2-micro VM for cron jobs). No API costs most months because Max plan includes generous usage.

**Cost-saving tips**:
- Use Sonnet (cheaper) for routine tasks, Opus only for decisions and deep thinking
- Run cron jobs on your own machine if it's always on — skip the VM
- GCP gives $300 free credits for new accounts

---

## Q15: Is it safe? Will the AI delete my files?

**A:** The AI operates within its working directory and can read/write any files there. This is powerful but comes with risk.

**Real incident**: The author's AI accidentally deleted a local file via terminal command. The file bypassed the trash — no recovery via Finder. Fortunately, git backup had it.

**Best practices (built into the system)**:

1. **Git backup everything** — Push to a private GitHub repo regularly. The handoff Skill includes git-commit handoff for platforms that can't push directly
2. **Use a dedicated folder** — Don't mount your entire home directory. Create a specific folder for this system
3. **Review before approving** — When the AI asks to run a command or modify a file, read what it's doing. Don't blindly approve
4. **`.gitignore` sensitive files** — The template includes rules to exclude credentials, API keys, and personal data from git
5. **(Optional) Use a separate machine or partition** — For maximum isolation, run on a dedicated machine or a virtual disk

**Bottom line**: Benefits significantly outweigh risks if you follow the backup practices. The system has been running daily for 3+ weeks with no data loss after the initial incident.

---

## Q16: How is this different from Claude Projects?

**A:** Claude Projects is great for single-topic deep work. This system is for managing your entire work life across multiple projects.

| Feature | Claude Projects | This System |
|---|---|---|
| **Scope** | One project at a time | Multiple projects + global overview |
| **Memory** | Project-level only (~200KB) | Layered: INDEX → inbox → memory → summaries |
| **Cross-project awareness** | ❌ | ✅ Secretary sees all projects |
| **Self-organization** | ❌ Manual | ✅ Automated review rhythm (daily/weekly/monthly) |
| **Cross-session handoff** | ❌ Start fresh each time | ✅ Structured handoff protocol |
| **Cross-model** | ❌ Claude only | ✅ Any model reads Markdown |
| **Knowledge base** | ❌ | ✅ URL → summarize → synthesize |
| **Learning from mistakes** | ❌ | ✅ 13-item review checklist + lessons accumulation |

**When Claude Projects is enough**: You have 1-2 focused projects, don't switch between them, and don't need knowledge accumulation across sessions.

**When you need this system**: You manage 3+ projects, need a "PM" to track everything, want knowledge to compound over time, or work across multiple AI platforms.

---

## Still have questions?

Check:
1. **Feature questions** → Relevant Skill file's detailed explanation
2. **Usage tips** → `BEGINNER-TIPS.md`
3. **Troubleshooting** → `docs/quickstart.md`'s troubleshooting section

Talk to secretary directly, it'll help!
