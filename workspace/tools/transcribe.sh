#!/bin/bash
# Recording → text. Router.
#
#   bash tools/transcribe.sh <audio-file> [language]
#
# language:  en (default) | zh | km
#
#   en  → Groq Whisper        → English transcript
#   zh  → Groq Whisper + s2tw → Traditional Chinese transcript
#   km  → Gemini (multimodal) → Khmer transcript
#
# The rule is the same in every case: what goes in comes out in the same
# language. This is not a translator. If you want a translation, ask your
# agent for one *after* you have the transcript — that keeps the record of
# what was actually said separate from anyone's rendering of it.
#
# Khmer takes a different provider because Whisper-family models return
# unusable output for it — not "a bit worse", garbage. See QA.md.
#
# Shared flags:
#   --keep-audio          don't move the audio into the buffer afterwards
#   --out PATH            write the transcript here instead of the default
#   --prompt "words..."   bias the model toward these words. A TRADE, not a free win:
#                         it also changes words you did not supply. Not the default.
#                         For names, use refs/transcribe-glossary.md instead.
#   --no-trad             zh only: skip the Traditional-Chinese conversion

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Flags are accepted ANYWHERE in the line, not just before the filename.
# People write `transcribe.sh recording.m4a zh --prompt "..."` — that is the
# natural order, and a parser that only reads leading flags drops the rest in
# silence. Silently ignoring a flag is the worst possible outcome here: the
# command appears to succeed and does the wrong thing.
PRE_FLAGS=()
POS=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --keep-audio|--no-trad) PRE_FLAGS+=("$1"); shift ;;
    --out|--prompt)
      if [ "$#" -lt 2 ]; then
        echo "Error: $1 needs a value after it."
        exit 1
      fi
      PRE_FLAGS+=("$1" "$2"); shift 2 ;;
    --*)
      echo "Error: unknown option '$1'."
      echo "This router accepts: --keep-audio --out PATH --prompt \"words\" --no-trad"
      exit 1 ;;
    *) POS+=("$1"); shift ;;
  esac
done

INPUT="${POS[0]:-}"
LANG="${POS[1]:-en}"

if [ "${#POS[@]}" -gt 2 ]; then
  echo "Error: too many arguments — got: ${POS[*]}"
  echo "Expected: bash tools/transcribe.sh <audio-file> [en|zh|km]"
  echo "If your filename contains spaces, wrap it in quotes."
  exit 1
fi

if [ -z "$INPUT" ]; then
  echo "Usage: bash tools/transcribe.sh <audio-file> [en|zh|km]"
  echo ""
  echo "  en  English in  → English transcript"
  echo "  zh  Chinese in  → Traditional Chinese transcript"
  echo "  km  Khmer in    → Khmer transcript"
  exit 1
fi

if [ ! -f "$INPUT" ]; then
  echo "Error: no such file — $INPUT"
  echo "Check the path. Drag the file into the terminal to get it exactly right."
  exit 1
fi

case "$LANG" in
  km)
    # Khmer → Gemini. Whisper cannot do this one; see QA.md "Why does Khmer
    # use a different service?"
    exec python3 "$SCRIPT_DIR/km_transcribe.py" ${PRE_FLAGS[@]+"${PRE_FLAGS[@]}"} "$INPUT"
    ;;
  en|zh)
    exec bash "$SCRIPT_DIR/transcribe-cloud.sh" ${PRE_FLAGS[@]+"${PRE_FLAGS[@]}"} "$INPUT" "$LANG"
    ;;
  *)
    echo "Error: unknown language '$LANG'."
    echo "This router handles: en, zh, km."
    echo ""
    echo "If you need another language, do NOT just try 'auto' and hope."
    echo "Ask your agent — some languages need the Khmer route, some don't work at all."
    exit 1
    ;;
esac
