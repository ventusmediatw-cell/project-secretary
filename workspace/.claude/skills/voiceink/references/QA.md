# QA — what actually went wrong

Six things that cost time. Each one: what you see, why it happens, what to do.

---

## 1. A pure-English sentence comes back in Chinese

**Symptom.** The person dictates *"I think this application is very elegant"* and gets 「我覺得這個應用程式很優雅。」 — a translation, not a transcription. Nothing warns them; the output looks like a clean, confident result.

**Cause.** The zh-TW Initial Prompt is a writing sample, and Whisper imitates it. With the language pinned to Chinese and that seed in place, the imitation is strong enough to carry English speech across into Chinese. The same audio on auto-detect with no seed keeps the English (measured 2026-06-27), which is how we know it is the seed doing it and not the model's own habit.

**Fix.** Set the language to **Auto-detect** rather than Chinese (Taiwan). On the pure-offline route that reduces the effect without eliminating it — a strong seed still tugs. The clean split is the local-Ollama route: Whisper on Auto-detect writes down what it hears, and the Traditional/Taiwan conversion happens afterwards in the enhancement pass. That is why the field-tested Taiwan setup is Auto-detect plus enhancement rather than a harder-pushed seed. Someone who speaks Chinese only, or who mixes in single English words ("幫我 check 一下"), should leave the language setting where it is.

---

## 2. opencc converts the characters but the wording is still mainland

**Symptom.** A deterministic converter is wired into the enhancement slot, 视频 correctly becomes 視頻 — and it stays 視頻, where a Taiwanese reader expects 影片.

**Cause.** `s2tw` and `s2twp` are different jobs. `s2tw` is glyph conversion only: Simplified characters in, Taiwan-standard Traditional characters out. `s2twp` does that **and** the phrase substitution — the `p` is for phrases — turning 视频 into 影片, 软件 into 軟體, and so on. A character converter cannot fix 視頻, because every character in it is already correct Traditional. The vocabulary gap is a separate axis from the script gap, and only the phrase table crosses it.

**Fix.** Use `opencc -c s2twp`, never `-c s2tw`, wherever this conversion is wired in (the Local CLI provider in the enhancement settings is one place it fits). Two things to know before trusting it: **the enhancement setting is per mode** — on the machine where this was measured on 2026-08-11 it was configured on a single non-default mode, so dictating in any other mode silently skipped the conversion entirely, with no error and no visible difference except in the output. And unlike an LLM pass, opencc only converts characters and phrases: it will not fix a homophone error or strip 嗯 / 呃. It is a precise converter, not an editor.

---

## 3. The dictionary replaces a word that should have been left alone

**Symptom.** 「這份文件要用印」 comes out as 「這份檔案要用印」. 「檢查項目」 becomes 「檢查專案」. The replacement fires on correct Taiwanese Mandarin.

**Cause.** The dictionary matches glyphs, with no notion of context. Both 文件 and 項目 are ordinary Taiwanese words with their own senses — a document, an item on a list — that happen to collide with mainland terms for a file and a project. Every occurrence gets rewritten, including the ones that were already right.

**Fix.** Decide on those two rows before importing, based on how the person actually speaks. Someone who only ever means a computer file and a work project keeps them; anyone who dictates 公文 or checklists drops them. There is no third setting, and no way to make the match conditional. The same reasoning applies to any row someone adds later: a replacement is safe only when the source word has one sense in that person's speech.

Note the mirror-image limitation: the dictionary also matches only the **glyph you listed**. The row is 視頻 in Traditional characters, so a Simplified 视频 from Whisper matches nothing and passes through untouched. The Initial Prompt is what pulls output into Traditional script so the dictionary has something to hit — the two pieces do not work separately.

---

## 4. Every dictated sentence is kept on disk

**Symptom.** None. This is not a malfunction, and nothing surfaces it in the UI — which is the reason it belongs in this file.

**Cause.** The app keeps a transcription history in its own store (`default.store`, in its application-support container). Measured on 2026-08-11: 3,205 Chinese segments, including verbatim sentences from that day's conversations.

**Fix.** Nothing to fix — but know it is there before making claims. "Your voice never leaves your Mac" is a statement about the network; it is not a statement about what is written to disk. On the local machine that history is an unencrypted running record of everything ever dictated, so it counts when the question is device loss, a shared machine, or a backup that goes somewhere else. Say the two things separately, and do not let the offline property be heard as "nothing is stored."

---

## 5. Checking the dictionary landed and getting a false "nothing found"

**Symptom.** The person imported all 39 rows, dictation behaves as if they took — but reading the store shows zero entries, so it looks like the import silently failed.

**Cause.** Two independent traps, both of which produce the same empty result.

- **SQLite write-ahead logging.** Fresh writes sit in the `-wal` sidecar file until a checkpoint folds them into the main store. Query the main store alone and the rows are genuinely not there yet.
- **`strings` cannot see the text.** It looks for runs of printable ASCII, and UTF-8 Chinese is none of that. It reports nothing regardless of what the file holds.

Run both mistakes together — main store only, read with `strings` — and you get a confident zero from a store that is full.

**Fix.** Scan the store **and** its `-wal` companion, matching CJK byte sequences rather than strings:

```sh
python3 - <<'PY'
import re, pathlib
for p in sorted(pathlib.Path("<VoiceInk application-support dir>").glob("dictionary.store*")):
    print(p.name, len(re.findall(rb'[\xe4-\xe9][\x80-\xbf]{2}', p.read_bytes())))
PY
```

This counts CJK byte sequences, not rows — it answers "are the words in there at all", which is the question the two traps get wrong. For "are all 39 rows correct", the answer is the app's own dictionary screen, read by the person.

---

## 6. The instructions describe buttons that are not there

**Symptom.** A step says a setting lives in one place and the app has it somewhere else, or under a different label.

**Cause.** Everything written down here is based on VoiceInk **v1.79** (released 2026-05-23; noted 2026-08-29). Later versions move things — that is normal for an app under active development, and no version of this file can stay ahead of it.

**Fix.** Trust the app in front of you over the write-up, say out loud that they disagree, and then fix the write-up rather than working around it. What does *not* change between versions is the payload: the Initial Prompt, the dictionary rows, and the enhancement prompt are text going into named fields, and the fields move but do not change jobs. Never adjust the payload to make a UI mismatch go away.
