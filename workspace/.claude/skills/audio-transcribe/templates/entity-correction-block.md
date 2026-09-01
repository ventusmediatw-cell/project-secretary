# Entity correction block — template

> Copy it and edit it. It goes **after the frontmatter and before the first line of the transcript**. Rules → `SKILL.md` §6.
> The body is never edited. This table is the only place a correction ever lives.

```markdown
## Entity corrections (checked YYYY-MM-DD)

> The transcript below is **the model's raw output, unedited**. Where a proper noun is
> disputed, this table is authoritative.
> ⚠️ The `Line` column is numbered against the original transcript. This block added N lines,
> so the body's actual line numbers are N higher.

| # | Line | Heard as | Should be | Raw quote (±2–3 lines) | Status |
|---|---|---|---|---|---|
| 1 | 214 | … | … | `…the two lines above` / **`…the line itself…`** / `…the two lines below` | ✅ confirmed by <person>, <date> |
| 2 | 337 | … | …? | `…` / **`…`** / `…` | ⏳ waiting on <person> |
| 3 | 402 | … | — | `…` / **`…`** / `…` | ⏸ looked at, deliberately left |
```

## Notes for whoever copies this

- **All six columns are required**, and `Line` plus `Raw quote` are the two that make the row checkable by someone who was not there. A row without them is an assertion; with them the person can go straight to the line and confirm or deny it in one look. Quote the surrounding 2–3 lines on each side verbatim from layer ② — never from memory, never from the inference layer.
- `N` is the number of lines this block actually adds. Write the number; do not write "about N". Without it every number in the `Line` column quietly points a few lines off.
- **✅ goes on only after that person has answered that specific row.** Pre-filling it because the correction looks obvious turns your guess into their confirmation, and nobody downstream can tell the difference. Until they reply, the row stays ⏳.
- **⏸ has to stay separate from ⏳.** "They looked at it and left it" and "nobody has looked yet" are different facts; collapse them and the next session asks again about something already settled.
- Editing the body instead destroys the only record of what was actually heard. After that you cannot tell an accurate transcription from a confident guess, and you cannot re-check it later against a better model.
- **The corrections are for what gets built next** — the recap, the reply, the document that leaves the building. Those use the corrected names. The transcript goes on saying what the model said.
- A batch of files: write the table into the one with the highest entity density and reference it from the others rather than duplicating it.
- The hand-off carries this table's status: all confirmed / N waiting / N deliberately left.
