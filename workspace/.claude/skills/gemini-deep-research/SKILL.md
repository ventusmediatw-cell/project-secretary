---
name: gemini-deep-research
description: "Gemini Deep Research SOP: decision tree (when to use Deep Research vs regular Gemini vs Opus), API specs, research Brief template, platform routing (Cowork → handoff / Claude Code → direct run), quality control."
---

# Gemini Deep Research — SOP

## Decision Tree for Research Needs

When receiving a research request, evaluate in this order:

```
Does it need "search the web + synthesize multiple sources"?
├─ Yes → Gemini Deep Research (this Skill)
└─ No → Does it need "bulk text processing / format conversion / batch summarization"?
         ├─ Yes → gemini-worker agent (regular Gemini API)
         └─ No → Does it need "judgment, decision, strategy design, cross-article synthesis"?
                  ├─ Yes → Opus
                  └─ No → Simple question, answer directly
```

**Core division principle**: Gemini = search research (grunt work) → Opus = judgment decisions (brain work) → Claude Code = write code. Don't use Opus for bulk searching, don't use Gemini for work requiring judgment.

### Deep Research vs Regular Gemini

| Feature | Deep Research | Regular Gemini (gemini-worker) |
|---|---|---|
| Web search | ✅ Automatic multi-source search | ❌ Training knowledge only |
| Output quality | Academic-grade, with cited sources | General answers |
| Time cost | 1-5 minutes (needs polling) | Seconds |
| Use for | Background research, market surveys, technical research | Batch summarization, format conversion, data extraction |
| Cost | Higher (one research consumes more quota) | Low |

---

## Platform Routing Rules

### ⚠️ Core Principle: Don't Run Deep Research Directly on Cowork

Deep Research needs 1-5 minutes of polling. Cowork has two constraints:

1. **Sandbox network restricted** — Python/WebFetch blocked by egress proxy, API calls unstable
2. **Polling wastes session quota** — Polling every 10 seconds for several minutes occupies Cowork session time

### Correct Approach per Platform

| Platform | Approach | Notes |
|---|---|---|
| **Cowork** | Write handoff → Claude Code or Antigravity picks up | Secretary only writes the research Brief, doesn't execute API |
| **Claude Code** | Run Python script directly via Bash | Stable network, can poll |
| **Antigravity (Gemini)** | Paste research question directly in Gemini chat | Simplest, Deep Research is Gemini's native feature |

> **Exception**: User explicitly says "research it now" on Cowork → execute immediately. But warn: may fail due to network restrictions.

---

## API Quota & Question Consolidation Rules

### Current: 3 API Keys

Currently **3** Gemini API Keys available. Deep Research consumes significant quota per call, therefore:

**⚠️ Research questions must be consolidated into ≤ 3 batches, not one-by-one.**

### Consolidation Strategy

1. **After receiving research needs, list all questions first** (could be 10-20)
2. **Group by topic proximity**, merge into ≤ 3 prompts (each covering 3-6 related sub-questions)
3. **Start each prompt with clear research purpose**, so Deep Research focuses its search
4. **Send 3 batches with different API Keys simultaneously** (true parallelism, maximize speed)

### Grouping Principles

- Same knowledge domain questions go in one batch (e.g., "market structure + trading costs + contract specs" → same batch)
- Questions needing cross-referencing go in one batch (e.g., "institutional behavior + retail indicators" → same batch)
- Highly independent questions can be split across batches
- Keep each prompt under **500-1000 words**, too long dilutes search focus

---

## Research Brief Template

Writing the research Brief is the secretary's core output on Cowork. A good Brief determines research quality.

> Template format: see `templates.md` in same folder, "Research Brief Template" section.

### Brief Writing Tips

1. **Be specific**: Don't write "how does stock trading work," write "what are the exact contract specs, margin requirements, and fee structures for the instruments we're evaluating"
2. **Logical grouping**: Group by topic, each group has "why we're asking" linking to the project
3. **Include known info**: Prevent Gemini from re-researching known facts
4. **Specify deliverable format**: Including archive path, Markdown structure, whether source URLs needed
5. **Clarify review responsibility**: Who reviews, reviews what, how to flag issues
6. **Consolidate to ≤ 3 batches**: Match API Key count, group questions before sending

---

## API Technical Specs (Reference for Claude Code Execution)

> ✅ Specs below verified through real-world testing. API flow and Response Schema in `templates.md`.

### Token Consumption Estimates (Tested)

| Question Complexity | total_tokens | tool_use | thought | output | Notes |
|---|---|---|---|---|---|
| Minimal (2+2) | ~22K | 0 | 8K | 1.7K | Doesn't trigger search |
| Actual research (3-4 sub-questions) | **320K-420K** | 196K-395K | 15K-26K | 10K-12K | ✅ Tested with 6 batches |

> **Key finding**: Deep Research token consumption is mainly `tool_use_tokens` (web search), comprising 60-94%. One research ~350K tokens.

### API Key Management

- Config file: `gemini-keys.json`
- Currently **3** Keys
- Rotation: On 429/403/quota exceeded → immediately switch to next key, don't wait for cooldown
- All exhausted → report `[GEMINI_QUOTA_EXCEEDED]`, wait for user decision
- **Parallel strategy**: 3 research batches assigned to 3 Keys simultaneously

### Error Handling

| Error | Handling |
|---|---|
| 429 / 403 | Switch to next API Key |
| Polling timeout (10 minutes) | Report failure, possibly topic too complex or API unstable |
| Network disconnect | **Don't retry** (avoid wasting tokens), record failure reason, retry next session or switch platform |
| SDK not supported | Interactions API only works via REST, don't use SDK |

### Batch Research Best Practices

- 3 Keys launched simultaneously (true parallel, not serial)
- After launching, wait **60 seconds** before starting to poll, then every **30 seconds** (polling too early wastes requests)
- Save results immediately upon completion, don't wait for entire batch to finish
- After batch completion, write kb-digest (if related projects exist)

---

## Quality Control

### First-Batch Calibration

First batch output (first 5 articles or 1st research report) must be reviewed immediately:

1. **Factual accuracy**: Any obvious wrong judgments?
2. **Source quality**: Are cited URLs valid and authoritative?
3. **Off-topic**: Any missed or drifted answers?
4. **Data source feasibility**: Are mentioned APIs / data sources actually usable? (Quick Python verification)
5. **Format compliance**: Does it match specified Markdown structure?

Found issues → fix Brief or prompt immediately, **don't wait for Milestone Review**. First batch is the best calibration opportunity.

### Review Annotation Format

Places in Gemini output needing correction, use:

```markdown
> [Code note]: {correction or supplementary info}

> [Code question]: {fact questionable, needs further verification}
```

### Output Archive Rules

**Core principle: One Deep Research response = one KB article. All research results go into KB.**

| Archive Layer | Location | Content |
|---|---|---|
| **KB (sole original)** | `knowledge-base/articles/YYYY-MM-DD-{slug}.md` | Deep Research raw report, with KB standard frontmatter |
| **Project index (pointer)** | Project `INDEX.md` or `memory.md` lists KB path | No raw content, just link pointing to KB |
| **Project conclusions (domain knowledge)** | Project `memory.md` or `refs/` | Opus review output: judgments, decisions, action items |
| Research Brief (handoff) | `handoff/pending/YYYY-MM-DD-{topic}-research.md` | Cowork only, research questions and instructions |

> **Why this split**: Raw facts go in KB (cross-project searchable), project judgments go in project (domain-specific). No duplicate storage.

---

## Relationship to Other Skills

| Skill | Relationship |
|---|---|
| **knowledge-base** | KB ingest flow triggers Deep Research ("please have Gemini research XXX"). This Skill defines SOP, KB Skill defines post-ingest archive and digest flow |
| **handoff** | Research Briefs produced on Cowork are delivered to Claude Code / Antigravity via handoff mechanism |
| **gemini-worker agent** | Regular Gemini API calls go through gemini-worker, Deep Research goes through this Skill's REST API |
| **subagent-guide** | Claude Code can use subagent for Deep Research, but note sub agents may reject credential-containing API operations — recommend main agent runs directly |

---

## Common Pitfalls

1. **Running API directly on Cowork** → Unstable network + polling wastes quota. Use handoff instead.
2. **Hitting API one question at a time** → Wastes quota. Consolidate into ≤ 3 batches before sending.
3. **Using SDK for Deep Research** → SDK's `client.interactions` doesn't exist. REST only.
4. **Using `name` field when polling** → Must use `id` field. `name` returns 404.
5. **Not waiting for first batch before bulk research** → Quality issues get amplified. Run 1 batch, review, then bulk.
6. **Opus doing bulk searches** → Wastes tokens. Search research is Gemini's job.
7. **Immediate retry after disconnect** → Wastes tokens. Record failure, retry next session or switch platform.
