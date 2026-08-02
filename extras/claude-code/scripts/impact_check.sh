#!/bin/bash
# impact_check.sh — Core link-checking logic
# Usage: impact_check.sh <file1> <file2> ...
# Can be called by SessionStart hook / scheduled task / manually
# Works on any platform (paths are auto-resolved from script location)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ROOT: walk up looking for the secretary root anchor; never assume how deep the
# script is buried.
#   home layout : <root>/CLAUDE.md + <root>/.claude/
#   repo layout : <repo>/workspace/CLAUDE.md + <repo>/workspace/.claude/  (root = that workspace/)
# The old hard-coded "$SCRIPT_DIR/../.." resolved to extras/ when the script ships
# under extras/claude-code/scripts/, so the reverse-reference grep pointed at paths
# that do not exist and was silently swallowed by 2>/dev/null.
find_root() {
  local d="$1"
  while [ "$d" != "/" ]; do
    if [ -f "$d/CLAUDE.md" ] && [ -d "$d/.claude" ]; then echo "$d"; return 0; fi
    if [ -f "$d/workspace/CLAUDE.md" ] && [ -d "$d/workspace/.claude" ]; then echo "$d/workspace"; return 0; fi
    d="$(dirname "$d")"
  done
  return 1
}

if [ -n "${CLAUDE_PROJECT_DIR:-}" ]; then
  ROOT="$CLAUDE_PROJECT_DIR"
else
  ROOT="$(find_root "$SCRIPT_DIR" || find_root "$PWD" || true)"
fi
if [ -z "${ROOT:-}" ]; then
  echo "WARN: no secretary root found (no CLAUDE.md + .claude/ in any parent);" >&2
  echo "      reverse-reference checking will be skipped. Set CLAUDE_PROJECT_DIR=<path> to override." >&2
fi

if [ $# -eq 0 ]; then
  echo "Usage: impact_check.sh <file1> [file2] ..."
  echo "Checks markdown links in the given files for broken targets."
  exit 0
fi

RED=()
YELLOW=()
GREEN=()

for file in "$@"; do
  # Normalize path: resolve relative paths against CWD first (normal CLI behaviour),
  # falling back to ROOT. Treating them as ROOT-relative only breaks in the repo
  # layout, where ROOT is <repo>/workspace and "workspace/X.md" typed from the repo
  # root would be joined into workspace/workspace/X.md.
  if [[ "$file" != /* ]]; then
    if [ -f "$PWD/$file" ]; then
      file="$PWD/$file"
    elif [ -n "${ROOT:-}" ] && [ -f "$ROOT/$file" ]; then
      file="$ROOT/$file"
    else
      file="$PWD/$file"
    fi
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
  # Strip fenced code blocks first, then inline code spans (`...`) — an example
  # link inside backticks is documentation, not a real link. Without the second
  # step, a line like `- [Title](file.md) — hook` gets reported as broken.
  done < <(awk '/^```/{f=!f; next} !f' "$file" 2>/dev/null | sed 's/`[^`]*`//g' | grep -oE '\[[^]]*\]\([^)]+\)' | sed 's/.*](//' | sed 's/)$//' | grep -v '^http' || true)

  # Reverse check: are other files referencing this file?
  # Only search paths that actually exist; skip the whole step if ROOT is unknown
  # rather than silently returning nothing.
  basename_file=$(basename "$file")
  search_paths=()
  if [ -n "${ROOT:-}" ]; then
    for p in "$ROOT/workspace" "$ROOT/CLAUDE.md" "$ROOT/.claude/skills" "$ROOT/projects" "$ROOT/refs"; do
      [ -e "$p" ] && search_paths+=("$p")
    done
  fi
  refs=""
  if [ ${#search_paths[@]} -gt 0 ]; then
    refs=$(grep -rl --include='*.md' "$basename_file" "${search_paths[@]}" 2>/dev/null | grep -v "^$file$" | head -5 || true)
  fi
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
