# Questions people actually asked

Append to this file. Never rewrite the whole thing.

The questions are in the words people really used, because that is how the next person will search. The answers lead with **what you are seeing**, because that is what someone has in front of them when they come looking — the cause only helps once they know they are in the right place.

**This file is read by agents as well as people.** When a teaching page renders these questions, it renders *from here*. Adding a row means editing this file, not the page.

An answer that later turned out to be wrong is **corrected by a new entry further down, not by rewriting the old one** — otherwise nobody can tell that the advice changed, and the person who followed the old version has no way to find out.

---

### Q: It says 401. Is my key wrong?

Almost certainly not. Nine times out of ten the key is fine and there is an invisible newline at the end of the file it lives in — usually because it was written with `echo` instead of `printf`.

Check the length, never the value:

```sh
wc -c ~/.config/groq/key
```

One byte longer than the key you copied? That is the newline. Fix it by running the setup again:

```sh
bash tools/setup-api-key.sh groq
```

The API will never mention whitespace in its error. This costs people an hour the first time.

_Source: build, 2026-08-10 · same trap seen previously on a different provider_

---

### Q: I typed the option but it didn't do anything. No error either.

If you are on an older copy of these scripts, options only worked when they came **before** the filename. Written the natural way —

```sh
bash tools/transcribe.sh recording.m4a zh --prompt "Marisa, Northwind, QBR"
```

— the `--prompt` was silently thrown away. The command still succeeded. It just quietly did less than you asked.

The current version reads options from anywhere in the line and rejects ones it does not recognise. If you see an option ignored with no complaint, you are on an old copy — say so.

_Source: found by testing during the build, 2026-08-10. It had been silently dropping prompts in real use._

---

### Q: The Chinese came out in Simplified characters. I speak Traditional.

Expected, and already handled. Whisper leans Simplified for Chinese at the model architecture level, no matter how the speaker writes. The pipeline runs the result through a character conversion afterwards.

If you are still seeing Simplified, the conversion library is missing. You will have seen a line about `opencc` on screen. Fix:

```sh
pip3 install opencc-python-reimplemented
```

The conversion swaps characters only — it can never change wording or meaning.

_Source: build_

---

### Q: Can I just paste my API key to you? It's faster.

No, and it is not faster.

Once the key value is in this conversation it is in the conversation's history and in every backup of that history — including copies neither of us controls. There is no version of "just this once" that undoes it afterwards.

```sh
bash tools/setup-api-key.sh groq https://console.groq.com/keys
```

Run that yourself, in your own terminal — it is not something your agent runs for you, and no new window appears. Paste the key at the prompt it gives you. Nothing will appear on screen as you paste — that is intentional. You get back a length and the last four characters so you can confirm it arrived.

_Source: design rule_

---

### Q: Nothing showed up when I pasted the key. Did it work?

Nothing appearing is normal — the script hides what you type on purpose.

To tell the difference between "it worked invisibly" and "the paste failed", read the two lines it prints afterwards: a **length in bytes** and the **last four characters**. Compare those against the key you copied. If they match, it worked.

If it says nothing was read, the paste genuinely did not land. Nothing was written and nothing was overwritten. Press the up arrow and run it again.

_Source: first live test, 2026-08-10_

---

### Q: Why does Khmer use a different service than English and Chinese?

Because the model the other two use produces genuinely unusable output for Khmer. Not "a bit worse" — unreadable. That is a property of that family of models, not of your recording or your microphone.

So Khmer goes to a different provider that handles it, with the language named explicitly in the request.

**Do not test this to be sure.** It has been tested. Retrying spends your quota to reproduce a result we already have.

_Source: prior finding, carried forward_

---

### Q: Can I get the Khmer recording as English instead?

Yes, but as a second step, not as a setting.

The transcript always comes back in the language that was spoken. Once you have it, ask your agent to translate it. You then have both: a record of what was said, and a translation of it.

That separation is deliberate. If the tool translated as it transcribed, nobody could ever check the translation against the original — including you.

_Source: design decision, 2026-08-10_

---

### Q: It says the file is too large.

Over 25 MB, which is the provider's limit. The pipeline compresses automatically when it can — an hour-long recording comes down to roughly 14 MB with no meaningful loss for speech.

If you saw a message about `ffmpeg` being missing, that is the compression tool and it is not installed:

```sh
brew install ffmpeg
```

That is a few hundred megabytes and will ask for your password. If it is still over 25 MB after compressing, the recording needs splitting — ask your agent, because splitting in the middle of a sentence damages the transcript.

_Source: build_

---

### Q: It says rate limited / 429. Did I break something?

No. The free tier allows roughly two hours of audio per hour. You reached the ceiling.

Wait a minute and run the same command again. Nothing is damaged and nothing was lost.

If you have a lot to get through, do it in pieces of about fifteen minutes rather than one long file — short pieces recover from this much faster.

_Source: build_

> ⚠️ **"Wait a minute" was withdrawn.** See *"I waited a minute after the 429 and it happened again"* below — the wait is about four times that, and the response tells you the real number.

---

### Q: The Khmer transcript just stops partway through.

Look at the top of the transcript file — if a chunk failed or was cut short, it says so there in a warning line.

The usual cause is a dense stretch of speech hitting the model's output limit. The setting that prevents this is already switched on in the script; if you or an agent edited that file, check that `thinkingBudget` is still `0`.

If it happens on a recording that used to work, say so rather than re-running it repeatedly.

_Source: build · previously cost a silent truncation that looked like a complete transcript_

---

### Q: A name in the transcript is wrong.

Normal, and the most dangerous thing this tool does — wrong names come back looking exactly as confident as right ones.

Two things:

**Next time**, put the name in the glossary — not in `--prompt`:

```
refs/transcribe-glossary.md
Marisa Devraj → Marisa Debraj
```

Every transcript from then on is checked against that list automatically, and hits
appear as a correction table above the text. Proper nouns only.

⚠️ **This used to say "feed the names in with `--prompt`". That advice was withdrawn on
2026-08-11.** Measured on real recordings, supplying three personal names also turned a
food item into a different food, corrupted a correct honorific, and rewrote `pain point`
as `point point` four times. `--prompt` biases the whole transcription, not just the words
you gave it. See `SKILL.md` for when it is still the right call — and it is never the
default, and never unattended.

**This time**, do not edit the transcript. Put a correction table above it instead:

```markdown
| Heard as | Should be |
|---|---|
| Mary Sa     | Marisa   |
```

Editing the text destroys the only record of what was actually heard, and after that nobody can tell an accurate transcription from a confident guess.

_Source: standing rule_

---

### Q: Can I use it for a language that isn't in the list?

Ask first — do not try `auto` and hope.

Some languages work through the same route as English. Some need the route Khmer uses. Some produce fluent nonsense in whichever route you pick, and fluent nonsense is worse than an error because nothing tells you it happened.

The router refuses unknown languages by name rather than guessing, for exactly this reason.

_Source: design decision_

---

### Q: It rejected my recording and I don't understand the error. It's a `.aiff` / a `.mov`.

The file type. For English and Chinese the recording is sent on exactly as it is, and the service at the other end takes only these:

`flac` · `mp3` · `mp4` · `mpeg` · `mpga` · `m4a` · `ogg` · `opus` · `wav` · `webm`

(If the error you got lists file types itself, believe that list over this one — it is coming from the service today.)

`.aiff` — what a Mac records by default — and `.mov` — what a phone or a screen recording gives you — are not on that list. Convert it once and run the same command on the new file:

```sh
afconvert -f m4af -d aac recording.aiff recording.m4a   # macOS, nothing to install
ffmpeg -i recording.mov -vn -c:a aac recording.m4a      # if you have ffmpeg
```

Two things that make this confusing while you are in it:

- A **big** `.mov` may well have worked for you before. Over 25 MB the recording gets compressed first, and that step changes the file type on the way. Under 25 MB it goes as-is and is refused. Nothing about your machine changed between those two.
- **Khmer recordings are not affected.** That route re-encodes everything before sending, so it takes `.mov` and `.aiff` without complaint.

_Source: reported from a machine in use, 2026-08-11 · the accepted list had never been written down anywhere_

---

### Q: This is a meeting recording. Why can't I tell who said what?

Because nothing in this pipeline tries to. What comes back is one undivided stream of words — no speaker labels, no turn boundaries, no tone. **It does not tell speakers apart, and there is no flag that makes it.** That is what the model does, not a setting somebody missed.

Two hours of a meeting is around two thousand lines of text that never names a speaker, and reading it afterwards does not recover the information — it was never captured.

If you only need to know *how many* people are in the recording, one cheap run answers that: look for pronouns switching between "you" and "we", question-and-answer turn taking, politeness formulas, two or more speaking styles. Read that run for its shape, not its content — the proper nouns in it will be mangled, which is the point.

If who-said-what actually matters, the route that works is a model that can genuinely listen to the audio, followed by checking the names and numbers one at a time. **These scripts do not offer that route**, and pretending otherwise wastes more of your time than saying so.

_Source: design limit of the model behind the `en` / `zh` route_

---

### Q: I ran the same Khmer file twice and got two different transcripts. Which one is right?

Neither is "the" transcript. **The Khmer route is not deterministic** — a second run produces a *new document*, not a check of the first one.

Measured 2026-08-13: four plain runs of one recording gave three different readings of the same phrase (`ត្រី ចៀន` fried fish / `សាច់ ជៀន` fried meat / `តែ គុជ` pearl tea), one pair of Khmer words traded places between runs, and speaker labels appeared on every turn in some runs and nowhere at all in others. The same test on English through Groq Whisper came back byte-identical three times running, down to the same two misspellings of one name in the same two places.

What follows from that:

- **Re-running is not verification on `km`.** There is no fixed point to compare against.
- **A single before/after comparison on `km` proves nothing** — `--prompt` on versus off, one model versus another. Two runs differ anyway. Only a difference that survives repeated runs at the same settings is real.
- **The audio file is the thing you can go back to.** For English you can re-run against a better model later and compare; for Khmer that baseline does not exist.

Tell people this before the recording matters — a client meeting, anything with prices in it — not after a line gets disputed.

_Source: measured 2026-08-13, on the same Khmer recordings as the `--prompt` table in `SKILL.md`_

---

### Q: I waited a minute after the 429 and it happened again.

That is expected, and the older answer in this file was wrong about it.

**The response body names its own wait** — a `try again in Ns` figure. That number is the authority, not any advice here. When this was measured (2026-08) the real wait was around **four minutes**; sixty seconds was never enough and mostly bought a second 429.

So: read the number the response gives you, wait that long, run the same command again. For a batch, cut it into roughly fifteen-minute pieces — they come back under the ceiling much faster than one long file does.

_Source: measured on the Groq free tier, 2026-08; the wording is in `tools/transcribe-cloud.sh`'s own 429 message_

**If `km` keeps returning 429 after the wait the response asked for**, the ceiling may not be the per-hour one — free tiers also cap by day, and no amount of waiting inside the day clears that. We have not measured this provider's limits: try the next day or a different key, and if you establish what the real ceiling is, add it here with the date.

---

### Q: Nothing errored, but the result is wrong. Where do I even start?

Here. In this domain **failure usually looks like success** — every row below exits zero.

| What you see | What it actually is | What to do |
|---|---|---|
| **`401 Unauthorized`** | Nine times out of ten, a newline at the end of the key file — usually from writing it with `echo`. The API says nothing about whitespace. | `wc -c ~/.config/<provider>/key`. One byte longer than what was copied? That's it. Re-run `setup-api-key.sh`, which uses `printf '%s'`. |
| **`413` / "file too large" / a truncated transcript** | The 25 MB cap. Not a broken key. | The compression step. If it is already compressed and still over, the recording has to be split — and splitting mid-sentence damages the result. |
| **Chinese comes back in Simplified** | Whisper leans Simplified for `zh` at the architecture level, regardless of how the speaker writes. | `_s2tw.py` handles it. Use `s2tw`, **never `s2twp`** — the `p` variant also localizes vocabulary and turns video 腳本 (*script*) into the IT term 指令碼. Wrong word, silently. |
| **The transcript is one enormous paragraph** | The response format. Plain text comes back as a wall; `verbose_json` returns segments, which is what preserves line breaks. | Keep `response_format=verbose_json`. It is not cosmetic. |
| **Khmer transcript stops early, no error** | The Khmer model is a thinking model, and thinking tokens come out of the same `maxOutputTokens` budget as the answer. On a dense chunk they eat the budget and the output is cut off, reported only as `finishReason=MAX_TOKENS`. | `thinkingConfig.thinkingBudget: 0`. Already set in `km_transcribe.py`. Transcription needs no reasoning. **Do not remove it.** |
| **A flag you passed did nothing, and nothing was reported** | Argument parsers that only read *leading* flags. `transcribe.sh file.m4a zh --prompt "..."` silently dropped the prompt — the natural word order was the broken one. | Fixed here: flags are read from anywhere, and unknown flags are rejected loudly. If you extend these scripts, keep that property. |
| **Short Chinese comes back as fluent English** | Language auto-detection guessing wrong on a short clip. | Always pass the language explicitly. This router refuses `auto` for exactly this reason. |
| **A Chinese filename or heading turns into corrupted bytes** | Multi-byte text through shell `echo` / `sed -i ''`. | Do that work in Python. This bit us on a different tool and cost a rebuild. |
| **Repeated `429` on a long job** | The free tier allows roughly two hours of audio per hour. Not a bug — a ceiling. | Wait what the response asks for, then retry; see the 429 entry above. Split long batches into ~15-minute pieces. |
| **A confident, fluent, completely wrong name or number** | The normal behaviour of every speech model, and the most dangerous one, because it reads as correct. | The correction table in `SKILL.md`. Never trust a number nobody checked. |

_Source: every row was found by running the thing_

---

### Q: There are six scripts in `tools/`. Which one do I run, and can I call the inner ones directly?

You run one. `bash tools/transcribe.sh <file> <en|zh|km>` reaches all of the others.

```
bash tools/transcribe.sh <audio-file> <en|zh|km>
        │
        ├── en, zh ──► transcribe-cloud.sh ──► Groq Whisper large-v3-turbo
        │                    │
        │                    └── zh only ──► _s2tw.py  (Simplified → Traditional)
        │
        └── km ──────► km_transcribe.py ────► a multimodal model, language pinned
                                     │
                                     └──► _glossary.py ──► correction table
                                          (both routes, after the file is written)

     tools/setup-api-key.sh — takes an API key, run by the person, not by you
```

- **`transcribe.sh`** — decides which provider handles this language. That is its whole job.
- **`transcribe-cloud.sh`** — checks the size cap, compresses if needed, makes one HTTP call, parses the response, writes the file.
- **`_s2tw.py`** — a dictionary conversion. Not a model. It swaps characters and cannot change meaning.
- **`km_transcribe.py`** — splits the audio into large time chunks, sends each to a multimodal model in parallel, stitches the results back.
- **`setup-api-key.sh`** — reads a key at the person's own terminal prompt. You hand them the line; they run it.
- **`_glossary.py`** — runs after every transcript, on both routes. Matches this machine's known-wrong names from `refs/transcribe-glossary.md` and writes a correction table **above** the text. It never edits the body, and it never fails a run: no glossary, no matches, or anything unexpected and it exits silently having changed nothing.

**Do not call the files behind the router, and do not teach anyone to.** The person learns one command; when the provider changes, the router keeps its name and its arguments and everything underneath is replaced. The moment an alias or a shortcut points at `transcribe-cloud.sh`, that path stops inheriting every future fix — and nothing will tell you it has fallen behind.

Output lands in `workspace/transcripts/<date>-<name>.md` with frontmatter. `status: pending` there means *transcribed but not yet filed anywhere* — a flag for unfinished work, not decoration.

_Source: design decision_

---

### Q: Why won't it just try a language that isn't on the list? Guessing is better than nothing.

It is not. The three failure modes are not equally visible: some languages come back correct, some come back as an obvious mess, and some come back as **fluent, confident text that is not what was said**. Nothing marks the third case, and it is the one that reaches a client.

So the router refuses by name. Adding a language is a real decision — which provider it goes to, and whether that provider is known to mangle it — and it is worth making deliberately once rather than discovering it in a transcript.

_Source: design decision_

---

### Q: Why doesn't it translate while it transcribes? That would be one step instead of two.

The Khmer script began life exactly that way — Khmer audio, Chinese out, because the person reading it read Chinese. It was right for that reader and wrong as a default: for someone whose own language is Khmer it is as strange as handing a Chinese speaker English text for a Chinese recording.

The deeper reason is that a transcript and a translation are different objects. One is a record of what was said; the other is somebody's rendering of it. Collapse them and nobody can ever check the second against the first — including the person who asked for it.

_Source: design decision, 2026-08-10_

---

### Q: Can't you just run the key setup for me? It'd be quicker.

It would not, and it does not work.

`setup-api-key.sh` reads the key with the screen blank, from a real keyboard. Run inside an agent's tool call there is no keyboard attached: it reaches the prompt, reads nothing, exits non-zero, and writes no key file at all. You get an error and still no key.

The reason it is built that way is the same one behind never pasting a key into chat: once the value has been in a conversation it is in that conversation's history and in every backup of it. There is no "just this once". The handoff is the agent's to get right — give the exact line, say plainly that you will not see what is typed, and wait.

_Source: design rule · confirmed by an agent trying it and getting a non-zero exit with no key written_

---

### Q: How do I know nobody edited the transcript afterwards?

Hash it when it is written, and hash it again after the corrections go in:

```sh
shasum -a 256 <transcript file>
```

**Same hash, corrections visible in a table above the text** — the rule held. **Different hash** — something was edited in place, and the record of what was actually heard is gone; recover the original if you can, and say what was lost if you cannot.

Do not re-run the hash after an edit and report the new one as though it had always been that. That turns a detectable mistake into an undetectable one.

_Source: standing rule_

---

### Q: I'm setting this up on a new machine. What's the whole sequence?

Two providers, because they do different jobs. Set up whichever the person actually records — Khmer is not needed by someone who never records Khmer.

**Say these four things before you install anything**, not while it is running:

1. **Where their audio goes** — the file is sent to a named company's servers to be transcribed, and on a free plan that company may use it to improve their own systems. Do not soften that into "it's processed in the cloud". For a client recording, that is their decision to make.
2. **What a free tier means here** — there is a ceiling, requests start being refused when it is reached, nothing breaks permanently, and you will come back and ask before anything costs money.
3. **What `ffmpeg` costs** — a few hundred megabytes and a password prompt. It is needed only for files over 25 MB, and for the Khmer route.
4. **If a key already exists at that path, you will not overwrite it** — you will show path, modification time and byte length, never the value, and ask which one stays.

```sh
# en, zh — the key is the only hard requirement
bash tools/setup-api-key.sh groq   https://console.groq.com/keys
brew install ffmpeg                        # only for recordings over 25 MB
pip3 install opencc-python-reimplemented   # zh only; without it the transcript still
                                           # lands, it just stays in Simplified

# km — all three lines. Any one missing and km_transcribe.py stops before it starts.
bash tools/setup-api-key.sh gemini https://aistudio.google.com/apikey
brew install ffmpeg                        # gives you ffmpeg AND ffprobe; it needs both
pip3 install requests                      # km_transcribe.py imports it and exits without it
```

**The asymmetry is what catches people**: the `en` / `zh` route under 25 MB needs nothing but the key, so a machine set up and tested on English looks finished — and then stops dead on the first Khmer file. Do the whole column, not just the key.

The two `setup-api-key.sh` lines are the person's to run at their own terminal. The `brew` and `pip3` lines are ordinary installs; run those yourself, after saying what they cost.

_Source: build · five machines where setup was never completed at all_

---

### Q: A model name returns 404. Is the pipeline broken?

Probably not broken — stale. These scripts name specific models and specific provider pages, and those move. Three signals and what each one means:

- **A model name returns `404` or "model not found"** → that model was retired. Replace the name; the rest of the pipeline is unaffected.
- **The response no longer contains `segments`** → the response shape changed. Transcripts still get produced, as one wall of text.
- **A setup URL leads nowhere** → the provider reorganised their site. Find the current page; do not guess a URL.

In all three: **say the mismatch before acting on it.** Then open an issue with the real output pasted in — `UPDATING.md` §7 has the link. Issues, not pull requests; nobody using this system needs write access.

More than once the agent at the far end has caught an error in what we shipped, and it was right every time. **An instruction cannot prove itself** — yours is the only reading of it happening on a real machine.

_Source: the trade we accepted by shipping scripts instead of instructions_
