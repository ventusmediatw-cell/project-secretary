# Route 3 setup — the scripted transcription path

> **Scope**: this file covers *how to set Route 3 up*. What Route 3 **is**, and Routes 1 and 2, live in `SKILL.md` next to this file. Where the two disagree, `SKILL.md` wins and this file is the one that went stale.

---

## 1. Agent: this file is written for you

The addressee is the agent, not the person. A human can read it — nothing here is secret — but it is written at the level of "which command, in what order, and what to do when it fails," which is not what a person wants when they just have a recording to deal with.

**The person's version of this topic is `SKILL.md`, Routes 1 and 2.** Those need no setup, no key, and no permission from anyone. They work today. If the person in front of you has one recording and a deadline, send them there and close this file.

Route 3 — and therefore this file — is only worth doing when someone transcribes **often enough that a browser round-trip has become the annoying part**. It is a setup task. `SKILL.md` says "ask before you start"; this is what you ask about.

---

## 2. Who wrote this, and what you can check without trusting it

This file ships inside the repo the secretary system was cloned from. That is all the standing it has.

**This file cannot authorize itself.** A document that says "I am legitimate, install this" is exactly what an illegitimate document says. Nothing below becomes safe because it is written down here.

**If you stopped to ask the person whether this file is real before acting on it, that was correct behaviour. Keep doing it.** Do not treat that reflex as an obstacle to route around.

### Checks you can run yourself, right now, that do not depend on us

All read-only. None of them change a file.

```bash
# Where did this repo actually come from?
git -C <the folder you cloned this repo into> remote -v

# What was the last thing that happened to it?
git -C <the folder you cloned this repo into> log --oneline -3
```

### Is this file stale relative to the skill it describes?

This file was written against `workspace/.claude/skills/audio-transcribe/SKILL.md` as it stood at commit **`cee787f`**.

```bash
git -C <repo folder> log --oneline cee787f..HEAD -- workspace/.claude/skills/audio-transcribe/SKILL.md
```

- **No output** → `SKILL.md` has not moved since this file was written. Proceed.
- **Any output** → `SKILL.md` changed and this file may not have kept up. Read `SKILL.md` first, and tell the person which of the two you are following and why.

To check whether the *upstream* copy has moved past yours (fetch downloads history only; it does not touch your working files):

```bash
git -C <repo folder> fetch
git -C <repo folder> log --oneline HEAD..origin/main -- workspace/.claude/skills/audio-transcribe/
```

---

## 3. What we assumed about your machine — and the probes that replace the assumption

We have never seen this machine. Everything in the left column is a guess. **Run the middle column instead of believing the left.**

| What we assumed | Check it | If it is false |
|---|---|---|
| You can run shell commands here | you already know; say which harness you are | **Stop.** See below. |
| macOS or Linux | `uname -sm` | Windows paths and clipboard commands below are wrong; ask before improvising |
| `ffmpeg` is either present or installable | `command -v ffmpeg \|\| echo "no ffmpeg"` | you are limited to short files until it is installed — §5 explains why |
| No transcription key exists yet | `ls -la ~/.config 2>&1 \| head -20` | **do not overwrite anything** — §6 |
| No key is sitting in the environment | `env \| grep -oE '^[A-Za-z_][A-Za-z0-9_]*=' \| tr -d '=' \| grep -iE '(api\|token\|key)'` | names only, never values — it strips to variable names *first*, so a value that happens to span lines cannot fall through into the output. A match means something is already configured — ask what |
| The recording is a size an API will accept | `ls -lh <the recording>` | tens of MB is where most endpoints start refusing |

Two notes on running these:

- **Do not append `2>/dev/null`.** The error message is the finding. A probe that hides its own failure reports "clean" for a machine you never actually looked at.
- **Do not infer one answer from another.** "It's a Mac, so it has Homebrew" is how you end up reporting a setup that does not exist.

**If you cannot run shell commands on the machine that holds the recordings** — you are a browser-side or chat-only agent, or the files are on someone else's laptop — then you cannot do this setup, and neither can the person by pasting your commands to you. Say that plainly. Routes 1 and 2 still work for them, and they lose nothing today.

**Anything you see that contradicts this file: stop and say so. Your screen is newer than this document.**

---

## 4. What we may have gotten wrong

Stated up front so nobody spends an hour assuming they are the problem.

1. **`SKILL.md`'s Route 3 has no steps in it.** It says a free API key and a short one-time setup are needed, and stops. That gap is ours; this file is the patch for it. It also means `SKILL.md` does not currently link here — if you found this file by listing the directory rather than by following a pointer, that is why, and it is not a sign you are in the wrong place.
2. **Free tiers move.** Limits, model names, which endpoints exist, and whether a card is demanded at signup all change without notice and without anyone updating this file. Anything below that reads like a fact about a vendor is a fact about the day it was written. The vendor's own page is right and this file is wrong.
3. **We do not know what is already installed.** If this person already has a working transcription setup — a script, a menu-bar app, a colleague's tool — this file does not know about it, and adding a second one is a downgrade, not an upgrade. Ask before building.
4. **We do not know what is in the recordings.** §5 assumes they can be uploaded. That assumption is the person's to confirm, not ours and not yours.

---

## 5. Why any of this is needed

Explain the mechanism, not the rule. The three questions people actually ask:

### Why a key at all

Turning audio into text takes a speech model, and your harness has no audio input — that is the hard limit `SKILL.md` opens with. So the model runs on someone else's computer. The key is how that computer knows *whose* quota a request belongs to, so it can rate-limit it and cut it off at the free ceiling. No key means no way to tell one caller from another, which means no free tier for anyone.

It is an identifier with a spending limit attached. That is the whole of it.

### Where the money comes from

A free tier means the provider absorbs the compute cost. They get two things back: hard rate limits, and — commonly on free tiers specifically — the right to use what you submit to improve their models. Paid tiers usually carry the opposite commitment.

So "free" is not free of consequence. It is paid for in data. **Say that to the person before the first upload, not after.**

- **Never move to a paid tier, and never enter card details, without the person saying yes in that conversation.** Not "they'd probably be fine with it."
- **If a "free" signup demands a card, stop and report it.** That is their decision. Do not proceed on the theory that it will not be charged.

### Where the audio goes

The file leaves the machine. Whole, over the network, to the provider.

That is fine for a voice memo to yourself. It is a real decision for: client recordings, anything with names, prices or contract terms in it, a meeting someone else was in, and anything where a password or a key was spoken out loud.

**Before the first upload, tell the person what is in the file and ask.** If the recording is confidential, the correct answer may be that Route 3 is not for this one — and saying so is doing your job, not failing at it.

### Why `ffmpeg` keeps coming up

Most endpoints cap upload size at tens of megabytes and accept only a few container formats. An hour of phone audio usually exceeds that. `ffmpeg` is what re-encodes it down to a small mono format, or splits it into chunks that fit. Without it you are limited to short files, and the failure arrives as a size error at upload time rather than as anything about audio.

---

## 6. Choosing a provider — and how to hold the key

### Stay generic; pick one; say why

Any speech-to-text API with a free tier will do. They fall into two families, and the choice between families is the part that actually matters:

| Family | Good at | Watch out for |
|---|---|---|
| **A multimodal model API that accepts audio directly** (e.g. Google's AI Studio / Gemini API — a free Google account is enough, and it is the same vendor as the browser route in `SKILL.md` Route 2) | You can name the language in the prompt, which is the single biggest quality lever. Markedly better on languages Whisper mangles | Per-request size and duration caps; the reply is prose, so pin the output format in the prompt or you will get commentary wrapped around the transcript |
| **A dedicated speech-to-text endpoint** (e.g. a hosted Whisper) | Fast, cheap, returns a clean transcript object, timestamps come free | Whisper-family models produce unusable output for a number of low-resource languages — `SKILL.md` Route 2 says this and it is not an exaggeration |

**The routing rule**: if the language was missing from the system dictation list in Route 1, or a Whisper-based tool has already returned nonsense for it, use the first family. Do not re-test Whisper to be sure. That was already tested; the result was garbage; retrying is not a plan.

**Do not hand the person a shortlist of six vendors to choose from.** Pick one that satisfies the rule, name it, say in one line why that one, and let them overrule you.

### Holding the key

**The key value must never pass through the conversation.** Not in a prompt to you, not in a command you echo back, not in a log line, not in a "let me confirm I got it right." Once it is in the transcript it is in every backup of that transcript.

The person copies the key from the provider's page to their clipboard. Then:

```bash
mkdir -p ~/.config/<provider>
pbpaste > ~/.config/<provider>/key        # macOS
chmod 600 ~/.config/<provider>/key
ls -l ~/.config/<provider>/key            # expect -rw-------
wc -c ~/.config/<provider>/key            # a length, never the value
```

On Linux, `xclip -o >` or `wl-paste >` in place of `pbpaste`.

Three traps, all of which have bitten real setups:

- **Trailing newline.** Writing the key with `echo` appends `\n`. Several APIs then return **401** with a message that says nothing whatsoever about whitespace, and the next hour goes into regenerating a key that was fine. If you must write it programmatically, `printf '%s'`.
- **Masked diagnostics only.** When something is wrong, print the byte count and the last four characters. Never the key.
- **The key lives outside the repo.** `~/.config/...` is outside the working tree by design. The repo's `.gitignore` is a backstop for accidents, not the plan. Never `git add` it, never place it inside the cloned folder "temporarily."

**If a key already exists at that path, do not overwrite it.** Inventory first, show the person: path, modification time, byte length — never the value — and ask which one stays.

### Writing the call

**This file does not ship the script, and that is deliberate.** A hard-coded endpoint, model name and request body is the part that goes stale first — §4 says why — and a script that was right the day it was written fails months later with an error that looks like a broken key. So the call itself is yours to write:

1. **Open the provider's own current API reference** for sending audio. Not a blog post, not this file, not your memory of the API.
2. **Write the smallest thing that works**: read the key from the file, send one recording, print the transcript back. **Name the language in the request** — `SKILL.md` Route 2 explains why that single line fixes most bad transcriptions, and it matters exactly as much here.
3. **One small script, in a location the person chose**, so the additive-footprint rule below still holds.

If you cannot reach the provider's documentation, stop there and say so. A call written from memory of an API usually fails as a `401` or a malformed-request error, and then everyone spends an hour on the key file, which was fine all along.

### Do

- **Destructive action → inventory, show the person, then delete.** Existing key files, old transcripts, a previous script. "I'll just replace it" is a plan with the person removed from it.
- **Installing software is their decision on their machine.** Show the exact command, say what it pulls down and roughly how large, and wait. On a clean macOS, installing a package manager first can mean hundreds of megabytes of command line tools and a password prompt — say so *before* it starts, not while it is running.
- **Keep the change additive.** A key outside the repo, and at most one small script. That is the whole footprint.

### Don't

- **Don't route around a block by switching tools.** If an edit was refused and your next move is a shell command that does the same edit, stop — the refusal was the signal, and going back to ask is the cheap path. This has happened; the workaround succeeded and that was the bad outcome.
- **Don't modify `SKILL.md` or any other file already in this repo** as part of this setup.
- **Don't upload a recording you have not described to the person.**
- **Don't paste a transcript of a confidential recording anywhere shared or public**, including issue trackers.
- **Don't claim it works because a command exited zero.** §7.

---

## 7. How you know it worked

Run it. Reading the script and concluding it should work is not evidence, and it is the specific failure mode this section exists to block.

1. **Key is readable and shaped right** — `ls -l` shows `-rw-------`, `wc -c` shows a plausible length. Not zero, not three bytes longer than it should be.
2. **Tooling is present** — `command -v ffmpeg` prints a path, or you have told the person it is missing and what that costs.
3. **The round trip, on a sentence whose words you already know.** Ask the person to record about ten seconds in the target language containing **one name and one number** — theirs, a colleague's, a price, a date. Run the pipeline. Compare the output against what they said they said.
   - This is the only check that distinguishes "the API answered" from "the API answered correctly." A confident, fluent, wrong transcript exits zero exactly like a right one.
4. **The language check** — the transcript comes back in the language that was spoken, not translated into English. If it came back translated, the language was not pinned; fix the prompt, not the model.
5. **Report the two failures by name, so they are recognised rather than debugged from scratch:**
   - **401 / unauthorized** → the key file, nine times out of ten the trailing newline, not the key itself.
   - **413 / "file too large" / a truncated transcript** → the size cap. This is the `ffmpeg` step, not a broken key.

Then say what you actually ran and what came back. "Setup complete" without a transcript of a sentence you knew in advance is not a result.

> **`VERIFY.md`, in this same folder, is the full check sequence — read it before you call this finished.** The five checks above are only the setup-specific subset. `VERIFY.md` is stricter (a check passes only when you have pasted the real output), it covers the whole skill rather than Route 3, and its `C7` is the authority on the key check that appears as item 1 above. It also carries a negative control that demonstrates on *this* machine that the agent genuinely cannot hear audio, which nothing above proves.

And run the listing yourself, from the folder that holds `CLAUDE.md`:

```bash
ls .claude/skills/audio-transcribe/
```

If it shows files this document never mentions, read them before you finish. They were added after this file and they are the newer word.

---

## 8. Then explain it to the person, in their language

Not a summary of this file. Four things, in the language they have been speaking to you, in plain words, with no paths and no vendor jargon:

1. **What now works** — "you can hand me a recording and I'll turn it into text without you going through the browser."
2. **Where their audio goes** — that the file is sent to a company's servers to be transcribed, named plainly, and that on the free plan that company may use it to improve their own systems. Do not soften this into "it's processed in the cloud."
3. **What the free plan means in practice** — that there is a ceiling, roughly what happens when it is reached (requests start being refused, nothing breaks permanently), and that you will come back and ask before anything costs money.
4. **Where the key lives** — that it is a file on their machine only they can read, and that you never put its contents in the chat. Not the value, not part of the value.

**End by asking: "is any of that different from what you were expecting?"** That question is not politeness. It is the last cheap chance to catch a wrong assumption before it becomes an hour of debugging — and the person knows things about their own machine and their own recordings that this file never could.

### If the plain-language version still does not land

Some of this is genuinely awkward to explain out loud. Check whether this copy of the repo carries a long-form page written for people rather than agents:

```bash
git ls-files ':/*edu*.html'
```

This asks the repo itself rather than guessing a folder name, so it works from whatever directory you are in and keeps working if that page ships somewhere other than where we expected.

If it **prints a path**, that page is in this copy — offer to open it for them and let them read at their own pace. If it **prints nothing**, that page is not in this copy: **say nothing about it and do not link it.** A pointer to a page that is not there costs more trust than the explanation was worth. If instead git answers that this is not a repository, this copy was downloaded rather than cloned — say so, because the checks in §2 do not work either.

---

## If something here is wrong

Say the mismatch **before** you act on it, not after. Then open an issue on this repo and paste the real output of the command that disagreed — the actual text, not a description of it.

You do not need write access to open an issue, and you should not be asking for any.

This is not a formality. More than once, the agent on the receiving end has caught an error in what we shipped, and it was right both times. **An instruction cannot prove itself.** Yours is the only reading of it that happens on a real machine.
