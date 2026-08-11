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
WORD = re.compile(r"\w", re.UNICODE)


def glossary_path(script_dir):
    """refs/ sits beside tools/. Resolved from __file__ so the tree can move."""
    return os.path.join(os.path.dirname(script_dir), "refs", "transcribe-glossary.md")


def load_entries(path):
    """Only live prose lines count. Comment blocks and code fences do not.

    The glossary file documents its own format with `heard → correct` inside a
    fenced example, and ships commented-out samples. A parser that reads every
    line containing an arrow turns both into live rules — which is how a stock
    install came to "correct" the ordinary English word *heard*.
    """
    entries = []
    seen = set()
    in_comment = False
    in_fence = False
    with open(path, encoding="utf-8") as f:
        for raw in f:
            line = raw.strip()

            if in_comment:
                if "-->" in line:
                    in_comment = False
                continue
            if line.startswith("<!--"):
                if "-->" not in line:
                    in_comment = True
                continue

            if line.startswith("```"):
                in_fence = not in_fence
                continue
            if in_fence:
                continue

            # Backticks mean prose about the format, not an entry. The line
            # explaining that `->` also works is the one that taught us this:
            # it contains an arrow, and it became a rule rewriting a backtick.
            if "`" in line:
                continue

            # Markdown decoration around a real entry is a normal thing to
            # write and used to make the entry silently dead.
            line = re.sub(r"^([-*+]|\d+[.)])\s+", "", line)
            line = line.strip("| ").strip()

            for arrow in ARROWS:
                # Whitespace on both sides. An arrow buried in a sentence, or
                # inside a word, is punctuation rather than a mapping.
                m = re.search(r"\s" + re.escape(arrow) + r"\s", line)
                if not m:
                    continue
                heard, correct = line[:m.start()], line[m.end():]
                # A trailing note, but only when it reads as one. A bare "#"
                # can be part of a name or a product code.
                correct = re.split(r"\s+#\s", correct, maxsplit=1)[0]
                heard, correct = heard.strip(" |\t"), correct.strip(" |\t")
                # Names are short. Anything sentence-length is prose that
                # happened to contain an arrow.
                if not (0 < len(heard) <= 80 and 0 < len(correct) <= 80):
                    break
                if heard != correct and (heard, correct) not in seen:
                    seen.add((heard, correct))
                    entries.append((heard, correct))
                break
    return entries


def finder(term):
    """Word boundaries only where the term's own edge is a word character.

    `\\b` is defined between a word and a non-word character. Anchoring it
    against a term that starts or ends with punctuation, or with Khmer or Han
    text, asks for a transition that never occurs — the term then matches
    nothing, silently. Deciding per edge keeps `Rea` from matching inside
    `Reality` without disabling the whole term because one character is not
    ASCII.
    """
    left = r"(?<!\w)" if WORD.match(term[0]) else ""
    right = r"(?!\w)" if WORD.match(term[-1]) else ""
    return re.compile(left + re.escape(term) + right, re.IGNORECASE)


def split_document(text):
    """Body starts after the frontmatter and the header block that follows it.

    Both writers end the header with a `---` line. Anything unexpected means we
    do not know where the body is, and the right move is to leave the file alone.
    """
    if not text.startswith("---"):
        return None
    marks = [m.start() for m in re.finditer(r"(?m)^---[ \t]*\r?$", text)]
    if len(marks) < 3:
        return None
    cut = marks[2] + text[marks[2]:].index("\n")
    return text[:cut], text[cut:]


def scan(body, entries):
    """Longest term first, so a short term cannot also match inside a long one."""
    hits, inconsistent = [], []
    claimed = []

    def overlaps(s, e):
        return any(s < ce and cs < e for cs, ce in claimed)

    for heard, correct in sorted(entries, key=lambda e: -len(e[0])):
        spans = []
        for m in finder(heard).finditer(body):
            s, e = m.span()
            if overlaps(s, e):
                continue
            # `ប៉េលី` is a prefix of `ប៉េលីណា`: the correct spelling contains the
            # wrong one, so an occurrence that is already correct must not be
            # reported. This only applies in that direction — when the model
            # ADDS a syllable the heard form contains the correct one, and
            # skipping those would discard every real hit.
            if len(correct) > len(heard) and body[s:s + len(correct)] == correct:
                continue
            spans.append((s, e))
        if not spans:
            continue

        # "Spelled both ways" means the correct form appears somewhere that is
        # not inside one of the wrong spellings we just found. Without that
        # test, any entry whose correct form sits inside its heard form reports
        # inconsistency on a transcript that is wrong every single time.
        elsewhere = any(
            not any(s <= m.start() and m.end() <= e for s, e in spans)
            for m in finder(correct).finditer(body)
        )

        claimed.extend(spans)
        hits.append({
            "heard": heard,
            "correct": correct,
            "count": len(spans),
            "lines": sorted({body.count("\n", 0, s) + 1 for s, _ in spans}),
        })
        if elsewhere:
            inconsistent.append((heard, correct))

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

    # newline="" keeps CRLF exactly as it arrived. Universal-newline mode would
    # rewrite every line ending in the body, which is an edit to the body.
    with open(target, encoding="utf-8", newline="") as f:
        text = f.read()

    if START in text:  # already annotated; do not stack tables
        return 0

    parts = split_document(text)
    if parts is None:
        return 0
    head, body = parts
    nl = "\r\n" if "\r\n" in text else "\n"
    body = body.lstrip("\r\n")  # strip first, so scanned lines are the final ones

    hits, inconsistent = scan(body, entries)
    if not hits:
        return 0

    # Two passes: the table's own length decides how far the body moves, and
    # that length does not change when the numbers inside it do.
    def build(off):
        table = render(hits, inconsistent, off).replace("\n", nl)
        return head + nl + nl + table

    prefix = build(0)
    prefix = build(prefix.count("\n"))

    # Write via a temp file in the same directory, then replace. A partial
    # write here would destroy the transcript this script exists to annotate,
    # and both call sites ignore the exit code, so nobody would be told.
    tmp = target + ".glossary.tmp"
    try:
        with open(tmp, "w", encoding="utf-8", newline="") as f:
            f.write(prefix + body)
            f.flush()
            os.fsync(f.fileno())
        os.replace(tmp, target)
    except Exception:
        if os.path.exists(tmp):
            os.unlink(tmp)
        raise

    total = sum(h["count"] for h in hits)
    print(f"  glossary: {total} correction(s) across {len(hits)} term(s) — table added, body untouched")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as e:  # a transcript must never be lost to its annotation
        sys.stderr.write(f"[glossary] skipped ({e})\n")
        sys.exit(0)
