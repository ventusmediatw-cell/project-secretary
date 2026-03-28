---
name: github-ops
description: "GitHub SOP: clone/push methods in Cowork, Classic PAT usage rules (not fine-grained), revoke after use, credential.helper store, security checklist. Load when operating GitHub."
disable-model-invocation: true
---

# GitHub SOP

## GitHub Operations in Cowork

Cowork sandbox **has no gh CLI** and no GitHub MCP connector.

| Operation | Method |
|---|---|
| Clone/push on VM | HTTPS + Classic PAT (use as password) |
| Clone in Cowork sandbox | HTTPS + PAT (need Network Egress enabled) |
| Manage repo settings | Use Chrome to operate github.com |
| Create Issue / PR | Chrome tool or ask user to use gh CLI locally |

## PAT Usage Rules

1. **Use Classic PAT, not Fine-grained Token** — Fine-grained has default narrow permissions, easy to get 403
2. **Revoke immediately after use** — PAT appearing in Agent dialogue counts as leaked; after operations remind user to go GitHub Settings → Developer Settings → Personal Access Tokens to revoke
3. **Store locally with credential.helper** — `git config --global credential.helper store`, input PAT once
4. **Submodules require second auth** — If submodule points to different org's repo, clone asks for credentials twice

## Security Checklist (After Each PAT Use)

- [ ] Confirm `.gitignore` excludes `.env`, `*.db`, credential files
- [ ] Remind user to revoke this session's PAT
- [ ] Confirm `~/.git-credentials` won't be committed

## Pitfall Records

- Fine-grained Token's "Repository permissions" default doesn't have Contents read/write, common 403 → Always use Classic PAT
- `credential.helper store` stores PAT plaintext in `~/.git-credentials` → Must remind user to revoke after session ends
