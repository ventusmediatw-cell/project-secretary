## Building a new skill — the detailed A→E checklist

> This checklist synthesizes best practices from multiple sources: lessons from ad-hoc digging (including a data-layer upgrade + a parser bug class) + the shape of open-source skillset workflows + the Anthropic official skill-creator iteration loop.

## Table of contents

- **A. before building** — guard against over-build (question the premise / find what exists / confirm N≥2 / two-stage design / decision form)
- **B. while building** — guard against bugs and breakage (align to the authoritative parser / DRY / fault-tolerance + normalization + validator / inline-or-isolate / soft→hard / 25K-token boundary)
- **C. verify** — guard against self-blind-spots (you only know once you've run it / enumeration beats counting / second-agent review / 13-item wrap-up / dogfood the first user case)
- **D. maintain** — guard against bloat ("update" = add + subtract + consolidate + harden / history into archive / scattered actions → consolidated into a workflow)
- **E. cross-platform** — guard against environment traps (platform limits / cross-platform md mirroring / handoff pattern)

> **When to read**: the user wants to build a new skill, or you've surfaced some repeated workflow that's ready to start. The §1 reference point in SKILL.md is the entry.

## A. before building — guard against over-build

> Most things people want to extract into a skill **shouldn't be**. This stage blocks fake needs.

### A.1 Question the premise

Ask three times:
1. "Is this really needed?" — list what bad thing happens if you don't do it, described with a concrete case
2. "How many times a year does this bad thing happen?" — estimate frequency; N<3/year usually isn't worth it
3. "Can an existing SOP / SKILL / tool cover 80%?" — answer only after you've gone through all SKILLs + existing SOP directories

### A.2 Find what exists (both phases mandatory, guards against wasted work)

**Phase 1: local scan**
- grep `.claude/skills/*/SKILL.md` for functional overlap
- grep existing SOP directories for an SOP-form equivalent
- grep existing templates directories for an existing template
- check the ideas staging area for a related idea already parked there (upgrading it to a skill beats building new)

**Phase 2: upstream scan** (**mandatory**, guards against the wasted-work anti-pattern)
- scan the Anthropic plugin marketplace (run `/plugin search <keyword>` inside Claude Code, or fetch the official plugins page)
- scan public skill-spec sites
- scan the MCP Registry
- scan high-star GitHub repos (open-source impls of the same concept)
- found an official match → install + evaluate / lightly modify; build your own only if nothing exists

**Why both phases are mandatory**: a common trap is to finish a local port, then discover an official plugin of the same kind already existed all along — the whole effort wasted. The local scan missing an already-mature upstream solution is a recurring cost sink → promoted to a hard rule.

### A.3 Confirm N≥2

- **N=1 observe**: only one successful run; write it into an observation note; wait for next time
- **Upgrade to a SKILL only at N=2**: redone across sessions + proven stable

### A.4 Two-stage design

Aligned with the data-layer upgrade lesson:
- **Cheap pre-filter** (tag / index slicing / rule filter) → narrow the scope
- **Expensive judgment** (top-down / LLM / full-text scan) → run only on what the pre-filter leaves

**Never brute-force the whole store** — index/tag exist precisely to bind cost.

### A.5 Decision form

- **Guidance-style SKILL.md** (baseline) — the agent reads the rules and acts on its own
- **Interactive workflow** (slash command + AskUserQuestion) — suited to complex decision trees
- **scripts/** (python/shell) — suited to deterministic automation
- **automation** (hook / cron / scheduled task) — suited to event triggers

Default to the baseline first; escalate to interactive only for complex decisions; move to scripts/ only when deterministic.

---

## B. while building — guard against bugs and breakage

### B.1 Align to the authoritative parser

For tools that read existing data, **parsing must align to the authoritative source**:
- Example 1: the authoritative parser recognizes two formats → the derived tool must copy it exactly, or it misses edge cases
- Example 2: extract the shared parsing into a standalone module (e.g. `<domain>_common.py`); don't keep it only in the main tool

**Anti-pattern class**: multiple tools each write half a parser, the shared logic isn't extracted → the bug shows up in the fallback path you weren't watching (a recurring trap).

### B.2 DRY — extract shared logic

- Duplication is a breeding ground for bugs
- Duplication seeds "a 1-place change becomes an N-place change"
- The shared module (`<domain>_common.py`, `utils/`, etc.) must be clearly named, not "I don't even know what to call it"

### B.3 Heterogeneous-data fault-tolerance + normalization + validator

Three pieces:
1. **Tool fault-tolerance**: the parser recognizes two formats / inconsistent casing / null
2. **Source-data normalization**: periodically run normalize to align old data to the new standard
3. **Ingest validator**: block dirty data at write time, curing pollution at the root

### B.4 inline-or-isolate (third-state anti-pattern)

- **Short** → inline into SKILL.md (< 50-line checklists / examples)
- **Large** → isolate into `references/*.md` (teaching material, very long checklists, principle discussions)
- **scripts** → isolate into `scripts/*.py` and mention in SKILL.md how to run them

**The "referenced-nonexistent-undisclosed" third state is forbidden**:
- ❌ SKILL.md says `see references/foo.md`, but the file doesn't exist
- ❌ SKILL.md mentions some script, but the file lives outside the workspace
- ✅ everything referenced exists; all external dependencies are explicitly disclosed

### B.5 soft → hard

- **soft** (will be sampled past / ignored): "please try to do X" "should X" "consider X"
- **hard** (grep-able, explicit): "must do X before Y" "when X doesn't exist, always take branch Z"
- Write execution-critical rules 100% as hard; write soft only to explain why it's done this way

### B.6 25K-token boundary

A single file < 25K tokens; otherwise:
- split into multiple references/ files
- pair with a paginated-read SOP (explicitly write "when reading §X, offset N, limit M")

### B.7 Splitting hard rule — pre-check

When you hit the following situations while writing a new SKILL → **isolate to references/ immediately, don't write it into the SKILL.md body**:

| Situation | Destination |
|---|---|
| "YYYY-MM-DD added / origin / field evolution / upgrade conditions" | `references/changelog.md` |
| internal bug / lesson number references | `references/lessons-cases.md` |
| specific person name / chat ID / account / internal path / API key | `references/system-config.md` (gitignore if needed) |
| design rationale longer than 1 line ("why it's done this way") | `references/*-design.md` |
| frozen / pending-thaw / low-frequency workflow | `references/cold-workflows.md` |

**Why a pre-check**: nearly all early-shipped SKILLs violated this rule. Retrofitting after the fact costs 3–10× more than blocking it at write time.

**Linkage to audit Tier 1**: the anatomy checklist's matching 5 items; this rule is the build-stage counterpart.

### B.8 retrofit-complete 8-step check (closing protocol)

**When to trigger**: after finishing a retrofit on an existing SKILL (body change / split into references/ / rename / description upgrade), before claiming "retrofit done."

**Why**: it's been repeatedly observed that "the retrofit statement ≠ the actual state" — the agent claims "retrofit done" but actually skips several closing steps: PII not redacted, index description not synced, old paths / old line numbers not aligned, cross-trigger not compared against other SKILLs. A retrofit has no equivalent ship checklist → completeness is underestimated, and a follow-up audit will catch it. These 8 steps are a mandatory closing protocol.

**8 steps (run in order, don't skip)**:

| # | Step | grep / action |
|---|---|---|
| 1 | SKILL.md body finished, line count / structure matches expectation | `wc -l SKILL.md`, manually scan the anchor sections |
| 2 | **Full PII redact scan** (mandatory keyword grep) | Scope: **SKILL.md body + references/ + templates/ + frontmatter** (not just references/). Scan class by class against the "PII three-class keyword table" below; any hit → reject, must redact (real name → "collaborator X" / internal project name → "project A/B" / account or key → `[redacted]`). See "§B.8 step 2 PII classification handling" at the end of this file. |
| 3 | Sync the index description | grep the system index files (e.g. CLAUDE.md / README) for that skill's section, align it to the new description |
| 4 | sibling refs / templates / usage-guide renamed consistently | grep `<old-name>` across the whole workspace + `.claude/`, find stale references |
| 5 | grep dated references in conversation logs / handoffs + mark stale | grep the handoff and journal directories; old line numbers / old paths must be marked `(out of date, current state see ...)` or fixed |
| 6 | cross-trigger compared against other SKILLs (substring + by-design distinction) | grep other SKILL descriptions for overlapping trigger phrases; judge whether it's trigger-stealing (fix it) or by-design sharing (don't fix, write a disambiguator) |
| 7 | dispatch a sub-agent to run an impact assessment | use a general-purpose subagent to run P0/P1/P2/P3 severity findings; confirm nothing was missed |
| 8 | **Self-run dogfood immediately after ship, don't wait for the user** | self-run 3 kinds of grep: (a) PII keyword (same as step 2) / (b) cross-skill propagation (index + sibling SKILL refs) / (c) self-narrative consistency (supersession / errata / line numbers between earlier and later sections). Hit > 0 must be surfaced to the user; don't trust your own "should be OK" intuition. **An LLM's tendency to self-run dogfood = 0, so it must be enforced** |

**Typical traps**:
- Skip step 2 → PII leaks into references/, unrecoverable after a git push
- Skip step 3 → the index description goes stale, an external agent sees the old description and runs the wrong flow
- Skip step 6 → two SKILLs fight over the same trigger, the user triggers it and silently runs the wrong skill
- Skip step 8 → ship done, you turn to the next SKILL and skip again, until the user proactively triggers it before you patch (self-recursive, extremely strong)

**Alignment**: §A.2 two-phase upstream scan in this file = build stage; this §B.8 8 steps = retrofit stage; both are anti-pattern defense mechanisms.

### §B.8 step 2 PII classification handling

**Why it must run**: a retrofit spec often claims "PII already abstracted" while actually doing nothing. For a public-facing repo (a template that spreads) this must be enforced especially strictly — any real name / internal project / account or key leaking into a tracked file is unrecoverable after a git push.

**PII three-class keyword table (replace with the words your system actually uses, then grep class by class)**:

| Class | keyword type | handling |
|---|---|---|
| **Class A (must redact)** | real names (collaborators / clients / employees, private context), personal chat IDs, API keys | must redact → "collaborator X" / "[redacted]", or add a CONFIDENTIAL banner (internal-only) |
| **Class B (keep by-design)** | public author + public repo + public framework label (design-source attribution naming, e.g. Anthropic skill-creator) | **do NOT redact**; redacting would break the design semantics |
| **Class C (optionally abstract)** | internal project / platform codenames inside internal SOPs / case narratives | choose by audience: internal readability vs external isolation; for external distribution → abstract to "project A/B" |

**Scan scope** (run all):
1. `SKILL.md` body (not just references/)
2. `references/*.md`
3. `templates/*.md`
4. SKILL frontmatter description

**Operation (template; replace `<...>` with your system's actual sensitive-term list)**:
```bash
cd .claude/skills/<target>
grep -nE "<real-name-1>|<real-name-2>|<internal-project>|<account>|<api-key-prefix>" \
  SKILL.md references/*.md templates/*.md 2>&1 || echo "CLEAN"
```

**Decision flow**:
1. grep hit → see which class the keyword belongs to
2. Class A → reject immediately, must redact
3. Class B → keep, add a note explaining "by-design public-source reference" (option)
4. Class C → check whether the SKILL is externally distributed: if external → abstract; if internal-only → keep readability

**Typical mistake**: treating Class B (public framework attribution) as Class A and redacting it, breaking the "multi-source synthesis" design semantics (a public framework's attribution naming is necessary).

**Recommended handling pattern (placeholder + gitignored ref)**:
- Use placeholders in the SKILL body (`{COLLABORATOR-PRIMARY}` / `{TEAM-MEMBER-A/B/C}` / `{CLIENT-PROJECT-A}` / `{INTERNAL-ORG}`)
- Write the real-name mapping in `references/_private-glossary.md`, and add the pattern `.claude/skills/*/references/_private-*.md` to `.gitignore` to ensure it stays internal
- Other tracked references (cases / changelog / system-config) also use placeholders, no real names
- This pattern is smarter than "CONFIDENTIAL banner internal-only": the SKILL stays clean for external use / grounded internally / the pattern generalizes to other internal-only SKILLs

---

## C. verify — guard against self-blind-spots

> Recurring lesson: self-review doesn't catch enough (a cold-start review by a different model family often surfaces 10+ missed findings in one round); the plan itself must also be reviewed before execution.

### C.1 You only know once you've run it

build → run → read the **actual output**, don't rely on reasoning alone:
- run one full workflow
- read stdout / output files
- compare expected vs actual

Most bugs only appear once you run it.

### C.2 Enumeration beats counting

- Don't trust aggregate numbers ("16 related items," but enumeration lists only 3)
- For ground truth you must enumerate
- When the count and the enumeration disagree, trust the enumeration

### C.3 Send to a different-model-family cold-start review

After building a SKILL, send it to a second agent of a **different model family** for a cold-start review (any second agent works):
- a different family is best at catching "the same LLM's blind spots"
- give it minimal context, let it cold-start by reading SKILL.md + references/, simulating an unfamiliar user
- adjudicate the findings manually after they come back; don't accept everything wholesale

### C.4 13-item wrap-up review

After building a SKILL, run the 13-item wrap-up review checklist:
- completeness / synthesis-correction / boundary / cross-platform...
- (if your system has a dedicated wrap-up / review skill, use it; if not, treat these 13 items as a standalone checklist and go through each)

### C.5 The first user case must be a dogfood

- The first trigger after a SKILL ships must be a real user case
- Don't fake-trigger, don't run with a fixture
- Once N=1 passes, record it in an observation note

---

## D. maintain — guard against bloat

### D.1 "Update" = add + subtract + consolidate + harden

Not just adding:
- **add**: new case / new rule
- **subtract**: expired N=1 observations that never upgraded
- **consolidate**: merge two similar rules into one, spelling out the boundary
- **harden**: soft → hard upgrade (after the observation period passes)

Aligned with the "only adds, never subtracts" anti-pattern that reviewers often point out.

### D.2 History into archive, SKILL.md keeps only navigation

- The main SKILL.md is an entry point, < 500 lines, pure navigation + core principles
- Teaching material / examples / detailed checklists into references/
- Stale cases into references/archive/ or deleted

### D.3 Scattered actions → consolidate into a workflow

Lesson: multiple ad-hoc scripts → a unified CLI + one happy-path healthy workflow (e.g. a chain like count_sync → lint → route → graph).

The same applies to a SKILL's references/: don't scatter across multiple files cross-linking each other; merge into one happy path.

---

## E. cross-platform — guard against environment traps

### E.1 Platform limits

- **Restricted platforms** (e.g. some cloud collaboration interfaces): can't git / can't modify `.claude/skills/` (protected) → hand off to a platform with full permission
- **Local Claude Code**: full permission, but the OS sandbox has file-access / permission boundaries
- **Other agents that don't recognize the SKILL format** (e.g. some Gemini-family tools): need to Read SKILL.md directly, so SKILL.md must be plain readable markdown

### E.2 Cross-platform md mirroring

- The SKILL logic itself = plain markdown
- Don't depend on hook / settings.json / plugin runtime on the logic path
- Side effects unreachable on a restricted platform (git, writing `.claude/`) get an explicit fallback: hand off to a platform with permission

### E.3 Handoff pattern

Aligned with the `handoff` SKILL:
- Write SKILL logic (plain md) on a restricted platform → land it in `.claude/skills/` on a platform with permission
- Write a handoff bundle into the handoff queue directory
- The picking-up session auto-surfaces it