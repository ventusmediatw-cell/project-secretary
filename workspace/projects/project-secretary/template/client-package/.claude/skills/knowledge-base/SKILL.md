---
name: knowledge-base
description: "Personal knowledge base pipeline: URL (article or YouTube) → fetch content → summarize → archive to workspace/knowledge-base/. Includes project knowledge bridging via kb-digest."
---

# Knowledge Base Pipeline

## Trigger Conditions

- User shares a URL (article or YouTube video) in conversation
- User asks to process items in `workspace/knowledge-base/inbox/fetch-queue.md`
- User says "save this" or "add to knowledge base" with a link

## Main Flow: process_url

```
Input: url, user_note (optional), tags (optional)
1. Determine type (YouTube / Article)
2. Fetch content
3. Generate summary + key takeaways
4. Generate slug + filename
5. Save to knowledge-base/{articles|videos}/YYYY-MM-DD-{slug}.md
6. If related project exists → execute "Project Knowledge Bridge" (see below)
7. Return result (title, first 2 sentences of summary, archive path)
```

---

## Article Pipeline

### Type Detection
- Non-YouTube URL → article pipeline

### Fetching
Use WebFetch tool to fetch full article text. If fetch fails (403/blocked) → mark `⚠️ Full text fetch failed, summary only` in file and summarize from page title/meta description.

### Content Generation
- **Summary**: 3-5 sentences in user's language
- **Key takeaways**: 3-5 bullet points
- **Language**: Detect from content, fill in Metadata

### Filename Convention
`YYYY-MM-DD-{slug}.md` — slug is 3-5 lowercase English keywords from the title, hyphen-connected.

Example: `2026-03-27-ai-secretary-best-practices.md`

### Related Project Inference
Based on content + user_note, attempt to match existing project names. Fill into Metadata. If uncertain, leave empty.

---

## YouTube Pipeline

### Type Detection
- URL contains `youtube.com/watch` or `youtu.be/` → YouTube pipeline

### Transcript Fetching
Use available tools (youtube-transcript-api, yt-dlp, or WebFetch) to extract video transcript/subtitles.

### Handling Cases
- Transcript available → Generate summary + key takeaways from transcript
- No transcript → Mark `⚠️ No transcript, pending manual processing`, fill summary with "TBD"
- Error → Note error reason

### Video Metadata
Extract from YouTube page:
- Title
- Channel name
- Duration (if available)

---

## Fetch Queue (Batch Processing)

Read `workspace/knowledge-base/inbox/fetch-queue.md` "Pending" section:
1. Move each item to "Processing"
2. Call process_url sequentially
3. Success → Move to "Completed" with archive path
4. Failure → Keep in "Pending" with error reason

---

## Article Template

Save articles/videos in this format:

```markdown
---
title: "Article Title"
url: "https://..."
source: "Site/Channel Name"
date_saved: YYYY-MM-DD
date_published: YYYY-MM-DD (if known)
language: en/zh-TW/etc.
type: article/video/research
tags: [tag1, tag2]
related_projects: [project-name]
---

# Article Title

## Summary
3-5 sentence summary...

## Key Takeaways
- Point 1
- Point 2
- Point 3

## Full Text / Transcript
(Original content below)
...
```

---

## Project Knowledge Bridge (KB → Project Digest)

When an article's "related_projects" is not empty, secretary writes an actionable digest to that project's `refs/kb-digest.md`.

### Design Principles
- **memory.md stays lean**: Only add one reference line `Knowledge base digests: see refs/kb-digest.md` (first time only, don't repeat)
- **INDEX.md untouched**: Don't put knowledge base content in INDEX
- **kb-digest.md is on-demand**: Project agent reads it only when needing background knowledge, not on every startup

### File Location
`workspace/projects/{project-name}/refs/kb-digest.md`

If `refs/` folder or `kb-digest.md` doesn't exist, secretary creates them.

### kb-digest.md Format

```markdown
# Knowledge Base Digest — {Project Name}

> Actionable digests extracted from knowledge-base/. Auto-appended by secretary during archival.
> Project agent reads on-demand, not loaded on every startup.

## YYYY-MM-DD
### {Article Title}
- {Actionable digest: 2-3 lines, focused on "what this means for this project"}
- **Action items**: {specific next steps}
- Full text: `{relative path to knowledge-base source}`
```

### Write Rules
1. New entries appended at top of file (newest first)
2. Each digest ≤ 5 lines (including action items + full text link)
3. Digest focuses on "actionable meaning for the project," not repeating the article summary
4. Same article related to multiple projects → write to each project's kb-digest.md, with project-specific action items

---

## File Paths

| Purpose | Path |
|---|---|
| Article storage | `workspace/knowledge-base/articles/` |
| Video storage | `workspace/knowledge-base/videos/` |
| Fetch queue | `workspace/knowledge-base/inbox/fetch-queue.md` |
| Article template | `workspace/knowledge-base/articles/_TEMPLATE.md` |
| Video template | `workspace/knowledge-base/videos/_TEMPLATE.md` |

> **First-time setup**: Create the above folder structure when first using this Skill. Secretary should auto-create missing directories.
