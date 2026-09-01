---
name: eli5
description: "Explain anything to someone who knows nothing about it — output an HTML page with big pictures and few words. Make sure to use this skill whenever the user says 'eli5', 'ELI5', 'explain like I'm 5', 'explain this simply', 'dumb it down', in Chinese 「用白話講 / 解釋得像我五歲 / 大圖少字解釋」, or asks to have something explained in plain language with visuals — even when they describe the same intent without these exact words. **Not this skill:** a system, process or mechanism with several steps or branches — that is explain1min (a flow diagram with decision diamonds)."
---

# eli5

> **Maintainer's note — this skill is one sentence on purpose.**
> No steps, no role, no checklist, no output template. That is the whole design: the work is
> carried by two constraints only — an assumption about the audience (they know nothing) and
> a shape for the output (HTML, big pictures, few words). If it reads as unfinished, it is
> not. Expanding it is the one change that breaks it.

`/eli5 <what you want explained>`

explain like I'm someone who knows nothing about this topic, using a HTML artifact with big pictures and few words

---

> The sentence above is the whole skill. Everything below is about the folder, not the prompt.

## When not

- The subject is a system, process or mechanism with several steps or branches → `explain1min` (a flow diagram with decision diamonds), not this
- The person wants depth or a reference to keep — this is the opposite of depth, on purpose

## Delivering

1. Write one `.html` file — inline SVG for the pictures, no external resources, readable in both themes (`references/QA.md` has the tokens and the traps). Write it in the language the person used; go bilingual only when they ask or the readers are mixed — a second language doubles the checks.
2. Look at it before anyone else does: serve it on localhost, screenshot it, read the screenshot — both themes, and both languages if the page is bilingual. Two identical screenshots mean you checked nothing. The method for forcing each theme and each language is in `../explain1min/SKILL.md` under "Before you deliver it, look at it"; the pastable commands are in `../explain1min/references/QA.md` §5.
3. Put it in front of the person: open it in a browser or publish it where they will see it, then hand them the file.

## The rest of this folder

| File | What it is | Read it when |
|---|---|---|
| **`references/QA.md`** | What people hit using this, and why one sentence is the design | The page came out long, text-heavy or unreadable; before your first one |
| **`human/`** | Two pages for the person rather than for you, Chinese and English in one file with a ZH/EN toggle. `human/eli5.html` — this skill explained its own way; `human/explain1min.html` — this skill as a one-minute diagram | They ask what this is |

**If something on this machine disagrees with this file, the machine is right.** Say so before you act on it, then follow `UPDATING.md` §7 at the repo root.
