#!/usr/bin/env python3
"""Annotate a finished transcript with a correction table. Never edits the body.

    python3 tools/_glossary.py <transcript.md>

Reads `refs/transcribe-glossary.md` (`heard → correct`, one per line), finds
which of those terms actually occur in this transcript, and inserts a table
above the text saying what to change.

Why a table and not a find-and-replace: the transcript body is the only record
of what the model actually heard. Overwrite it and you can no longer tell an
accurate transcription from a confident guess, and you cannot re-check it later
against a better model. The table is what downstream work reads — the summary,
the reply, the document that leaves the building.

Silent and harmless by design: no glossary, no matches, or anything unexpected
means this exits 0 and changes nothing. A transcript is worth more than an
annotation, so nothing here is allowed to be the reason one fails to appear.
"""
import os
import re
import sys

ARROWS = ("→", "->")
START = "<!-- glossary:begin -->"
END = "<!-- glossary:end -->"


def glossary_path(script_dir):
    """refs/ sits beside tools/. Resolved from __file__ so the tree can move."""
    return os.path.join(os.path.dirname(script_dir), "refs", "transcribe-glossary.md")


def load_entries(path):
    """Every line holding an arrow is an entry. Everything else is prose."""
    entries = []
    seen = set()
    with open(path, encoding="utf-8") as f:
        for raw in f:
            line = raw.strip()
            if line.startswith("<!--") or line.startswith("-->"):
                continue
            for arrow in ARROWS:
                if arrow in line:
                    heard, _, correct = line.partition(arrow)
                    # An inline "# note" is for the reader, not for the matcher.
                    correct = correct.split("#")[0].strip()
                    heard = heard.strip().lstrip("<!-").strip()
                    if heard and correct and (heard, correct) not in seen:
                        seen.add((heard, correct))
                        entries.append((heard, correct))
                    break
    return entries


def finder(term):
    """ASCII terms need word boundaries; Khmer and Chinese have no word breaks.

    Without this, `Rea` matches inside `Reality`. With it applied to Khmer, a
    term would never match at all — \\b is defined on word characters, and
    Khmer text has no non-word characters between syllables to anchor against.
    """
    if all(ord(c) < 128 for c in term):
        return re.compile(r"\b" + re.escape(term) + r"\b", re.IGNORECASE)
    return re.compile(re.escape(term))


def split_document(text):
    """Body starts after the frontmatter and the header block that follows it.

    Both writers (transcribe-cloud.sh, km_transcribe.py) end the header with a
    `---` line and a blank line. Anything unexpected means we do not know where
    the body is, and the right move is to leave the file alone.
    """
    if not text.startswith("---"):
        return None
    marks = [m.start() for m in re.finditer(r"(?m)^---$", text)]
    if len(marks) < 3:
        return None
    cut = marks[2] + len("---")
    return text[:cut], text[cut:]


def scan(body, entries):
    """Longest term first, so a short term cannot also match inside a long one."""
    hits, inconsistent = [], []
    claimed = []
    lines = body.splitlines()

    def line_of(pos):
        return body.count("\n", 0, pos) + 1

    for heard, correct in sorted(entries, key=lambda e: -len(e[0])):
        already = finder(correct).search(body) is not None
        spans = []
        for m in finder(heard).finditer(body):
            s, e = m.span()
            if any(s < ce and cs < e for cs, ce in claimed):
                continue
            # `ប៉េលី` is a prefix of `ប៉េលីណា`. Reporting the correct spelling as
            # an error is worse than saying nothing, so check before claiming.
            if body[s:s + len(correct)] == correct:
                continue
            spans.append((s, e))
        if not spans:
            continue
        claimed.extend(spans)
        hits.append({
            "heard": heard,
            "correct": correct,
            "count": len(spans),
            "lines": sorted({line_of(s) for s, _ in spans}),
        })
        if already:
            inconsistent.append((heard, correct))

    del lines
    return hits, inconsistent


def render(hits, inconsistent, offset=0):
    out = [START, "", "## Corrections", "",
           "> Found by matching this machine's glossary (`refs/transcribe-glossary.md`)",
           "> against the text below. **The text below is unedited** — it is the record",
           "> of what was heard. Apply these to whatever you build from it.", "",
           "| Heard as | Should be | Times | Lines |", "|---|---|---|---|"]
    for h in hits:
        # Line numbers are of THIS file after the table is in it. Inserting the
        # table pushes the body down, so a number counted against the raw body
        # would point at the wrong line the moment it is written — which is the
        # only kind of line number anybody actually clicks.
        where = ", ".join(str(n + offset) for n in h["lines"][:8])
        if len(h["lines"]) > 8:
            where += ", …"
        out.append(f"| `{h['heard']}` | `{h['correct']}` | {h['count']} | {where} |")
    if inconsistent:
        out += ["", "**Spelled both ways in this one transcript** — "
                    + ", ".join(f"`{a}` and `{b}`" for a, b in inconsistent) + ".",
                "", "> The same name, right in one sentence and wrong in another. This is",
                "> the failure worth knowing about: it reads as reliable exactly where it",
                "> is not, and someone who does not know the people involved will read",
                "> them as two different names. Check every mention, not the first one."]
    out += ["", END, ""]
    return "\n".join(out)


def main():
    if len(sys.argv) != 2:
        return 0
    target = sys.argv[1]
    script_dir = os.path.dirname(os.path.abspath(__file__))
    gpath = glossary_path(script_dir)
    if not os.path.isfile(gpath) or not os.path.isfile(target):
        return 0

    entries = load_entries(gpath)
    if not entries:
        return 0

    with open(target, encoding="utf-8") as f:
        text = f.read()

    if START in text:  # already annotated; do not stack tables
        return 0

    parts = split_document(text)
    if parts is None:
        return 0
    head, body = parts
    body = body.lstrip("\n")  # strip first, so scanned lines are the final ones

    hits, inconsistent = scan(body, entries)
    if not hits:
        return 0

    # Two passes: the table's own length decides how far the body moves, and
    # that length does not change when the numbers inside it do.
    prefix = head + "\n\n" + render(hits, inconsistent)
    offset = prefix.count("\n")
    prefix = head + "\n\n" + render(hits, inconsistent, offset)

    with open(target, "w", encoding="utf-8") as f:
        f.write(prefix + body)

    total = sum(h["count"] for h in hits)
    print(f"  glossary: {total} correction(s) across {len(hits)} term(s) — table added, body untouched")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as e:  # a transcript must never be lost to its annotation
        sys.stderr.write(f"[glossary] skipped ({e})\n")
        sys.exit(0)
