---
name: knowledge-base
description: "Personal knowledge base pipeline: article URL or YouTube URL → fetch full text/subtitles → summarize → archive to workspace/knowledge-base/. Includes synthesis layer, project knowledge bridging, book ingestion, and health checks."
---

# Knowledge Base Pipeline

## Trigger Conditions

- User (via Telegram or direct conversation) shares a URL
- Manual processing of items in `workspace/knowledge-base/inbox/fetch-queue.md`

## Main Flow: process_url

```
Input: url, user_note (optional), tags (optional)
1. Determine type (YouTube / article)
2. Fetch content
3. Generate summary + key takeaways
4. Generate slug + filename
5. Write to knowledge-base/{articles|videos}/YYYY-MM-DD-{slug}.md
6. Run `python3 scripts/gen_wiki.py --rolling 20` to regenerate wiki.md + wiki-archive.md
7. Synthesis trigger check (see "Synthesis Layer" section)
8. If related project exists → execute "Project Knowledge Bridge" (see below)
9. log.md record (see "Operation Log" section)
10. Return result (title, first two sentences of summary, archive path)
```

---

## M2a: Article Pipeline

### Type Detection
- Non-YouTube URL → article pipeline

### Fetch
Use WebFetch tool to fetch URL full text. If fails (403/blocked) → mark `⚠️ Full text fetch failed, summary only` and summarize from page title/meta description.

### Content Generation
- **Summary**: 3-5 sentences, in user's language (translate summary if original is foreign, keep full text in original language)
- **Key takeaways**: 3-5 items, in user's language
- **Language**: Detect from content, fill into Metadata

### Filename Rules
`YYYY-MM-DD-{slug}.md`, slug is 3-5 English keywords lowercase connected, e.g., `2026-03-27-digital-economy-trends.md`

### Tag Standards
- **Required**, 3-8 tags, comma separated
- User's language primarily, keep proper nouns in English (e.g., Claude Code, KPI)
- Tags should cover: topic domain, key technologies/tools, application scenarios
- Empty tags cause health check to miss the article, **strictly forbidden to leave empty**

### Related Project Inference
Based on content + user_note, try to match existing project names from workspace/INDEX.md, fill into Metadata. If unsure, leave empty.

---

## M2b: YouTube Pipeline

### Type Detection
- URL contains `youtube.com/watch` or `youtu.be/` → YouTube pipeline

### Fetch Subtitles
```bash
python3 workspace/knowledge-base/scripts/fetch_youtube.py <URL>
```
Output JSON: `status` (ok / no_transcript / error), `language`, `source` (manual / auto), `text` (full subtitles)

### Situation Handling
- `status: ok` → Use subtitles to generate summary + key takeaways
- `status: no_transcript` → Mark `⚠️ No subtitles, pending manual processing`, summary field "TBD"
- `status: error` → Mark error reason

### Video Metadata
Use WebFetch to fetch YouTube page, parse from HTML:
- Title: `<title>` or `og:title`
- Channel: `og:site_name` or page text
- Duration: Leave empty if can't parse

---

## fetch-queue Batch Processing

Read `workspace/knowledge-base/inbox/fetch-queue.md` "Pending" section:
1. Move each item to "Processing"
2. Call process_url sequentially
3. Success → move to "Completed" with archive path
4. Failure → keep in "Pending" with error reason

---

## Gemini Deep Research Integration

> **Full SOP migrated to independent Skill**: `.claude/skills/gemini-deep-research/SKILL.md`
> Includes: decision tree, platform routing, API quota consolidation (≤ 3 batches), research Brief template, quality control.

**Trigger phrase**: User says "**have Gemini research XXX**" → load gemini-deep-research Skill

**KB-specific flow** (parts not covered by the Skill):
- Archive output to `workspace/knowledge-base/articles/YYYY-MM-DD-{slug}.md`, Metadata type: `research`
- After archiving, trigger kb-digest write (see "Project Knowledge Bridge" below)

---

## Project Knowledge Bridge (KB → Project Digest)

When an article's Metadata "Related Project" is non-empty, secretary writes an actionable summary to that project's `refs/kb-digest.md`.

### Design Principles
- **memory.md doesn't bloat**: Only add one reference line `Knowledge base summaries in refs/kb-digest.md` (first time only, don't repeat)
- **INDEX.md untouched**: Don't put KB content in INDEX
- **kb-digest.md read on demand**: Project agent only reads when background knowledge needed, not loaded at every startup

### File Location
`workspace/projects/{project-name}/refs/kb-digest.md`

If `refs/` folder or `kb-digest.md` doesn't exist, secretary creates it.

### kb-digest.md Format

> Format: see `templates.md` in same folder, "kb-digest.md Format" section.

### Write Rules
1. New entries prepended to top of file (newest on top)
2. Each summary max 5 lines (including action suggestion + full article link)
3. Summary focus is "action significance to the project," not repeating the article summary
4. Same article related to multiple projects → write to each project's kb-digest.md, action suggestions tailored per project

---

## Book Ingestion SOP (Phase 4)

> Pipeline for splitting entire books (epub/PDF) into chapters for ingestion.

### When to Use This vs Single Article Ingestion

| Situation | Which Pipeline |
|---|---|
| Single article/video/research report | Main flow `process_url` (above) |
| Entire book (≥5 chapters) | This pipeline (5 steps) |
| Single chapter from a book | Main flow, frontmatter adds `source: book` field |

### Five-Step Pipeline

```
1. Extract  : epub/PDF → raw JSON/markdown
               Script: scripts/epub_chapterize.py or scripts/extract_chapters_raw.py
               Note: epub spine ≠ book chapters, must use TOC-driven splitting

2. Skeleton : Python script builds skeleton
               verbatim original text + §X.0 section markers + image refs + TODO placeholder
               Script: scripts/build_skeleton.py (template, copy and modify for new books)

3. Parallel Edit: N sub-agents in parallel, each using Edit only to fill analysis
               Each chapter output ~10K tokens
               Model: Opus (Sonnet Write truncates long chapters)
               Or Antigravity Gemini manual route (production route when API unstable)

4. Post-process: Fix orphan refs
               Script: scripts/fix_orphans.py
               Issue: top references §X.Y but body has no matching marker → auto-fix

5. Gen Wiki : python3 scripts/gen_wiki.py --rolling 20
               Regenerate wiki.md + wiki-archive.md
```

### Frontmatter Convention (Book Chapters)

```yaml
source: book
book: "Book Title"
book_author: "Author"
book_year: YYYY
chapter: "01"          # Two-digit zero-padded
chapter_title_en: "..."
chapter_title_zh: "..."
```

Filename format: `articles/<book-slug>-ch<NN>-<chapter-slug>.md`

### Pitfall Records

| Problem | Cause | Solution |
|---|---|---|
| Sonnet Write truncates long chapters | Sonnet output limit insufficient | Use Opus or Antigravity Gemini ¹ |
| epub spine ≠ chapters | Publisher splits one chapter across multiple spine items | TOC anchor splitting (don't use spine-based) |
| Orphan refs (§X.Y in top but not in body) | Sub-agent analysis referenced markers skeleton didn't pre-embed | `fix_orphans.py` auto-fix |
| Gemini wraps markdown fence | Model wraps output in ` ``` ` | `strip_code_fence()` helper post-processing |
| Gemini API unstable | Paid Tier cap issues / 503 | Switch to Antigravity manual route |

> ¹ **2026-04 update**: Batches API now supports 300k `max_tokens` output (Opus 4.6 / Sonnet 4.6, beta header `output-300k-2026-03-24`). For future large-file ingestion, re-evaluate whether single-pass write is viable before defaulting to the skeleton pipeline.

---

## Synthesis Layer (Phase 3)

> Core idea (inspired by Karpathy): Knowledge should be compiled once and continuously updated, not re-derived from raw materials every query.
> wiki.md is the index, synthesis is cross-article compiled knowledge products.

### Directory Structure

```
knowledge-base/
  articles/           ← Individual article summaries (unchanged)
  videos/             ← Individual video summaries (unchanged)
  synthesis/          ← Cross-article compiled pages (new)
  wiki.md             ← Main index (Synthesis table + latest 20 articles + Tag Cloud)
  wiki-archive.md     ← Historical entry archive (old entries rolled out)
  log.md              ← Unified operation log
  health-check/
    milestone-100.md  ← System checkpoint every 100 articles
```

### Synthesis Page Format

> See `templates.md` in same folder.

### Ingest Triggers Synthesis

After ingesting new article, **ask user first**: "Update synthesis now or accumulate?" Ask every time, no default.

- **Single mode** (daily sporadic): After ingest, check tag match → match reads synthesis page and integrates; no match but same tag ≥5 articles → suggest creating new synthesis page
- **Batch mode** (bulk import): Phase A ingest without triggering synthesis → Phase B after all complete, scan tag distribution once, batch update/create synthesis pages
- **Manual trigger**: User says "update synthesis" → full scan, check unintegrated material + pending corrections

### Query Uses Synthesis

Search prioritizes wiki.md's Synthesis section → hit reads synthesis page (already compiled, saves tokens) → not enough then drill into articles. Write-back rule: only when user explicitly says "save it back."

### Synthesis Correction Digestion

When Review Skill A5 detects real-world experience overturning existing conclusions, inbox journal marks `[synthesis-correction]`.

**Trigger timing**: Weekly report Step 4 / manual "update synthesis" / synthesis page update.

**Digestion flow**: grep inbox for `[synthesis-correction]` → read corresponding synthesis page → annotate correction → update `last_updated` → log.md record.

**Annotation format**: `> [Real-world correction YYYY-MM-DD]: Originally stated "{original conclusion}", testing found {actual situation}. (Lesson #{N})`

> Design principle: Don't delete original text, add correction annotations, preserve knowledge evolution trail.

### Health Check Additions

Existing health check flow preserved, additions:
- Synthesis page with source article updates but synthesis not updated?
- Tag with ≥5 articles but no synthesis built? Suggest creating
- Contradictions between synthesis pages?
- Orphan synthesis (source articles deleted or outdated)
- **Undigested corrections**: inbox journal has `[synthesis-correction]` but synthesis page not yet updated?

### Knowledge Gap → Gemini Research Delegation

When health check finds knowledge gaps, **don't call Gemini API directly on Cowork**. Instead:

1. Mark gap topic + suggested search keywords in health check report
2. Write to `handoff/pending/` for Claude Code background execution
3. Output auto-archived to `knowledge-base/articles/`, verified at next health check

### Milestone Review (Every 100 Articles)

Every 100 articles (count from log.md), pause ingestion, run Milestone Review:

| Check Item | What to Look For |
|---|---|
| Synthesis trigger rate | <10% means tag or trigger logic issues |
| Synthesis quality | Sample 2-3 pages, more valuable than individual articles? |
| Ingest time | Per-article token/time reasonable? |
| Search hit rate | Random 3 queries, synthesis pages prioritized? |
| Tag distribution | `--stats` for oversized (50+) or orphan tags |
| wiki.md bloat | Line count/KB manageable? |

Output: `health-check/milestone-{N}.md`. **Wait for user confirmation before continuing ingestion.**

---

## Operation Log (log.md)

Location: `workspace/knowledge-base/log.md`

After each operation, append one line:

```
## [YYYY-MM-DD] operation_type | topic | result
```

---

## Model Routing (Phase 3)

> Details in `workspace/knowledge-base/refs/model-routing.md`.
> Core principle: Single article ingest uses Gemini (save tokens), synthesis creation/update + health check uses Opus (needs judgment).

---

## Pull Mode: Knowledge Base Search (M5a)

> **Phase 3 upgrade**: Search first checks synthesis layer. Synthesis is pre-compiled cross-article knowledge. L1→L2→L3 layered rules below apply to articles layer.

### Trigger Words
"knowledge base" "I saved before" "find info" "that article I saw" "anything related"

### Search Tool
```bash
python3 workspace/knowledge-base/scripts/search_kb.py <query> [options]
```

| Option | Description |
|---|---|
| `<query>` | Keywords (title+summary+takeaways+tags) |
| `--tag TAG` | Filter by tag |
| `--project NAME` | Filter by related project |
| `--since DATE` | Start date |
| `--type TYPE` | article / video / research |
| `--limit N` | Max results (default 10) |
| `--stats` | Statistics |
| `--lint` | Metadata quality check |

### Flow (Single Question)
1. Combine parameters based on user intent
2. Execute search, get JSON
3. Return: title + first two sentences of summary + file path
4. Need deeper → Read original

### Flow (Pull Project-Related Knowledge)

**Strict layering, drill down level by level:**

1. **L1 Search list**: `search_kb.py --project NAME` + `--tag`, get JSON. **Stop here first, report to user.**
2. **L2 Wiki entry**: User wants more → check wiki.md latest 20; if not there → grep wiki-archive.md
3. **L3 Original**: User explicitly asks → Read original, one at a time

**Forbidden:**
- ❌ Reading all matching originals at once
- ❌ Skipping L1 to read wiki.md full text
- ❌ Proactively reading originals "for completeness"

---

## Push Mode: Health Check (M5b)

### Trigger
- Weekly review auto-trigger
- User says "scan the knowledge base"

### Flow (Tag-Driven)
1. Read projects-digest.md
2. Extract 2-3 keywords/tags per project
3. Use search_kb.py per project
4. Judge "new action significance at current stage"
5. Read original only when needing more context
6. Cross-project correlation check
7. Knowledge gap identification
8. Tag quality check (`--stats`)
9. Output to `health-check/YYYY-MM-DD.md`

### Report Format

> See `templates.md` in same folder.

### Division with kb-digest
- **kb-digest** (real-time): At ingest, single article → single project
- **Health check** (periodic): Global cross-comparison, discovers hidden correlations

---

## Wiki Index Maintenance

### wiki.md + wiki-archive.md
- Maintenance: After ingest, run `python3 scripts/gen_wiki.py --rolling 20` for full regeneration (**no manual append**)
- Dry-run: `python3 scripts/gen_wiki.py --rolling 20 --dry-run`

### projects-digest.md
- Only update when project changes Phase or direction

---

## File Paths

| Purpose | Path |
|---|---|
| Article storage | `workspace/knowledge-base/articles/` |
| Video storage | `workspace/knowledge-base/videos/` |
| Synthesis pages | `workspace/knowledge-base/synthesis/` |
| KB index | `workspace/knowledge-base/wiki.md` |
| Historical archive | `workspace/knowledge-base/wiki-archive.md` |
| Operation log | `workspace/knowledge-base/log.md` |
| Project digest | `workspace/knowledge-base/projects-digest.md` |
| Pending queue | `workspace/knowledge-base/inbox/fetch-queue.md` |
| Search script | `workspace/knowledge-base/scripts/search_kb.py` |
| Wiki generator | `workspace/knowledge-base/scripts/gen_wiki.py` |
| YouTube script | `workspace/knowledge-base/scripts/fetch_youtube.py` |
| Health check | `workspace/knowledge-base/health-check/` |
| Article template | `workspace/knowledge-base/articles/_TEMPLATE.md` |
| Video template | `workspace/knowledge-base/videos/_TEMPLATE.md` |
