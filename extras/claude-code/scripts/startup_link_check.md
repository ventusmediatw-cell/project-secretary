# startup_link_check.sh

Claude Code SessionStart hook. Cowork uses scheduled tasks for the same purpose.

## Trigger

Runs automatically when Claude Code starts a session (configured via `.claude/settings.local.json` SessionStart hook).

## Daily Gate

Uses `/tmp/claude-startup-check-last-run` to record today's date. Runs only once per day.

- Same day, second session: silent skip (exit 0, no output)
- Machine reboot: `/tmp/` cleared, gate resets, next session runs the check

## What It Does

1. **SOP self-check**: Verifies `.claude/skills/secretary/refs/index-mgmt-sop.md` exists
2. **Collect boot files**: CLAUDE.md, workspace/INDEX.md, SOP file, all projects/*/memory.md
3. **Run `impact_check.sh`**: Scans all boot file links for breakage

## Output Behavior

- **Issues found**: Outputs report to stdout, which Claude Code injects into session context
- **All clean**: Completely silent — no output, no context injection, zero noise

## Cowork Equivalent

Cowork has no hook mechanism. Use a daily scheduled task (e.g., at 02:09) to achieve the same check.
