---
name: meta-skill
description: "Meta-skill for building and auditing a **single** skill — a three-piece kit: build / standards / audit (qualitative, trigger-based). Make sure to use this skill whenever the user wants to build, audit, or modify a specific skill, or check skill anatomy/standards — even when they describe the same intent without saying the word \"skill\" explicitly (phrases like \"extract this flow into something reusable,\" \"does this one meet the standard,\" \"this one looks off\" also count). Three workflows: (1) the A→E flow for building a new skill (before/build/verify/maintain/cross-platform), (2) SKILL anatomy + boundary checklist, (3) 4-Tier single-skill audit + retrofit prioritization. Trigger phrases: \"build a skill / extract this flow into a skill / fix a skill / modify a skill / check this skill / audit this skill / audit my skill / skillset-audit / audit the health of some SKILL,\" or when the secretary notices repeated work with N≥2 and a non-trivial cost to redo. **Does NOT handle**: scheduled sweeps of the whole SKILL portfolio (you can build a dedicated scheduled-maintenance skill later). For the detailed build flow see `references/build-checklist.md`."
---

# Meta-Skill: the meta-skill for building skills and auditing skills

Lets the user "grow" new skills themselves, not just use the few shipped with the repo. This skill synthesizes best practices from multiple sources (including the Anthropic official `skill-creator` spec, the shape of open-source skillset workflows, and an external skillset-audit method) into a reusable three-piece kit: build / standards / audit.

## Trigger

**When to trigger**:
- User says: "build a skill / extract this flow into a skill / check this skill / audit this skill / audit my skill / skillset-audit / audit the health of some SKILL"
- The secretary notices **a piece of repeated work reaching N≥2 with a non-trivial cost to redo**
- When deciding whether to adopt some rule → follow the §4 RATIONALE-TEMPLATE line of thinking

**When NOT to trigger** (avoid false fires / overuse):
- One-off needs (N=1) — write an observation note, don't extract a SKILL
- An existing SKILL / SOP / refs already covers 80% — use that, don't reinvent the wheel
- Pure LLM conversation / pure research query — use the secretary's normal flow
- Small patches to an existing SKILL (wording fixes, adding one line of rule) — just edit it, don't run A→E
- Scheduled sweeps of the whole SKILL portfolio / official version drift — this is scheduled maintenance; you can build a dedicated standalone skill for it later; this skill governs a single skill only
- The user explicitly says "ad-hoc is fine, don't extract a SKILL" — respect that

## Core Principles

### 1. Anti over-encapsulation (guard against over-build)

- **Question the premise before acting: "Is this really needed?"** Most things people want to extract into a skill shouldn't be (N=1 too thin, an existing SOP already covers it, ad-hoc is fine)
- **Find what already exists (both phases mandatory)**:
  - **Local scan**: grep all SKILLs + existing SOP / templates directories + any ideas staging area
  - **Upstream scan**: scan the Anthropic plugin marketplace (`/plugin search`) + public skill-spec sites + MCP Registry + high-star GitHub repos. Found an official match → install + evaluate / lightly modify; build your own only if nothing exists
- **Upgrade at N=2, observe at N=1**

> **Wasted-work anti-pattern**: finish a local implementation, then discover an official plugin already existed all along — the whole effort wasted. **Fix: make "find what already exists" a mandatory two-phase scan; never run the local scan alone.**

### 2. SKILL.md is an entry point, not a manual

- Confine each skill to one folder + one SKILL.md; everything else (references/ / templates/ / scripts/ / assets/) is optional
- Put only the two required fields `name` + `description` in the frontmatter; write nothing else
- Keep the SKILL.md body under 500 lines; split into references/ or templates/ once it gets long
- Write the description as a trigger: contains WHAT + WHEN, third-person, 1024-character max
- Write the description in a "pushy" style ("Make sure to use this skill whenever...")

### 3. Workflow shape: relay (file baton-passing, not function calls)

- Make each skill solve exactly one thing; chain multi-stage work to the next skill via a **file baton**
- Bind cross-skill state with a shared source of truth (DESIGN.md / approved.json / handoff bundle)
- Don't write an everything-skill — split into multiple single-responsibility skills

### 4. Skill Boundary Enforcement

- Spell out four sections explicitly for each skill: **does / does NOT / when to trigger / when NOT to trigger**
- Write trigger conditions in phrases the user might actually say; don't write abstract descriptions

### 5. soft → hard, inline-or-isolate

- Write execution-critical rules as grep-able hard rules; use soft language only to explain why
- Inline short content into SKILL.md; isolate large content into references/ or templates/
- Any referenced reference / template **must actually exist + be disclosed**; the "referenced-nonexistent-undisclosed" third state is forbidden

### 6. Cross-platform markdown mirroring

- Put skill logic in `.claude/skills/*/SKILL.md` (auto-loaded by Claude Code / Cowork)
- Ensure the logic itself can be Read directly by other agents that don't recognize the SKILL format (e.g. some Gemini-family tools) — plain markdown, third-person, no hook dependency

### 7. SKILL.md body purity (splitting hard rule)

Hard rules for SKILL.md body content:

- **"Sources / trade-off process / multi-source comparison"** does NOT belong in the SKILL.md body → `references/`
- **"Patch history / changelog"** does NOT belong in the SKILL.md body → `references/changelog.md` or git log
- **"Personalized examples"** (specific dates, private events, private memory-link examples) do NOT belong in the SKILL.md body → de-sensitize and move to `references/`
- **"Checklists with `- [ ]` checkboxes / copy-and-adapt templates / report skeletons"** do NOT belong in the SKILL.md body → `templates/`
- The SKILL.md body **must be understandable to anyone**, with no dependency on personal-system background knowledge

Violations auto-fail audit Tier 1 (❌).

---

## §1 Build a new skill — A→E entry point

Follow `references/build-checklist.md` — **when to read**: the user wants to build a new skill, or you've surfaced some repeated workflow that's ready to start.

| Stage | Action | Guards against |
|---|---|---|
| **A. before** | Question the premise / find what exists / confirm N≥2 | Over-build |
| **B. while** | Align to the authoritative parser / DRY / fault-tolerance + normalization + validator / inline-or-isolate / soft→hard | Bugs |
| **C. verify** | Run it once / read the actual output / enumeration beats counting / send to a second agent + wrap-up review | Self-blind-spots |
| **D. maintain** | "Update" = add + subtract + consolidate + harden | Bloat |
| **E. cross-platform** | A restricted platform can't write to .claude/ → hand off to a platform that has permission | Environment traps |

## §1.5 Modify an existing skill (not building a new one)

Changes to an existing SKILL go here (not the full §1 A→E):

| Change scale | Procedure |
|---|---|
| **Small patch** (wording fix, adding one line of rule, fixing a typo) | Edit directly, don't run the flow below (matches §Trigger "When NOT to trigger" item 4) |
| **Large change** (body rewrite / split into references/ / rename / description upgrade / changing rule semantics / cross-file sync) | Follow `references/build-checklist.md` **D. maintain** (add + subtract + consolidate + harden) → then **mandatorily** run the **B.8 closing protocol 8 steps** (PII scan / index sync / sibling stale references / cross-trigger / self-run dogfood after ship) → stage C send to wrap-up review (only re-send to a second agent if multi-file semantics are involved) |

> Criterion: does the change touch "rule semantics" or "span multiple files"? Yes → large change. Only single-file wording → small patch.

## §2 SKILL anatomy standard

Run this checklist before ship or during audit Tier 1 — **when to read**: when running an anatomy check against a single SKILL. You can copy the checklist below into an audit report / PR description and tick each item.

Scope: Frontmatter / Body / Structure / Splitting hard rule / Cross-platform / Naming and distribution.

**anatomy checklist (tick after copying)**:

- [ ] **Frontmatter**: only the two fields `name` + `description`; no extra fields
- [ ] **name**: kebab-case, matches the folder name
- [ ] **description**: contains WHAT + WHEN, third-person, pushy style, ≤ 1024 characters
- [ ] **Body length**: < 500 lines; long content already split into references/ or templates/
- [ ] **Boundary four sections**: does / does NOT / when to trigger / when NOT to trigger all spelled out
- [ ] **Trigger conditions**: written in phrases the user might say, not abstract descriptions
- [ ] **soft→hard**: execution-critical rules written as grep-able hard rules
- [ ] **inline-or-isolate**: short content inlined, large content isolated; no "referenced-nonexistent-undisclosed" third state
- [ ] **Splitting hard rule** (§Core Principle 7): sources / changelog / personalized examples / checklist templates are NOT in the body → each placed in references/ or templates/
- [ ] **No background dependency**: the body is understandable without personal-system knowledge
- [ ] **Cross-platform**: plain markdown, the logic itself doesn't depend on hook / settings.json / plugin runtime

Any item ❌ → that SKILL fails its anatomy check.

## §3 Audit an existing skill — 4-Tier procedure

Follow `references/audit-checklist.md` (if you haven't built it yet, the summary below IS the executable version of the 4-Tier procedure) — **when to read**: the user wants to audit an existing skill, or this report needs to run Tiers 1–4.

Summary (must run in order, no skipping):

- **Tier 1**: anatomy check (cheapest; run the §2 checklist)
- **Tier 2**: boundary and duplication (compare triggers / does-what against other SKILLs; judge trigger-stealing vs by-design sharing)
- **Tier 3**: actual-usage verification (evidence from conversations / handoffs / observation notes over some period, confirming it was really used)
- **Tier 4**: retrofit prioritization (priority = (impact × frequency) / cost)

**7 agent hard rules for the audit**:

1. Run in Tier order, never skip a Tier
2. Tag each finding with P0/P1/P2/P3 severity
3. Enumeration beats counting (give concrete line numbers / concrete keywords, not aggregate numbers)
4. Tier 2 cross-triggers must distinguish "trigger-stealing (fix it)" vs "by-design sharing (don't fix, write a disambiguator)"
5. Tier 3 with no actual-usage evidence → may NOT claim the skill is "healthy"
6. Order retrofit suggestions by priority, don't modify the SKILL on your own (act only after the user decides)
7. The audit report itself must also pass the §Core Principle 7 purity check (don't write private examples into the report body)

## §4 RATIONALE-TEMPLATE

Write each skill's core rules as "Layer 1 short rule + Layer 2 RATIONALE":

- **Layer 1**: the rule in one sentence, a hard rule, grep-able
- **Layer 2**: rationale (why it's done this way, the root-cause observation, when it doesn't apply)

Example:

> **Layer 1 (rule)**: when today's log file doesn't exist, you must create the file first and then append — never Edit it directly.
> **Layer 2 (rationale)**: root cause = Edit on a nonexistent file silently creates an empty file but writes no content; promoted to a hard rule after N=3 observations.

## §5 Design sources

This skill synthesizes best practices from multiple sources: the Anthropic official `skill-creator` spec (public), the "relay / file baton-passing" shape of open-source skillset workflows, and an external skillset-audit method. Adjudication principle when the three sources conflict: first principles > general-methodology consensus > single-source preference.

## §6 Boundaries with the rest of the lifecycle

| Phase | Trigger | Scope |
|---|---|---|
| **discovery** (find workflow candidates worth upgrading to a SKILL) | user asks / periodic review | produce a shortlist for the user to pick from; can be built later as a standalone skill |
| **`meta-skill` (this skill)** | user asks / N=2 reached | build + audit of a **single SKILL** (qualitative, trigger-based) |
| **scheduled maintenance** (whole-portfolio sweep + official drift) | scheduled / official version bump | quantitative, scheduled; can be built later as a standalone skill |

> The discovery and scheduled-maintenance phases are not shipped with the public repo by default; if the user feels they're needed, use this skill's A→E flow to grow each into its own standalone skill.

## §7 Relationships with existing SKILLs

| Existing SKILL | Relationship | Action |
|---|---|---|
| `project-setup` | parallel | new "project" six-step vs new "skill" A→E |
| wrap-up review skill | downstream | run the wrap-up checklist after building — mandatory in §1 stage C |
| `handoff` | cross-platform | write SKILL logic on a restricted platform → land it in `.claude/skills/` on a platform with permission |
| Anthropic official `skill-creator` | same meta-layer source | meta-skill is the wrapper; can call skill-creator to run an iteration loop / dual-subagent benchmark |

## §8 Trigger routing

| User phrase | Triggers |
|---|---|
| "build a skill / extract this flow into a skill" | §1 A→E |
| "fix a skill / modify a skill" | §1.5 (small patch edited directly / large change follows build-checklist D + B.8) |
| "audit this skill / check this skill / skillset-audit / audit the health of some SKILL" | §3 4 Tiers |
| "is my skill's description right / is the frontmatter right" | §2 anatomy |
| "run a skill health check / sweep all SKILLs" | → this is scheduled maintenance, not meta-skill (can be built later) |
| (internal) some repeated work reaches N≥2 | prompt the user "want to run meta-skill §1?" |

## §9 N=1 → N=2 upgrade conditions

**N=1 observation period**: 4 weeks (counted from the creation date).

**N=2 upgrade evaluation criteria (all must be met)**:

1. **Cross-session proactive trigger**: the user proactively triggers meta-skill ≥ 2 times in **different sessions** (not surfaced within the same session)
2. **Workflow not overturned**: the A→E or 4-Tier you provided ran through; the user didn't abort midway / didn't say "no, it should be that way"
3. **Output actually shipped**: the built SKILL gets triggered in a later session / the audit retrofit was adopted and executed

**Same-session self-audit / dogfood / surfacing does NOT count toward N** (reflexivity avoidance).

**N=1 trigger-failure fallback**:
- First run goes poorly → write an observation note, don't change the SKILL immediately
- Keeps going poorly at N=3 → evaluate three paths: (a) large change to references/templates/, (b) merge with project-setup, (c) retire it

**Handling after reaching N=2**: (a) solidify / (b) extend / (c) split.