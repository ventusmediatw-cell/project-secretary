---
name: audio-transcribe
description: "Recording → transcript on one route: the audio goes to the Antigravity CLI (agy), which does the hearing — languages auto-detected, speakers separated, an acoustic layer beside the words. Done means the transcript and the original audio both land in the transcripts folder under the same name. Make sure to use this skill whenever the user says new recording / this recording / transcribe this / turn this into a transcript / speech to text / who said what / speaker separation / we recorded that meeting, pastes a path ending in .m4a / .mp3 / .wav / .mp4 / .MOV / .aiff, or asks which transcription tool to use — even when they describe the same intent without these exact words. Does not handle: a YouTube URL, a chat-export folder or any other multi-file export, video behind a login wall — audio files only; reading a finished transcript closely, or filing it away — downstream."
---

# Audio → Text

> **Done means two files, not one.** The transcript lands in `workspace/transcripts/` **and the original audio is saved alongside it under the same name** — both, then this skill is done. Where the content goes next is not this skill's job.

## What this does

1. **Before you run** — de-duplicate, work out the real recording date, ask once who is in the room
2. **Transcribe** — one route (`agy`), four output layers, speakers identified by what they say
3. **Merge and verify** — four gates, then re-run whatever failed
4. **The file contract** — transcript and audio, same name, same folder, frontmatter written
5. **Names and numbers** — homophones and unknown proper nouns surfaced to the person, then a correction table above the body

## What it does not do

- ❌ No recap, no filing, no batch debrief — those are hand-offs (see **Hand-off**)
- ❌ **Never edits the transcript body.** Corrections only ever go in a table above it
- ❌ Does not assume the backup lane is set up. Ask once; if the answer is no, run the whole thing on `agy`
- ❌ Does not hand speaker identity to a sub-agent — it needs context the sub-agent does not have
- ❌ Does not take a YouTube URL, a chat-export folder, or video behind a login wall — **audio files only**

## When to use

- Someone mentions a recording, a meeting they recorded, or a voice memo, or asks for a transcript
- A path ending in `.m4a` / `.mp3` / `.wav` / `.mp4` / `.MOV` / `.aiff` appears
- Someone asks which transcription tool to use here, or how this is done

## When not to

- No recording involved, or the person says "not now"
- The material is a YouTube URL, a chat-export folder, or a video behind a login wall — none of those are audio files
- The transcript already exists and what is wanted is a close reading or a filing decision — downstream, not here
- **`agy` is not on this machine, or the audio is not on this machine.** Do not transcribe here; hand it to the machine that has both

---

## 0. Read this first: you cannot hear

**You have no audio input.** Your file-reading tool handles images, PDFs and notebooks. It does not handle `.m4a`, `.mp3`, `.wav`, or `.mp4`.

If someone drops a recording into the chat, you will not get an error. At worst you will guess from the filename and produce something that reads like a summary and is entirely invented. That has happened. It is the failure this whole skill exists to prevent.

**Audio has to reach a model that can genuinely listen before it reaches you.** That is what `agy` — the Antigravity CLI — is for. You drive it; it does the hearing.

## 1. First time on this machine

**Paths in this file are relative to `workspace/`** (the folder you mount) — that is where `tools/`, `refs/` and `transcripts/` resolve from. This skill lives at `workspace/.claude/skills/audio-transcribe/`, and its own `templates/` and `references/` sit inside that folder.

```sh
curl -fsSL https://antigravity.google/cli/install.sh | bash    # macOS, Linux
irm https://antigravity.google/cli/install.ps1 | iex           # Windows, in PowerShell
agy --version
```

**Signing in — three paths, and no `agy login` subcommand.** The first `agy` run reads the OS keyring; if it finds no valid session it goes on by itself to whichever of these fits the machine:

- **On your own machine** — it opens your default browser for OAuth. Sign in with an approved Google account.
- **Over SSH** — it works out that no browser can be opened and prints a manual URL loop instead: paste the URL into a browser wherever you have one, paste the code it gives back into the terminal.
- **Headless or CI** — no browser at all, so use a Gemini API key instead.

Signing out is `/logout`, typed into `agy`'s own prompt box. Install docs: <https://antigravity.google/docs/cli/install> · getting started: <https://antigravity.google/docs/cli/getting-started/>

`ffmpeg` is the other requirement — `brew install ffmpeg` gives you both `ffmpeg` and `ffprobe`, and you need both: every file is re-wrapped and cut before it is sent, and gate 2 uses `ffprobe`.

**If `agy` hangs or comes back with nothing, find out which failure it is before you debug anything else:**

```sh
agy -p "reply with the single word ok"    # is it signed in, and answering at all?
```

- Nothing comes back, or you get an auth prompt or a sign-in URL → it is the sign-in above, not your prompt and not the audio.
- `ok` comes back → it is signed in and alive, so now run `agy update`. A stale CLI fails silently on real work and looks exactly like a bad prompt.

### The negative control — prove you cannot hear

This is the one check that is supposed to come back empty:

```sh
mkdir -p "${TMPDIR:-/tmp}/transcribe-verify"
say -o "${TMPDIR:-/tmp}/transcribe-verify/2026-01-01-quarterly-budget-meeting.m4a" \
    --data-format=aac "Purple elephant seventeen. Purple elephant seventeen."
```

Hand that path to your **file-reading tool** — not a shell command, and not `agy`. The name is bait for guessing; the phrase is nonsense, so no model can produce it from context. Not on macOS? Record five seconds yourself and give the file a name with nothing to do with what you said.

**PASS** — a refusal, and nothing resembling speech comes back. *Purple elephant seventeen* must not appear anywhere in your answer.
**FAIL** — anything about a budget, a quarter, or a January meeting. None of that is in the audio. That is the invention at the top of this file, now demonstrated on your own machine. Falling back to `strings` and reporting the container header is the same failure in a technical costume.

The optional Whisper lane needs an API key. **Do not go looking for it, and do not ask anyone to paste it to you** — `references/QA.md` explains why a key must never pass through this conversation, and why running the setup script inside a tool call of your own does not work either.

## 2. Before you run

- **De-duplicate on the decoded audio hash, not the file's MD5.** Re-exporting changes metadata and nothing else: `ffmpeg -v error -i "$f" -map 0:a -f md5 -`
- 🔴 **The recording date is not settled here, and it never comes from metadata.** `creation_time`, `birth`, the time the file landed on this machine are all export times. The anchors that give you the real date are inside the recording, so the date is fixed in §5, once a transcript exists — until then, do not let an export time into a filename.
- 🔴 **A single file gets all of this too.** It reads like batch prep. It is not.
- **A gap in a numbering sequence is not a missing file** — an inventory only proves what is there now, so ask rather than writing a missing-file warning into a durable file. And **a collision check has a shelf life**: re-run it immediately before you move anything, not from a result a few minutes old.
- 🔴 **Ask once, before you start, two things**: ① how many people are talking — the answer does not change how you transcribe, it decides whether speaker separation is worth doing; ② **who is in the room, plus 2–3 clues each that only that person would say** (their company, their role, their project, what they call the other people). ② is the raw material for §3's fingerprints. **If the roster is incomplete, ask before you run, not after.**

## 3. Transcribe with agy

Audio goes to `agy`. **You do not need to work out the language** — it handles mixed and non-English audio itself.

**The working directory, first — every command below and every gate in §4 assumes this layout.** Run these from `workspace/`:

```sh
D="$PWD/transcribe-work/<slug>"          # absolute, so the paths inside prompts resolve
S=.claude/skills/audio-transcribe        # this skill's folder, where templates/ lives
mkdir -p "$D"/seg "$D"/prompts "$D"/out  # add transcribe-work/ to .gitignore
```

| Path | What is in it |
|---|---|
| `$D/audio.mp4` | the whole recording, re-wrapped |
| `$D/seg/sNN.mp4` | the segments |
| `$D/prompts/pNN.txt` | one prompt file per segment |
| `$D/out/sNN.md` | 🔴 **`agy`'s output, redirected there by you.** `agy -p` prints to stdout and writes no file; unredirected, the transcript exists only in terminal scrollback and every gate in §4 reads an empty directory |
| `$D/merged.md` | the merged transcript, before it becomes the delivered file (§5) |

**Prerequisites, all hard:**

- The file **must** be re-wrapped as mp4 — `agy`'s file viewer refuses `application/ogg`. This also means `.aiff` and `.MOV` are fine on this lane; they go through the same line as everything else:
  ```sh
  ffmpeg -nostdin -loglevel error -y -i IN -c:a aac -b:a 64k -ac 1 -movflags +faststart "$D/audio.mp4"
  ```
- **Cut 5–8 minute segments with 5–10 seconds of overlap**, each under 20 MB, **one segment per call** — batching several into one request shifts speaker labels. The overlap is the raw material for gate 3; skip it and that gate cannot run.
  ```sh
  LEN=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$D/audio.mp4" | cut -d. -f1)
  i=0; for s in $(seq 0 360 "$LEN"); do
    ffmpeg -y -v error -ss "$s" -t 370 -i "$D/audio.mp4" -c copy "$D/seg/s$(printf %02d $i).mp4"; i=$((i+1))
  done
  ls "$D/seg" | wc -l   # expect ceil(LEN/360)
  ```
  🔴 **`-t 370` against a step of `360` is the entire source of the 10-second overlap.** Do not reach for `ffmpeg -f segment` instead: it cuts back to back with **zero** overlap, and gate 3 then compares two windows that share no audio, finds nothing to disagree about, and passes on nothing.
- State in the prompt that the recording is the person's own and authorised. Content filters otherwise refuse ordinary material.

**Generate the prompt files** — one per segment, from `templates/agy-prompt.md`, which carries `{{SEGMENT}}` where the audio path goes:

```sh
# 1. lift the prompt body out of the template's code fence — the prose around it is not sent
sed -n '/^\[SOURCE\]/,/^`\{3\}$/p' "$S/templates/agy-prompt.md" | sed '$d' > "$D/prompts/_base.txt"
# 2. fill the [SPEAKER LABELS] roster in _base.txt once, from §2's answers
# 3. then one file per segment — only the path changes
for f in "$D"/seg/s*.mp4; do b=$(basename "$f" .mp4)
  sed "s#{{SEGMENT}}#$f#" "$D/prompts/_base.txt" > "$D/prompts/p${b#s}.txt"
done
```

**The command — four details, none of them optional:**

```sh
# 1. write the prompt to a file first — feeding it through a shell pipe deadlocks
# 2. --add-dir the directory the audio is in, or agy's own permission check blocks the read
# 3. never --dangerously-skip-permissions — the auto-mode classifier rejects the whole call
# 4. redirect, or the output is gone
cd "$D" && agy --print-timeout 9m --add-dir "$D" -p "$(cat prompts/p00.txt)" > "$D/out/s00.md"
```

- `agy --help | grep -c add-dir` before the first run. It works here, but it is not on the vendor's published flag list — it is documented as the in-session `/add-dir` command. **If that count is `0`**, drop the flag, `cd "$D"` and refer to the audio by relative path (`seg/s00.mp4`) in the prompt as well: `agy` then reads the directory it was started in.

- 🔴 **The prompt must say, in so many words, "do not run any shell / bash / python command."** Otherwise it finishes listening, decides to run `ffmpeg` itself, hits the permission wall, and the whole turn dies — taking the transcription it had already done with it.
- The prompt must also say **"output the final result directly; each layer appears exactly once; do not write a 'let me confirm the format' draft and then rewrite it."**
- 🔴 **Prompt template → `templates/agy-prompt.md`** — absolute audio path, four-layer spec, the no-shell rule, the speaker fingerprints, the source statement, the no-draft rule. One file per segment; only the path and the segment number change.

**Four layers:** ① who spoke ② timestamped verbatim ③ **observable acoustics** — interruptions, overlapping speech, a sudden jump in volume, laughter, sighs, pauses over three seconds, self-corrections, room noise, **no emotion words** ④ inference.

- 🔴 **③ and ④ must be separate**, and every line of ④ carries `basis: acoustic | text_only | both`. Put "most of these are actually text_only — do not put both on everything" in the prompt itself; as a footnote it gets ignored.
- 🔴 **Layers ② and ③ go into the permanent file. Layer ④ does not.** The acoustic layer changes conclusions — a passage that reads as a calm exchange of views turns out to be one person cutting in before the other finished, and four minutes of monologue with nobody interrupting is invisible in the text. Layer ④ is a synthesis; left in the file, it gets quoted later as though it were something someone said.

**Speaker identity — fingerprints, not voice profiles:**

- ❌ No voice profiles. A profile that includes "dominant, speaks 65–70% of the time" breaks the moment the balance shifts, and the same label ends up pointing at two different people — plausibly, in segments that each look fine on their own.
- ✅ **Fixed named labels plus each person's content fingerprint in every segment's prompt** — the clues from §2.
- 🔴 The prompt says **"identify people by what they say, not by who says more."** Anything unplaceable gets `[?]`; a gap beats a guess.
- ⚠️ **A name in the transcript that is not on your list means the fingerprint table is incomplete** — fix it then, not after the run. The fingerprints are the one thing you have that the model does not, which is why the identity mapping is yours to do.

**Scope:** ⚠️ **do not transcribe half of it** because the opening sounds like a low-value monologue. Reactions, interruptions and the numbers people say in passing live exactly there, and the omission has no symptom — the transcript reads complete and the timeline is continuous, because the missing part was never sent. Narrowing the scope is the person's call. ⚠️ And **lean towards collecting more from a one-off**: acoustics and tone ride along free on the same request, and nobody re-runs an hour of audio to add a field.

**Non-determinism:** multimodal transcription is **not deterministic** — a re-run hands you a new document, not a check of the first one. So **re-running is not verification**, **a single A/B comparison proves nothing**, and **the only way to correct a name is §6's table**. If the recording has money or a client in it, say this **before** it matters, not after a line gets disputed. It is also why the original audio is the only thing you can go back to (§5).

## 4. Merge and verify

Lost data here is **silent**: the merge produces output and the line count looks normal. Each gate catches a different failure. 🔴 **Skipping any one of them means you did not verify.**

| # | Gate | Test |
|---|---|---|
| 1 | Lines contributed per segment | Any segment contributing single-digit lines gets opened by hand. Scale the threshold to segment length — a fixed word count kills a legitimate two-second tail segment |
| 2 | Timeline continuity | No gap over 2 minutes anywhere in the merged file, and the last timestamp is close to the real duration from `ffprobe` |
| 3 | Overlap-window agreement | The overlap means the same sentence is labelled twice, by the two adjacent segments. Compare them: **`references/QA.md` §4 has a two-line `awk` you can paste**, or read the two windows side by side yourself. Where they disagree, take the segment that also holds the sentences around it, especially the reply. This gate needs no word list, and the sentences it can compare all sit at segment boundaries, which is exactly where speaker labels are least reliable |
| 4 | Content spot-check, manual | Re-transcribe 5–10% — **consecutive** segments, not scattered ones — through a **second independent route** and compare numbers and proper nouns. Differences go in §6's table. There is no automatic accuracy metric here |

🔴 **Gate 4 when there is no second route.** The backup lane is optional and often absent, so this gate has three endings and you pick the first one available:

1. **The backup lane below**, on 5–10% consecutive segments — run it with `--keep-audio` (see that section), then compare numbers and proper nouns line by line.
2. **The person listens.** Give them the two or three windows and the matching lines of layer ②. You cannot hear; they can, and this is the only route that exists on a machine with no second transcriber.
3. **Neither** → write `status: gate4-not-run` in the frontmatter, say it in the hand-off, and **do not call the transcript verified.** Re-running `agy` is not a substitute: a second run is a new document, not a check of the first.

- **Re-run failed segments one at a time, up to five rounds.** The content filter is probabilistic: the same segment can be refused three times and go through on the fourth. Still failing → **split it in half**. A smaller payload moves the trigger to a different boundary.
- **Merging takes the last complete set of four layers, not the first.** The model writes a format draft before the real content — headings, structure, no timestamps, and no error — and sometimes writes the whole transcript twice. Take the block with the most timestamp lines. Make the timestamp pattern accept ranges (`[01:38 - 01:43]`) as well as points; a stricter one drops the tail of a segment without saying so.

## 5. The file contract

The transcript goes into **`workspace/transcripts/`** as `<date>-<slug>.md`, with layers ② and ③ in the body:

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

- 🔴 **`created:` and the date in the filename come from content anchors, and the anchors are in the transcript** — which is why this is settled here and not in §2. Find "tomorrow is the 14th" / "next Monday" / "end of the month" in layer ②, cross it against a calendar you can actually check, and **show the person the reasoning chain before it goes into the filename or `created:`**. Metadata — `creation_time`, `birth`, the arrival time — is an export time and never the answer.
- **`audio_deleted:`** ships as `no` and stays `no` while you hold it. Only the person deletes the audio, after `expires`, and whoever does it writes that date in.
- **`extracted_to:`** ships as `-`. Whoever takes the content downstream replaces it with the path they took it into — that is how you tell a transcript nobody has used from one already mined.
- **`model:`** is yours to fill from `agy --version`, not from asking the model what it is. A model's own answer about its version is a guess dressed as a fact.
- **`language:`** you fill in yourself, after reading layer ① — the model is not asked to report it.
- 🔴 **The original audio is saved next to the transcript, same name, same folder.** Transcription is non-deterministic, so the audio is the only thing anyone can go back to — and same-name-same-folder puts it structurally outside whatever cleanup script sweeps your staging directories, instead of relying on that script's orphan check to spare it.
- ⚠️ **`workspace/transcripts/` is a 30-day staging area** (`expires`). Anything that has to last gets moved into a durable home.
- 🔴 **When you finish, hand the list of unhomed transcripts to whatever does the routing in your system** — file names, recording dates, a suggested destination for each, correction status, verification result, where the audio is. **This skill does not move them.** It also must not leave them sitting: somebody has to file them before they expire.
- Write frontmatter with python, not `sed -i ''` — `sed` cuts multi-byte characters into invalid UTF-8 and the title turns to mojibake. And before deciding whether something may go into a downstream file: **private ≠ local.** A private repository is still a repository.

## 6. Names and numbers: check before anything leaves

🔴 **Never read a transcript truncated.** Read in ranges with `sed -n '<start>,<end>p'` covering every line — **no `head` or `tail` on the end of the pipe.** Truncation is silent: what comes back has headings, numbered sections and complete sentences, so it looks whole. Length is not a reason; a long transcript is a small fraction of your context.

Three ways these models invent text: a stretch in another language, or a silence, comes back as a stock phrase from the training data; a short word in a non-native speaker's accent is swapped for a common word that sounds like it (**six letters or fewer plus a non-native speaker = suspect by default**); a broken sentence is smoothed into a fluent one.

1. **Identify the entities** — people, project names, numeric anchors, business terms, internal codes
2. **grep each one against your own sources of truth** — your roster of people, your project index, your numbers baseline
3. **Not found, or unsure → mark it `[? unverified entity]`**, and do not copy it into anything anyone will read
4. 🔴 **The table you show the person carries six columns** — `# · Line · Heard as · Should be · Raw quote (±2–3 lines) · Status` (`templates/entity-correction-block.md`). **grep evidence means the actual command and its actual output**, including the output that found nothing. **Never report a line number from memory.**
5. ⚠️ **No match is not the same as does not exist.** "Three greps found nothing" is the strongest signal that something is wrong, and it has to be surfaced.
6. **Check numeric anchors against a local baseline**, and **quote only from layer ②**. The inference layer is not content. The same number said three times often refers to three different things.

🔴 **A fresh machine has no sources of truth, and then step 2 has nothing to grep against.** A clean install ships no roster, no project index, no numbers baseline. When that is the case, **the person is your source of truth**: collect every candidate first and ask them in one message, not one name at a time. And read the zero-hit result correctly — **with nothing to search, zero hits means *could not check*, not *suspicious*.** Those rows are `⏳`, they go to the person, and rule 5 above does not fire on them.

**The correction block** — format → `templates/entity-correction-block.md`:

- **The body stays exactly as the model produced it.** Corrections live in a table between the frontmatter and the body, nowhere else. Editing the body destroys the only record of what was actually heard, and after that nobody can tell an accurate transcription from a confident guess.
- **Three statuses, not interchangeable**: ✅ confirmed by that person / ⏳ waiting on them / ⏸ they looked and deliberately left it. Collapse the last two and the next session asks again about something already settled.
- 🔴 **✅ goes on only after that person has actually answered that row.** Filling it in because the correction looks obvious is fabrication — it turns your guess into their confirmation.
- 🔴 **Note the line-number shift.** Inserting the block pushes the body down by exactly the number of lines you added, so write that number into the block's own header. Across a batch, put the table in the file with the highest entity density and reference it from the others.
- ⚠️ **⏳ does not block "done."** Unconfirmed rows travel onward with the hand-off.

## Hand-off

| Goes to | When | What it is |
|---|---|---|
| Routing and filing — which project, moving the file, updating `status` | Once the file contract is met | Whatever does routing in your system: a secretary layer, a queue, a person |
| A recap, or a debrief across several files from one session | The person asks what this batch was about | Downstream. Build it from layer ② only, and name what you could not make out — a recap that hides its gaps is worse than one that admits them |
| Close reading for frameworks the person named but never wrote down | They say "go through it piece by piece" | Downstream |
| Anything going to a third party | Before it leaves the building | A four-axis check: **entities** (homophones, unknown nouns, numeric anchors, and passages where the audio was too poor to trust — list those line ranges and keep them out); **sensitive material** (other people's admissions, third-party privacy, credentials, money); **coverage** (does every source file appear at all — a file with zero coverage fails silently); **spoken commitments** ("I'll send it over", "you go do X") and whether each was followed up |
| A YouTube URL | — | Not this skill |
| The Whisper backup lane, deterministic English, keys and quotas | — | `references/QA.md` |

## Optional backup lane: Whisper via Groq

```sh
bash tools/transcribe.sh <audio-file> <en|zh|km> --keep-audio
```

**Deterministic for English** — three consecutive runs come back byte-identical, down to the same misspelling in the same two places. That is the one thing `agy` cannot give you, and it is why this lane is gate 4's second route. It offers no speaker labels, no turn boundaries and no acoustic layer, so it is a rough draft and never a substitute. One command reaches every script beneath it; do not call the inner ones.

- 🔴 **Always pass `--keep-audio`.** Without it the router's own scripts **move your input file** into `transcripts/_audio_buffer/` when they finish. Used for gate 4 — `bash tools/transcribe.sh "$D/seg/s07.mp4" en --keep-audio`, since `.mp4` is on the accepted list — the flagless version relocates `s07.mp4` out of `$D/seg/`, and the next thing that touches that segment fails on a missing file with no hint why. It also puts the audio in a buffer directory, which is exactly what §5 forbids.
- **The Khmer route needs a different key.** `en` and `zh` go to Groq; `km` goes to a multimodal model and reads `GEMINI_API_KEY` — `bash tools/setup-api-key.sh gemini`, run by the person, never by you.
- ⚠️ **Rename what this lane writes.** It names its output with **today's** date, which is an arrival date, not a recording date. Re-derive the date from content anchors (§5) and rename the file before it is delivered.

**The trap to know before you send anything on this lane**: it hands the file to the provider as it is, and **`.aiff` and `.mov` are not on the accepted list** — which are exactly the two people arrive with, because `.aiff` is what a Mac records by default and `.mov` is what a phone or a screen recording produces. The refusal comes back from the provider as an HTTP error, not from the script, so it does not read like "wrong file type" unless you know to look. Worse, **a large `.mov` works and a small one does not**: over 25 MB the pipeline compresses through `ffmpeg` first, which produces an `.m4a` on the way, while under 25 MB the file goes up untouched and is refused. Convert first, then run the same command on the converted file:

```sh
afconvert -f m4af -d aac recording.aiff recording.m4a   # macOS, nothing to install
ffmpeg -i recording.mov -vn -c:a aac recording.m4a      # anywhere ffmpeg is installed
```

Known-wrong names for this machine live in `refs/transcribe-glossary.md` and are checked after every run on this lane — proper nouns only. Keys, quotas, the 429 wait, Simplified-versus-Traditional Chinese, and the rest → `references/QA.md`.

## The rest of this folder

| File | What it is | Read it when |
|---|---|---|
| **`references/QA.md`** | Every trap we hit, in the words people used when they hit it, with the reason underneath | Something behaves oddly — before you start debugging, and on first setup |
| **`templates/`** | The `agy` prompt, one file per segment; and the entity correction block | Every run, and every correction |
| **`human/`** | Two pages for the person rather than for you — Chinese and English in one file with a ZH/EN toggle: why the agent cannot hear, and how a recording becomes text | They want the shape at a glance, or you are explaining what this is |

**If something on this machine disagrees with this file, the machine is right.** Say so before you act on it, then follow `UPDATING.md` §7.
