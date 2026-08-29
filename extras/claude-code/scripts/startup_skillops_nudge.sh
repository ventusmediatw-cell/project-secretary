#!/bin/bash
# startup_skillops_nudge.sh — SessionStart hook
# One job: when the last skill-ops §5 portfolio sweep is more than N days old,
# say so at session start. It reads one date stamp and reports a number of days.
# It runs no metrics and makes no judgements — deliberately: the sweep itself
# stays a decision a person makes.

# Resolve the workspace root without depending on cwd (same pattern as
# startup_link_check.sh). Installed location is workspace/.claude/scripts/,
# so two levels up is the workspace.
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"

SKILLS="$ROOT/.claude/skills"
STAMP="$ROOT/.claude/.last-skillops-sweep"
GATE="$ROOT/.claude/.last-skillops-nudge-run"
TODAY=$(date +%Y-%m-%d)
DUE_DAYS=7          # weekly sweep: nudge after 7 days
LOUD_DAYS=30        # escalate wording after 30

[ -d "$SKILLS/skill-ops" ] || exit 0   # skill absent: stay silent

# once per day, not once per session — gated only after the guard above, so a
# session opened outside this workspace never burns the day's one nudge
[ -f "$GATE" ] && [ "$(cat "$GATE")" = "$TODAY" ] && exit 0
echo "$TODAY" > "$GATE"

if [ -f "$STAMP" ]; then
  LAST=$(cat "$STAMP")
  LAST_EPOCH=$(date -j -f "%Y-%m-%d" "$LAST" +%s 2>/dev/null || date -d "$LAST" +%s 2>/dev/null) || exit 0
  DAYS=$(( ( $(date +%s) - LAST_EPOCH ) / 86400 ))
else
  LAST="never"
  DAYS=999
fi

[ "$DAYS" -lt "$DUE_DAYS" ] && exit 0
N_SKILLS=$(ls -d "$SKILLS"/*/ 2>/dev/null | grep -v _archive | wc -l | tr -d ' ')

if [ "$DAYS" -ge "$LOUD_DAYS" ]; then
  echo "🔴 Skill portfolio unswept for ${DAYS} days (last: ${LAST}) — ${N_SKILLS} skills installed."
  echo "   skill-ops §5's red-flag window is 30 days; this gap has outgrown the detector itself."
else
  echo "🟡 Skill portfolio last swept ${DAYS} days ago (${LAST}) — ${N_SKILLS} skills installed."
fi
echo "   Run it: say 「跑 skill-ops」 and pick 3️⃣ (sweep all). Afterwards: date +%Y-%m-%d > .claude/.last-skillops-sweep"
