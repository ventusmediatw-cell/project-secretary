# Questions people actually asked

Append to this file. Never rewrite the whole thing. An answer that later turns out to be wrong is **corrected by a new entry further down, not by rewriting the old one** — otherwise nobody can tell the advice changed, and whoever followed the old version has no way to find out.

**Paths here are relative to this skill's own folder** — `SKILL.md`, `templates/`, `references/` and `human/` all sit inside it. A path beginning `../eli5/` is the sister skill next door; `UPDATING.md` is at the repo root. Where a rule is shared with `eli5`, this file points at that skill's files rather than restating them, so the two cannot drift apart.

Each answer leads with **what you are seeing**, then what is actually happening, then what to do — the cause is only useful once you know you are in the right place. Section names quoted from `SKILL.md` are quoted exactly, so you can search for them. **This file is read by agents as well as by people.** The grouping below is by where you got stuck, not by the order of `SKILL.md`.

---

## §1 — Should this be a diagram at all

### Q: Someone asked me how something works. Do I open this skill, or just answer?

Symptom that you opened it too eagerly: you are drawing one box with an arrow to a second box, and there is nothing else to draw.

`SKILL.md` narrows this on purpose under **"When to use / when not"** — the subject has to be a system, process or mechanism with **several steps or branches**. A single function, a single line of code, a single term, a single decision: answer in words. When you genuinely cannot tell, do not guess and do not build one to find out. Ask first, in these words or close to them: **"diagram, or shall I just tell you?"** It costs a sentence, and it is the difference between a page they wanted and a page they now have to be polite about.

_Source: the narrowing condition exists because the trigger phrases are everyday speech_

### Q: I have five diagrams and every one of them feels necessary.

That is the signal the ceiling exists to give you. **"Output spec — these are limits, not defaults"** puts the cap at three, and going over does not mean draw smaller — it means **the subject you chose is too wide**, and you are about to explain two mechanisms badly instead of one well. Pick the mechanism the person actually asked about and cut to its main line, its one decisive branch, and how it gets used; the other two diagrams are usually a second subject wearing the first one's name. If both really are wanted, that is two pages, and the second can be asked for.

Counting trap on a bilingual page: each diagram exists **twice**, once per language, so a raw count of `<svg>` elements returns six for a three-diagram page. Count per language.

_Source: the cap was set by pages that went over it_

### Q: How do I know this is `explain1min` and not `../eli5/SKILL.md`?

The split is about the **subject**, not the reader — both assume the reader knows nothing. The tell is branching: if someone would sensibly ask "and what happens if it *isn't*?", the subject has gates in it, and gates need diamonds, which is this skill. A topic, an idea, a thing with no branches is `eli5`. The full comparison table lives in `../eli5/references/QA.md` §1 and is not repeated here, so the two cannot drift.

_Source: the two skills were separated after each kept being used for the other's job_

---

## §2 — Before you draw

### Q: I wrote three drafts, they all read fine, and someone says the gates are missing.

They are missing, and re-reading will not find them. This is the failure `SKILL.md` puts under **"The rule: find the branches before you draw anything"**, and its shape is worth knowing because it does not feel like a mistake while you are making it: three drafts written as a linear story dropped **the same three entry gates**, all three times. Not because the gates were unimportant — because **a straight line has nowhere to put a branch**, so the sentence that would have carried one simply never gets written. Redrawn as a flow chart, six diamonds appeared.

Do this before any markup exists. Write out, in plain sentences, every point where the answer could go two ways — "if X then… otherwise…", "what gets turned away here", "what has to be true before this is allowed", "what happens when it is already there". Every line on that list becomes a diamond. If the list is empty, go back to §1: a mechanism with no branches may not need this skill.

_Source: three drafts, three identical omissions_

### Q: What are the three diagrams supposed to be?

Symptom of getting this wrong: three diagrams that are all the same diagram at three zoom levels. `SKILL.md` **"What the three diagrams are for"** assigns them different jobs — the main line with the gates sitting **in the middle** rather than tucked at the end; the one decision that actually changes the result; and how the thing is used, usually two paths running in opposite directions. Different jobs, not different magnifications.

The layout trap in diagram 2, written into `templates/skeleton.html` as a comment because it is easy to reproduce: put every branch outcome on the **same side**, staggered vertically. Never let one branch's line pass directly under another node — it reads as two steps in series when it is two exclusive branches, and it passes every source-level check.

_Source: build_

### Q: How long should the `.note` under a diagram be?

One sentence. It answers **"why is it built this way"** — not what the diagram shows, which the diagram already did. Symptom that it has outgrown that: the note explains the boxes. That is the diagram failing, and the fix belongs in the picture, not in the paragraph you are about to write under it.

_Source: the notes that grew into paragraphs were all covering for an unclear diagram_

---

## §3 — Colour and the legend

### Q: A reader thinks the flow stops at a step that actually continues.

Symptom: someone reads the page and reports that the process "ends" at a node you drew as a detour. The source looks correct, because it is correct in every way except one. Cause: red. `SKILL.md` **"Colour carries meaning here — do not reassign it"** reserves red for **"this is the end of the line"** and nothing else. Something like *"go and check that repository first, then come back"* is **an extra step, not a rejection** — the flow continues, it just takes longer. That is orange, solid, rejoining the main line. Drawn in red and dashed, the reader believes the run is over, and nothing in the text corrects them because the text never mentions it.

The check that finds this: look at the picture and ask of every red thing, *"is this where the story stops?"* If no, it is orange. This one was caught from a screenshot; the source had passed review.

_Source: caught by looking at a screenshot, after the source read as correct_

### Q: My three diagrams each have a legend and they do not quite say the same thing.

Symptom, and it is why this is worth an entry: the same grey swatch appears in all three legends described three different ways — "context" in one, "not in scope" in the next, "background" in the third. Each is defensible alone. Together they teach the reader that grey means three things, so from diagram 2 onwards they stop trusting the colours at all, which costs you the whole colour system. Cause: legends get written while you are drawing each diagram, so each is worded for the diagram in front of you, and the drift is invisible in the source because you never see the three strings side by side.

Fix: **settle one wording set before diagram 1 and paste it unchanged into all three.** If one diagram seems to need a fourth meaning, that is a signal the diagram is doing too much — not a licence to reword the other three. To see the drift, pull every legend string out and read them as a flat list. The test is **one wording per swatch, everywhere that swatch appears** — a diagram that uses no grey simply omits the grey row, so a shorter set is fine; a reworded one is the drift:

```sh
grep -o '</i>[^<]*' page.html | sed 's|</i>||'
```

_Source: build — three legends, one page, three meanings for the same swatch_

### Q: The legend says "de-emphasised" and a reader asked what that meant.

Symptom: a word on the page that describes **the stylesheet** rather than the subject — "de-emphasised", "muted", "secondary", "accent", "crit". A reader asks what it means, or worse, assumes it is a term from the domain you are explaining.

Cause: the colour table in `SKILL.md` names the tokens (`--s1`, `--s2`, `--crit`, `--deemph`) and glosses each one **for you**. "de-emphasised" is the gloss on `--deemph`, an instruction to whoever writes the CSS. It reaches the page when the legend is written by reading the token table instead of by asking what that colour means *in this mechanism*. On a bilingual page it gets worse: the gloss then gets translated literally into the second language, where it is not even a normal word.

Fix: the legend says what the colour means **in the subject**, in the reader's words — "not part of this run", "someone else's job", "already exists". Never the token name, never the token's gloss. Cheap grep before you hand it over:

```sh
sed '1,/<\/style>/d' page.html | grep -nE 'de-?emphasi|muted|--s1|--s2|--crit|--deemph|nodebg' | grep -v 'var(--'
```

It drops the stylesheet first, so anything it prints is body copy. A clean run prints nothing.

_Source: build — the gloss reached a legend, then reached a translation of that legend_

---

## §4 — The page itself

### Q: How many words am I allowed, and how do I count them?

Under 1000; 644 read best in practice. Both numbers are in **"Output spec — these are limits, not defaults"** because both were measured. Two things people then get wrong. **Count each language separately** — a bilingual page holds two complete texts, and a combined total describes no reader, because nobody reads both. And **count CJK by character, not by whitespace-delimited word**: the word count returns something near zero and reads like a comfortable pass.

```sh
python3 - <<'PY'
import io, re
s = io.open('page.html', encoding='utf-8').read()
s = re.sub(r'(?s)<(script|style|title)\b.*?</\1>', ' ', s)     # tab title is chrome, not copy
s = re.sub(r'(?s)<!--.*?-->', ' ', s)
secs = re.findall(r'(?s)<section lang="([^"]+)">(.*?)</section>', s) or [('page', s)]
tot = {}
for lang, body in secs:
    body = re.sub(r'aria-label="[^"]*"', ' ', body)              # alt text is not copy either
    body = re.sub(r'<[^>]+>', ' ', body)
    n = len(re.findall(r'[\u3400-\u4dbf\u4e00-\u9fff]', body)) + len(re.findall(r"[A-Za-z][A-Za-z'-]*", body))
    tot[lang] = tot.get(lang, 0) + n
print(tot)   # one figure per language; each must be under 1000
PY
```

The same discipline points at the page's content: **only numbers you actually measured**. Percentages, durations, throughput, "most of the time" — if you cannot say where the figure came from, cut it. A page written for someone who knows nothing is exactly the page where an invented number cannot be caught by its reader.

_Source: the ceiling and the 644 both came from real pages; the counting rule from a page that passed a word count it should have failed_

### Q: The file has no `<!doctype>`, no `<html>`, no `<body>`. Is it broken?

No — a fragment is correct for this output. A publishing surface wraps whatever you hand it in its own `<!doctype><html><head><body>` shell, so adding your own gives you two nested documents. `templates/skeleton.html` is a fragment for that reason and says so in its first comment.

Worth separating from the next entry, because the two get merged and then both get fixed wrongly: **quirks mode is caused by the missing doctype**, and only when the file is opened straight from disk — once published, the shell supplies the doctype and quirks mode is not in play at all. A fragment is not a mistake, and you do not add a doctype to "fix" anything.

_Source: how the publishing surface works_

### Q: I opened the file locally and every non-ASCII character is garbage.

Different problem, different fix. A fragment carries no character-set declaration, so a browser opening it from disk guesses the encoding and guesses wrong. Nothing is wrong with the file's bytes, and the doctype has nothing to do with it. Fix — **first line of the source file, always**, exactly as `templates/skeleton.html` has it:

```html
<meta charset="utf-8">
<title>…</title>
<style>…</style>
```

One line satisfies both ends: opened locally it declares the encoding; after publishing it lands in the body and is harmlessly ignored, because the shell brings its own.

⚠️ **This symptom is misdiagnosed almost every time** — read as a broken CJK font, or as a local server not sending a charset header. **The tell is the browser tab title**: a font problem cannot affect the tab, so if the tab is mangled too it is encoding. Second confirmation: `file -I page.html` reporting `charset=utf-8` while the screen is still garbled means the file is fine and the *declaration* is what is missing.

_Source: reported repeatedly, diagnosed as a font first every time_

### Q: They want it in two languages. Two files?

One file, both languages, a toggle — two files drift the moment either is edited, and nobody can see that they have. Mark each block with `lang`, hide by an attribute on the root:

```css
[data-lang="en"] [lang|="zh"]{display:none!important}
[data-lang="zh"] [lang|="en"]{display:none!important}
```

```html
<section lang="zh-TW"> … </section>
<section lang="en"> … </section>
```

⚠️ **The region subtag is not optional.** A bare `lang="zh"` makes the browser pick regional glyph forms *inside the same font* — the typeface never changes, so nothing in the source looks wrong and a byte-level comparison finds nothing, while the rendered page is visibly not the writing system the reader expects. Always `zh-TW`, or whichever region actually applies.

⚠️ **Use the hyphen-match form `[lang|="…"]` on both sides of the pair.** `[lang|="zh"]` matches `zh` and `zh-TW`; plain `[lang="zh"]` stops matching the moment the content is tagged properly, and the rule then silently does nothing. Hyphen-matching one side and leaving the other exact is the version that survives review, because the half that breaks is the half nobody has re-tagged yet.

⚠️ **Do not wrap CJK inside a display or monospace face.** Those faces have no CJK glyphs, so those characters fall back to another font and split away from the Latin ones with a visible gap, reading as two words. Put only the digits and Latin inside the styled span: `<em>26</em>` followed by the unit, not both inside the `<em>`.

Verifying a bilingual page means comparing **renderings**. Every geometric check passes.

_Source: four pages hit the same fault because they shared one spec_

### Q: Does every `<svg>` really need an `aria-label`?

Yes, and it earns its place twice: it is what a screen reader gets instead of the picture, and it is the fastest self-check you have — **if you cannot describe the diagram in one clause, the diagram is doing too much.** A label reading "diagram" or "flow chart" is the same as no label.

```sh
python3 -c "import io,re;s=io.open('page.html',encoding='utf-8').read();t=re.findall(r'<svg\b[^>]*>',s);print(len(t),'svg,',sum('aria-label' in x for x in t),'labelled')"
```

_Source: the labelling rule; the one-clause test came out of it by accident_

---

## §5 — Before you hand it over

### Q: I read the source and it looks right. Is that done?

No. **"Before you deliver it, look at it"** is not advice. Every fault that matters at this size is a visual one — an arrow crossing a box it has nothing to do with, two labels colliding, a diamond's text escaping its shape, a diagram sliding off sideways — and none are visible in the source. Reading it more carefully will not surface them.

**Step 1 — serve it.** **Step 2 — shoot the whole page**, with `CHR` set to your platform's binary (macOS `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome`, Linux `google-chrome` or `chromium`, Windows `C:\Program Files\Google\Chrome\Application\chrome.exe`). **Step 3 — open `shot.png` and read it yourself, top to bottom**, then kill the server.

```sh
cd <folder containing the html> && python3 -m http.server 8931 --bind 127.0.0.1 &
"$CHR" --headless --disable-gpu --hide-scrollbars \
  --window-size=1000,4600 --virtual-time-budget=3000 \
  --screenshot=shot.png "http://127.0.0.1:8931/page.html"
```

_Source: every fault listed above passed a source-level review first_

### Q: I pointed the browser at the file and got nothing, or a blank page.

You used `file://`. It is blocked or unreliable in most browser-automation paths, and the failure is quiet — a blank page, or a page with no styling, which reads like a broken stylesheet. Serve over localhost as in the step above; that is the path that works.

_Source: the same dead end, reached from several different automation tools_

### Q: My light and dark screenshots are identical.

Then you have not tested anything yet, and it looks exactly like a pass. Cause: headless Chrome inherits the machine's colour scheme, so on a machine in dark mode **both** files render dark and you are handed two identical images. Chrome's flags do not move `prefers-color-scheme`, so `--force-dark-mode` and its relatives produce the same identical pair. Use the method in `SKILL.md` **"Before you deliver it, look at it"** and do not invent a second one: **copy the theme's token block and append it as `:root:root{…}` at the end of `<style>`**, once per theme, then shoot each copy. Specificity 0,2,0 and last in the sheet, so it beats both the media query and any `[data-theme]` rule.

```sh
python3 - <<'PY'
import io, re
src = io.open('page.html', encoding='utf-8').read()
light = re.search(r'^:root\{(.*?)^\}', src, re.S | re.M).group(1)
dark  = re.search(r'^:root\[data-theme="dark"\]\{(.*?)^\}', src, re.S | re.M).group(1)
for theme, block in (('light', light), ('dark', dark)):
    io.open('t-%s.html' % theme, 'w', encoding='utf-8').write(
        src.replace('</style>', ':root:root{%s}\n</style>' % block, 1))
PY
```

**The acceptance test is that the two screenshots have different checksums.** That is the only one — "I checked and it looked dark" is not it, and the same sum means you have not tested.

```sh
md5 t-light.png t-dark.png     # Linux: md5sum
```

_Source: measured while writing this file — one machine in dark mode, two identical shots, then four distinct ones once the token block was appended_

### Q: The page is bilingual and both screenshots came out in the same language.

Symptom: you shot light and dark, got two different checksums, called it done — and every image is in one language. Half the page has never been looked at, and it is the half most likely to be broken, because a translated line is longer or shorter than the one the layout was sized for. Cause: the toggle decides at load time, from `localStorage` first and `navigator.language` second. Headless Chrome brings its own locale and an empty store, so it picks one language and picks the same one every time. Fix: **edit the default at the tail of the file before you shoot.** That line ends in a `set(s || …)` call; replace the whole call with the language you want.

```sh
sed "s/set(s||[^;]*);/set('en');/" page.html > p-en.html
sed "s/set(s||[^;]*);/set('zh');/" page.html > p-zh.html
```

Then run the theme step above on **each** of those two, giving four preview files, and shoot all four:

```sh
for f in t-en-light t-en-dark t-zh-light t-zh-dark; do
  "$CHR" --headless --disable-gpu --hide-scrollbars \
    --window-size=1000,4600 --virtual-time-budget=3000 \
    --screenshot=$f.png "http://127.0.0.1:8931/$f.html"
done
md5 t-*.png
```

**Four shots, four different checksums.** Any repeat is a pair you have not tested.

⚠️ Stamping the root element instead — `{ echo '<html data-lang="en">'; cat page.html; } > stamped.html` — **does not survive a page that carries that script**: the script runs at load and overwrites the attribute. Measured, on a page stamped `en`: both screenshots came back in the other language, with nothing in the output to say why. The stamp holds only on a page with no such script; editing the default works in both cases.

_Source: measured — stamp overwritten, sed held, four distinct checksums_

### Q: A diagram runs off the side of the page.

Two different faults, and only one of them is a bug. **The page must never scroll sideways; a wide diagram may.** That is what the skeleton's `figure{…overflow-x:auto}` with `figure svg{min-width:620px}` buys you — the diagram keeps a readable minimum width and scrolls inside its own box. Remove the `overflow-x`, or put the `min-width` on the figure rather than the `svg`, and the diagram pushes the body instead, so the whole page scrolls.

How to check: **look at the right edge of the screenshot.** A figure that scrolls internally is cleanly clipped at its own rounded border; content escaping past the page margin is the bug. You do not need to measure anything — it is a picture-sized failure and the picture shows it. (In a browser-automation context that runs JavaScript, `document.body.scrollWidth === innerWidth` says the same thing in one line; do not go and build that context just for this.)

_Source: build — the two failures look similar in the source and completely different in the screenshot_

### Q: The page is taller than the window and I only want to look at one band of it.

Do not crop the screenshot with `sips`. `sips -c H W --cropOffset Y X` crops **from the centre**, not from the top left, so `--cropOffset 0 0` hands you the middle of the page — and you spend the review looking at a section you did not choose, repeatedly, because nothing in the output says it moved. Push the band you want to the top of the window in a temporary copy, and shoot that:

```sh
python3 -c "import io;s=io.open('page.html',encoding='utf-8').read();\
io.open('_band.html','w',encoding='utf-8').write(s+'<style>.wrap{margin-top:-3300px}</style>')"
```

⚠️ **A broken-looking line in a downscaled image gets re-shot at full size before you believe it.** A hairline rendered at two-thirds scale comes out as several disconnected pieces, identical to an actual mistake — close enough that a perfectly good junction line has been "fixed" on the strength of a thumbnail.

_Source: build — one centre-crop review, one near-miss repair of a line that was fine_

### Q: What am I actually looking for in the screenshot?

At minimum: does an arrow pass under a node it has nothing to do with; do two labels collide; does anything overflow sideways; does any diamond's text escape its shape.

Two of those show up far more often in the English half of a bilingual page, for the same reason — **English runs longer than Chinese for the same content**, so shapes sized against the Chinese label are too small. **Text escaping a diamond**: a diamond's usable width is much narrower than its bounding box, so a label that fits a rectangle overflows a diamond of the same width — shorten the label ("approved?", not "has this been approved yet?") before you widen the shape. **Text touching or crossing a box border**: same cause, less obvious, and it reads as sloppiness rather than as a bug. Neither is visible in the source, and neither is caught by a word count.

_Source: build — the English half of bilingual pages, repeatedly_

---

## §6 — The pages in `human/`

### Q: Can I put the verification commands, or the file's path, on a page in `human/`?

No, to both. Those pages are written **for the person**, not for you — that is the whole distinction the folder makes, and `SKILL.md` says as much under **"The rest of this folder"**. The commands you ran, the flags you passed, the file you served: all of that stays in the conversation. On the page it reads as documentation for a job the reader is not doing, and it tells them they are in the wrong place.

The same goes for **repository paths** — `references/QA.md`, `templates/skeleton.html`, wherever the file lives on your machine. None of those mean anything to the reader, and a path from your machine is also a small leak of where you are. Name the thing, not its location. The narrow exception is a step **only the person at the keyboard can do** — a click in a settings pane, a password, a physical action — because nobody else can do it.

And when they ask what the skill is, show them the page that already exists rather than writing a third one; that is how a set of pages starts disagreeing with itself. If the existing page is wrong, fix that page. **If something on this machine disagrees with `SKILL.md`, the machine is right** — say so before you act on it, then follow `UPDATING.md` §7, at the repo root.

_Source: design decision — the pages that carried the operator's commands were read as manuals and put down_
