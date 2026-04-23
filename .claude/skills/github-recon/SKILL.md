---
name: github-recon
description: "GitHub Repo security recon: auto-triggers when user pastes any github.com/<user>/<repo> URL, produces red/yellow/green light report + red flag list. Read-only, zero execution, goal is to build risk picture before user decides to clone/install/run."
---

# GitHub Recon — Repo Security Recon SOP

## Trigger Condition

**Any time** the user pastes a `github.com/<user>/<repo>` URL, **regardless of intent** (read notes, research, want to use, want to fork, want to install), run this SOP **first**, then do what the user asked.

Exception: User explicitly says "skip the scan, just take notes" or "I already scanned it" → skip.

**Key principle**:
- Recon phase **read-only, no execution**. Allowed: WebFetch, read raw files, query GitHub API.
- Forbidden: `git clone`, `pip install`, `npm install`, `docker pull`, run examples, run setup scripts
- These actions only after recon complete, report produced, user approves

---

## SOP Flow (5 Steps)

### Step 1: URL Sanity Check (30 seconds)

1. Strip tracking params (`?fbclid=...`, `?utm_source=...`, `?ref=...`)
2. Confirm host is `github.com`, not `github.io` / `githab.com` / `gtihub.com` variants
3. Confirm `<user>/<repo>` spelling:
   - For well-known orgs (`microsoft`, `google`, `anthropic`, `openai`, `vercel`, `huggingface` etc.) do typosquat check
   - Red flag: `microsft`, `anthropc`, `hugginface`, `opena1` etc.
4. Record source context: Where did the user see this? (HN / Twitter / Telegram / friend / official docs)
   - If user didn't say and URL has `fbclid` / `utm_source` etc. → note "source is social media share, manual verification of repo authenticity recommended"

### Step 2: Repo Metadata Fetch (2 minutes)

Use WebFetch to fetch `https://github.com/<user>/<repo>` main page, extract:

| Field | How to Check | Red Flag Condition |
|---|---|---|
| Stars | Top right of main page | Too low (<10) or disproportionate (>1k but commits <20) |
| Forks | Top right of main page | Too low (<5) usually no community |
| Commit count | Middle of main page | <10 commits but >1k stars = strong red flag (fake stars / pushed up at once / pre-launch hype) |
| First commit date | Fetch `/commits` | <30 days ago but stars already exploding → red flag |
| Last commit date | Main page | >6 months no commit = zombie repo |
| Author account | Click author username | Check other repo count, followers, first activity date |
| Issues | Issues tab | 0 issues + high stars = abnormal; issues unanswered = poor maintenance |
| Releases / Tags | Sidebar | 0 releases = no version management |
| Contributors | Sidebar | 1 person = single maintainer risk |

**Author secondary check**:
- Click into author profile, check:
  - Account creation date (if visible)
  - Other repo count
  - Has real photo / bio / link to personal site?
  - Red flag: single-repo account + no bio + no followers + random username (e.g., `xkj9281`)

### Step 3: License & Security Files (30 seconds)

Fetch raw files (`https://raw.githubusercontent.com/<user>/<repo>/main/<file>` or `master`):

- [ ] LICENSE exists, is it a common license (MIT / Apache / GPL / BSD)?
- [ ] SECURITY.md exists (mature projects have one)?
- [ ] CONTRIBUTING.md exists?
- [ ] CODE_OF_CONDUCT.md exists?

**Red flag**: No LICENSE or LICENSE says "All rights reserved" but encourages forking

### Step 4: Dependency & Install Script Scan (3 minutes)

Fetch and read these files (whichever exists):

**Python**:
- `requirements.txt` / `pyproject.toml` / `setup.py` / `setup.cfg`
- Check dependency list: every package name should be recognizable or verifiable
- Red flags: Strange small packages (e.g., `python-helper-utils-2024`, `fast-json-parser-pro`), typosquat (`requets` vs `requests`, `numpyy` vs `numpy`)
- **Focus on `setup.py`**: Any arbitrary Python code execution during install (`os.system`, `subprocess`, `urllib.request.urlopen`)?

**Node.js**:
- `package.json`
- Check `scripts` section, especially `postinstall`, `preinstall`, `prepare`
- Red flags: postinstall runs `curl ... | sh`, `node -e "..."`, executes external URL scripts

**Docker**:
- `Dockerfile`
- Check `RUN` commands for `curl ... | sh`, `wget ... | bash`

**Universal red flag patterns** (any language):
- `curl <url> | sh` / `wget -O - <url> | bash`
- `base64 -d | sh` (obfuscated execution)
- `eval $(...)`
- Connects to unknown IP / domain
- Writes to `~/.ssh/`, `~/.aws/`, `/etc/cron.d/` etc. sensitive locations
- Reads `~/.ssh/id_rsa`, `~/.aws/credentials`, browser cookies

### Step 5: Produce Recon Report

> Report format: see `templates.md` in same folder.

---

## Light Rating Criteria

| Rating | Condition | Default Action |
|---|---|---|
| 🟢 **Green** | Well-known org / known author / high stars + proportional commits / has LICENSE + SECURITY.md / no suspicious install script / clean dependencies | Notes OK, clone to read source OK, install still needs explicit consent |
| 🟡 **Yellow** | At least one red flag (star/commit ratio abnormal / single-repo account / no SECURITY.md / suspicious dependency but no clear malice) but no RCE-level risk | Notes OK, clone to read source recommend manual re-check first, install strongly recommend sandbox |
| 🔴 **Red** | Any RCE-level red flag (postinstall runs `curl \| sh` / typosquat dependency / setup.py has os.system / connects to unknown IP / steals ssh key) | **Do not recommend any further action**, even clone — stop and ask user, notes must include explicit warning |

**Conservative principle**: When unsure, mark yellow and hand decision to user.

---

## Relationship to Other Skills

- **`tool-scout`**: Broad search for "what tools exist." github-recon is the deep security check after tool-scout finds candidates, also independently applicable when user directly pastes URL.
- **`workspace/refs/security-checklist.md`**: Full 7-dimension security checklist. github-recon is its "quick version" + GitHub-specialized. High-importance tool evaluations should still run full checklist after github-recon.
- **`knowledge-base`**: When writing KB notes, if recon is yellow/red, notes must clearly flag the red flag list and "not recommended for execution" warning — can't only write about advantages.

---

## 🔍 Recon ≠ Source Review (Important Extension)

github-recon is a **pre-clone risk picture**, only looking at README / package.json / Dockerfile / setup.py level metadata evidence. **Cannot catch source-level risks**.

**Case lesson**:
- Recon gave 🟡 yellow (README `--trust-all-tools` flag + Dockerfile external binary without checksum)
- Source review found the broker **hardcoded** automatic `allow_always` response to all `session/request_permission`, couldn't disable without forking
- Difference: recon saw "configurable flag," source review saw "hardcoded forced behavior" — latter is far more serious

**Rules**:
1. **Repos with yellow or above that will be deployed must get source review** (clone + Read + Grep, don't run cargo/npm/pip), can't rely on recon report alone for decisions
2. **When source review finds new red flags**: Add "📌 source review amendment" at top of original KB article or recon report, pointing to source map file
3. **Ratings can be adjusted by source review**: e.g., recon green but source review finds hardcoded backdoor → upgrade to red; recon yellow but source review confirms red flag is just a configurable default → maintain yellow or downgrade
4. **Error-prevention wording in recon reports**: Don't write "security assessment complete," write "metadata-level recon complete, source review needed before deployment"

---

## Platform Routing (Cowork vs Claude Code)

Both platforms can run this SOP, but risks differ:

| Platform | Advantage | Risk |
|---|---|---|
| **Cowork** | No local shell, worst case prompt injection can't RCE | Can still pollute workspace notes |
| **Claude Code** | Can actually clone / run sandbox checks | Has Bash, worst case prompt injection can RCE |

**Recommended routing**:
- **Unknown repo / suspicious source** → Give to Cowork for recon report, Claude Code reads from report, doesn't directly WebFetch the repo
- **Known high trust (official org / previously verified)** → Claude Code can run directly

---

## Self-Check List

After each SOP run, confirm:

- [ ] Report has explicit light rating
- [ ] Red flag list is specific (not vague "looks suspicious")
- [ ] Recommended action table is complete
- [ ] **Did not take any install / clone / run action on own initiative**
- [ ] User source context is recorded (where they saw it)
- [ ] If yellow/red, KB notes (if written) also flagged warning
