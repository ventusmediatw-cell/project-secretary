#!/usr/bin/env python3
"""stdin -> Traditional Chinese (Taiwan) -> stdout.

Whisper leans Simplified for Chinese at the architecture level, so zh
transcripts come back in Simplified regardless of how the speaker writes.
This is a dictionary conversion — it swaps characters and never touches
wording. It is not a model and it cannot introduce errors of meaning.

s2tw, not s2twp: the 'p' variant also localizes vocabulary, which turns
video 腳本 (script) into the IT term 指令碼. Wrong word, silently.

If opencc is not installed, pass the text through unchanged and warn on
stderr rather than failing the whole transcription over formatting.
"""
import sys

text = sys.stdin.read()
try:
    from opencc import OpenCC
    text = OpenCC("s2tw").convert(text)
except Exception as e:
    sys.stderr.write(
        f"[s2tw] opencc unavailable, leaving text as-is (still Simplified): {e}\n"
        f"[s2tw] to fix:  pip3 install opencc-python-reimplemented\n"
    )
sys.stdout.write(text)
