#!/bin/bash
# startup_link_check.sh — SessionStart hook
# Daily-gate: runs once per day (first Code session only)
# Checks boot file links for breakage, outputs to context if issues found
# Note: This script is for Claude Code only. Cowork uses scheduled tasks instead.

LAST_RUN="/tmp/claude-startup-check-last-run"
TODAY=$(date +%Y-%m-%d)

# Daily gate: skip if already ran today
if [ -f "$LAST_RUN" ] && [ "$(cat "$LAST_RUN")" = "$TODAY" ]; then
  exit 0
fi
echo "$TODAY" > "$LAST_RUN"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"

# Self-check: verify the SOP file itself exists
SOP_FILE="$ROOT/.claude/skills/secretary/refs/index-mgmt-sop.md"
if [ ! -f "$SOP_FILE" ]; then
  echo "CRITICAL: index-mgmt-sop.md not found at $SOP_FILE"
  echo "The INDEX management SOP itself is missing. Please restore it."
  exit 0
fi

# Collect boot files
BOOT_FILES=(
  "$ROOT/CLAUDE.md"
  "$ROOT/workspace/INDEX.md"
  "$SOP_FILE"
)

# Dynamically add all projects/*/memory.md (max depth 3)
while IFS= read -r f; do
  BOOT_FILES+=("$f")
done < <(find "$ROOT/workspace/projects" -maxdepth 3 -name "memory.md" 2>/dev/null)

# Run core check
RESULT=$("$SCRIPT_DIR/impact_check.sh" "${BOOT_FILES[@]}" 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
  echo "Daily boot file link check found issues:"
  echo ""
  echo "$RESULT"
  echo ""
  echo "Please review and fix broken links."
fi
# Silent pass when clean — no output injected into context
exit 0
