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
--prompt "names, product names, jargon"   # stops proper nouns coming back wrong
--out PATH                                # write somewhere specific
--keep-audio                              # don't move the audio afterwards
```

`--prompt` is worth more than it looks. Names, brands and internal jargon are exactly what speech models mangle, and feeding them in advance is the cheapest fix available. Use it whenever you know what the recording is about.

### First time on this machine

`tools/transcribe.sh` needs an API key and will tell you so, with the exact command, if one is missing. Do not go looking for the key or ask the person to paste it to you — **`INSTALL.md` in this folder explains why the key must never pass through this conversation**, and `tools/setup-api-key.sh` handles it in a separate window.

---

## After you have the text

**Say what you want done with it.** A transcript is raw material, not the thing anyone wanted. Summarise it, pull the action items, draft the reply.

**Check names and numbers before it goes anywhere.** People's names, place names, prices and dates are what speech models get wrong, and they come back looking exactly as confident as the parts that are right. Verify them against something you trust before any of it reaches a client, a colleague, or a shared document.

**Never edit the transcript body.** If something needs correcting, put a table above it:

```markdown
| Heard as | Should be |
|---|---|
| <what the transcript says> | <the correct term> |
```

Editing the body destroys the only record of what was actually heard. After that you cannot tell an accurate transcription from a confident guess, and you cannot re-check it later against a better model.

---

## The rest of this folder

| File | What it is | Read it when |
|---|---|---|
| **`INSTALL.md`** | Why this is built the way it is, what we broke getting here, and how to set it up | Before changing anything, and on first setup |
| **`QA.md`** | Questions people actually asked, and what turned out to be wrong | Something behaves oddly — check here before debugging |
| **`FLOW.md`** | Diagrams: how setup runs, how a recording becomes text | You want the shape at a glance |
| **`VERIFY.md`** | Checks that produce evidence rather than claims | Before telling anyone this works |

**If something on this machine disagrees with this file, the machine is right.** Say so before you act on it, then follow the instructions at the end of `INSTALL.md`.
