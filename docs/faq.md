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
| **SYSTEM.md (Old)** | `workspace/SYSTEM.md` | Plain text, no automation, manual read |

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

**A:** Use `workspace/handoff/` folder:

1. **Originator** (Claude Code) writes handoff file to `handoff/pending/`
   ```
   workspace/handoff/pending/2026-03-25-1430-urgent-task.md
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
3. **Paused** → Started, not progressing → Move to `workspace/projects/archived/`
4. **Completed** → Done → Move to `workspace/projects/done/`

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
3. **Batch processing**: Drop URLs in `workspace/knowledge-base/inbox/fetch-queue.md`

**Where things go**:

| Content Type | Storage Path |
|---|---|
| Articles | `workspace/knowledge-base/articles/YYYY-MM-DD-slug.md` |
| Videos | `workspace/knowledge-base/videos/YYYY-MM-DD-slug.md` |

**Project bridging** (the key differentiator):
- Each saved article gets tagged with related projects
- Secretary writes actionable digests to `projects/{name}/refs/kb-digest.md`
- Project agents read these on-demand for background knowledge

**Example workflow**:
```
You: "Save this: https://example.com/ai-marketing-guide"
Secretary: "Saved! Related to project Marketing-Strategy.
            Added digest to Marketing-Strategy/refs/kb-digest.md:
            - Key insight: [actionable summary]
            - Action item: [what to do next]"
```

---

## Still have questions?

Check:
1. **Feature questions** → Relevant Skill file's detailed explanation
2. **Usage tips** → `workspace/BEGINNER-TIPS.md`
3. **Troubleshooting** → `docs/quickstart.md`'s troubleshooting section

Talk to secretary directly, it'll help!
