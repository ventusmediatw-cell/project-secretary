# Questions people actually asked

Append to this file. Never rewrite the whole thing. An answer that later turns out to be wrong is **corrected by a new entry further down, not by rewriting the old one** — otherwise nobody can tell the advice changed, and whoever followed the old version has no way to find out.

**Paths here are relative to this skill's own folder** — `SKILL.md`, `references/` and `human/` all sit inside it. A path beginning `../explain1min/` is the sister skill next door; `UPDATING.md` is at the repo root. Where a rule is shared with `explain1min`, this file points at that skill's files rather than restating them, so the two cannot drift apart.

Each answer leads with **what you are seeing**, then what is actually happening, then what to do — the cause is only useful once you know you are in the right place. **This file is read by agents as well as by people.** There is no section-by-section map back to `SKILL.md`, and that is not an oversight: the prompt is a single sentence, and the three sections below the divider in that file — when not to use it, how a page gets delivered, what else is in the folder — are about routing, delivery and the folder, not the prompt. The grouping below is by where you got stuck.

---

## §1 — The skill itself

### Q: This skill looks unfinished. Where are the steps?

There are none, and there never were. `SKILL.md` is one sentence: *explain like I'm someone who knows nothing about this topic, using a HTML artifact with big pictures and few words*. No role, no numbered procedure, no output template, no checklist.

That sentence carries two constraints and nothing else — **an assumption about the audience** (they know nothing) and **a shape for the output** (HTML, big pictures, few words). Everything a procedure would have told you falls out of those two on its own. What counts as "few words" for a payment protocol is not what it is for a compost heap; a checklist would have to pick one and be wrong for the other.

So: read the sentence, then go and make the page. If it reads as though someone stopped writing halfway, that is the design working, not a gap for you to close.

_Source: the skill is copied verbatim from an internal usage that was already this short_

### Q: Can I add a checklist, a role line, or an output template to it?

No. This is the single change that breaks the skill, which is why the file says so at the top.

The observable failure: the moment a template lands in that file, every page it produces starts to look like the template — same headings, same intro, same summary block — and the thing that made it worth reading, that it was *shaped like the subject*, is gone. A role line ("you are a patient teacher…") does the same more slowly: it makes every page sound alike. Anything you were going to add belongs elsewhere — a **fact about how pages get delivered** (encoding, themes, publishing) in this file, a **rule about flow diagrams and branches** in `explain1min`.

_Source: design decision, stated in `SKILL.md` itself_

### Q: When is this the right skill, and when is it `explain1min`?

Symptom that you picked wrong: you are drawing boxes joined by arrows and you keep needing to write "if… otherwise…" beside them. That is not an eli5 page.

The split is about the **subject**, not the audience — both assume the reader knows nothing.

| The subject is… | Skill | The output |
|---|---|---|
| A topic, an idea, a thing — "what is a container", "why is this bill so high" | **`eli5`** | Big pictures, few words, no fixed count of anything |
| A system, process or mechanism with several steps or **branches** | **`explain1min`** | Flow diagrams, a decision diamond at every branch, a measured word ceiling |

The tell is branching. If a reader would sensibly ask "and what happens if it *isn't*?", the subject has gates in it, and gates need diamonds — see `../explain1min/SKILL.md`. A straight narrative has nowhere to put a branch, so it drops the gates silently and nobody notices. Neither skill is for a single function, a single term or a single decision — answer those in words; and neither is a long-form reference, this one being the opposite of depth on purpose.

_Source: the two skills were separated after each kept being used for the other's job_

---

## §2 — The page came out wrong

### Q: What I produced is a long article with one picture at the top.

You wrote the explanation and then illustrated it. The sentence asks for the reverse: **the pictures are the explanation, and the words are captions on them.**

Practical way back: for each section, ask what the picture would have to show for the paragraph to become unnecessary, draw that, then delete the paragraph and keep the one sentence the picture cannot say by itself. A section with no picture that could carry it is background you wrote for yourself, not for the reader.

The two constraints are also the only two acceptance tests you have. **Audience — does this land on someone who knows nothing?** Any term you did not introduce is a fail, including the ones that feel like plain English inside the domain. **Shape — big pictures, few words?** If the page reads top-to-bottom as prose with images, it is a fail however good the prose is. There is no third test; do not invent one.

_Source: the most common way a first page goes wrong_

### Q: How many words am I allowed?

There is no number here, and you should not invent one. `explain1min` has a ceiling because somebody measured it — under 1000, and 644 read best in practice; that is written down in `../explain1min/SKILL.md` because it came from real pages. This skill has never had a count measured against it, so **no count goes in this file.** "Few words" is a shape you judge against the pictures, not a budget you spend.

The same rule points outward, at the page you are writing: **a number you have not measured does not go on it either.** Percentages, speeds, costs, "most people…" — if you cannot say where the figure came from, cut it. A page for someone who knows nothing is exactly the page where an invented number cannot be caught by the reader.

_Source: design decision — the alternative is a number nobody can defend_

### Q: Where are the pictures supposed to come from?

Symptom: you reached for an image URL, an icon font, or a diagram library on a CDN, and the published page shows nothing at all — no error, no broken-image icon, just a gap. Cause: publishing surfaces block outbound requests for images, stylesheets and fonts. The page renders, the request dies quietly, and the hole looks like a layout bug you then go hunting for in your CSS.

Draw the pictures **inline, as SVG, by hand.** They are then part of the file, work offline, scale to any width, and — the part that matters here — take their colours from your tokens, so they survive a theme change. A shape vocabulary of rectangles, circles, arrows and text is enough for almost every eli5 page; see `human/eli5.html` for a page built entirely that way.

```html
<div class="big">
  <svg viewBox="0 0 640 210" role="img" aria-label="say here what the picture shows">
    <rect x="396" y="46" width="208" height="118" rx="20"
          fill="var(--nodebg)" stroke="var(--ink)" stroke-width="4"/>
    <path d="M240 105 L360 105" stroke="var(--axis)" stroke-width="5" fill="none"/>
    <text class="lab" x="500" y="192" text-anchor="middle">a label</text>
  </svg>
</div>
```

Give every `<svg>` a real `aria-label`. It is also the fastest self-check you have: if you cannot describe the picture in one clause, it is doing too much.

_Source: build — the silent-failure shape is why this is a rule and not a preference_

---

## §3 — The file will not open properly

### Q: The file has no `<!doctype>`, no `<html>`, no `<body>`. Is that broken?

No — that is correct for this output. A publishing surface wraps whatever you hand it in its own `<!doctype><html><head><body>` shell, so the source has to be a **fragment**: your `<title>`, your `<style>`, then the content. Adding your own shell gets you two nested documents. The one exception is the very first line — see the next entry.

The missing doctype does put a browser into quirks mode when the file is opened straight from disk, and that is the only thing it does. Once the fragment is published the shell supplies the doctype, so quirks mode is not in play — a fragment is not a mistake, and you do not add a doctype to "fix" anything.

_Source: how the publishing surface works_

### Q: I opened the file and the whole page is garbage characters.

Cause: a pure fragment carries no character-set declaration, so a browser opening it from disk guesses the encoding and guesses wrong. Nothing is wrong with the file's bytes. Keep this separate from the previous entry, because the two get merged and then both get fixed wrongly: **quirks mode comes from the missing doctype, mojibake comes from the missing charset.** The charset line below fixes the second and has nothing to do with the first.

Fix — **first line of the source file, always:**

```html
<meta charset="utf-8">
<title>…</title>
<style>…</style>
```

That one line satisfies both ends: opened locally it declares the encoding, and after publishing it lands in the body where it is harmlessly ignored, because the shell brings its own. When you hand this job to another agent, **write that line into the instruction**; a file structured as "title, style, content" is exactly how the line goes missing.

⚠️ **This symptom is misdiagnosed almost every time** — it gets read as a broken CJK font, or as a local server not sending a charset header, because all three look identical on screen. **The tell is the browser tab title.** A font problem cannot affect the tab; if the tab is mangled too, it is encoding. Second confirmation: `file -I page.html` reporting `charset=utf-8` while the screen is still garbled means the file is fine and the *declaration* is what is missing.

_Source: reported from machines in use, repeatedly, always diagnosed as a font first_

### Q: In dark mode, half the page is invisible.

Two causes, and they need different fixes. Find out which by checking whether the missing thing is inside an `<svg>`.

**Cause 1 — the tokens are only defined in one place.** A colour whose only definition sits inside a media query or a `[data-theme]` block has no value in the other state. Define the full light palette on bare `:root`, then redefine *only the tokens* twice more, and give `body` an explicit background — a transparent body borrows whatever is behind it.

```css
:root{ --plane:#f9f9f7; --surface:#fcfcfb; --ink:#0b0b0b; --line:#e3e2dc; --s1:#2a78d6; }
@media (prefers-color-scheme:dark){:root:not([data-theme="light"]){
  --plane:#0d0d0d; --surface:#1a1a19; --ink:#ffffff; --line:#2c2c2a; --s1:#3987e5;
}}
:root[data-theme="dark"]{
  --plane:#0d0d0d; --surface:#1a1a19; --ink:#ffffff; --line:#2c2c2a; --s1:#3987e5;
}
body{ margin:0; background:var(--plane); color:var(--ink); }
```

**Cause 2 — the SVG has hard-coded colours, or none.** `<text>` with no `fill` defaults to black, which is invisible on a dark plane and looks exactly like a missing label. Every `fill` and `stroke` in a diagram takes a token: `fill="var(--ink)"`, `stroke="var(--s1)"`, `fill="var(--nodebg)"`. No `#000`, no `black`, no `white` anywhere inside a diagram.

_Source: build — cause 2 passes every source-level check there is_

---

## §4 — Who the page is for

### Q: Should the commands I ran go on the page?

Almost never, and the reason is a division of labour rather than tidiness. The reader of an eli5 page is, by assumption, someone who knows nothing about the subject. Commands are not an explanation to them; they are noise that makes the page look like documentation and tells them they are in the wrong place. Anything **you** run stays in the conversation.

The exception is narrow and worth stating: a step **only the person at the keyboard can perform** — a click in a settings pane, a password, a physical action — earns its place, because there is no one else who can do it. Everything else does not. Look at `human/eli5.html`: it explains what the thing is and why it is built that way, and it contains no instruction for driving anything.

_Source: design decision — pages that carried the operator's commands were read as manuals and abandoned_

### Q: The reader wants it in two languages. Two files?

One file, both languages, a toggle. Two files drift the moment either is edited, and nobody can see that they have.

Mark each block with `lang`, hide by an attribute on the root, and remember the state:

```css
[data-lang="en"] [lang|="zh"]{display:none!important}
[data-lang="zh"] [lang|="en"]{display:none!important}
```

Both sides use the hyphen-match form `[lang|="…"]`, and not because `en` currently needs it — because the day someone tags a block `en-GB`, an exact-match selector on that side stops matching and the rule silently does nothing. Match the same way on both halves and there is no half left to forget.

```html
<section lang="zh-TW"> … </section>
<section lang="en"> … </section>
```

⚠️ **The region subtag is not optional.** A bare `lang="zh"` makes the browser pick regional glyph forms *inside the same font* — the typeface never changes, so nothing in the source looks wrong and a byte-level comparison finds nothing, while the rendered page is visibly not the writing system the reader expects. Always `zh-TW` (or whichever region actually applies), and note that the selector must then be `[lang|="zh"]`, the hyphen-match form — `[lang="zh"]` stops matching the moment the content is tagged properly.

⚠️ **Do not wrap CJK text inside a display or monospace face.** Those faces have no CJK glyphs, so those characters fall back to another font and split away from the Latin ones with a visible gap, reading as two words. Put only the digits and Latin inside the styled span and leave the rest outside it: `<em>26</em>` followed by the unit, not both inside the `<em>`.

Verifying a bilingual page means comparing **renderings**, not content. Every geometric check will pass.

_Source: reported from machines in use — four pages hit the same fault because they shared one spec_

---

## §5 — Before you hand it over

### Q: I read the source and it looks right. Is that done?

No. **If you have not looked at the page, it is not finished.** Every fault that matters at this size is a visual one: an arrow crossing a box it has nothing to do with, two labels colliding, a diamond's text escaping its shape, a diagram overflowing sideways. None of those are visible in the source, and reading it more carefully will not surface them.

**Step 1 — serve it.** `file://` is blocked or unreliable in most browser-automation paths; localhost is the one that works.

```sh
cd <folder containing the html> && python3 -m http.server 8931 --bind 127.0.0.1 &
```

**Step 2 — screenshot the whole thing.** Set `CHR` to your platform's binary (macOS `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome`, Linux `google-chrome` or `chromium`, Windows `C:\Program Files\Google\Chrome\Application\chrome.exe`).

```sh
"$CHR" --headless --disable-gpu --hide-scrollbars \
  --window-size=1000,4600 --virtual-time-budget=3000 \
  --screenshot=shot.png "http://127.0.0.1:8931/page.html"
```

**Step 3 — open `shot.png` and read it yourself, top to bottom.** Then kill the server.

⚠️ **Both themes, and prove you actually got two.** If the machine is in dark mode, headless Chrome renders both shots dark and hands you two identical images, which looks exactly like a pass. Force each theme the way `../explain1min/SKILL.md` describes under "Before you deliver it, look at it" — copy that theme's token block and append it as `:root:root{…}` at the end of `<style>`, once per theme — and do not invent a second method here.

**The acceptance test is that the two screenshots have different checksums.** Identical means you have not tested anything yet.

⚠️ Chrome's command-line flags do **not** move `prefers-color-scheme`; `--force-dark-mode` and its relatives leave `matchMedia('(prefers-color-scheme: dark)').matches` false, so shots taken with them are all the same image.

⚠️ A bilingual page needs **one shot per language as well**, because only one of them is on screen at a time — the recipe, and the reason a root-element stamp is not enough, is in `../explain1min/references/QA.md` §5.

**Step 4 — check sideways overflow on the screenshot's right edge.** Content escaping past the page margin is the bug; a wide figure clipped at its own border is not. The picture shows it, so you do not need to measure anything. Only if you are already in a browser-automation context that runs JavaScript, these two lines say the same thing:

```js
document.body.scrollWidth === innerWidth  // must be true
[...document.querySelectorAll('body *')].filter(e => e.getBoundingClientRect().right > innerWidth + 2)
```

The fix belongs on long links (`a[href^="http"]{overflow-wrap:anywhere}`), not on table cells or list items — applied broadly it breaks CJK and all-caps words character by character.

⚠️ Two traps while looking at screenshots. A page taller than the window cannot be cropped with a centre-cropping tool such as `sips` — an offset of `0 0` hands you the middle of the page, so you spend the review looking at a section you did not choose; make a temporary copy with a negative `margin-top` on `.wrap` to push the section you want to the top instead. And **a broken-looking line in a downscaled thumbnail is re-shot at full size before you believe it** — a hairline shown at two-thirds scale renders as several disconnected pieces, identical to an actual mistake.

_Source: build — every item here passed a source-level review first_
