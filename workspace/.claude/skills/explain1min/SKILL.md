---
name: explain1min
description: "One-minute explainer diagram — explain a system, process or mechanism to someone who has never seen it, as a self-contained HTML page: at most 3 flow diagrams, under 1000 words, and a decision diamond wherever the flow can branch. Make sure to use this skill whenever the user says 'explain how this works', 'walk me through it', 'draw me a diagram', 'how does this actually run', 'show me the flow', 'explain it until I get it', or in Chinese 「解釋一下 / 這怎麼運作 / 畫個流程圖 / 用圖講一下 / 講到我懂」 — even when they describe the same intent without these exact words. **Narrowing condition:** the subject has to be a system, process or mechanism with several steps or branches. A single function, line of code, term or decision — answer in words and do not open this skill; unsure? ask 'diagram, or shall I just tell you?' first. **Not this skill:** statistical charts (bar, line, distribution) are data visualisation, not flow diagrams."
---

# One-minute explainer (`/explain1min`)

`/explain1min <a system, process or mechanism>` — or just "explain how X works"

## What this does / does not

- ✅ Turns **one** system, process or mechanism into a self-contained HTML page: at most 3 flow diagrams, under 1000 words, a decision diamond wherever the flow branches, readable in both themes, and looked at before it is handed over
- ❌ Not for a single function, a single line of code, a single term or a single decision — answer those in words
- ❌ Not statistical charts (bar, line, distribution), and not a long-form teaching page
- ❌ Not "big pictures, few words" for someone who knows nothing — that is `eli5`

## When to use / when not

- Use it when someone says "explain how this works", "walk me through it", "draw me a diagram", "show me the flow" — **and** the subject has several steps or branches
- Not when the subject is one thing. Unsure → ask "diagram, or shall I just tell you?" before drawing anything

## Output spec — these are limits, not defaults

| | |
|---|---|
| Diagrams | **At most 3.** More than three means the subject is too wide; narrow it before drawing. |
| Words | **Under 1000 per language** (a bilingual page is two counts, not one; count CJK by character). 644 read best in practice. The words are the support act, the pictures are the act. |
| Decision diamonds | **Wherever the flow branches.** See the rule below. |
| Format | One `.html` file, no external resources, readable in both light and dark. |
| Language | The one the person used. Bilingual only on request or for a mixed audience — a second language doubles the checks (four shots, not two). |
| Numbers | **Only ones you actually measured.** If you cannot measure it, leave it out. |

## The rule: find the branches before you draw anything

**A linear narrative has nowhere to put a branch, so it drops gates silently.** Before you
draw, write out the subject's decision points — "if X then… otherwise…", "what gets turned
away here", "what has to be true before this is allowed". Those are your diamonds.

What it looks like when this goes wrong: three drafts written as a linear story, and all
three missed the same three entry gates. Not because the gates were unimportant — because a
straight line cannot show them. Redrawn as a flow chart, six diamonds appeared.

## Colour carries meaning here — do not reassign it

| | | |
|---|---|---|
| Blue | doing something (a process step) | `--s1` |
| Orange | a decision — or a detour that rejoins the main line | `--s2` |
| Red | turned away; this is where it ends | `--crit` |
| Grey | context, de-emphasised | `--deemph` |

⚠️ **Red is only for "this is the end of the line."** Something like "go and check that
repository first, then come back" is *an extra step, not a rejection* — that is orange. Use
red for it and the reader will believe the flow stops there. This one was caught by looking
at a screenshot; the source looked correct.

## What the three diagrams are for

1. **Diagram 1 — the main line.** Input through to outcome, with the gates sitting in the middle of it rather than tucked at the end.
2. **Diagram 2 — the decision that actually changes the result.** The one branch that determines whether the thing is any use: a threshold, an ownership call, a route.
3. **Diagram 3 — how it is used.** Two paths running in opposite directions (you ask it / it tells you), or front-of-house versus back-of-house.

Under each diagram, one `.note` block answering **"why is it built this way"** — one
sentence, not a paragraph.

## Before you deliver it, look at it

**If you have not seen it, it is not done.** Layout faults — a line crossing a box, two
labels colliding, something overflowing sideways — are only visible in the picture. Reading
the source will not find them.

**Step 1.** Serve it locally. `file://` is blocked or flaky in most browser-automation
paths; localhost is the one that works.

```sh
cd <directory containing the html> && python3 -m http.server 8931 --bind 127.0.0.1 &
```

**Step 2.** Screenshot the whole page with headless Chrome. Set `CHR` to your platform's
binary — macOS `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome`, Linux
`google-chrome` or `chromium`, Windows
`C:\Program Files\Google\Chrome\Application\chrome.exe`.

```sh
"$CHR" --headless --disable-gpu --hide-scrollbars \
  --window-size=1000,4600 --virtual-time-budget=3000 \
  --screenshot=shot.png "http://127.0.0.1:8931/<file>.html"
```

**Step 3.** Open `shot.png` and read it yourself, top to bottom. At minimum: does an arrow
pass under a node it has nothing to do with, do two labels collide, does anything overflow
sideways, does any diamond's text escape its shape.

⚠️ **Check both themes, and check that you actually got two.** If the machine is in dark
mode, headless Chrome renders both files dark and hands you two identical screenshots —
which looks exactly like a pass. Force it instead: copy the dark token block and append it
as `:root:root{…}` at the end of `<style>` for the dark shot, and do the same with the light
block for the light one. **The acceptance test is two different checksums** — `md5 shot-light.png shot-dark.png` — not two files. And a bilingual page (ZH/EN toggle) has two language states as well as two themes: the toggle reads `navigator.language`, so a headless shot only ever shows one; make a temporary copy per language (set the toggle's default to `'en'` / `'zh'` in the script at the end of the file) and shoot each — four shots, four checksums.

## The layout skeleton

CSS tokens, the SVG idiom for nodes / diamonds / arrows, and the `.note` and legend blocks
live in `templates/skeleton.html`. Copy it and edit it; do not start from a blank file. Its bilingual toggle block is optional — delete it for a single-language page, keep it (and tag every section `lang="zh-TW"` / `lang="en"`) for two.

## Delivering

1. Write the file → 2. screenshot it and look → 3. open it in a browser for the person → 4. hand them the file.

## The rest of this folder

| File | What it is | Read it when |
|---|---|---|
| **`references/QA.md`** | What people hit making these pages, and why the rules above are shaped the way they are | Something looks wrong in the screenshot, or before your first page |
| **`templates/skeleton.html`** | Tokens, the node / diamond / arrow idiom, the `.note` and legend blocks | Every page — copy it, do not start from a blank file |
| **`human/`** | Two pages for the person rather than for you, Chinese and English in one file with a ZH/EN toggle. `human/eli5.html` — this skill in big pictures and few words; `human/explain1min.html` — this skill as its own one-minute diagram | They ask what this is, or you are explaining what you are about to do |

**If something on this machine disagrees with this file, the machine is right.** Say so before you act on it, then follow `UPDATING.md` §7 at the repo root.
