#!/usr/bin/env python3
"""Khmer audio -> Khmer transcript, via a multimodal model.

Reached through tools/transcribe.sh with language `km`. Call the router, not this.

WHY THIS EXISTS AS A SEPARATE FILE
Whisper-family models — which includes the Groq route the other languages use —
return unusable output for Khmer. Not lower quality: garbage. That is a property
of those models, not of the recording, and retrying will not change it. So Khmer
goes to a multimodal model instead, with the language pinned in the prompt.

WHAT IT DOES NOT DO
It does not translate. Khmer in, Khmer out — the same rule every other language
follows here. If you want it in English afterwards, ask your agent to translate
the transcript. Keeping those two steps apart is deliberate: the transcript stays
a record of what was said, separate from anyone's rendering of it.

HOW IT WORKS
  ffmpeg -> mono 16k mp3 -> split into large time chunks -> one model call per
  chunk, in parallel -> stitch back together.

Chunks are large (8 minutes by default) on purpose. Small voice-activity slices
give the model no context, and context is most of what makes a transcript
readable. Time-based chunking keeps whole exchanges intact.

Usage:
  python3 km_transcribe.py <audio-file> [--out PATH] [--chunk-min 8]
                           [--workers 2] [--keep-audio] [--prompt "words"]
"""
import argparse
import atexit
import base64
import datetime
import json
import os
import shutil
import subprocess
import sys
import tempfile
import time
from concurrent.futures import ThreadPoolExecutor

try:
    import requests
except ImportError:
    sys.exit("Python package 'requests' is missing.  Install it:  pip3 install requests")

MODEL = "gemini-3.5-flash"
API = "https://generativelanguage.googleapis.com/v1beta/models/{m}:generateContent?key={k}"

WORK = tempfile.mkdtemp(prefix="km_tr_")
atexit.register(lambda: shutil.rmtree(WORK, ignore_errors=True))


def die(msg, code=1):
    print(msg, file=sys.stderr)
    sys.exit(code)


def load_key():
    """Env var first, then the key file. Never printed, never logged."""
    k = os.environ.get("GEMINI_API_KEY")
    if k:
        return k.strip()
    path = os.path.expanduser("~/.config/gemini/key")
    if os.path.exists(path):
        with open(path) as f:
            return f.read().strip()
    die(
        "No Gemini API key on this machine.\n\n"
        "  Set one up:  bash tools/setup-api-key.sh gemini https://aistudio.google.com/apikey\n\n"
        "  That opens a separate window and never puts the key in this conversation."
    )


def need(binary, install_hint):
    if shutil.which(binary) is None:
        die(f"'{binary}' is not installed on this machine.\n  Install it:  {install_hint}")


def duration_seconds(path):
    out = subprocess.check_output([
        "ffprobe", "-v", "error", "-show_entries", "format=duration",
        "-of", "default=noprint_wrappers=1:nokey=1", path,
    ])
    return float(out.strip())


def extract_chunk(src, start, length, dst):
    subprocess.check_call([
        "ffmpeg", "-v", "error", "-y", "-i", src,
        "-ss", str(start), "-t", str(length),
        "-ac", "1", "-ar", "16000", "-c:a", "libmp3lame", "-b:a", "32k", dst,
    ])


def build_prompt(extra_words=""):
    p = (
        "The following is one segment of an audio recording. The speech is in Khmer, "
        "possibly with English words mixed in.\n\n"
        "Transcribe it into Khmer script, exactly as spoken. This is a transcription, "
        "NOT a translation — do not render it in English or any other language, and do "
        "not romanize it.\n\n"
        "Rules:\n"
        "- Write every sentence. Do not summarize, do not omit, do not add commentary.\n"
        "- If several people speak, label them 'Speaker A:', 'Speaker B:' and so on. "
        "The same speaker continuing does not need a new label.\n"
        "- Keep English proper nouns, brand names and numbers in their original form.\n"
        "- Where the audio is unclear, write (unclear). Do not guess at words.\n"
        "- Output only the transcript itself. No preamble, no explanation."
    )
    if extra_words:
        p += (
            "\n\nThese names and terms appear in this recording; spell them this way:\n"
            + extra_words
        )
    return p


def call_model(mp3_path, prompt, key, max_tokens=65536):
    """One chunk -> text. Returns (text, warning) — warning is None when clean.

    thinkingBudget=0 is load-bearing. gemini-3.5-flash is a thinking model, and
    thinking tokens are drawn from the same maxOutputTokens budget as the answer.
    On a dense 8-minute chunk they eat the budget and the transcript is cut off
    silently, reported only as finishReason=MAX_TOKENS. Transcription needs no
    reasoning, so it is turned off.
    """
    with open(mp3_path, "rb") as f:
        b64 = base64.b64encode(f.read()).decode()
    body = {
        "contents": [{"parts": [
            {"text": prompt},
            {"inline_data": {"mime_type": "audio/mp3", "data": b64}},
        ]}],
        "generationConfig": {
            "temperature": 0.2,
            "maxOutputTokens": max_tokens,
            "thinkingConfig": {"thinkingBudget": 0},
        },
    }
    last = None
    for attempt in range(4):
        try:
            r = requests.post(API.format(m=MODEL, k=key), json=body, timeout=300)
        except Exception as e:
            last = f"connection: {str(e)[:120]}"
            time.sleep(2)
            continue
        if r.status_code == 200:
            try:
                cand = r.json()["candidates"][0]
                fr = cand.get("finishReason", "")
                txt = cand["content"]["parts"][0]["text"].strip()
            except (KeyError, IndexError):
                last = f"unexpected response shape: {r.text[:200]}"
                time.sleep(1)
                continue
            return txt, (f"finishReason={fr}" if fr and fr != "STOP" else None)
        if r.status_code == 429 or "RESOURCE_EXHAUSTED" in r.text:
            wait = 10 * (attempt + 1)
            last = "429 rate limited"
            print(f"  rate limited, waiting {wait}s...", file=sys.stderr)
            time.sleep(wait)
            continue
        if r.status_code == 401 or r.status_code == 403:
            die(
                "Unauthorized (HTTP %d).\n\n"
                "Nine times out of ten this is not the key itself — it is a newline at\n"
                "the end of the key file. Check the length, never the value:\n\n"
                "  wc -c ~/.config/gemini/key\n\n"
                "If it is one byte longer than what you copied, that is the newline.\n"
                "Re-run: bash tools/setup-api-key.sh gemini" % r.status_code
            )
        last = f"HTTP {r.status_code}: {r.text[:160]}"
        time.sleep(2)
    return None, last


def main():
    ap = argparse.ArgumentParser(add_help=True)
    ap.add_argument("input")
    ap.add_argument("--out")
    ap.add_argument("--chunk-min", type=int, default=8)
    ap.add_argument("--workers", type=int, default=2)
    ap.add_argument("--keep-audio", action="store_true")
    ap.add_argument("--prompt", default="")
    ap.add_argument("--no-trad", action="store_true")  # accepted, not used for km
    args = ap.parse_args()

    src = os.path.abspath(os.path.expanduser(args.input))
    if not os.path.isfile(src):
        die(f"Error: no such file — {src}")

    need("ffmpeg", "brew install ffmpeg")
    need("ffprobe", "brew install ffmpeg")
    key = load_key()

    tools_dir = os.path.dirname(os.path.abspath(__file__))
    workspace = os.path.dirname(tools_dir)
    transcripts = os.path.join(workspace, "transcripts")
    os.makedirs(transcripts, exist_ok=True)

    base = os.path.splitext(os.path.basename(src))[0]
    slug = "-".join(base.replace("'", "").replace('"', "").split())
    today = datetime.date.today()
    out_path = args.out or os.path.join(transcripts, f"{today.isoformat()}-{slug}.md")

    dur = duration_seconds(src)
    chunk_s = args.chunk_min * 60
    n = int(dur // chunk_s) + (1 if dur % chunk_s else 0)

    print(f"Transcribing: {src}")
    print(f"  language: km (Khmer)")
    print(f"  model:    {MODEL}")
    print(f"  length:   {dur:.0f}s -> {n} chunk(s) of {args.chunk_min} min")
    print(f"  output:   {out_path}")
    print()

    prompt = build_prompt(args.prompt)

    def do_chunk(i):
        mp3 = os.path.join(WORK, f"c{i:03d}.mp3")
        extract_chunk(src, i * chunk_s, chunk_s, mp3)
        text, warn = call_model(mp3, prompt, key)
        if text is None:
            print(f"  chunk {i+1}/{n}: FAILED — {warn}", file=sys.stderr)
            return i, None, warn
        if warn:
            print(f"  chunk {i+1}/{n}: done, but {warn}", file=sys.stderr)
        else:
            print(f"  chunk {i+1}/{n}: done", file=sys.stderr)
        return i, text, warn

    with ThreadPoolExecutor(max_workers=max(1, args.workers)) as ex:
        results = sorted(ex.map(do_chunk, range(n)), key=lambda r: r[0])

    failed = [i for i, t, _ in results if t is None]
    truncated = [i for i, t, w in results if t is not None and w]
    body = "\n\n".join(t for _, t, _ in results if t)

    if not body:
        die("Every chunk failed. Nothing was written. The errors above say why.")

    expires = today + datetime.timedelta(days=30)
    notes = ""
    if failed:
        notes += (f"\n> INCOMPLETE: chunk(s) {[i+1 for i in failed]} failed and are "
                  f"missing from this transcript.\n")
    if truncated:
        notes += (f"\n> WARNING: chunk(s) {[i+1 for i in truncated]} may be cut off "
                  f"(the model stopped early).\n")

    with open(out_path, "w", encoding="utf-8") as f:
        f.write(
            f"---\naudio_file: {os.path.basename(src)}\ncreated: {today}\n"
            f"language: km\nmodel: {MODEL}\nstatus: pending\nextracted_to:\n"
            f"expires: {expires}\n---\n\n"
            f"# Transcript: {base}\n\n"
            f"> date: {today} · language: km (Khmer) · chunks: {n}\n"
            f"> source: {os.path.basename(src)}\n"
            f"{notes}\n"
            "> Names, numbers and dates in here are the parts speech models get\n"
            "> wrong, and they come back looking as confident as everything else.\n"
            "> Check them against something you trust before this goes anywhere.\n\n"
            "---\n\n" + body + "\n"
        )

    print()
    print(f"Done — {out_path}")
    if failed:
        print(f"  {len(failed)} chunk(s) failed. The transcript is incomplete and says so.")

    if not args.keep_audio:
        downloads = os.path.expanduser("~/Downloads")
        buf = (os.path.join(downloads, "_transcribed")
               if src.startswith(downloads + os.sep)
               else os.path.join(transcripts, "_audio_buffer"))
        os.makedirs(buf, exist_ok=True)
        shutil.move(src, os.path.join(buf, os.path.basename(src)))
        print(f"  audio moved to {buf}/")


if __name__ == "__main__":
    main()
