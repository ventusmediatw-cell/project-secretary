# Pitfalls and Best Practices

This document consolidates problems discovered in actual AI Secretary use, solutions, and best practices. Welcome to contribute your own pitfalls.

---

## Memory and File Structure

### Problem 1: Memory scattered, don't know where to find

**Symptoms**:
- "Secretary, do you remember X?"
- Secretary searches half-day, says "can't find in INDEX.md"
- Actually in daily/ journal

**Root cause**: No clear layering rules at start

**Solution**:
Follow secretary Skill's "Memory Write-Back Rules":
- **Key decisions / research conclusions** → `memory.md` (permanent, cold start read)
- **Status tracking / to-do items** → `INDEX.md` (latest state)
- **Time-series records** → `daily/YYYY-MM-DD.md` (who did what, when)

**Best practice**:
```
Before writing ask yourself:
- "Must know this next session?" → memory.md
- "What's current status?" → INDEX.md
- "Who did what when?" → daily/
```

---

### Problem 2: INDEX.md became junk pile

**Symptoms**:
- INDEX.md has 50+ lines, all messy to-do items
- "Recent priorities" unchanged from 2 months ago
- Opening INDEX.md, don't know what to prioritize

**Root cause**: No regular cleanup

**Solution**:
Build cleanup rhythm:
- **Each wrap-up** (session end): Update to-do, priorities (5 min)
- **Weekly**: Generate weekly report, secretary asks "new ideas?" → Chance to clean INDEX (30 min)
- **Monthly**: Big cleanup, archive completed, reshuffle priority (1 hour)

**Best practice**:
```
□ Each to-do add priority (High / Medium / Low)
□ After completion, check off then delete periodically
□ "Recent priorities" ≤ 5 items
□ Month-end delete items untouched 30+ days
```

---

## Debate and Decision-Making

### Problem 3: Debate length out of control

**Symptoms**:
- Want to discuss 3 topics
- First topic alone ~1500 characters
- Dialogue becomes Novel, decision muddier

**Root cause**:
- Word limits not enforced
- Topics too broad, should focus on decision points
- Advocate can't respond fully

**Solution**:
Reference debate-protocol Skill's word limits and topic screening:

| Stage | Limit | Enforce |
|---|---|---|
| Advocate opening | 200-300 | ❌ Secretary reminds |
| Each round exchange | 100-150 | ❌ Secretary reminds |
| Secretary convergence | 100 | ❌ Secretary reminds |

**Topic screening**:
```
❌ "How many competitors?" (information gathering)
✅ "Should we prioritize Market A or B?" (decision point)

❌ "How does tool X work?" (technical detail)
✅ "Custom build vs buy off-the-shelf?" (strategy choice)
```

**Best practice**:
Secretary announces at opening: "Max 3 topics, 2-3 rounds each, I'll stop if exceeding word limit."

---

### Problem 4: After Debate, disagreement not recorded

**Symptoms**:
- Debate ends, each side has different understanding
- Weeks later, discuss same issue, no previous conclusion
- "How did we decide last time?" → Secretary doesn't know

**Root cause**:
- Debate transcript not properly archived
- ✗ Disagreement points not recorded
- ❓ Pending items not consolidated

**Solution**:
debate-protocol already specifies storage:
```
workspace/projects/{name}/debates/{YYYY-MM-DD}-{topic}/
├── transcript.md   ← Complete dialogue
└── summary.md      ← ✓ Consensus, ✗ Disagreement, ❓ Pending
```

summary.md must include:
```markdown
## Core Consensus
✓ ...

## Key Disagreements
✗ A thinks X, B thinks Y

## User Decision Items
❓ Question 1: ...
❓ Question 2: ...
```

**Best practice**:
Secretary produces summary immediately after Debate, user reviews again before decision, confirm nothing missed.

---

## Tools and Platforms

### Problem 5: gcloud CLI config fails

**Symptoms**:
- In Cowork `gcloud compute ssh` hangs
- Or OAuth login stuck
- `gcloud` can't find Google account

**Root cause**:
- Cowork needs Network Egress enabled for Google login
- First login needs manual browser confirmation

**Solution**:
See gcp-ops Skill's "Cowork Sandbox" section:
1. Settings → Enable Network Egress
2. Run `curl -sSL https://sdk.cloud.google.com | bash`
3. Run `gcloud init` → Browser login window appears

**Best practice**:
```
□ Enable Network Egress from start (don't wait)
□ Before gcloud init, confirm Egress enabled in Settings
□ If login fails, check internet (use curl test)
```

---

### Problem 6: GitHub PAT leak risk

**Symptoms**:
- Secretary pastes GitHub PAT in dialogue
- User alarmed "will it leak?"
- Don't know what to do

**Root cause**:
- Dialogue content might be saved, exported, or shared
- PAT in dialogue = assume leaked

**Solution**:
See github-ops Skill's "PAT Usage Rules":
1. Use Classic PAT, not fine-grained
2. **PAT in dialogue = treat as leaked**
3. After operations immediately remind user to revoke
4. Use `credential.helper store` local storage, avoid re-entering

**Best practice**:
```
□ Before git operation, secretary reminds "revoke PAT after"
□ After operation, remind user to GitHub Settings to revoke
□ Check ~/.git-credentials won't be committed (.gitignore)
□ Multi-person same machine? Use `credential.helper store` not in code
```

---

## Cross-Platform Collaboration

### Problem 7: File sync between Cowork and Claude Code

**Symptoms**:
- Cowork wrote memory.md, Claude Code doesn't see new content
- Vice versa
- Don't know which version is latest

**Root cause**:
- No unified source of truth
- Git not regularly pushed / pulled

**Solution**:
This system treats workspace markdown as source of truth. Ensure sync:
1. **Always write handoff** at session end (secretary auto-does)
2. **Handoff written where**:
   - Cowork → `workspace/inbox/YYYY-MM-DD.md`
   - Claude Code project mode → `workspace/projects/{name}/daily/YYYY-MM-DD.md`
3. **Cross-platform tasks** → `workspace/handoff/pending/`

**Best practice**:
```
□ Regularly git push (each session end)
□ Before new session git pull
□ If conflict, manually merge (markdown usually merges easily)
□ Use handoff/ mechanism not voice
```

---

### Problem 8: Sub Agent prompt not clear

**Symptoms**:
- Launch sub agent, say "research X"
- Sub agent spends 20% tokens on "what do you want"
- Output not what you expected

**Root cause**:
- Sub agent doesn't inherit main agent context
- Prompt must be **complete and explicit**

**Solution**:
See subagent-guide Skill's "Usage Notes":
1. **Complete explicit prompt**:
   ```
   Don't: "Research X market"
   Do: "Search X market size, growth rate, main players (2023-2025).
        Return format: {market_size: $X, growth: Y%, players: [list]}"
   ```

2. **Give expected output format**: JSON, table, markdown list?

3. **Clear paths and parameters**:
   ```
   "Scan workspace/projects/foo/refs/ all .md files,
    find paragraphs with 'decision', organize chronologically"
   ```

**Best practice**:
```
□ Sub agent prompt detailed like instruction manual
□ Provide expected output sample
□ Limit search scope (file path, time range)
□ 1-2 sentences background, 3-5 sentences concrete instruction
```

---

## Daily Habits

### Problem 9: Forgot to say "wrap up"

**Symptoms**:
- Work 2 hours, say goodbye
- Didn't say "wrap up," secretary didn't write handoff
- Next session, secretary says "what did you do last time? no idea"

**Root cause**:
- Manual reminding easy to forget
- Secretary doesn't auto-do (waits for trigger)

**Solution**:
Build habit:
1. **End work, always say "wrap up"**
2. **Secretary auto**:
   - Write handoff to inbox/ or daily/
   - Update INDEX.md
   - Organize to-do

3. If often forget: Set reminder (Cowork scheduled task)

**Best practice**:
```
□ Add "say wrap up before end" to daily workflow
□ Consider Cowork scheduled task: end-of-day "don't forget wrap up" reminder
□ Review secretary's handoff, ensure clear, add if needed
```

---

### Problem 10: Started project but no follow-through

**Symptoms**:
- Opened 5 projects
- 2 completed, 2 frozen, 1 active
- INDEX.md lists all 5, don't know which priority

**Root cause**:
- No regular cleanup
- "Activity" not dynamic

**Solution**:
Build cleanup rhythm (see Problem 2 solution):
1. **Weekly check** INDEX.md "activity" column
2. **Activity categories**:
   - **High**: This week had action
   - **Medium**: This month had action
   - **Low**: Completed or paused

3. **Monthly big cleanup**:
   - Completed → `projects/done/`
   - Paused → `projects/archived/` / await-revival list
   - Keep INDEX.md only "active" (3-5)

**Best practice**:
```
□ INDEX.md "active projects" add "last pushed date" column
□ Untouched 30+ days → Mark "paused," move away
□ Month-end "project health check"
□ Decision-class projects write memory.md after completion, then archive
```

---

## Contribute Your Pitfalls

Found new problems? Welcome to:
1. Describe in GitHub issue
2. PR to update this file
3. Or tell secretary "I hit a pitfall..." secretary helps record

---

## Summary: Golden Rules

| Principle | Description |
|---|---|
| **Write it down** | Important things must write to markdown file, don't rely only on voice |
| **Regular cleanup** | Weekly check INDEX.md, monthly cleanup |
| **Clear hierarchy** | memory (knowledge), INDEX (status), daily (events) each own role |
| **Clear handoff** | Each session end say "wrap up," auto-generate handoff |
| **Cross-platform sync** | Use git + markdown, don't depend on SaaS |
| **Clear instructions** | Agent / Sub Agent prompts detailed like manual |

Follow these, your secretary system becomes rock-solid.
