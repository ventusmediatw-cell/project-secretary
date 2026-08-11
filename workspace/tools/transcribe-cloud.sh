#!/bin/bash
# Groq Whisper large-v3-turbo. Reached through transcribe.sh — call that, not this.
#
# Why go through the router: when this file is replaced (a better model, a
# different provider), the router keeps the same name and the same arguments.
# Anything that calls this file directly stops inheriting those changes.

set -e

# Flags anywhere, same reason as in transcribe.sh: a dropped flag looks like success.
KEEP_AUDIO=0
EXPLICIT_OUT=""
PROMPT=""
NO_TRAD=0
POS=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --keep-audio) KEEP_AUDIO=1; shift ;;
    --no-trad) NO_TRAD=1; shift ;;
    --out) EXPLICIT_OUT="$2"; shift 2 ;;
    --prompt) PROMPT="$2"; shift 2 ;;
    *) POS+=("$1"); shift ;;
  esac
done

INPUT="${POS[0]:-}"
LANG="${POS[1]:-en}"

[ -z "$INPUT" ] && { echo "Called without a file. Use tools/transcribe.sh."; exit 1; }
[ ! -f "$INPUT" ] && { echo "Error: no such file — $INPUT"; exit 1; }

# --- API key ---------------------------------------------------------------
# Env var first so a machine can override without editing anything.
if [ -n "${GROQ_API_KEY:-}" ]; then
  API_KEY="$GROQ_API_KEY"
elif [ -f "$HOME/.config/groq/key" ]; then
  API_KEY=$(cat "$HOME/.config/groq/key")
else
  echo "No Groq API key on this machine."
  echo ""
  echo "  Set one up:  bash tools/setup-api-key.sh groq https://console.groq.com/keys"
  echo ""
  echo "  Hand that line to the person to run in their own terminal — do not run it"
  echo "  yourself. It reads the key without echoing it, so the value never enters"
  echo "  this conversation."
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TRANSCRIPTS_DIR="$WORKSPACE_ROOT/transcripts"
mkdir -p "$TRANSCRIPTS_DIR"

BASENAME=$(basename "$INPUT" | sed 's/\.[^.]*$//')
SLUG=$(echo "$BASENAME" | tr ' ' '-' | tr -d "'\"" | tr -s '-')
DATE=$(date +%Y-%m-%d)
OUTPUT="${EXPLICIT_OUT:-$TRANSCRIPTS_DIR/${DATE}-${SLUG}.md}"

echo "Transcribing: $INPUT"
echo "  language: $LANG"
echo "  model:    groq whisper-large-v3-turbo"
echo "  output:   $OUTPUT"
echo ""

# --- size cap --------------------------------------------------------------
# Groq refuses anything over 25 MB. Compressing to mono/16kHz/32kbps costs
# almost nothing in transcription quality and takes an hour-long recording
# to roughly 14 MB.
FILE_SIZE=$(stat -f%z "$INPUT" 2>/dev/null || stat -c%s "$INPUT" 2>/dev/null)
MAX_SIZE=$((25 * 1024 * 1024))
UPLOAD_FILE="$INPUT"
COMPRESSED=""

if [ "$FILE_SIZE" -gt "$MAX_SIZE" ]; then
  if ! command -v ffmpeg &>/dev/null; then
    echo "This file is $(( FILE_SIZE / 1024 / 1024 )) MB. The limit is 25 MB, so it needs"
    echo "compressing first — but ffmpeg is not installed on this machine."
    echo ""
    echo "  Install it:  brew install ffmpeg     (a few hundred MB, asks for your password)"
    echo ""
    echo "Tell the person what that costs before running it."
    exit 1
  fi
  COMPRESSED="/tmp/transcribe-$(date +%s)-${SLUG}.m4a"
  echo "File is $(( FILE_SIZE / 1024 / 1024 )) MB — over the 25 MB limit. Compressing..."
  ffmpeg -i "$INPUT" -ac 1 -ar 16000 -b:a 32k "$COMPRESSED" -y -loglevel error
  COMPRESSED_SIZE=$(stat -f%z "$COMPRESSED" 2>/dev/null || stat -c%s "$COMPRESSED" 2>/dev/null)
  echo "  → $(( COMPRESSED_SIZE / 1024 / 1024 )) MB"
  if [ "$COMPRESSED_SIZE" -gt "$MAX_SIZE" ]; then
    echo "Still over 25 MB after compressing. This recording has to be split."
    echo "Ask your agent — splitting mid-sentence damages the transcript."
    rm -f "$COMPRESSED"
    exit 1
  fi
  UPLOAD_FILE="$COMPRESSED"
fi

# --- the call --------------------------------------------------------------
# response_format=verbose_json is not cosmetic: it returns segments, which is
# what lets the transcript keep line breaks. Plain text comes back as one wall.
T_START=$(date +%s)

CURL_ARGS=(-s -w "\n%{http_code}" -X POST "https://api.groq.com/openai/v1/audio/transcriptions"
  -H "Authorization: Bearer $API_KEY"
  -F "file=@$UPLOAD_FILE"
  -F "model=whisper-large-v3-turbo"
  -F "response_format=verbose_json"
  -F "language=$LANG"
  --max-time 300)
[ -n "$PROMPT" ] && CURL_ARGS+=(-F "prompt=$PROMPT")

HTTP_RESPONSE=$(curl "${CURL_ARGS[@]}")
ELAPSED=$(( $(date +%s) - T_START ))
[ -n "$COMPRESSED" ] && rm -f "$COMPRESSED"

HTTP_CODE=$(echo "$HTTP_RESPONSE" | tail -1)
BODY=$(echo "$HTTP_RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "429" ]; then
  echo "Rate limited (429). The free tier allows about 2 hours of audio per hour."
  echo "Nothing is broken. Wait 60 seconds and run the same command again."
  echo ""
  echo "$BODY"
  exit 1
fi

if [ "$HTTP_CODE" = "401" ]; then
  echo "Unauthorized (401)."
  echo ""
  echo "Nine times out of ten this is not the key — it is a newline at the end"
  echo "of the key file, usually from writing it with 'echo'. Check:"
  echo ""
  echo "  wc -c ~/.config/groq/key      # a length, never the value"
  echo ""
  echo "If it is one byte longer than the key you copied, that is the newline."
  echo "Re-run: bash tools/setup-api-key.sh groq"
  exit 1
fi

if [ "$HTTP_CODE" != "200" ]; then
  echo "The API returned HTTP $HTTP_CODE"
  echo "$BODY"
  echo ""
  echo "If that message lists file types, it is the provider's own current list and it"
  echo "is the one to trust. .aiff (what a Mac records) and .mov (phone video, screen"
  echo "recording) are not on it. Convert first, then run this again on the new file:"
  echo "  afconvert -f m4af -d aac \"$INPUT\" \"${INPUT%.*}.m4a\"     # macOS"
  echo "  ffmpeg -i \"$INPUT\" -vn -c:a aac \"${INPUT%.*}.m4a\"       # anywhere"
  exit 1
fi

TEXT=$(python3 -c "
import json, sys
data = json.loads(sys.stdin.read())
if 'segments' in data:
    for seg in data['segments']:
        print(seg['text'].strip())
elif 'text' in data:
    print(data['text'].strip())
else:
    print('[ERROR] unexpected response shape', file=sys.stderr)
    sys.exit(1)
" <<< "$BODY")

# --- Traditional Chinese ---------------------------------------------------
# Whisper leans Simplified for zh at the architecture level. This is a
# dictionary conversion, not a model — it changes characters, never wording.
TRAD_NOTE=""
if [ "$LANG" = "zh" ] && [ "$NO_TRAD" -eq 0 ]; then
  TEXT=$(printf '%s' "$TEXT" | python3 "$SCRIPT_DIR/_s2tw.py")
  TRAD_NOTE=" + opencc s2tw"
fi

EXPIRES=$(date -v+30d +%Y-%m-%d 2>/dev/null || date -d "+30 days" +%Y-%m-%d)

{
  echo "---"
  echo "audio_file: $(basename "$INPUT")"
  echo "created: $DATE"
  echo "language: $LANG"
  echo "model: groq-whisper-large-v3-turbo${TRAD_NOTE}"
  echo "status: pending"
  echo "extracted_to:"
  echo "expires: $EXPIRES"
  echo "---"
  echo ""
  echo "# Transcript: ${BASENAME}"
  echo ""
  echo "> date: $DATE · language: $LANG · took: ${ELAPSED}s"
  echo "> source: $(basename "$INPUT")"
  echo ""
  echo "> Names, numbers and dates in here are the parts speech models get"
  echo "> wrong, and they come back looking as confident as everything else."
  echo "> Check them against something you trust before this goes anywhere."
  echo ""
  echo "---"
  echo ""
  echo "$TEXT"
} > "$OUTPUT"

# --- Glossary ---------------------------------------------------------------
# Writes a correction table above the text for any known-wrong name it finds.
# Never edits the body, and never fails the run — see tools/_glossary.py.
python3 "$SCRIPT_DIR/_glossary.py" "$OUTPUT" 2>/dev/null || true

echo "Done in ${ELAPSED}s"
echo "  $OUTPUT"

if [ "$KEEP_AUDIO" -eq 0 ]; then
  if [ -d "$HOME/Downloads" ] && [[ "$INPUT" == "$HOME/Downloads/"* ]]; then
    BUFFER_DIR="$HOME/Downloads/_transcribed"
  else
    BUFFER_DIR="$TRANSCRIPTS_DIR/_audio_buffer"
  fi
  mkdir -p "$BUFFER_DIR"
  mv "$INPUT" "$BUFFER_DIR/$(basename "$INPUT")"
  echo "  audio moved to $BUFFER_DIR/"
fi
