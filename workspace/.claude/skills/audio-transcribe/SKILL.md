---
name: audio-transcribe
description: "Turn a recording — or something you'd rather say than type — into text your agent can actually work with. Use this whenever the user has an audio or video file, mentions a recording, pastes a path ending in .m4a / .mp3 / .wav / .mp4 / .MOV, or asks to speak instead of type. Covers the hard limit (Claude Code cannot hear audio) and the route that works for languages your system's dictation does not support."
---

# Audio → Text

## Read this first: the agent cannot hear

**Claude Code has no audio input.** `Read` handles images, PDFs and notebooks. It does not handle `.m4a`, `.mp3`, `.wav`, or `.mp4`.

Dropping a recording into the chat does not work — and the agent will not necessarily tell you it failed. At best it guesses from the filename, which looks like an answer and isn't one.

**Audio has to become text before it reaches the agent.** Everything below is about how.

---

## Route 1 — Your system's dictation

Fastest, nothing to install.

- **macOS**: press `Fn` twice, then speak. **System Settings → Keyboard → Dictation** shows which languages are available.

Good for widely-supported languages.

**If your language is not in that list, stop and use Route 2.** There is no workaround — the language assets do not exist on the machine, and retrying will not change that.

---

## Route 2 — A multimodal model, in the browser

For languages dictation doesn't cover, or when you already have a recording file.

1. Open a multimodal assistant that accepts audio (for example `gemini.google.com` — a free account is enough)
2. Speak into it, or upload the recording
3. Ask for this — **the language line is the part that matters**:

   > Transcribe this audio. The audio is in `<language>`. Write the transcript in `<language>`.
   > Do not translate unless I ask you to. If any part is unclear, mark it `(unclear)` — do not guess words.

4. Copy the text back into your agent and carry on

### Why naming the language matters so much

When you don't say what language it is, a speech model guesses — and for less common languages it guesses badly, usually substituting a regional neighbour. The output comes back fluent, confident, and wrong.

Naming the language explicitly is the single change that fixes most bad transcriptions. Do it even when it seems obvious.

### If you have tried Whisper-based tools and got nonsense

Whisper — and the many services built on it — produce genuinely unusable output for a number of low-resource languages. Not "a bit worse": garbage.

That is a property of the model, not something you did wrong. Switch to Route 2 and name the language.

---

## Route 3 — Scripted, if you do this often

A browser round-trip is fine occasionally. If you transcribe regularly, it can run as a single command from inside your agent instead.

This needs a free API key and a short one-time setup. **Ask before you start** — it is a setup task, not something to attempt in the middle of other work.

---

## Once you have the text

**Say what you want done with it.** "Summarise this", "pull out the action items", "draft a reply" — the transcript is raw material, not the deliverable.

**Check names and numbers before the text goes anywhere.** People's names, place names, product names, prices and dates are exactly what speech models get wrong, and they come out looking as confident as everything else. Verify those against a source you trust before any of it reaches a client, a colleague, or a shared document.

**Keep the original transcript unedited.** If you need to correct something, put the correction in a short table above the transcript rather than editing the text itself:

```markdown
| Heard as | Should be |
|---|---|
| <what the transcript says> | <the correct term> |
```

Editing the transcript directly destroys the only record of what was actually heard. After that you cannot tell an accurate transcription from a confident guess, and you cannot re-check it later against a better model.
