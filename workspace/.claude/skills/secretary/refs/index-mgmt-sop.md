# INDEX / Memory Management SOP

> The full SOP. The pointer lives in `secretary/SKILL.md`; read this on demand.

---

## 1. File Roles

| File | Role | Target lines |
|------|------|---------|
| **INDEX.md** | ID card — current status + open to-dos + navigation | < 150 |
| **memory.md** | Accumulated knowledge — designs, decisions, and durable facts still valid in 3 months | < 100 |
| **refs/** | Long procedures / templates / fill-in formats | no limit |
| **refs/index-archive-*.md** | Completed items / historical snapshots | no limit |

INDEX and memory keep only a one-line pointer to refs/; they don't hold the full procedure.

### Active-project row schema

```
| [Project name](path/INDEX.md) | {role ≤10 words} {status emoji} {milestone ≤15 words} |
```

**Status emojis**: 🟢 active / 🟡 needs attention / 🔴 blocked / ✅ stage done / ⏳ not started / ⛔ paused

**Do NOT put here**: specific numbers, next actions, deadlines — those go in the weekly plan + to-dos + that project's INDEX.

**Update triggers**:
1. Milestone reached/abandoned → update that row
2. Status downgrade (🟢→🟡 / 🟡→🔴) → update immediately + note the reason in recent priorities
3. Staleness thresholds: 14 days idle → 🟡, 30 days → 🔴, 60 days → ⛔ candidate
4. If you run a daily check, compare each row's status against that project's INDEX last-update and flag anomalies

---

## 2. SOP Extraction Criteria

### Pre-filter

**Event narratives (completed items / historical snapshots) go straight to archive, not through the criteria below.** The §2 criteria apply only to extracting *active* content. Completed items, post-mortems, and historical snapshots → `projects/{name}/refs/index-archive-YYYYMMDD.md`.

### Active-content extraction criteria

While slimming down, scan proactively; meeting **2 or more** → extraction candidate:

1. Has clear steps or a fixed procedure
2. Has a fixed format / template / fill-in example
3. Recurs (the same kind of task happens at least monthly — e.g. status reports, handoffs, weekly reviews)
4. Still valid in 3 months
5. Length > 15 lines OR duplicates existing memory/refs content OR is a completed-event narrative

### Before extracting, ask

"Is this **how to do it** or **why it's designed this way**?"

- **How to do it** → extract the SOP / template to refs/
- **Why this way** → put it in memory.md

Example: "the three-layer architecture decision" is design knowledge (→ memory), not an SOP.

### Four extraction destinations

| Type | Location | Example |
|------|------|------|
| Project-specific SOP/spec | `projects/{name}/refs/` | ProjectX `checkpoint-report-spec.md` |
| Cross-project process template | `.claude/skills/{name}/` or upgrade an existing Skill | debate-protocol |
| Pure fill-in template | the Skill's `templates/` subdirectory | handoff templates |
| Completed-event narrative | `projects/{name}/refs/index-archive-YYYYMMDD.md` | ProjectX `index-archive-20260415.md` |

**Archive naming**: `index-archive-YYYYMMDD.md`. Same-day repeated slim-downs append to the same file; a new day gets a new file.

**The archive file's first block must include**:
1. Source file (`INDEX.md` / `memory.md`)
2. Time range (which period the content covers)
3. Trigger (which slim-down / what drove it)

Format: `# {source file} archived content (YYYY-MM-DD {trigger})`

---

## 3. Gray-Area Criteria (memory vs INDEX)

- Still valid in 3 months → **memory**
- Expires over time → **INDEX / daily**
- Time-bound observations (live run data, a specific post-mortem) go to archive after more than one batch of new data; memory keeps only the general rule
- **Verified hypotheses**: compress the conclusion to one line in memory, extract the reasoning and supporting data to archive. Unverified hypotheses stay where they are.

### Examples

| Content | Goes to | Why |
|------|------|------|
| A three-layer architecture decision | memory | Design knowledge |
| Current snapshot: Project A at stage 3 | INDEX | Snapshot, will expire |
| How the payment API auth flow works | memory | Technical knowledge |
| This week's plan (W16) | INDEX | Time-sensitive |

### memory "further reading"

When refs/ exceeds 3 files, consider adding a "further reading" block at the end of memory listing the 3-5 most important ones. Not mandatory.

---

## 4. Organization Rhythm (layered)

| Frequency | Action | Who | Cost |
|------|------|---------|------|
| **Each wrap-up** | Update the main INDEX + write the inbox journal (no checks) | agent (wrap-up Skill) | low |
| **Daily (optional, you set it up)** | Secretary Review (incl. the daily check, §5) — **best-effort, not guaranteed; a fork has no such schedule by default** | a scheduled task you register on your platform (e.g. a Cowork scheduled task) | ~10K tokens |
| **First session each day (optional)** | A startup link-check, if you wire one up | a SessionStart hook on Claude Code (see `extras/`) | ~500 tokens |
| **Weekly (weekly-report Step 6)** | Structural slim-down: line-count check + SOP extraction candidates + move to archive | agent | high, 15-30 min |
| **Manual** | User says "slim down" / "impact check" | agent | on demand |

---

## 5. What a Daily Review Should Do

> ⚠️ This section describes what a daily Review *should do* **if you set one up**. A fork has **no such schedule by default** — register a scheduled task on your platform if you want it, and treat it as **best-effort, not guaranteed**. The reliable persistence layer is behavioral (wrap-up + the startup scan in CLAUDE.md); a schedule is a bonus.

### The daily check (three items)

1. **Refresh the status column** of the main INDEX's weekly-plan table
2. **Run a link-check** over the startup files (see §6) to catch broken links
3. **Scan every active project's INDEX line count**; list any over 150 lines
4. **Fold the health findings into the Review report** (don't write a separate sub-section)
5. **Write / replace / clear the alert block in the main INDEX**:

#### When there's a problem

Insert or replace, below the main INDEX's "system status" block:

```
<!-- impact-check-alert -->
⚠️ YYYY-MM-DD check: {Project A} {N} lines / {Project B} {N} lines / {M} broken links — see inbox/YYYY-MM-DD.md
<!-- /impact-check-alert -->
```

#### When there's no problem

Delete the entire `<!-- impact-check-alert -->` … `<!-- /impact-check-alert -->` block (including the markers).

#### When today's alert already exists

Replace it with the latest status — **don't append**.

### Registering it

If you want this to run on its own, register it as a scheduled task on your platform (Cowork supports scheduled tasks; on Claude Code, use a SessionStart hook or a scheduled routine). On a single machine, avoid registering two writers for the same files — pick the hook *or* the scheduled task, not both.

---

## 6. Impact-Check (link-check) SOP

The template ships an example link-check script at `extras/claude-code/scripts/impact_check.sh` (plus `startup_link_check.sh`). It's **optional** — run it manually, or wire it to a SessionStart hook (Claude Code) / scheduled task (Cowork) if you want it to run automatically. It does not run on its own unless you set that up.

### Startup files to check (the core set + refs)

1. `CLAUDE.md`
2. `INDEX.md`
3. any `projects/*/memory.md`
4. any file under `.claude/skills/handoff/`
5. any file under `.claude/skills/wrap-up/`
6. any refs those files point to (`refs/`, `projects/*/refs/`)

### Steps

1. Run `impact_check.sh <file path>`
2. Read the output:
   - **BROKEN** (target doesn't exist) → must fix
   - **SUSPICIOUS** (path exists but the anchor is wrong) → assess
   - **CLEAN** → pass
3. Fix every BROKEN item
4. When you move a file, leave one line at the old location: `> moved to {new path}` (keep for 3 months; the weekly Step 6 clears expired pointers)

### Running it manually (Cowork)

```bash
# In Cowork (adjust the path to your mount if needed)
bash extras/claude-code/scripts/impact_check.sh INDEX.md CLAUDE.md
```

The script derives the repo root from its own location; no absolute path needed.
