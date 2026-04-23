#!/bin/bash
# impact_check.sh — Core link-checking logic
# Usage: impact_check.sh <file1> <file2> ...
# Can be called by SessionStart hook / scheduled task / manually
# Works on any platform (paths are auto-resolved from script location)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"

if [ $# -eq 0 ]; then
  echo "Usage: impact_check.sh <file1> [file2] ..."
  echo "Checks markdown links in the given files for broken targets."
  exit 0
fi

RED=()
YELLOW=()
GREEN=()

for file in "$@"; do
  # Normalize path
  if [[ "$file" != /* ]]; then
    file="$ROOT/$file"
  fi

  if [ ! -f "$file" ]; then
    RED+=("$file -> file itself does not exist")
    continue
  fi

  # Forward check: parse markdown links, verify targets exist
  # Match [text](path) and [text](path#anchor) — skip http(s) links
  while IFS= read -r link; do
    [ -z "$link" ] && continue

    # Split off anchor
    link_path="${link%%#*}"
    anchor="${link#*#}"
    [ "$anchor" = "$link" ] && anchor=""

    # Skip empty paths (pure anchors like #section)
    [ -z "$link_path" ] && continue

    # Resolve relative path from the file's directory
    if [[ "$link_path" != /* ]]; then
      file_dir="$(dirname "$file")"
      if command -v realpath >/dev/null 2>&1; then
        link_path="$(realpath -m "$file_dir/$link_path" 2>/dev/null || echo "$file_dir/$link_path")"
      else
        link_path="$file_dir/$link_path"
      fi
    fi

    if [ ! -e "$link_path" ]; then
      RED+=("$file -> broken link: $link (target not found)")
    elif [ -n "$anchor" ] && [ -f "$link_path" ]; then
      heading=$(echo "$anchor" | sed 's/-/ /g')
      if ! grep -qi "^#.*$heading" "$link_path" 2>/dev/null; then
        YELLOW+=("$file -> suspicious anchor: #$anchor in $(basename "$link_path")")
      else
        GREEN+=("$file -> $link")
      fi
    else
      GREEN+=("$file -> $link")
    fi
  done < <(awk '/^```/{f=!f; next} !f' "$file" 2>/dev/null | grep -oE '\[[^]]*\]\([^)]+\)' | sed 's/.*](//' | sed 's/)$//' | grep -v '^http' || true)

  # Reverse check: are other files referencing this file?
  basename_file=$(basename "$file")
  refs=$(grep -rl --include='*.md' "$basename_file" "$ROOT/workspace" "$ROOT/CLAUDE.md" "$ROOT/.claude/skills" 2>/dev/null | grep -v "$file" | head -5 || true)
  if [ -n "$refs" ]; then
    while IFS= read -r ref; do
      [ -z "$ref" ] && continue
      GREEN+=("$file <- referenced by $(basename "$ref")")
    done <<< "$refs"
  fi
done

# Output report
echo "=== Impact Check Report ==="
echo ""

if [ ${#RED[@]} -gt 0 ]; then
  echo "BROKEN (must fix):"
  for item in "${RED[@]}"; do echo "  $item"; done
  echo ""
fi

if [ ${#YELLOW[@]} -gt 0 ]; then
  echo "SUSPICIOUS (review):"
  for item in "${YELLOW[@]}"; do echo "  $item"; done
  echo ""
fi

echo "CLEAN: ${#GREEN[@]} link(s) verified"
echo ""
echo "Files checked: $#"

# Exit 1 if any broken links found (for caller to detect)
[ ${#RED[@]} -gt 0 ] && exit 1
exit 0
