# startup_skillops_nudge.sh

A SessionStart hook for the **skill-ops** Skill. When the last portfolio sweep
(skill-ops §5) is 7+ days old it prints one reminder line per day; at 30+ days
the wording escalates — §5's own red-flag window is 30 days, so by then the gap
has outgrown the detector.

Deliberately a **reminder, not an automation**: it reads one date stamp
(`.claude/.last-skillops-sweep`, which you write after finishing a sweep) and
reports days elapsed. It runs no metrics and changes no files.

Install: same steps as `startup_link_check.sh` — copy into
`workspace/.claude/scripts/`, register under `hooks.SessionStart` (see the
README in this directory). Cowork and other platforms have no hooks; trigger
the sweep manually there.
