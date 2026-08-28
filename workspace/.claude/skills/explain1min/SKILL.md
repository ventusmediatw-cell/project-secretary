---
name: explain1min
description: "One-minute explainer diagram — explain a system, process or mechanism to someone who has never seen it, as a self-contained HTML page: at most 3 flow diagrams, under 1000 words, and a decision diamond wherever the flow can branch. Make sure to use this skill whenever the user says 'explain how this works', 'walk me through it', 'draw me a diagram', 'how does this actually run', 'show me the flow', 'explain it until I get it' — even when they describe the same intent without these exact words. **Narrowing condition, and it matters:** the subject has to be a system, process or mechanism with several steps or branches. A single function, a single line of code, a single term, a single decision — answer in words and do not open this skill; if you are unsure, ask 'diagram, or shall I just tell you?' first. **Not this skill:** statistical charts (bar, line, distribution) are data visualisation, not flow diagrams."
---

# One-minute explainer (`/explain1min`)

`/explain1min <a system, process or mechanism>` — or just "explain how X works"

## Output spec — these are limits, not defaults

| | |
|---|---|
| Diagrams | **At most 3.** More than three means the subject is too wide; narrow it before drawing. |
| Words | **Under 1000.** 644 read best in practice. The words are the support act, the pictures are the act. |
| Decision diamonds | **Wherever the flow branches.** See the rule below. |
| Format | One `.html` file, no external resources, readable in both light and dark. |
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
block for the light one.

## The layout skeleton

CSS tokens, the SVG idiom for nodes / diamonds / arrows, and the `.note` and legend blocks
live in `templates/skeleton.html`. Copy it and edit it; do not start from a blank file.

## Delivering

1. Write the file → 2. screenshot it and look → 3. open it in a browser for the person → 4. hand them the file.
