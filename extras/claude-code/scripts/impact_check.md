# impact_check.sh

Core link-checking script. Pure function — takes file paths, outputs a categorized report.

## Usage

```
impact_check.sh <file1> [file2] ...
```

Accepts relative or absolute paths. Relative paths are resolved from the script's auto-detected root directory.

## Output Format

```
=== Impact Check Report ===

BROKEN (must fix):
  /path/to/file.md -> broken link: refs/missing.md (target not found)

SUSPICIOUS (review):
  /path/to/file.md -> suspicious anchor: #old-section in target.md

CLEAN: 15 link(s) verified

Files checked: 3
```

- **BROKEN**: Link target does not exist — must fix
- **SUSPICIOUS**: Path exists but `#anchor` heading not found — review manually
- **CLEAN**: Verified OK

## Exit Code

- `0`: All clean (or only SUSPICIOUS)
- `1`: BROKEN items found

## Checking Logic

1. **Forward check**: Parse markdown relative links `[text](path)`, verify target exists
2. **Anchor check**: If link has `#section`, verify target file contains that heading
3. **Reverse check**: Find other files referencing the checked file (informational, reported as CLEAN)
