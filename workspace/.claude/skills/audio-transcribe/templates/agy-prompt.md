# agy transcription prompt — one file per segment

> Copy it and edit it. Goes with `SKILL.md` §3: the prompt **must be written to a file first**, then
> `cd "$D" && agy --print-timeout 9m --add-dir "$D" -p "$(cat prompts/p00.txt)" > "$D/out/s00.md"`.
> `--add-dir` opens the directory the audio is in; the redirect is what makes the output a file.
> `{{SEGMENT}}` below is a placeholder — `SKILL.md` §3 has the one-line loop that fills it in per segment.
> 🔴 Do not feed this template to `agy` through a shell pipe — it deadlocks.

```text
[SOURCE] This is my own recording, made with the knowledge of everyone in it. I am transcribing it to keep a record of the conversation.

[TASK] Read this audio file and transcribe it verbatim:
{{SEGMENT}}
This is one segment of several. The first 5-10 seconds overlap with the previous segment; that is expected, not an error.

[HARD RULES]
1. Do not run any shell / bash / run_command / python command. Read the audio, output text, nothing else.
2. Output the final result directly. Each of the four layers appears exactly once. Do not write a "let me confirm the format" draft and then rewrite it, and do not write the transcript twice.
3. Language: transcribe in whatever language is spoken. If the speakers mix languages, write each part in the language it was said in. Do not translate and do not tidy up the phrasing.

[SPEAKER LABELS - identify people by what they say, not by who says more]
Who is in this recording, and each person's content fingerprint (things only that person would say):
- [A] = <name>: <company / role / project / what they call the other people / 2-3 habitual phrases>
- [B] = <name>: <same>
- (list as many as there are. A voice that is not on this list gets [?], and so does any line you cannot place. Do not guess.)

[OUTPUT FORMAT: four layers, in order, each exactly once]

### Layer 1 - Speakers
How many people are audible in this segment, and roughly what share each has. Answering "only 1 person" is allowed and is sometimes the correct answer.

### Layer 2 - Verbatim (this layer is the record; every quotation comes back to it)
One line per utterance: [mm:ss] [label] what was said
Timestamps are relative to the start of this segment. One utterance per line - do not merge lines, do not drop backchannels ("mm", "right", "yeah").

### Layer 3 - Observable acoustics (no emotion words)
Only things that are audible: interruptions, overlapping speech, a sudden jump in volume, laughter, sighs, a hand on the table, pauses longer than 3 seconds, self-corrections, room noise. Every entry carries [mm:ss].
Do not write "he sounds angry" - that is an inference and belongs in layer 4.

### Layer 4 - Inference
One line each: - [mm:ss] <reading>  basis: acoustic | text_only | both
`basis` is a required field. Most of these are actually text_only - do not put `both` on everything.
```

## Notes for whoever copies this

- `{{SEGMENT}}` is filled with an **absolute** path — `$D` in `SKILL.md` §3 is absolute for exactly this reason. `--add-dir` has to open that directory, or `agy`'s own permission check blocks its file read and the run fails for a reason that looks like something else. (Only if `agy --help | grep -c add-dir` comes back `0` do you fall back to `cd "$D"` and a relative `seg/sNN.mp4`.)
- **Where the fingerprints come from**: if your system keeps a roster of people or a project index, draft the candidate list from it first and take the draft to the person to correct — do not turn up empty-handed. If it does not, ask directly: who was in the room, and what does each of them talk about. A name in the finished transcript that is not on your list means the list was incomplete; fix it during the run, not after.
- Generate the `pNN.txt` files with the loop in `SKILL.md` §3 — only `{{SEGMENT}}` changes. Do not hand-edit each one.
- Two shapes still come back sometimes: an empty format draft followed by the real content, and the whole transcript written twice. When merging, take the last complete set of four layers — the one with the most timestamp lines (`SKILL.md` §4).
- If the layer headings above are edited, edit the merge step with them. The merge finds layers by their headings, and a rename there fails silently: it produces output, and the line count looks normal.
