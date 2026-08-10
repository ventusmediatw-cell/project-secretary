#!/usr/bin/env bash
# setup-api-key.sh — take an API key in a SEPARATE terminal window.
#
# Why a separate window: once a key value passes through the conversation with
# an agent, it is in that conversation's history and in every backup of it.
# This script runs in its own window. The agent cannot see what you type here.
#
# Usage:  bash tools/setup-api-key.sh <provider> [url-to-get-the-key]
#   bash tools/setup-api-key.sh groq   https://console.groq.com/keys
#   bash tools/setup-api-key.sh gemini https://aistudio.google.com/apikey

set -euo pipefail

HANDLED=0   # set to 1 for exits this script handled properly (user aborted, empty paste)
trap 'rc=$?; if [ "$rc" -ne 0 ] && [ "${HANDLED:-0}" -eq 0 ]; then
  printf "\n\n"
  printf "  ════════════════════════════════════════════════════════\n"
  printf "  x  This script stopped with an error (code %s).\n" "$rc"
  printf "\n"
  printf "  ⚠️  DO NOT PASTE YOUR KEY NOW.\n"
  printf "     What appears below is your normal shell prompt, not this\n"
  printf "     script asking you a question. A key pasted there gets run as\n"
  printf "     a command and stored in your shell history.\n"
  printf "\n"
  printf "  Send the error above to your agent, and run this again once fixed.\n"
  printf "  ════════════════════════════════════════════════════════\n\n"
fi' EXIT

# Not ${1:?...}: that style of failure skips the EXIT trap above in a
# non-interactive shell, which is exactly where the safety net is needed.
if [ "$#" -lt 1 ]; then
  HANDLED=1
  echo "Usage: bash tools/setup-api-key.sh <provider> [url-to-get-the-key]" >&2
  exit 2
fi
PROVIDER="$1"
GET_URL="${2:-}"
DEST="$HOME/.config/$PROVIDER/key"

bar() { printf '%s\n' "────────────────────────────────────────────────────────────"; }

clear
bar
printf '  Set up the %s API key\n' "$PROVIDER"
bar
echo
echo "  Three things are about to happen:"
echo "    1. You paste the key into this window"
echo "    2. It is saved to ${DEST}, readable only by you"
echo "    3. You get back the length and last four characters, so you can"
echo "       confirm it arrived — the key itself is never printed"
echo
echo "  ⚠️  Do not paste the key back into your chat with the agent."
echo "      This window is the only place it goes."
echo

if [ -n "$GET_URL" ]; then
  echo "  Don't have a key yet? Get one here (free):"
  echo "    $GET_URL"
  echo
fi

if [ -e "$DEST" ]; then
  bar
  echo "  ⚠️  There is already a key at this location:"
  printf '     path:     %s\n' "$DEST"
  printf '     modified: %s\n' "$(date -r "$DEST" '+%Y-%m-%d %H:%M')"
  printf '     length:   %s bytes  (contents not shown)\n' "$(wc -c < "$DEST" | tr -d ' ')"
  echo
  read -r -p "  Replace it? Type yes to replace, anything else cancels: " ANS
  if [ "$ANS" != "yes" ]; then
    HANDLED=1
    echo
    echo "  Cancelled. The existing key was not touched. You can close this window."
    exit 0
  fi
  echo
fi

bar
echo
echo "  Paste the key and press Enter."
echo "  (Nothing will appear on screen as you paste — that is intentional.)"
echo
printf '  > '
read -rs KEY
echo
echo

if [ -z "$KEY" ]; then
  HANDLED=1
  echo "  x  Nothing was read — the paste may not have worked. Since the screen"
  echo "     stays blank either way, there was no way to see that at the time."
  echo "     Nothing was written, and any existing key was left alone."
  echo
  echo "     Try again: press the up arrow to recall the command, then Enter."
  exit 1
fi

mkdir -p "$(dirname "$DEST")"
# printf '%s', never echo: echo appends a newline, several APIs then return 401,
# and the error message says nothing whatsoever about whitespace.
printf '%s' "$KEY" > "$DEST"
chmod 600 "$DEST"
unset KEY

BYTES="$(wc -c < "$DEST" | tr -d ' ')"
LAST4="$(tail -c 4 "$DEST")"
PERM="$(ls -l "$DEST" | awk '{print $1}')"

bar
echo "  ✓ Saved"
bar
printf '     path:        %s\n' "$DEST"
printf '     length:      %s bytes\n' "$BYTES"
printf '     last four:   …%s\n' "$LAST4"
printf '     permissions: %s   (should start -rw-------, meaning only you can read it)\n' "$PERM"
echo
echo "  Compare the length and last four against the key you copied."
echo "  If they match, it worked."
echo
echo "  You can close this window and tell the agent the key is set up."
echo "  ⚠️  Do not paste the key to it — it does not need the value, only the path."
echo
bar
