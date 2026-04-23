---
name: gcp-ops
description: "GCP Compute Engine SOP: gcloud CLI installation (Mac/Cowork), SSH connection, SCP file transfer, VM first-time setup, browser SSH operating notes, multi-project handling. Load when operating GCP."
disable-model-invocation: true
---

# GCP Compute Engine SOP

## Operation Route Selection

| Operation Type | Recommended Method | Notes |
|---|---|---|
| Create/manage VM, firewall, IAM | Use Chrome to operate GCP Console | GCE MCP connector unavailable (redirects to docs page), use Chrome directly |
| SSH into VM to run commands | Option A: gcloud CLI → `gcloud compute ssh` (recommended); Option B: Chrome browser SSH (usable but painful) | Option A lets you use Bash tool directly |
| Transfer files to VM | `gcloud compute scp` or git pull directly on VM | Don't hand-type long content in browser SSH |

## gcloud CLI Installation

### Mac (Tested ✅)

```bash
brew install --cask google-cloud-sdk
gcloud auth login          # Browser login to Google account
gcloud config set project YOUR_PROJECT_ID
```

PATH: `/opt/homebrew/share/google-cloud-sdk/bin` (brew adds automatically).

### Cowork Sandbox (⚠️ Untested)

> Need to ask user to enable Network Egress first (Settings → Allow network egress)

```bash
curl -sSL https://sdk.cloud.google.com | bash
# After shell restart
gcloud init
```

**Note**: First use might need OAuth login flow handling.

## ⚠️ Multi-Project Considerations

gcloud has a default project. If your VMs are spread across multiple projects, you must specify `--project=` when operating on non-default project VMs:

```bash
# Example: SSH to a VM in a non-default project
gcloud compute ssh VM_NAME --zone=ZONE --project=OTHER_PROJECT_ID
```

Keep a reference table of which VM lives in which project and zone to avoid mistakes.

## Common Commands

```bash
# Create VM
gcloud compute instances create VM_NAME --zone=asia-east1-b \
  --machine-type=e2-micro --image-family=ubuntu-2204-lts \
  --image-project=ubuntu-os-cloud --boot-disk-size=20GB

# SSH
gcloud compute ssh VM_NAME --zone=asia-east1-b

# Transfer file
gcloud compute scp LOCAL_FILE VM_NAME:/home/USER/ --zone=asia-east1-b
```

**New project note**: Compute Engine API is disabled by default, need to enable manually in GCP Console.

## Browser SSH Operating Notes (Tested)

1. GCP Console → Compute Engine → VM instances → Click "SSH"
2. **First thing**: `sudo apt install -y tmux && tmux new -s dev`
3. Use `key` action to type commands character-by-character (`type` action often drops characters)
4. After long operations, use screenshot to confirm results
5. Reconnect after disconnect: Click SSH → `tmux attach -t dev`

## VM Environment First-Time Setup SOP

1. **Create VM** — e2-small enough for light tasks; pick region closest to you
2. **SSH + tmux** — `sudo apt install -y tmux && tmux new -s dev`
3. **System packages** — `sudo apt update && sudo apt install -y git python3-pip python3-venv`
4. **Git auth** — `git config --global credential.helper store`, use GitHub Classic PAT when cloning
5. **Clone repo** — `git clone --recurse-submodules https://github.com/...`
6. **Python venv** — `python3 -m venv .venv && source .venv/bin/activate && pip install --upgrade pip`
7. **Install dependencies** — Prefer `pip install -e .`; if fails, `pip install` individual packages
8. **Verify** — `python3 -c "import numpy, scipy, ..."` confirm imports work

## Cowork File Transfer to VM (Tested ✅)

**⚠️ Browser SSH cannot reliably transfer files** (paste/keyboard/clipboard/file_upload all fail).

Correct approach: **Ask user to run gcloud scp from their local terminal**:

```bash
gcloud compute scp LOCAL_FILE USERNAME@VM_NAME:REMOTE_PATH \
  --zone=ZONE --project=PROJECT_ID
```

**Note**: User's gcloud default project might differ from target project — `--project=` is essential.

## Pitfall Records

- Browser SSH unstable, disconnects on long operations (git clone large repos especially) → Always use tmux
- `type` action often drops characters in SSH terminal → Use `key` action for character-by-character input
- GCE MCP connector appears available but redirects to docs on Connect → Use Chrome to operate Console directly
- **Browser SSH file transfer doesn't work**: 5 methods all failed → Use user's local `gcloud compute scp` instead
