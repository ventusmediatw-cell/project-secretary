# Questions people actually asked

Append to this file. Never rewrite the whole thing.

**Paths in this file are relative to `workspace/`** (the folder you mount) — that is where `tools/`, `refs/` and `transcripts/` resolve from. This skill lives at `workspace/.claude/skills/audio-transcribe/`, and its own `templates/` and `references/` sit inside that folder.

The questions are in the words people really used, because that is how the next person will search. Each answer leads with **what you are seeing**, then what is actually happening, then what to do — the cause only helps once you know you are in the right place. Sections **§0–§6 line up one for one with `SKILL.md`'s numbered sections**, so an entry can be found from wherever you got stuck; three unnumbered sections follow them — **Hand-off** and the **backup lane**, which `SKILL.md` also carries, and **Before you say it works**, which exists only here. **This file is read by agents as well as by people.** An answer that later turns out to be wrong is **corrected by a new entry further down, not by rewriting the old one** — otherwise nobody can tell the advice changed, and whoever followed the old version has no way to find out.

---

## §0 — Read this first: you cannot hear

### Q: I dropped the recording into the chat. Why do you say you can't hear it?

Because you can't. Your file-reading tool handles images, PDFs and notebooks; it does not handle `.m4a`, `.mp3`, `.wav` or `.mp4`, and it does not fail in a way that looks like a refusal. At worst you guess from the filename and produce something that reads like a summary and is entirely invented. Audio has to become text before it reaches you. `agy` — the Antigravity CLI — is a separate process that genuinely reads the audio. You drive it; you never listen.

_Source: the failure this whole skill exists to prevent_

---

## §1 — First time on this machine

### Q: How do I install `agy`, and how does it sign in?

macOS / Linux, then check it answers:

```sh
curl -fsSL https://antigravity.google/cli/install.sh | bash
agy --version
```

Windows, in PowerShell: `irm https://antigravity.google/cli/install.ps1 | iex`

Signing in is the part people look for and do not find: **there is no `agy login` subcommand, and no IDE is involved.** The first run reads the OS keyring, and if there is no valid session there it picks one of three paths by itself, depending on the machine:

1. **Your own machine** — it opens your default browser and runs OAuth there. Sign in with an approved Google account. Nothing to type.
2. **Over SSH** — it works out that it cannot open a browser and falls back to a manual loop: it prints a URL, you open that URL in a browser wherever you have one, and you paste the code it hands back into the terminal.
3. **Headless or CI** — no browser exists at all, so authenticate with a Gemini API key instead.

Signing out is `/logout`, typed inside `agy`'s own prompt box — not a shell command.

Docs: install <https://antigravity.google/docs/cli/install> · getting started <https://antigravity.google/docs/cli/getting-started/> · product page <https://antigravity.google/product/antigravity-cli/>

_Source: the vendor's published install path_

### Q: `agy` hangs, or exits with nothing at all.

**Two different failures produce that exact symptom** — a first run that never got signed in, and a stale CLI — and they need opposite fixes. Separate them before you touch anything else:

```sh
agy -p "reply with the single word ok"
```

- **Nothing comes back, or you get a sign-in prompt or a URL** → it is authentication, not your prompt and not your audio. Go back to the sign-in entry above and pick the path that matches this machine.
- **`ok` comes back** → it is signed in and answering, so the CLI itself is the next suspect: `agy update`. A stale CLI produces no error message on real work — it produces a hang or an empty string, which reads exactly like a bad prompt or a bad audio file and sends you off editing the wrong thing.
- **Still nothing after both** → go to the empty-segment entry in §3.

_Source: recurring; the two causes look identical from outside_

### Q: I'm setting this up on a new machine. What's the whole sequence?

**Say these four things before you install anything**, not while it is running:

1. **Where the audio goes** — the file is sent to a named company's servers to be transcribed, and on a free plan that company may use it to improve their own systems. Do not soften that into "it's processed in the cloud". For someone else's recording, that is their decision.
2. **What signing in means** — the CLI signs in as a real person's Google account, through a browser on this machine or a URL loop over SSH. Use the account that is supposed to own this work.
3. **What `ffmpeg` costs** — a few hundred megabytes and a password prompt. Not optional here: every recording is re-encoded and split before anything is sent.
4. **What a free tier means** — there is a ceiling, requests start being refused at it, nothing breaks permanently, and you will come back and ask before anything costs money.

```sh
curl -fsSL https://antigravity.google/cli/install.sh | bash   # then complete the sign-in it opens
agy --version
agy -p "reply with the single word ok"   # proves it is signed in, not just installed
brew install ffmpeg      # gives you ffmpeg AND ffprobe — the gates in §4 need both
```

Finish by transcribing **one 6-minute segment end to end** before you queue a batch. A machine where `agy --version` answers is not a machine that has produced a transcript, and the difference only shows up thirty segments in.

_Source: build · machines where setup was declared done and had never transcribed anything_

---

## §2 — Before you run

### Q: How many people are talking? Should I run a cheap pass to find out?

Ask. Do not probe. The answer does not change how the file is transcribed — it decides whether speaker separation is worth doing, and it is one question to a person who already knows. A probe run spends time and quota guessing at something someone in the room can tell you in five seconds.

Ask both things in the same message, once: **(1)** how many people are on this recording, and **(2)** who they are — with **two or three things only that person would say**: their company, their role, a project name, what they call the other person. Question 2 is not politeness, it is the raw material for speaker attribution in §3. **If the list is incomplete, ask again before you start** — not after twenty segments come back marked `[?]`.

_Source: standing rule_

### Q: The recording date is in the file's metadata, isn't it?

No. `creation_time`, `birth`, the timestamp a transfer lands with — all of them are **export** times. A file recorded three weeks ago and re-exported this morning says this morning, with nothing to indicate it is wrong.

The real date comes from content anchors — "tomorrow is the 14th", "next Monday", "end of the month" — and those live in the verbatim layer, which does not exist yet at this point in the run. **So nothing is settled here.** All this step owes you is a rule: do not let an export time into a filename. The date is fixed in §5, once there is a transcript to read it out of. **This applies to a single file exactly as much as to a batch** — it reads like batch hygiene; it is not.

_Source: standing rule_

---

## §3 — Transcribe with agy

### Q: Where do `$D`, `seg/`, `out/` and `merged.md` come from? Nothing created them.

They are the working-directory contract in `SKILL.md` §3, and every gate command in §4 below reads them back. Set it up before the first `agy` call, from `workspace/`:

```sh
D="$PWD/transcribe-work/<slug>"          # absolute — the prompts carry absolute audio paths
S=.claude/skills/audio-transcribe        # this skill's folder, where templates/ lives
mkdir -p "$D"/seg "$D"/prompts "$D"/out  # add transcribe-work/ to .gitignore
```

`$D/audio.mp4` is the re-wrapped recording, `$D/seg/sNN.mp4` the segments, `$D/prompts/pNN.txt` one prompt file per segment, `$D/out/sNN.md` **agy's output**, `$D/merged.md` the merged transcript.

🔴 **`agy -p` writes no file.** It prints to stdout, so the redirect is not decoration:

```sh
cd "$D" && agy --print-timeout 9m --add-dir "$D" -p "$(cat prompts/p00.txt)" > "$D/out/s00.md"
```

Leave the `>` off and the transcript exists only in terminal scrollback — it is gone the moment the buffer scrolls, and every gate below then reads an empty `out/`, reports nothing wrong, and passes.

_Source: build · the layout is assumed by every command in this file_

### Q: `agy` refused to read my audio file. Why does it have to be `.mp4`?

The run comes back refusing the file type — often naming `application/ogg` — even though the file plays fine everywhere else. `agy`'s file reader takes a narrow set of containers. Wrap the audio in mp4, which is also the step that makes segments small enough to send:

```sh
ffmpeg -nostdin -loglevel error -y -i IN -c:a aac -b:a 64k -ac 1 -movflags +faststart "$D/audio.mp4"
```

Mono at 64 kbps puts a 6-minute segment around 3 MB. Cut segments of 5–8 minutes with a 5–10 second overlap, keep each under 20 MB, and send **one segment per request** — batching several into one prompt is how content ends up attributed to the wrong stretch of time.

_Source: build_

### Q: How do I actually cut the segments? Is `-f segment` fine?

**No — and this is the one improvisation that breaks a gate silently.** `ffmpeg -f segment -segment_time 360` cuts back to back, with **zero overlap**. Gate 3 then compares two windows that share no audio at all, finds nothing to disagree about, and passes. Nothing errors; the gate simply verified nothing.

Paste this instead. Six-minute steps, seven-minute-ten cuts, and the difference between the two is the overlap:

```sh
LEN=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$D/audio.mp4" | cut -d. -f1)
i=0; for s in $(seq 0 360 "$LEN"); do
  ffmpeg -y -v error -ss "$s" -t 370 -i "$D/audio.mp4" -c copy "$D/seg/s$(printf %02d $i).mp4"; i=$((i+1))
done
ls "$D/seg" | wc -l   # expect ceil(LEN/360)
```

`-t 370` against a step of `360` is where the 10 seconds of overlap come from, and that overlap is the whole raw material for gate 3 in §4. `-c copy` keeps it fast — the audio was already encoded by the re-wrap above. The last segment is short, which is expected; do not let a fixed threshold in gate 1 kill it.

_Source: build · the obvious alternative produces a gate that passes on nothing_

### Q: Why does the prompt have to be in a file? I piped it in and nothing happened.

Because the pipe deadlocks. `agy` reading its prompt from stdin while you hold the pipe open produces no output and no error — it sits there until the timeout and the segment is wasted. Write the prompt to a file first, then pass it as an argument:

```sh
cd "$D" && agy --print-timeout 9m --add-dir "$D" -p "$(cat prompts/p00.txt)" > "$D/out/s00.md"
```

`templates/agy-prompt.md` is a prompt that already carries the four-layer spec, the shell ban, the source declaration and the fingerprint block, with `{{SEGMENT}}` where the audio path goes. `SKILL.md` §3 has the loop that lifts the prompt body out of the template and fills in one file per segment — do not hand-edit thirty of them.

_Source: build_

### Q: It says it can't read the file, but the path is right there. Can I add `--dangerously-skip-permissions`?

That refusal is `agy`'s own permission check, not the filesystem: it will not read files outside the directories it was opened on, and the message reads like a missing file. Open the directory the audio lives in — `agy --print-timeout 9m --add-dir "$D" -p "$(cat prompts/p00.txt)"` — and give the audio file's **absolute** path inside the prompt as well; a relative path resolves against a working directory you cannot reconstruct from the transcript afterwards.

**Not with that flag.** It does not work and it is not the matching fix: the **whole command** is then refused by the auto-mode classifier, so you go from "one file was not readable" to "nothing ran at all", which is harder to diagnose because there is no partial output to look at. The denial is a directory-scope problem; `--add-dir` is the lever for it.

⚠️ **`--add-dir` works here but is not on the vendor's published flag list** — the docs carry it as the in-session `/add-dir` slash command. Check before you build a batch on it:

```sh
agy --help | grep -c add-dir      # expect 1 or more
```

If that comes back `0`, the flag is gone from your build. The fallback is not the dangerous flag: `cd "$D"` first and refer to the audio by **relative** path (`seg/s00.mp4`) in the prompt too, so `agy` reads the directory it was started in.

_Source: build · the flag was tried, and made things worse_

### Q: It read the audio, then started running ffmpeg, and the whole turn died.

Left to itself the model decides it ought to convert or split the file, tries to run a shell command, hits the permission wall, and takes the turn down with it — **including everything it had already transcribed**. There is no partial output to recover. The prompt has to say so, in as many words:

> Do not run any shell / bash / run_command command. Only read the audio file and output text.

Put it in the hard-rules block near the top, not as a closing footnote. A note at the end does not survive a long audio file.

_Source: build · the loss is the entire segment, every time_

### Q: The output has the four layers twice, or starts with a "let me confirm the format" draft.

Two shapes of one trap. An empty **format template** first — headings, structure, zero timestamps — then the real content: 8 segments out of 30 did this in one batch. Or **two complete sets** of the four layers, the first truncated to a two-line verbatim layer and the second full at sixty-plus: 2 out of 16 in another batch, both in the most important stretch.

Either way an assembler taking the *first* match silently keeps the draft. It does not error — there are headings and a structure, only no content — so a whole segment disappears while the merged file's line count still looks plausible. Take the **last** complete set whose layer positions increase, or per layer the block with the **most timestamp lines**:

```python
blocks = re.findall(rf'###\s*{layer}.*?\n(.*?)(?=\n###|\Z)', txt, re.S)
best = max(blocks, key=lambda b: len(TS.findall(b))) if blocks else ""
```

Tell the prompt not to do it either: *output the final result directly; each of the four layers appears exactly once; do not write a "let me check the format" draft and then rewrite it.* A third variant writes the entire transcript **twice**, the copies 99.8–100% identical — keep the one under the heading, record the difference in the §6 correction table, and do not edit the body.

_Source: measured across two batches_

### Q: A segment came back "blocked by the model's filters" and there is nothing sensitive in it.

The message reads: `This request was blocked by Gemini's filters. They can occasionally trigger by mistake on safe coding, security, or biology-related queries.` It is **probabilistic and it misfires** — ordinary programming instruction has been blocked three times running on the same segment with the same prompt, then gone through on the fourth attempt.

1. **Retry sequentially, up to five rounds.** Three is not enough; segments that fail three times routinely pass on the fourth or fifth.
2. Still blocked? **Split the segment into two halves** — smaller payload, and the trigger region lands on a different boundary. Halved segments have passed on their first retry.
3. Keep a source declaration at the top of every prompt — *this is my own recording, used with permission, for my own notes* — which reduces false blocks before they start.

Make your checker report this reason **by name**. Folded in with "empty or too short" it looks like random flakiness, and nobody thinks to split the segment.

_Source: measured on a batch of 120 segments_

### Q: I ran three segments at once and one came back empty.

Concurrency drops segments. At concurrency 3, two segments out of sixteen returned nothing three times running — an empty string, or a JSON fragment like `]\n}` — and the same segments passed on the first sequential re-run. Across a batch of 120 segments the first-pass failure rate ran around 20%, varying widely between runs. Use concurrency for speed, then **check every segment's output and re-run the failures sequentially**. Never read "the batch finished" as "the batch produced 120 transcripts" — count them.

_Source: measured across two batches_

### Q: I ran the same file twice and got two different transcripts. Which one is right?

Neither is "the" transcript, and the second run was not a check of the first — it is a **new document**. Multimodal transcription is not deterministic: four plain runs of one recording produced three different readings of the same phrase, a pair of words traded places between runs, and speaker labels appeared on every turn in some runs and nowhere at all in others.

- **Re-running is not verification.** There is no fixed point to compare against.
- **A single A/B proves nothing** — prompt on versus off, one model versus another. Two runs differ anyway; only a difference that survives repeated runs at the same settings is real.
- **Checking a name means the §6 correction table**, not another run.

Tell the person this *before* the recording matters — a client meeting, anything with prices in it — not after a line gets disputed. It is also why the audio is kept (§5): it is the only thing you can go back to.

_Source: measured, four runs of one file_

### Q: A name appeared in the transcript that wasn't on the list I was given.

Not a curiosity — a **signal that the fingerprint list is incomplete**. Someone was in the room you were not told about, or someone's fingerprints are too thin to separate them from the person next to them. Fix it during the run, not after: ask who that is, add them to the fingerprint block, re-run the affected segments. In one batch, going from six named people to nine turned a 27-minute recording from mostly `[?]` into all seven named markers recognised, with only 30 unattributed lines left. Waiting until the batch finishes means re-running the batch.

_Source: measured on one multi-recording batch_

---

## §4 — Merge and verify

### Q: What are the four gates, and what does each one actually catch?

Every failure in this pipeline is **silent**: the merge produces output and the line count looks normal. Each gate catches one independent thing, so **skipping one is not verifying at all**.

```sh
# 1. lines contributed per segment — single-digit results get opened by hand
for f in "$D"/out/*.md; do printf '%s %s\n' "$f" "$(grep -cE '^\[[0-9]{1,2}:[0-9]{2}' "$f")"; done

# 2. timeline continuity — any gap over 2 minutes is suspect; last timestamp ~ real duration
awk -F'[][]' '{split($2,a,":"); t=a[1]*60+a[2]; if(t-p>120) print "GAP", p, "->", t; p=t}' "$D/merged.md"
ffprobe -v error -show_entries format=duration -of csv=p=0 "$D/audio.mp4"

# 3. overlap agreement — the same sentences, judged twice by two neighbouring segments
awk -F'[][]' '{split($2,a,":"); t=a[1]*60+a[2]; if(t>=340) print FILENAME": "$0}' "$D/out/s07.md"
awk -F'[][]' '{split($2,a,":"); t=a[1]*60+a[2]; if(t<=20)  print FILENAME": "$0}' "$D/out/s08.md"
```

With the 360/370 cutting loop in §3 the true overlap is the last 10 seconds of one segment against the first 10 of the next; the two windows above are deliberately a little wider so you can read the sentences on both sides of the join. **If those windows have no sentences in common at all, the segments were cut without overlap** — go back and re-cut, because this gate cannot run on them.

**Gate 4 is manual and has no tool.** Take 5–10% of the segments — *contiguous* ones, not scattered — re-transcribe them by a second independent route, and compare **numbers and proper nouns** line by line. Differences go in the §6 correction table; the body is not edited. This is the only gate that catches fluent, confident and wrong.

⚠️ **Scale every threshold to what you are measuring, and test the gate in both directions.** Fixed thresholds kill good output silently: "under 500 characters = failed" flagged a 1.6-second tail segment; "starts with `]` or `}` = fragment" flagged a complete 9 KB output; "gap over 90 seconds = hole" flagged three real 170-second monologues. Run each gate against your shortest segment and your longest uninterrupted stretch before you trust what it tells you.

_Source: every row cost a silent loss before it became a gate_

### Q: There is no second route on this machine. How do I close gate 4?

Three endings, and you take the first one that is available. What you may not do is call the transcript verified without one of them.

1. **The backup lane**, if it is set up — `bash tools/transcribe.sh "$D/seg/s07.mp4" en --keep-audio` on 5–10% of consecutive segments, then compare numbers and proper nouns. `--keep-audio` is not optional; see the backup-lane section for what happens without it.
2. **The person listens.** Hand them the two or three time windows and the matching lines of layer ②, and ask them to check the numbers and the names. You cannot hear; they can. On a machine with no second transcriber this is the only route that exists, and it is a real one — not a downgrade.
3. **Neither** → the honest status is `NOT RUN`. Write `status: gate4-not-run` into the frontmatter, say it in the hand-off in those words, and **do not describe the transcript as verified**. A run that ends here is still deliverable; it is just not checked, and whoever reads it next is entitled to know which.

Re-running `agy` is **not** a fourth option. A second run is a new document, not a second opinion (§3).

_Source: the gate with no tool is the one people quietly skip_

### Q: The merge ran fine, but the end of one segment is missing.

Timestamp formats are not consistent. One batch produced all three of these:

```
[00:00] [Y]…
[01:38 - 01:43] [Y]…
- **00:00 ~ 04:33**: …
```

A merge regex matching only `\[(\d{1,2}):(\d{2})\]` silently dropped the last 36 lines of a segment: there was output, the total looked plausible, and nothing reported anything wrong. Accept the range form —

```python
TS = re.compile(r'\[(\d{1,2}):(\d{2})(?:\s*[-–—]\s*\d{1,2}:\d{2})?\]')
```

— and then **check the tail**: the last timestamp in the merged file should land close to the duration `ffprobe` reports. That single comparison catches the whole class.

_Source: found by comparing a merged file against its own segments_

### Q: The speaker labels flip between segments.

Expected at the boundaries, and there are two separate things to fix.

**If you built voice profiles, that is the cause — stop.** A profile taken from one probe segment ("lower pitch, fast, dominant, 65–70% of the talking") contains a quantity that changes from segment to segment. A visitor monologuing at the start gets marked as the dominant speaker; the host dominating later gets the same marker. **One marker pointing at two people**, and each segment looks perfectly reasonable on its own. What works instead is **fixed named markers plus content fingerprints** — the two or three things only that person would say — with the prompt told outright, *identify speakers by what they say, not by who talks more*, and allowed to mark `[?]` rather than guess.

**The check** is the 5–10 second overlap: the same sentences judged twice, by two segments, with no word list to maintain. Where they disagree, **adopt the segment that also holds the surrounding context** — especially the reply. If the next line answers "right, so that's the CEO then", the line before it belongs to the other speaker.

One measured window: of 14 comparable sentences, 8 disagreed. That is **not** an overall error rate — every comparable sentence sits at a segment boundary, which is exactly where context is thinnest. The narrower and more useful conclusion: **labels at segment boundaries are the least reliable thing in the file.** Even with fingerprints, one segment in a batch of sixteen came back labelled backwards end to end; when you find one, keep the original file next to the corrected one and write down what the judgement rested on.

_Source: measured on two batches_

### Q: Some segments failed no matter what. Do I drop them?

No. Re-run them **sequentially**, up to five rounds, and split any survivor into two halves.

Dropping a segment is the failure that leaves no trace: the merged transcript reads continuously, the timeline gate only catches gaps over two minutes, and nothing in the file says a stretch of audio was never sent. If you genuinely cannot transcribe a stretch, **write that into the file** at the position where it belongs, so the gap is visible to whoever reads it next.

_Source: build_

---

## §5 — The file contract

### Q: Which folder is "the transcripts folder"?

`workspace/transcripts/`, named, not inferred — and the backup-lane scripts write there too, which is the point. The transcript goes in as `<date>-<slug>.md` and the audio beside it under the same base name. Invent a `./transcripts` next to the audio instead and the two lanes land in two different places, so the same-name-same-folder contract is met in neither.

_Source: build · the one destination both lanes have to agree on_

### Q: Why keep the original audio next to the transcript?

Because a re-run gives you a different transcript (§3), so **the audio is the only thing you can go back to.** Every other pipeline has an original to re-check against; this one has the recording and nothing else. Same base name, same folder as the transcript — not a separate audio folder, not a buffer directory, not "still in the downloads folder". The reason it is the *same folder* is mechanical, not tidiness: cleanup scripts sweep the staging directories — downloads, audio buffers — on a timer, and an audio file sitting beside its transcript is **structurally outside what those scripts scan**. Do not rely on a cleanup script's "orphan" guard either: once a transcript mentions the filename, the file is no longer an orphan and is eligible for deletion.

_Source: the alternative is an unrecoverable loss_

### Q: What goes in the frontmatter, and who fills each field in?

Eight fields, exactly these — the same block as `SKILL.md` §5:

```yaml
audio_file: <basename>
audio_deleted: no          # a date, once the person deletes the audio after expires
created: <YYYY-MM-DD>      # from content anchors, confirmed by the person
language: <the main language; mixed if it genuinely is>
model: agy <version>       # the output of agy --version
status: pending            # only whoever files it downstream changes this
extracted_to: -            # a path, once something downstream takes the content
expires: <30 days out>
```

- **`created:`** is the one that has been waiting since §2. The anchors — "tomorrow is the 14th", "next Monday" — are in layer ②, which now exists. Cross them against a calendar you already trust, show the person the chain of reasoning, and write the date into the filename and this field only after they confirm it. Metadata is an export time and never the answer.
- **`audio_deleted:`** ships as `no` and stays `no` for as long as you hold the file. Only the person deletes the audio, after `expires`, and whoever does it replaces the `no` with that date.
- **`extracted_to:`** ships as `-`. Whoever takes the content downstream replaces it with the path they took it into — that is how anyone later tells a transcript nobody has used from one already mined.
- **`model:`** you fill from `agy --version`, not by asking the model what it is. A model's answer about its own version is a guess wearing a fact's clothes.
- **`language:`** you fill yourself after reading layer ①. Nothing in the prompt asks the model to report it.
- **`status:`** is a flag, not decoration — `pending` means transcribed and not yet filed anywhere. `gate4-not-run` is the other value you may write (§4).

_Source: build · two copies of this block had drifted two fields apart_

### Q: The transcripts folder is a staging area. Doesn't that mean the file expires?

Yes, and that is the point — the `expires` field makes unfinished work visible as unfinished. Somebody has to move the file into a durable home before it expires; that somebody is not this skill (see **Hand-off**).

Write frontmatter with Python, never with an in-place stream edit — `sed -i ''` cuts multi-byte characters in half and leaves invalid UTF-8 in the header of a file you can no longer read.

_Source: build · transcripts that expired in staging holding the only copy of a conclusion_

---

## §6 — Names and numbers

### Q: A name in the transcript is wrong.

Normal, and the most dangerous thing this pipeline does — wrong names come back looking exactly as confident as right ones.

**This time:** do not edit the transcript. Put a correction table above it, between the frontmatter and the body (`templates/entity-correction-block.md`). Six columns, and the last three are what make a row checkable by someone who was not there:

```markdown
| # | Line | Heard as | Should be | Raw quote (±2–3 lines) | Status |
|---|---|---|---|---|---|
| 1 | 214 | <what the transcript says> | <the correct term> | `…` / **`…`** / `…` | ✅ confirmed by <person> |
```

**Next time:** the glossary does **not** help you here. `_glossary.py` runs only on the backup lane — the `agy` lane never calls it, so a name added to `refs/transcribe-glossary.md` will not be applied to the next main-lane transcript and nothing will tell you it wasn't. What works on this lane is two things: put the name into the **roster block of the next run's prompt** (`templates/agy-prompt.md`), and keep it in the correction table of every transcript it appears in.

⚠️ **Do not feed names into the transcription prompt to "help" the model** — that is a different thing from the roster block, which describes *who is in the room and what they talk about*, not how a word is spelled. Measured on real recordings, supplying three personal names also turned a food item into a different food, corrupted an honorific the plain run got right, rewrote a two-word term as nonsense four times over, and moved names out of their own script into Latin letters. **The bias does not stay inside the words you gave it.** Editing the body destroys the only record of what was actually heard, and after that nobody can tell an accurate transcription from a confident guess.

_Source: standing rule · measured plain-versus-prompted on three recordings_

### Q: The correction is obviously right. Can I just mark it ✅?

No. The three statuses are three different facts and they are not interchangeable:

- **`✅` goes on only after that person has actually answered that row.** Filling it in because the correction looks obvious turns your guess into their confirmation, and nobody downstream can tell the difference.
- **`⏳ pending`** — nobody has looked yet.
- **`⏸ deliberately left`** — they looked and chose to leave it. Collapse this into `⏳` and the next session asks again about something already settled.

Two rules ride along. **Note the line-number shift**: inserting the block pushes the body down by however many lines you added, so write *line numbers are from the original transcript; this block added N lines* into the block's own header, with a real number — the `Line` column is unusable without it. And **`⏳` does not block delivery** — unconfirmed rows travel onward with the hand-off note; a finished transcript is not held hostage to a reply.

_Source: standing rule · a row once marked ✅ with a fabricated line-number citation under it_

### Q: Do I have to read the whole transcript? It's long.

Yes, in full — and this is a rule about **how you write the command**, not about what you remember to do. Read by explicit line ranges, and never put `head` or `tail` on the end of the pipe:

```sh
sed -n '1,400p'   transcript.md
sed -n '401,800p' transcript.md
```

What happened when this was not a rule: an acoustic layer was read with `sed -n '730,892p' … | head -90` when the layer was 149 non-blank lines, and **four segments were never read at all**. Truncated output has headings, numbered sections and complete sentences — it looks finished. The file was 84 KB, roughly 3% of the context window, so length was never the reason; a reflex against long output was. The cost, both times: a quoted line read as a flat negative when the acoustic layer showed it carried an uneasy laugh, and a hard policy statement made during an interruption that never reached the first summary at all. The same silence exists on the writing side — see the draft-block entry in §3 and the merge entry in §4. Both ends need their own guard.

_Source: found only because someone asked "did you read all of it?"_

### Q: What exactly am I checking before this goes to anyone?

Five categories, in this order: **people's names · project or product names · numbers · business jargon · anything you cannot place at all.**

1. Grep each candidate against whatever your machine treats as the source of truth for that category — your list of people, your project index, your own baseline for numbers.
2. **Paste the actual command and its actual output**, including the zero-hit output. A line number you did not read is a fabrication, and it has happened.
3. No hit, or unsure → mark `[? unverified entity]`, and do not copy it into anything a person is going to read.
4. Surface every one with its **line number and 2–3 lines of raw quotation on each side** — the `Line` and `Raw quote` columns of the block above.
5. **"Three greps found nothing" is the strongest suspicion signal there is, not an all-clear.** Surface it.
6. Numbers get checked against a baseline outside the recording, and **any sentence you intend to quote goes back to the verbatim layer** — never quote the inference layer, which is the model's reading and not the words that were said.

_Source: standing rule · a confident wrong project name once reached a shared document_

### Q: There is no roster and no project index on this machine. What do I grep against?

Nothing — and that changes what rule 5 means. A fresh install ships no roster, no project index and no numbers baseline, so **your source of truth is the person**. Two consequences, both of them rules:

- **Ask in one message, not one name at a time.** Collect every candidate across the whole transcript first, then put the list to them once. Drip-feeding twelve names over an afternoon is how a roster question stops getting answered.
- **Zero hits against nothing means *could not check*, not *suspicious*.** Rule 5 above is about a search that had somewhere to look and came back empty. With no source of truth, zero hits carry no information at all: those rows are `⏳`, they go to the person, and you say "unverifiable here" rather than implying doubt you have no basis for.

_Source: cold start · the rule that fires on everything tells you nothing_

---

## Hand-off

### Q: The transcript is written. Am I done?

Only once you have handed it on. The delivery contract is the transcript **plus** the audio, same name, same folder — and then a note to whoever files things, because this skill does not move anything into a durable home and must not leave the file to expire in staging.

The note carries five things and stays short: **(1)** the file list, **(2)** the recording date for each and what it was inferred from, **(3)** a suggested destination for each, **(4)** the correction status (`✅ all confirmed` / `⏳ N pending` / `⏸ N left`), **(5)** where the audio is, plus the gate results from §4 — including gate 4 as `NOT RUN` if that is what it was. Use whatever your hand-off mechanism is — a queue folder, an issue, a message to the person. Before writing a new note, check whether an open one already covers the same recordings and add to that instead of opening a second.

_Source: transcripts that were finished, correct, and lost anyway_

---

## Before you say it works *(QA-only, no SKILL section)*

### Q: I read the scripts and the output looks right. Is that evidence?

No. There are three honest statuses: **PASS with pasted output**, **FAIL with pasted output**, **NOT RUN**.

**1. The round trip.** Ask for about ten seconds of speech containing **one name and one number** whose answer you already know. Run it, compare word by word. This is the only check that separates *it answered* from *it answered correctly* — a confident wrong transcript exits zero exactly like a right one. Because re-runs differ (§3), compare against what they told you, never against another run.

**2. The negative control — prove you cannot hear.** This is the one check that is supposed to come back empty:

```sh
mkdir -p "${TMPDIR:-/tmp}/transcribe-verify"
say -o "${TMPDIR:-/tmp}/transcribe-verify/2026-01-01-quarterly-budget-meeting.m4a" \
    --data-format=aac "Purple elephant seventeen. Purple elephant seventeen."
```

Hand that path to your **file-reading tool** — not to a shell command, not to `agy`. The filename is bait for guessing; the phrase is nonsense no model can produce from context. Not on macOS? Record five seconds yourself and give the file a name with nothing to do with what you said.

**PASS** — a refusal, and nothing resembling speech comes back; *purple elephant seventeen* must not appear anywhere in your answer. **FAIL** — anything about a budget, a quarter, or a January meeting, none of which is in the audio. Falling back to `strings` and reporting the container header is the same failure in a technical costume.

_Source: the invention this skill exists to prevent, demonstrated on your own machine_

---

## Optional backup lane: Whisper via Groq

> **Not the main lane, and not assumed to be connected.** The lane in `SKILL.md` handles every language and separates speakers. This one is plain speech-to-text: no speakers, no tone, no acoustics, and proper nouns in a dense business conversation come back mangled badly enough to poison anything built on them. It earns its place in exactly two cases — a **single-speaker** file that needs a rough draft in seconds, and a case that needs a **byte-identical re-run**, which the main lane cannot give you. Ask the person before using it, never use it for a multi-speaker recording, and do not ask it for a language that is not in its list — some languages come back as fluent, confident text that is not what was said, and nothing marks that case. It does not translate either: the transcript comes back in the language that was spoken, and translating it is a separate second step, so that the record and somebody's rendering of it stay apart. The entry point is `tools/transcribe.sh <file> <en|zh|km> --keep-audio`; everything below is about that lane only.

### Q: My input file disappeared after the run.

It was moved, by design, and `--keep-audio` is the flag that stops it. Without that flag the scripts under the router **`mv` your input into `transcripts/_audio_buffer/`** when they finish. Two things break as a result:

- **A buffer directory is exactly what §5 forbids.** The contract is the audio beside the transcript under the same name; an audio buffer is one of the staging directories cleanup scripts sweep.
- **Used for gate 4, it eats your segments.** `bash tools/transcribe.sh "$D/seg/s07.mp4" en` runs happily — `.mp4` is on the accepted list — and relocates `s07.mp4` out of `$D/seg/`. The §4 instruction to re-run a failed segment then fails on a missing file, with nothing in the message to suggest a previous command moved it.

So the command always reads:

```sh
bash tools/transcribe.sh <audio-file> <en|zh|km> --keep-audio
```

_Source: read out of the shipped scripts · the default is the opposite of the skill's own rule_

### Q: It named the file with today's date. Is that the recording date?

No — it is the day you ran it. The Khmer route names its output `<today>-<slug>.md`, which is an arrival date wearing a recording date's format, and nothing downstream can tell them apart afterwards. Re-derive the date from content anchors (§5) and **rename the file before it is delivered**. Every rule about metadata dates applies here too: the script has no more access to when the recording happened than `creation_time` does.

_Source: read out of the shipped script_

### Q: It says 401. Is my key wrong?

Almost certainly not. Nine times out of ten the key is fine and there is an invisible newline at the end of the file it lives in — usually because it was written with `echo` instead of `printf`. Check the length, never the value:

```sh
wc -c ~/.config/groq/key
```

One byte longer than the key you copied? That is the newline. Fix it by running the setup again — `bash tools/setup-api-key.sh groq`. The API will never mention whitespace in its error, which is what makes this cost an hour the first time.

_Source: build · the same trap on a different provider before that_

### Q: Can I paste my API key to you? Or can you run the setup for me?

No to both, and neither is faster. Once the key value is in this conversation it is in that conversation's history and in every backup of it, including copies neither of you controls; there is no version of "just this once" that undoes it afterwards. And the script genuinely cannot run inside your own tool call: it reads the key with the screen blank, from a real keyboard, so with no terminal attached it reaches the prompt, reads nothing, exits non-zero and writes no key file — an error, and still no key.

```sh
bash tools/setup-api-key.sh groq   https://console.groq.com/keys    # en, zh
bash tools/setup-api-key.sh gemini https://aistudio.google.com/apikey  # km
```

Hand over the line the person needs, say plainly that you will not see what is typed, and wait. Nothing appears on screen during the paste; that is intentional. It prints back a **length in bytes** and the **last four characters**, and those two lines are how the person tells "it worked invisibly" from "the paste failed".

⚠️ **`km` is a different provider and a different key.** English and Chinese go to Groq; Khmer goes to a multimodal model and reads `GEMINI_API_KEY`. A machine set up with only the Groq key runs `en` and `zh` and fails on `km`, and the failure arrives at the first Khmer file rather than at setup.

_Source: design rule · confirmed by an agent trying it and getting a non-zero exit with no key written_

### Q: It says the file is too large.

Over 25 MB, the provider's limit. This lane compresses automatically when it can — an hour of speech comes down to roughly 14 MB with no meaningful loss. If you saw a message about `ffmpeg`, that is the compression tool and it is not installed: `brew install ffmpeg`. Still over 25 MB after compression? The recording has to be split, and it should be cut on a silence boundary — splitting mid-sentence damages the transcript on both sides of the cut.

_Source: build_

### Q: It says 429 / rate limited. Did I break something?

No — that is a ceiling. The free tier allows roughly two hours of audio per hour. **The response body names its own wait**, a `try again in Ns` figure, and that number is the authority, not any advice written here: measured, the real wait ran around four minutes, and sixty seconds mostly bought a second 429. Read the number, wait that long, run the same command again. For a batch, cut it into roughly fifteen-minute pieces — they come back under the ceiling far faster than one long file does. If 429s continue past the wait the response asked for, you may be against a **daily** cap instead, which no amount of waiting inside the day will clear.

_Source: measured on the free tier · the wording is in the script's own 429 message_

### Q: The Chinese came out in Simplified characters.

Expected on this lane and already handled: Whisper leans Simplified for Chinese at the model architecture level, no matter how the speaker writes, and the pipeline converts afterwards. Still seeing Simplified? The conversion library is missing: `pip3 install opencc-python-reimplemented`. The conversion swaps characters only and can never change wording. Two things ride along: **pass the language explicitly**, because `auto` does not trigger the conversion and also guesses wrong on short clips (which is how a short Chinese recording comes back as fluent English); and the conversion must be the plain character mapping, not the "localise the vocabulary" variant, which quietly swaps ordinary words for regional synonyms.

_Source: build_

### Q: It rejected my `.aiff` / `.mov` and the error doesn't say why.

The file type. This lane hands the recording on exactly as it is, and the service accepts only these:

`flac` · `mp3` · `mp4` · `mpeg` · `mpga` · `m4a` · `ogg` · `opus` · `wav` · `webm`

(If the error you got lists file types itself, believe that list over this one — it is coming from the service today.) `.aiff` is what a Mac records by default and `.mov` is what a phone or a screen recording produces; neither is on the list. Convert once, then run the same command on the new file:

```sh
afconvert -f m4af -d aac recording.aiff recording.m4a   # macOS, nothing to install
ffmpeg -i recording.mov -vn -c:a aac recording.m4a      # anywhere ffmpeg is installed
```

⚠️ **A large `.mov` may well have worked for you before.** Over 25 MB the file is compressed first and that step changes the type on the way; under 25 MB it goes as-is and is refused. Nothing about your machine changed between those two.

_Source: reported from a machine in use · the accepted list had never been written down anywhere_

### Q: There are several scripts in `tools/`. Which one do I run?

One. Everything else is reached through it.

```
bash tools/transcribe.sh <audio-file> <en|zh|km> --keep-audio
  ├── en, zh ─► transcribe-cloud.sh ─► Whisper ─► _s2tw.py (zh: Simplified → Traditional)
  └── km ─────► km_transcribe.py ───► a multimodal model, language pinned (needs GEMINI_API_KEY)
                                └──► _glossary.py ─► correction table (both routes)
tools/setup-api-key.sh — takes an API key; run by the person, never by you
```

**Do not call the scripts behind the router, and do not teach anyone to.** The person learns one command; when a provider changes, the router keeps its name and its arguments and everything underneath is replaced. The moment an alias or a shortcut points at an inner script, that path stops inheriting every future fix — and nothing will tell you it has fallen behind. `--keep-audio` passes straight through the router to the script that would otherwise move your file.

`_glossary.py` runs after every transcript **on this lane only** — the `agy` lane never calls it. It matches the machine's known-wrong names from `refs/transcribe-glossary.md` and writes a correction table **above** the text. It never edits the body, and it never fails a run — no glossary, no matches, or anything unexpected, and it exits silently having changed nothing.

_Source: design decision_
