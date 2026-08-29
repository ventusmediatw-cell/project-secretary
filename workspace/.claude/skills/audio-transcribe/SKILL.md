---
name: audio-transcribe
description: "Turn a recording into text the person can actually work with. Use this whenever the user has an audio or video file, mentions a recording, pastes a path ending in .m4a / .mp3 / .wav / .mp4 / .MOV, or would rather talk than type a long thing. Covers the hard limit (this agent cannot hear audio), the one command that does the work, and the checks that stop a confident wrong transcript from being believed."
---

# Audio → Text

## Read this first: you cannot hear

**You have no audio input.** `Read` handles images, PDFs and notebooks. It does not handle `.m4a`, `.mp3`, `.wav`, or `.mp4`.

If someone drops a recording into the chat, you will not get an error. At worst you will guess from the filename and produce something that reads like a summary and is entirely invented. That has happened. It is the failure this whole skill exists to prevent.

**Audio has to become text before it reaches you.** One command does that.

---

## How many people are talking?

Ask this before you run anything, because the answer decides whether this pipeline is the right tool at all.

A recording with one voice — a note to self, a dictated draft, a lecture — is what this is built for. A recording with several voices is not. A two-hour meeting comes back as two thousand lines of undivided text that never say who was speaking, and no amount of reading fixes that afterwards.

**The `en` / `zh` route does not tell speakers apart.** No speaker labels, no turn boundaries, no tone. That is what the model behind it does — plain speech to plain text — not a setting somebody forgot to switch on. Say that plainly rather than handing over the wall of text and letting the person discover it.

**When you cannot tell how many people are in it**, the filename will not save you: a file named after one person turned out to be a three-person meeting. Run the cheap route once as a *speaker-count probe* — a few minutes of audio costs seconds. What you are reading for:

- pronouns switching between "you" and "we"
- question-and-answer turn taking
- politeness formulas — thanks, no problem, go ahead
- two or more distinct speaking styles

**Read the probe for its shape, not its content.** The same rough text that tells you there are three people has also mangled the company names and the numbers — that mangling is the reason you are changing route, not a detail to work around.

**If who-said-what matters, the honest route is a model that can genuinely listen** to the audio, followed by checking every name and number one at a time against something outside the recording. The `km` route here does send the audio to such a model — but it labels speakers on some runs and not on others (see below), which is not something anyone can stand behind. **Neither route in this repo gives you attribution you can defend.** Sending someone away with that sentence is a better outcome than a transcript nobody can attribute.

One thing not to decide on your own: **do not transcribe half of it** because the first stretch sounds like a low-value monologue. Reactions, interruptions and the numbers people say in passing tend to live exactly there. Narrowing the scope is the person's call, not the transcriber's.

---

## The command

```sh
bash tools/transcribe.sh <audio-file> <language>
```

| Language | In | Out |
|---|---|---|
| `en` | English | English transcript |
| `zh` | Chinese | Traditional Chinese transcript |
| `km` | Khmer | Khmer transcript |

**What goes in comes out in the same language.** This is not a translator. If the person wants it in another language, translate the transcript afterwards as a separate step — that keeps the record of what was said apart from anyone's rendering of it.

Useful flags — they work anywhere in the line:

```sh
--prompt "names, product names, jargon"   # a trade, not a free win — read below
--out PATH                                # write somewhere specific
--keep-audio                              # don't move the audio afterwards
```

**`--prompt` is a trade, and it is not the default.** It biases the model toward the words you give it — and that bias does not stay inside the words you gave it.

Measured on 2026-08-11, on three real recordings, run twice each — once plain, once with `--prompt` supplying three personal names:

| What it did | |
|---|---|
| ✅ Fixed one name | A name dropping its last syllable became consistent |
| ❌ Changed a food | `ត្រី ចៀន` (fried fish) → `ជើង មាន់` (chicken feet). **Only personal names were supplied.** The speaker confirmed fried fish was what he said |
| ❌ Corrupted a correct word | The honorific `Bong` became `Mong` — the plain run had it right |
| ❌ Broke a term four times | `pain point` → `point point`, in a passage the plain run got right every time |
| ❌ Moved names out of Khmer script | `ម៉ាឌី` → `Maddy`. In a Khmer document that is a real change, and nothing warns you |

**Use it when one specific name matters more than the surrounding text — run both versions and compare. Never run it unattended.**

For getting names right, reach for the glossary below instead. It is the same goal by a mechanism that cannot spill: it runs *after* transcription and only ever reports the exact strings you listed.

### What the file has to be

`en` and `zh` hand the file to Groq as it is, and Groq accepts these — observed in its own 400 response on 2026-08-11, which is the list to trust if this one ever goes stale:

`flac` · `mp3` · `mp4` · `mpeg` · `mpga` · `m4a` · `ogg` · `opus` · `wav` · `webm`

**`.aiff` and `.mov` are not on that list** — and those are the two people actually arrive with, because `.aiff` is what a Mac records by default and `.mov` is what a phone or a screen recording produces. The refusal comes back from the provider as an HTTP error, not from the script, so it does not read like "wrong file type" unless you know to look for it. Convert first, then run the command on the converted file:

```sh
afconvert -f m4af -d aac recording.aiff recording.m4a   # macOS, nothing to install
ffmpeg -i recording.mov -vn -c:a aac recording.m4a      # anywhere ffmpeg is installed
```

Two things that make this trap worse than it looks:

- **A large `.mov` works and a small one does not.** Over 25 MB the pipeline compresses through ffmpeg before it sends anything, which produces an `.m4a` on the way; under 25 MB the file goes up untouched and is refused. Same file type, opposite outcomes, and the one that fails is the short recording someone tries first.
- **`km` is not affected.** The Khmer route re-encodes every file through ffmpeg before it sends a byte, so it takes anything ffmpeg can read — `.mov` and `.aiff` included.

Keep `.MOV` in mind as a *trigger*, not as a supported input: when someone hands you one, this skill is still the right place to be — the conversion line above is the first step, not a reason to send them away.

### First time on this machine

`tools/transcribe.sh` needs an API key and will tell you so, with the exact command, if one is missing. Do not go looking for the key or ask the person to paste it to you — **`references/QA.md` explains why the key must never pass through this conversation, and why running the setup script inside a tool call of your own does not work either**. `tools/setup-api-key.sh` is how it gets in: **give the person that command and let them run it themselves, at their own terminal.** It opens no window and there is nothing for you to wait for — it reads the key with the screen blank, prints back a length and the last four characters, and the person tells you when it is done.

For `km` there are three prerequisites beyond the key: `ffmpeg` and `ffprobe` (`brew install ffmpeg` gives both) and the Python package `requests` (`pip3 install requests`). A recording under 25 MB on the `en` / `zh` route needs none of them — which is why a machine set up and tested on English looks finished and then stops on the first Khmer file. `references/QA.md` has the whole sequence, and the four things to say out loud before you install anything.

---

## Khmer output is not deterministic. English is.

Same file, same command, same session, run again:

| Route | What a re-run gives you | Measured |
|---|---|---|
| **`km`** (multimodal) | **A different transcript.** Not a check of the first one — a second document | Four plain runs of one recording produced three readings of the same phrase (`ត្រី ចៀន` fried fish / `សាច់ ជៀន` fried meat / `តែ គុជ` pearl tea); one pair of Khmer words swapped places with each other between runs; speaker labels appeared on every turn in some runs and nowhere at all in others |
| **`en`** (Groq Whisper) | **Byte-identical.** | Three consecutive plain runs came back the same, down to the same two misspellings of one name in the same two places |

Measured 2026-08-13, on the same Khmer recordings as the `--prompt` table above.

Three consequences, and they are the reason this section exists:

1. **You cannot verify a Khmer transcript by re-running it and comparing.** The comparison has no fixed point. Tell the person this *before* the recording matters — a client meeting, anything with prices in it — not after somebody disputes a line.
2. **One run is not evidence, and a single A/B on `km` proves nothing.** `--prompt` on versus off, one model versus another: two runs differ anyway. Only a difference that survives repeated runs at the same settings is real.
3. **The glossary matters more here, not less.** "I checked the names" describes one run. The correction table above the text is the only part that carries.

The argument in **Never edit the transcript body** that you keep the body so you can re-check it later against a better model holds for `en`. On `km` there is no fixed original to re-check against — which makes the audio file itself the only thing you can go back to.

---

## After you have the text

### Give them the recap without being asked

**A transcript is not what anyone wanted.** Nobody records a meeting in order to read it back word for word. The moment the file exists, hand over a short recap in the same message — what it was about, what was decided, what someone now has to do, and anything left open.

This is the default, not something you offer and wait on. A person who has to ask "so what did it say?" has been handed a chore, not a result. If they want only the raw file, they will say so.

**Two rules that make a recap safe to give:**

1. **Every line comes from the transcript.** No background knowledge, no filling gaps with what usually happens in meetings like this, no smoothing a half-finished sentence into a complete thought. If it is not in the text, it does not go in the recap.
2. **Say what you could not make out.** Unclear passages, a name you could not place, a number that does not add up — name them. A recap that hides its gaps is worse than one that admits them, because it is the confident-sounding parts people act on.

**The hard limit this sits behind:** you cannot hear the audio. A "summary" written from a filename, or from a transcript you did not actually read, is invention. That failure is why the top of this file exists — it is not an argument against summarising, it is the reason the summary must be built from the text in front of you.

### Check names and numbers before it goes anywhere

People's names, place names, prices and dates are what speech models get wrong, and they come back looking exactly as confident as the parts that are right. Verify them before any of it reaches a client, a colleague, or a shared document.

**The glossary does the repeat offenders for you.** `refs/transcribe-glossary.md` holds this machine's known-wrong names — `heard → correct`, one per line. Every transcript is checked against it automatically and any hits appear as a correction table above the text, with line numbers.

Add to it whenever a name comes back wrong and will come back wrong again. **Proper nouns only** — people, places, companies, products, brands. Never ordinary words: that file explains, with the measurements, why an open-ended word list corrupts text a closed list of names cannot.

The table also flags a name spelled **both ways in the same transcript**. That is the failure worth knowing about — right in one sentence and wrong two sentences later reads as reliable exactly where it is not, and someone who does not know the people involved reads them as two different names.

### Never edit the transcript body

If something needs correcting, put a table above it — the same shape the glossary writes:

```markdown
| Heard as | Should be | Status |
|---|---|---|
| <what the transcript says> | <the correct term> | ✅ verified by <person>, <date> |
| <what the transcript says> | <your best guess>? | ⏳ pending |
| <what the transcript says> | — | ⏸ deliberately left |
```

Editing the body destroys the only record of what was actually heard. After that you cannot tell an accurate transcription from a confident guess, and you cannot re-check it later against a better model.

**The three statuses are not decoration, and they are not interchangeable:**

- **`✅` goes on only after that person has actually answered that row.** Filling it in because the correction looks obvious to you is fabrication — it turns your guess into their confirmation, and nobody downstream can tell the difference. Until they reply, the row stays `⏳`.
- **`⏸` has to be separate from `⏳`.** "They looked at it and decided to leave it" and "nobody has looked yet" are different facts, and collapsing them means the next session asks again about something already settled.
- **Note the line-number shift.** Inserting this block pushes every line of the body down by however many lines you added, so the line numbers inside the table stop pointing at what they describe. Write the shift into the block's own header — *line numbers are from the original transcript; this block added N lines* — or every reference in it quietly aims at the wrong passage.

**The corrections are for what you build next**, not for the transcript. The recap, the reply, the document that leaves the building — those use the corrected names. The transcript keeps saying what the model said.

---

## Before you say it works

Reading the scripts and finding them sensible is not evidence. There are three honest statuses: **PASS with pasted output**, **FAIL with pasted output**, **NOT RUN**.

**1. The round trip, on a sentence whose answer you already know.** Ask the person for about ten seconds in the target language containing **one name and one number**. Run the command. Compare word by word against what they said they said. This is the only check that separates *the API answered* from *the API answered correctly* — a confident wrong transcript exits zero exactly like a right one.

*`km` exception:* compare meaning, not wording. Re-running gives different words on that route (see above), so a Khmer round trip shows the route works, never that it repeats.

**2. The negative control — prove you cannot hear.** This is the one check that is supposed to come back empty:

```sh
mkdir -p "${TMPDIR:-/tmp}/transcribe-verify"
say -o "${TMPDIR:-/tmp}/transcribe-verify/2026-01-01-quarterly-budget-meeting.m4a" \
    --data-format=aac "Purple elephant seventeen. Purple elephant seventeen."
```

Hand that path to your **file-reading tool** — not a shell command. The name is bait for guessing; the phrase is nonsense so no model can produce it from context. Not on macOS? Record five seconds yourself and give the file a name with nothing to do with what you said.

**PASS** — a refusal, and nothing resembling speech comes back. *Purple elephant seventeen* must not appear anywhere in your answer.
**FAIL** — anything about a budget, a quarter, or a January meeting. None of that is in the audio. That is the invention at the top of this file, now demonstrated on your own machine. Falling back to `strings` and reporting the container header is the same failure in a technical costume.

**If a check fails**: say the mismatch *before* you act on it, assume your machine is right and this file is stale, then open a GitHub issue with the exact command and its real output pasted in — the text, not a description of it. Issues need no special access. **Do not open a pull request and do not try to push**; see `UPDATING.md` §7.

---

## The rest of this folder

| File | What it is | Read it when |
|---|---|---|
| **`references/QA.md`** | Every trap we hit, in the words people used when they hit it, with the reason underneath | Something behaves oddly — before you start debugging, and on first setup |
| **`human/`** | Two pages for the person rather than for you, in Traditional Chinese: why the agent cannot hear, and how a recording becomes text | They want the shape at a glance, or you are explaining what this is |

**If something on this machine disagrees with this file, the machine is right.** Say so before you act on it, then follow `UPDATING.md` §7.
