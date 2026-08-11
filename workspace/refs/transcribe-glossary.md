# Transcription glossary

Names and terms this machine's recordings actually contain, and what the speech
model turns them into. `tools/_glossary.py` reads this file after every
transcript and writes a correction table above the text.

**It never edits the transcript body.** The body stays exactly as the model
produced it, because that is the only record of what was heard. The table says
what to change; you and your agent change it in whatever you build *from* the
transcript — the summary, the reply, the document that goes to a client.

---

## Format

One entry per line, anywhere in this file:

```
heard → correct
heard → correct   # a note, ignored by the tool
```

`->` works too. Lines without an arrow are ignored, so you can write notes
around your entries and this file stays readable.

---

## What belongs in here, and what will hurt you

**Put in**: proper nouns. People, place names, company names, product names,
brands, internal jargon. Things that are wrong in exactly one way and are not
ordinary words in any language this machine records.

**Keep out**: ordinary words, and anything that is a common word *somewhere*.

That second rule is not caution, it is the finding this whole file exists
because of. On 2026-08-11 the Khmer pilot ran three real recordings twice —
once plain, once with `--prompt` supplying three personal names. The prompt
fixed one name and, in the same pass:

- turned `ត្រី ចៀន` (**fried fish**) into `ជើង មាន់` (**chicken feet**) — only
  personal names were supplied, and it changed a food
- turned the correct honorific `Bong` into `Mong`
- turned `pain point` into `point point`, four times, in a passage the plain
  run had got right every time

The same trade shows up in Chinese from the opposite direction: this
repository's `_s2tw.py` deliberately uses OpenCC `s2tw` and **not** `s2twp`,
because the phrase table in `s2twp` "localises" 腳本 (a *script*, as in video
script) into 指令碼 (a *shell script*). Correct word in, wrong word out.

**The difference between the two is not the mechanism, it is the size of the
set.** An open-ended phrase table has to guess which sense you meant, and
sometimes guesses wrong. A closed list of proper nouns cannot: `Reaksa` is
`Reaksa` in every sentence it ever appears in.

So: closed set only. If you find yourself adding a word that could be an
ordinary noun, that is the moment to stop and ask instead of adding it.

---

## Entries

<!-- Add yours below. The examples are commented out; delete them or replace
     them with your own. Nothing here is required — an empty glossary is fine
     and the tool simply says nothing. -->

<!--
Bong Rea Sa → Reaksa      # English recordings; also appears as "Bonde Sa"
Bonde Sa → Reaksa
Mong Ria Sa → Reaksa
ប៉េលី → ប៉េលីណា             # Pelina, with the final syllable dropped
Marity Siha → Marady Seyha
Meredith Seha → Marady Seyha
-->

---

## Two things the tool does that are worth knowing

**It will not report a term that is already correct.** If an entry's wrong form
is a prefix of its right form — `ប៉េលី` inside `ប៉េលីណា` is the real case — the
tool checks whether the full correct form is already there before it says
anything. Otherwise every correct spelling would be reported as an error.

**It flags inconsistency separately.** If one transcript contains *both* the
wrong form and the right form of the same name, that gets its own line. This is
the failure mode worth knowing about: a model that spells a name correctly in
one sentence and drops a syllable two sentences later looks reliable exactly
where it is not, and a reader who does not know the team reads them as two
different people. You do not need to know the right answer to detect it, which
is why the tool can do it and a person does not have to remember to.
