# Claude Code Extras

This directory contains tooling **specific to Claude Code** (the CLI tool). If you use Cowork, Antigravity, or another platform, you can safely ignore this directory.

## Contents

- `scripts/` — Automation scripts for Claude Code hooks
  - `impact_check.sh` — Core link-checking logic (checks markdown links for broken targets)
  - `impact_check.md` — Documentation for impact_check.sh
  - `startup_link_check.sh` — SessionStart hook wrapper (runs impact_check once per day)
  - `startup_link_check.md` — Documentation for startup_link_check.sh
- `settings.json.example` — Example Claude Code settings with SessionStart hook

## Setup

1. Copy scripts to your `workspace/.claude/scripts/` directory:
   ```bash
   mkdir -p workspace/.claude/scripts
   cp extras/claude-code/scripts/* workspace/.claude/scripts/
   chmod +x workspace/.claude/scripts/*.sh
   ```

2. Add the SessionStart hook to your `workspace/.claude/settings.local.json`:
   ```json
   {
     "hooks": {
       "SessionStart": [
         {
           "matcher": "",
           "hooks": [
             {
               "type": "command",
               "command": "bash .claude/scripts/startup_link_check.sh"
             }
           ]
         }
       ]
     }
   }
   ```

   **Warning**: `settings.json.example` is a reference only. Merging into your existing settings is recommended — directly replacing your `workspace/.claude/settings.local.json` will overwrite your current configuration.

## Cowork / Antigravity Equivalent

These platforms don't have hooks. Use a scheduled task (e.g., `daily-secretary-review` running at 02:09) to achieve the same daily health check. See the secretary Skill for details.
