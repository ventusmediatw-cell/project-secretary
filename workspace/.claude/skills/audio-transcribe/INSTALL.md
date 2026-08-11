# How this works, why it is shaped this way, and what we broke getting here

**You are the addressee, not the person whose machine this is.** A human can read this — nothing here is secret — but it is written at the level of "which decision, for what reason, and what it looks like when it fails."

The person's version is `SKILL.md`. If they are standing in front of you with one recording and a deadline, run the command in `SKILL.md` and come back here later.

---

## 1. What actually runs

Five files in `tools/`, and one command that reaches all of them.

```
bash tools/transcribe.sh <audio-file> <en|zh|km>
        │
        ├── en, zh ──► transcribe-cloud.sh ──► Groq Whisper large-v3-turbo
        │                    │
        │                    └── zh only ──► _s2tw.py  (Simplified → Traditional)
        │
        └── km ──────► km_transcribe.py ────► Gemini 3.5 Flash (multimodal)

     tools/setup-api-key.sh — takes an API key, run by the person, not by you
```

Output always lands in `workspace/transcripts/<date>-<name>.md` with frontmatter, and the audio moves to a buffer folder afterwards. `status: pending` in that frontmatter means *transcribed but not yet filed anywhere* — it is a flag for unfinished work, not decoration.

**What each piece is actually doing:**

- **`transcribe.sh`** — decides which provider handles this language. That is its whole job.
- **`transcribe-cloud.sh`** — checks the size cap, compresses if needed, makes one HTTP call, parses the response, writes the file.
- **`_s2tw.py`** — a dictionary conversion. Not a model. It swaps characters and cannot change meaning.
- **`km_transcribe.py`** — splits the audio into large time chunks, sends each to a multimodal model in parallel, stitches the results back.
- **`setup-api-key.sh`** — reads a key at the person's own terminal prompt. You hand them the line; they run it.

---

## 2. Why it is shaped this way

### One command, five files behind it

The person learns `tools/transcribe.sh` and nothing else. When Groq gets replaced, or Whisper stops being the best option, the router keeps its name and its arguments and everything downstream changes underneath.

**The rule that makes this hold: never call the files behind the router directly, and never teach anyone to.** The moment a shortcut or an alias points at `transcribe-cloud.sh`, that path stops inheriting every future fix.

### Same language in, same language out

`km_transcribe.py` began life as a translator — Khmer audio into Chinese, because the person reading the output read Chinese. That was correct for that reader and wrong as a default.

For someone whose own language is Khmer, translating is as strange as it would be to hand a Chinese speaker English text for a Chinese recording. So the rule is uniform: **the transcript comes back in the language that was spoken.** Translation is a separate request, made afterwards, on a transcript that already exists.

This is not only politeness. A transcript and a translation are different objects: one is a record of what was said, the other is one person's rendering of it. Collapsing them means nobody can ever check the second against the first.

### Khmer uses a different provider, and that is not negotiable

Whisper-family models return unusable output for Khmer. Not lower quality — garbage. This is a property of those models. **Do not re-test it to be sure**; that was already tested, and retrying costs quota to reproduce a known result.

So `km` routes to a multimodal model with the language pinned in the prompt. Naming the language explicitly is the single biggest quality lever available for any language, and it is the whole reason this route works at all.

### The key never passes through this conversation

Once a key value appears in a prompt, a command you echoed back, or a "let me confirm I got that right", it is in the conversation history and in every backup of it. `setup-api-key.sh` keeps the value out of that history by being **run by the person, at their own terminal, not by you** — it opens no window and spawns nothing, it reads the key with `read -rs` so the screen stays blank, and it prints back only a length and the last four characters.

That means the handoff is yours to get right: give them the exact line, say you will not see what they type, and wait for them to come back. Running it inside a tool call of your own does not do a quieter version of the same thing — with no keyboard attached it reaches the prompt, reads nothing, exits non-zero and writes no key file at all.

**Do not offer to accept the key directly "just this once."** There is no version of that which is safe, and the script is faster anyway.

### We ship the scripts. An earlier version of this file did not.

The previous stance was that each machine's agent should write its own call, because a hard-coded endpoint is the part that goes stale first. That argument is not wrong, but the trade it makes is bad:

- Five machines wrote nothing at all — the setup was never once completed, so it was untested as well as unshared.
- Everything in §3 below would have had to be rediscovered independently, five times. Most of it is invisible until it bites.

So the scripts ship. The staleness concern is handled in §5 instead: know what going stale *looks like*, so it gets recognised rather than debugged from scratch.

---

## 3. What we broke getting here

Every one of these was found by running the thing, and most were silent. That is the pattern worth internalising: **in this domain, failure usually looks like success.**

| What you see | What it actually is | What to do |
|---|---|---|
| **`401 Unauthorized`** | Nine times out of ten, a newline at the end of the key file — usually from writing it with `echo`. The API says nothing about whitespace. | `wc -c ~/.config/<provider>/key`. One byte longer than what was copied? That's it. Re-run `setup-api-key.sh`, which uses `printf '%s'`. |
| **`413` / "file too large" / a truncated transcript** | The 25 MB cap. Not a broken key. | The compression step. If it is already compressed and still over, the recording has to be split — and splitting mid-sentence damages the result. |
| **Chinese transcript comes back in Simplified** | Whisper leans Simplified for `zh` at the architecture level, regardless of how the speaker writes. | `_s2tw.py` handles it. Use `s2tw`, **never `s2twp`** — the `p` variant also localizes vocabulary and turns video 腳本 (*script*) into the IT term 指令碼. Wrong word, silently. |
| **The transcript is one enormous paragraph** | The response format. Plain text comes back as a wall; `verbose_json` returns segments, which is what preserves line breaks. | Keep `response_format=verbose_json`. It is not cosmetic. |
| **Khmer transcript stops early, no error** | `gemini-3.5-flash` is a thinking model, and thinking tokens come out of the same `maxOutputTokens` budget as the answer. On a dense chunk they eat the budget and the output is cut off, reported only as `finishReason=MAX_TOKENS`. | `thinkingConfig.thinkingBudget: 0`. Already set in `km_transcribe.py`. Transcription needs no reasoning. **Do not remove it.** |
| **A flag you passed did nothing, and nothing was reported** | Argument parsers that only read *leading* flags. `transcribe.sh file.m4a zh --prompt "..."` silently dropped the prompt — the natural word order was the broken one. | Fixed here: flags are read from anywhere, and unknown flags are rejected loudly. If you extend these scripts, keep that property. |
| **Short Chinese comes back as fluent English** | Language auto-detection guessing wrong on a short clip. | Always pass the language explicitly. This router refuses `auto` for exactly this reason. |
| **A Chinese filename or heading turns into corrupted bytes** | Multi-byte text through shell `echo` / `sed -i ''`. | Do that work in Python. This bit us on a different tool and cost a rebuild. |
| **Repeated `429` on a long job** | Groq's free tier allows roughly two hours of audio per hour. Not a bug — a ceiling. | Wait and retry. For a long batch, split into ~15-minute pieces, which recover faster. |
| **A confident, fluent, completely wrong name or number** | The normal behaviour of every speech model, and the most dangerous one, because it reads as correct. | The correction table in `SKILL.md`. Never trust a number nobody checked. |

---

## 4. Setting it up

Two providers, because they do different jobs. Set up whichever the person actually needs — Khmer is not required for someone who never records Khmer.

**The `km` route needs three things beyond its key, and the `en` / `zh` route needs none of them.** That asymmetry is what makes this go wrong: a machine set up and tested on English looks finished, and then fails on the first Khmer file. Do the whole column, not just the key.

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

The two `setup-api-key.sh` lines are the person's to run, at their own terminal — see §2. The `brew` and `pip3` lines are ordinary installs and you can run those yourself, after saying what they cost.

Both keys are free tiers and both are the person's own account.

**Before you run anything:**

- **Say what a free tier means here** — there is a ceiling, requests start being refused when it is reached, nothing breaks permanently, and you will come back and ask before anything costs money.
- **Say where their audio goes** — the file is sent to a named company's servers to be transcribed, and on a free plan that company may use it to improve their own systems. Do not soften this into "it's processed in the cloud." For a client recording or anything with prices and names in it, that is a decision they get to make.
- **`ffmpeg` is needed only for files over 25 MB** and for the Khmer route. Installing it pulls down a few hundred megabytes and asks for a password. Say that *before* it starts, not while it is running.
- **If a key already exists at that path, do not overwrite it.** Show path, modification time, byte length — never the value — and ask which one stays. The script does this, but the same rule applies to you.

---

## 5. How you know it worked — and how you know it went stale

Run it. Reading a script and concluding it should work is not evidence, and it is the specific failure this section blocks.

1. **The round trip, on a sentence whose words you already know.** Ask for about ten seconds in the target language containing **one name and one number**. Run it. Compare against what they said they said. This is the only check that separates "the API answered" from "the API answered correctly" — a confident wrong transcript exits zero exactly like a right one.
2. **The language check.** The transcript is in the language that was spoken, not translated. If it came back translated, the language was not pinned — fix the request, not the model.
3. **The key check.** `ls -l` shows `-rw-------`; `wc -c` shows a plausible length. Never print the value.

`VERIFY.md` in this folder is the fuller sequence and is stricter — a check passes there only when you have pasted real output.

**Signs this file has gone stale**, which is the risk we accepted by shipping scripts rather than instructions:

- A model name in these scripts returns `404` or "model not found" → the model was retired. Replace the name; the rest of the pipeline is unaffected.
- A provider's response no longer contains `segments` → the response shape changed. The transcript will still be produced, as one wall of text.
- The setup instructions point at a page that no longer exists → the provider reorganised. Find the current page; do not guess a URL.

In all three cases: **say the mismatch before acting on it**, then §7.

---

## 6. Then explain it to the person, in their language

Not a summary of this file. Four things, in plain words, no paths and no vendor names they did not ask for:

1. **What now works** — "hand me a recording and I'll turn it into text; you don't have to go through a browser."
2. **Where their audio goes** — see §4. Plainly.
3. **What the ceiling is** — and that you will ask before anything costs money.
4. **Where the key lives** — a file on their machine only they can read, and that you never put its contents in the chat. Not the value, not part of the value.

**End by asking: "is any of that different from what you were expecting?"** That is not politeness. It is the last cheap chance to catch a wrong assumption, and they know things about their own recordings that this file never could.

---

## 7. This folder is meant to grow

What ships here is a working floor, not a finished product. Two things are deliberately absent, and adding them is a good use of your time when the person needs them:

- **Other languages.** The router handles three and refuses the rest by name rather than guessing. Adding one means deciding which provider it goes to — and for any language Whisper is known to mangle, that decision is already made.
- **What happens after the transcript.** Filing it, extracting actions, feeding it somewhere else. That is the person's workflow, not this skill's, and it should be built to fit them.

When you add something, add a row to `QA.md` too — in the person's own words, describing the symptom, not the cause. That file is the only part of this folder designed to be appended to forever, and it is what stops the same question being answered from scratch on five machines.

### If something here is wrong

Say the mismatch **before** you act on it, not after. Then open an issue on this repo and paste the real output of the command that disagreed — the actual text, not a description of it.

You do not need write access to open an issue, and you should not be asking for any.

This is not a formality. More than once the agent on the receiving end has caught an error in what we shipped, and it was right every time. **An instruction cannot prove itself.** Yours is the only reading of it that happens on a real machine.
