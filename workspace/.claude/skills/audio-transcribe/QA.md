# Questions people actually asked

Append to this file. Never rewrite the whole thing.

The questions are in the words people really used, because that is how the next person will search. The answers lead with **what you are seeing**, because that is what someone has in front of them when they come looking — the cause only helps once they know they are in the right place.

**This file is read by agents as well as people.** When a teaching page renders these questions, it renders *from here*. Adding a row means editing this file, not the page.

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

**Next time**, feed the names in beforehand:

```sh
bash tools/transcribe.sh meeting.m4a en --prompt "Marisa, Devraj, Northwind, QBR"
```

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
