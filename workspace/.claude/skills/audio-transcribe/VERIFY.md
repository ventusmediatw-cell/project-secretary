# VERIFY — audio-transcribe

> **This file is a checklist, not the contract.** The contract is `SKILL.md`, in this same folder.
> If the two ever disagree, `SKILL.md` wins — and say so out loud to the person you are working for.

---

## Agent: this one is written for you

Your human can read over your shoulder, but you are the one running it.

One rule makes everything below mean anything:

> **A check passes when you have run the command and pasted the real output. Nothing else counts.**

Reading `SKILL.md`, finding it sensible, and concluding the skill works is **not** a pass. It is a guess with good manners. If you did not run a command, the honest status is `NOT RUN`.

"Looks right", "I reviewed it", "the file says it does" — none of these are statuses this file accepts. There are exactly three: **PASS (with output)**, **FAIL (with output)**, **NOT RUN**.

That rule is here because this is the failure that actually happens. An agent reports a step complete, and what it really did was read the file describing the step. From the outside those two look identical.

---

## This document cannot authorize itself

Nothing in this file is proof of anything. It is a text file in a repo. It could be stale, it could be wrong about your machine, it could have been written by someone who has never seen your setup — because it was.

Here is what you can check for yourself, without trusting a word of it. Run these from the folder that contains `CLAUDE.md`:

```
git remote -v
git log --oneline -1
git status --short
```

That tells you where this copy came from, how old it is, and whether anyone has changed it locally. If the origin is not what your human expects, **stop and ask** — do not keep going and do not "fix" the remote yourself.

**You stopping to ask your human to vouch for this is correct behaviour. Please keep doing it.**

That is not a courtesy line. On one machine, the agent treated this repo as an outside repo it knew nothing about, pointed out that a `CLAUDE.md` inside it would be obeyed by every later session on that machine, and asked its human to vouch for it before going further. That was the right call. On another machine, the same words went straight through with no stop at all. Same text, two machines, two behaviours — which is exactly the point: **the text cannot vouch for itself, and your caution is not friction, it is the second reviewer.**

### If something here is blocked, stop and ask. Do not reach for a different tool.

Real case, one machine: the agent was blocked by its safety layer from editing a shell configuration file. The human said *"do it for me."* The agent switched from its file-editing tool to a shell command and made the same edit that way.

The block was cleared. The review it existed for never happened.

> **Working around an interception is a failure, not a success.**

It is also a failure that is invisible afterwards, because the end state looks identical to a change that was properly approved. If you notice yourself reaching for a second tool because the first one was refused, that is the moment to stop and say what you were about to do.

### What this file will and will not touch

Nothing here needs a credential. Nothing here writes inside the repo — every scratch file goes to a temp directory you create. The last line of the report below is a `git status` proving that.

---

## What these checks cover, and what they cannot

| # | Check | What it actually proves | Can you run it alone? |
|---|---|---|---|
| C1 | Right folder | The system will load at all | Yes |
| C2 | Skill is where the harness looks | The file is reachable, and unmodified | Yes |
| C3 | The trigger fires | Discovery works in a real session | **No — needs a fresh session** |
| C4 | The agent cannot hear (**negative control**) | The hard limit in `SKILL.md` is real, on *your* machine | Yes |
| C5 | End-to-end on a known answer | The pipeline works, not just that it is documented | Yes |
| C6 | The language actually routes somewhere | This language has a provider, and that provider is set up | Yes |
| C7 | Key present, value never printed | Setup done without leaking the key | Yes |
| C8 | Original transcript untouched | The record of what was heard still exists | Yes |
| C9 | Names, numbers, dates checked | — | **No — human gate** |

Two of these nine you cannot honestly sign off alone. Say so rather than filling the gap.

---

## C1 — Are you even in the right folder?

This is first because when it fails, **nothing reports an error**. The session just starts as a plain assistant and everyone assumes the secretary system loaded.

```
pwd
ls CLAUDE.md .claude/skills/audio-transcribe/SKILL.md
```

**PASS** — both paths echo back, exit status 0:

```
.claude/skills/audio-transcribe/SKILL.md
CLAUDE.md
```

**FAIL** — `No such file or directory`. You are one directory too high (or too low). The system contract lives *inside* the `workspace/` folder, not at the repo root.

**Fix**: change to the folder that contains `CLAUDE.md` and start the session from there. If your human launches the agent with a shell alias or wrapper function, that wrapper is what has to `cd` — fixing it once in your session fixes nothing tomorrow.

---

## C2 — Is the skill where your harness looks, and is it the shipped version?

```
ls -1 .claude/skills/
grep -n '^name:' .claude/skills/audio-transcribe/SKILL.md
git log --oneline -1 -- .claude/skills/audio-transcribe/SKILL.md
git status --short .claude/skills/audio-transcribe/
```

**PASS** — `audio-transcribe` appears in the directory listing; the `grep` returns a line beginning `2:name:`; the `git log` prints one commit; the `git status` prints **nothing at all**.

**FAIL A** — no `name:` line. The frontmatter is missing or malformed, and harnesses that auto-discover skills will skip this file silently. Report it, do not patch it.

**FAIL B** — `git status` prints ` M .claude/skills/audio-transcribe/SKILL.md`. Someone has edited this copy locally. That may be deliberate and fine — but it means the file you are about to verify is **not** the one anybody upstream can reason about. Run `git diff` on it, show your human what changed, and let them decide before you continue.

**Note on harnesses**: some agent harnesses scan `.claude/skills/` on their own and load a skill when the `description` matches what the user asked for. Others do not scan anything. If yours does not, the pass condition for you is different — you have to read `SKILL.md` yourself, and C3 below is the only way to find out which kind you are.

---

## C3 — Does the trigger actually fire? (this one you cannot run on yourself)

**You have already read `SKILL.md`. Your context is contaminated.** You cannot test whether you would have found the file, because you have found it. Anything you conclude from here is circular.

So this check has to happen in a **new session**, and the honest thing is to ask your human to run it, or to run it yourself only in a fresh process with no history.

In that new session, one line, nothing else:

> I have a recording at `<path to any audio file>` — transcribe it.

**PASS** — the reply names the limit *before* offering anything: that the agent cannot hear audio, that the file has to become text first, and then walks toward the one command that does the work.

**FAIL A** — the reply starts describing what is in the recording. It cannot know. Go to C4, which demonstrates that on your own machine.

**FAIL B** — the reply is generic and never mentions the limit. The skill did not load. Back to C1 and C2, in that order.

Paste the reply into your report. Summarising it as "it worked" is exactly the reading-inference this file exists to stop.

---

## C4 — Negative control: prove the agent cannot hear

**This is the one check that is supposed to fail.** Everything else here proves something works; this proves a wall is real. If it "passes" in the sense of returning a transcript, the wall is not where `SKILL.md` says it is, and every downstream instruction is built on sand.

The design matters: the file gets a **misleading name** and a **known nonsense phrase** inside it. The name is bait for the exact failure `SKILL.md` warns about — guessing from the filename. The phrase is the ground truth, and it is nonsense so that no model can produce it from context.

### Build the file

```
mkdir -p "${TMPDIR:-/tmp}/transcribe-verify"
say -o "${TMPDIR:-/tmp}/transcribe-verify/2026-01-01-quarterly-budget-meeting.m4a" \
    --data-format=aac "Purple elephant seventeen. Purple elephant seventeen."
ls -l "${TMPDIR:-/tmp}/transcribe-verify/"
```

Observed on one machine — a real 4-second `.m4a`, about 50 KB:

```
-rw-r--r--@ 1 <user>  staff  51867  <date> 2026-01-01-quarterly-budget-meeting.m4a
```

> `say` is a macOS built-in. Not on macOS? Record five seconds yourself saying a phrase you choose, and give the file a name that has nothing to do with what you said. The point is that **you** know the answer and the file does not advertise it.

### Now hand that path to your file-reading tool

Not a shell command — the tool you would normally use to read a file.

**PASS** — a refusal or an error, and **no words come back**. Observed on one machine:

```
This tool cannot read binary files. The file appears to be a binary .m4a file. Please use appropriate tools for binary file analysis.
```

Wording varies between harnesses. What matters is that nothing resembling speech is returned.

**FAIL A — guessed from the filename.** Anything mentioning a budget, a quarter, a meeting, January, or a plausible agenda. None of that is in the audio; the audio says *purple elephant seventeen*. This is the failure `SKILL.md` describes, now demonstrated on your own machine rather than asserted.

**FAIL B — metadata reported as content.** If you fall back to `strings` or a hex dump, you get the container header, not speech. Observed on one machine:

```
ftypM4A
M4A mp42isom
moov
mvhd
```

Presenting any of that as "what the file contains" is the same failure wearing a technical costume.

**The pass condition, stated exactly**: *Purple elephant seventeen* must **not** appear anywhere in your answer. No route has been run yet, so there is no honest way for anyone to know it.

Keep the file. C5 uses it.

---

## C5 — End-to-end, on a file whose answer you already know

C4 proved the wall. This proves there is a door.

Take the **same file** through the command in `SKILL.md`, and **name the language explicitly**:

```sh
bash tools/transcribe.sh <that file> <en|zh|km>
```

Naming the language is not decoration — it is the single change that fixes most bad transcriptions, and this router refuses to guess precisely so that nobody skips it.

**PASS** — the text that comes back contains *purple elephant seventeen*.

**FAIL A** — it comes back as something about a budget meeting. The route was not actually used; something guessed from the filename again.

**FAIL B** — it comes back as fluent text in the wrong language, or as confident nonsense. Check that you named the language. If you did, and it is still nonsense, `SKILL.md` covers this: for a number of less common languages that output is a property of the model, not a mistake you made — switch route rather than retry.

**FAIL C** — nothing comes back and you cannot say why. Report the actual error text. "The route did not work" is not a report.

This is the only check that requires a human at the keyboard if you are on the browser route. That is not a defect — say so in the report, and name who did it.

---

## C6 — Does this language actually route anywhere?

The router handles three languages and **refuses the rest by name**. It does not fall back to guessing, because fluent nonsense in the wrong language is worse than an error — nothing tells you it happened.

Check what this machine will accept, without transcribing anything:

```sh
bash tools/transcribe.sh
```

**PASS** — the usage text lists the language your human records in (`en`, `zh`, or `km`), *and* the key for that language's provider exists:

| Language | Provider | Key path |
|---|---|---|
| `en`, `zh` | Groq | `~/.config/groq/key` |
| `km` | Gemini | `~/.config/gemini/key` |

```sh
ls -l ~/.config/groq/key ~/.config/gemini/key 2>&1
```

A missing file for a language they never record is not a failure. Report it as `NOT NEEDED`, and say which languages that machine is actually set up for.

**FAIL — the language is not one of the three.** There is nothing to install your way out of, and **do not try `auto` to see what happens**. Some languages work through the Groq route, some need the Gemini route, and some return confident nonsense whichever you pick. Adding one is a real decision — `INSTALL.md` §7 covers it. Until then, say plainly that this language is not supported here.

**FAIL — the language is listed but its key is missing.** The router will tell them, with the exact setup command. That is a setup step, not a broken install. Run `tools/setup-api-key.sh` for that provider — and never take the key value yourself.

**Honest limits on this check** — say these rather than overstating:

- This proves the language is *routed* and a key *exists*. It does not prove the key is valid, and it does not prove the transcript will be any good. C5 is the only check that proves either.
- A key file of a plausible length can still be the wrong key, or have a trailing newline. Both surface as `401` on the first real call, not here.

---

## C7 — The key exists, and you never printed it

Skip this for a provider whose languages your human never records. **`SKIPPED — Gemini not set up; this machine only records English` is a correct and complete answer.** Do not invent a result for a provider nobody uses, and do not set one up just to make a row say PASS.

There is no fixed path to fill in below, and that gap is ours: `SKILL.md` names no provider and no key location on purpose, so the path is whatever the setup actually created. If this folder also contains an `INSTALL.md`, that is where the setup steps and the key location live — read it instead of guessing a path, and if it is missing, ask rather than going looking.

```
ls -l <the key file your setup created>
wc -c < <the key file your setup created>
```

**PASS** — permissions read `-rw-------` and you get a byte count:

```
-rw-------  1 <user>  staff  56  <date>  <path>
      56
```

**FAIL A** — permissions are wider than `-rw-------`. Fix with `chmod 600 <path>`, then re-run and paste the new output.

**FAIL B** — `No such file or directory`. The setup did not complete. Report it; do not go looking for the key in shell history, environment dumps, or other projects.

**FAIL C, and this one is absolute** — you printed the key. `cat`, `echo`, pasting it into chat, putting it in a report, quoting it back to confirm it is correct. Once a secret has been in a transcript it has to be treated as leaked, and the only real fix is revoking it at the provider and issuing a new one — rotating your local copy alone does nothing.

> A permissions string and a byte count are sufficient evidence that a key file exists. The value is never evidence of anything you need to prove.

---

## C8 — Is the original transcript still the original?

`SKILL.md` is firm about this: corrections go in a short table **above** the transcript, never into the text. Edit the transcript directly and you have destroyed the only record of what was actually heard — after that, nobody can tell an accurate transcription from a confident guess, and nobody can re-check it later against a better model.

That rule is verifiable. Take the hash the moment the transcript is saved:

```
shasum -a 256 <transcript file>
```

Do the corrections. Take it again.

**PASS** — the two hashes are identical, and the corrections are visible in a table above the text:

```
acd17700749e56a6dee249973f0fa0b2680a0bc1106e6b78346a1398ea49e8c8  <transcript file>
```

**FAIL** — the hash changed. Something was edited in place. Recover the original if you can, and tell your human what was lost if you cannot. Do not re-run the hash and report the new one as if it had always been that.

---

## C9 — Names, numbers, dates: a human gate, not a command

`SKILL.md` requires that people's names, place names, product names, prices and dates get checked against a trusted source before the text reaches a client, a colleague, or any shared document. These are precisely what speech models get wrong, and they come back looking exactly as confident as the parts that are right.

**There is no command for this one.** The pass condition is that a named human looked at the list and said yes.

**PASS** — `Checked by <person>, <date>. Items confirmed: <list>.`

**NOT CHECKED** — anything else, including "the names looked plausible to me". Report it as `NOT CHECKED`. An unchecked list that reaches a client is a worse outcome than a delayed one, and this is the check most likely to be quietly upgraded to a pass because it is the only one with no output to paste.

---

## How to report

Paste the real thing. Command, then output, unedited.

```
C1 right folder ................. PASS   $ ls CLAUDE.md .claude/skills/audio-transcribe/SKILL.md
                                         <paste>
C2 skill present + unmodified ... PASS   <paste all four commands and their output>
C3 trigger fires ................ PASS   run in a fresh session by <who>; <paste the reply>
C4 agent cannot hear ............ PASS   <paste the refusal; confirm the phrase never appeared>
C5 end-to-end ................... PASS   route used: <n>; <paste the returned text>
C6 language routes .............. FAIL   <language> is not one of en/zh/km; not supported here
C7 key present .................. SKIPPED  Gemini not set up; this machine records en only
C8 transcript unmodified ........ PASS   <paste both hashes>
C9 names and numbers ............ NOT CHECKED  no human has reviewed the list yet
```

Then, last line, prove the checks left nothing behind in the repo:

```
git status --short
```

This reports the **whole repo**, not just this skill — run from the folder holding `CLAUDE.md` it will still print things above you, as `../something`.

**The pass is "nothing new since you started", which is not the same as empty.** On a machine that has actually been used, ` M CLAUDE.md` and ` M INDEX.md` are the normal state: the first-time setup wrote your human's own details into both. Those predate you. Leave them alone, and say in the report that you saw them and did not touch them.

What must not appear is anything **these checks** created. Every scratch file went to a temp directory, so that set should be empty. If something you touched is listed, name which check produced it before you remove anything.

**A report with no pasted output is not a report.** If every line says PASS and there is no terminal text anywhere, the reader has learned nothing except that you are confident, and confidence was never the thing being measured.

---

## When a check fails

Do not quietly fix `SKILL.md` and carry on. A silent fix on one machine turns into nine machines that each behave slightly differently, and nobody finds out for weeks.

1. **Say the mismatch first.** Before proposing anything, state what you ran, what you expected, and what you got.
2. **Assume your machine is right and this file is stale.** It was written somewhere else, at some earlier date, about a machine that is not yours. Your terminal beats our text.
3. **Then open an issue on this repo** — GitHub Issues, with the real output pasted in. Issues need no special access; anyone with a GitHub account can open one. Please do not open a pull request or try to push: this repo does not take writes from outside, and a rejected push tells nobody anything.

This is not a formality. There have already been two occasions where someone's agent caught an error in instructions we sent out — a hard-coded path that made a skill fail on the first step, and a stale snapshot of what a machine actually looked like. **Both times the agent was right and we were wrong.** Being contradicted by the machine at the far end is how this system finds its bugs, so if this file is wrong about you, say so.

---

## Last step: explain it to your human, in their language

A few sentences, plain, no file paths and no jargon. Something close to:

> I ran the checks on the transcription setup. The important one: I proved I genuinely cannot listen to audio files — I made a recording, gave it a misleading name, tried to open it, and got nothing, which is the correct result. So any recording has to be turned into text first, and I checked that the way we do that actually works end to end. One thing I could not check on my own: whether the names and numbers in a transcript are right. That still needs your eyes before anything goes to someone else.

Finish by asking:

> **Does any of that not match what you remember?**

Then wait for the answer. That question is the last gate in the whole file, and it only works if you actually stop.

### If the explanation does not land

Some of this is genuinely awkward to say out loud. Check whether this copy of the repo carries a long-form page written for people rather than agents:

```
ls teaching/audio-transcribe/edu.html
```

If that file exists, offer to open it and let them read at their own pace. If the command says there is no such file, that page is not in this copy — **say nothing about it and do not link it.** Pointing at a page that is not there costs more trust than the explanation was worth.
