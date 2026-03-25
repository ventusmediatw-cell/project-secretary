# External Tool Security Checklist

Use this checklist to quickly assess external tools (MCP Server, Plugin, GitHub repo, third-party API) security in new projects' Step 3 tool exploration. Check each item before integration; conclude with "Low" "Medium" "High" risk level.

---

## 📋 Source Code and Open Source

- [ ] Source code publicly available (open source > closed source, aids verification)
- [ ] License type clear (MIT, GPL, Apache, etc.; avoid unlicensed)
- [ ] License compatible with project usage scenario (commercial, internal use, etc.)
- [ ] README, docs clearly describe tool functionality and permission requirements

---

## 👥 Maintainer Reputation

- [ ] GitHub stars / favorites sufficient (>100 baseline, >1000 more peace of mind)
- [ ] Latest commit within three months (active maintenance)
- [ ] Regular release publishing (version management)
- [ ] Issue response time reasonable (<2 weeks ideal)
- [ ] Maintainer has real identity and contribution history (single anonymous project needs caution)

---

## 🔐 Known Vulnerabilities and Security Advisories

- [ ] Search CVE Database / NVD for known vulnerabilities
- [ ] Check GitHub Security tab for Advisories
- [ ] Use Snyk / WhiteSource scan for dependency vulnerabilities
- [ ] If vulnerabilities exist, patch speed
- [ ] Security policy or Security.md file exists

---

## 🔑 Permissions and Authorization Scope

- [ ] What system permissions does MCP Server need (file read/write, network access, etc.)
- [ ] What user data does Plugin need (location, storage, accounts, etc.)
- [ ] Can permissions be restricted (Scope, Sandbox)
- [ ] Do permission needs match functionality (over-requesting raises red flag)

---

## 📤 Data Leakage and Privacy Risk

- [ ] Does tool transmit data to external servers
- [ ] If yes, target server location and reputation
- [ ] Is data encrypted in transit (HTTPS / TLS)
- [ ] Privacy policy exists explaining data usage and retention
- [ ] Sensitive data (accounts, keys, personal info) recorded by tool

---

## 🔗 Supply Chain Risk

- [ ] One-level dependency count reasonable (too many increases attack surface)
- [ ] Transitive dependency clear (use npm audit / pip audit)
- [ ] Typosquatting risk (name similar to famous package)
- [ ] Dependencies themselves verified (recursive assessment)
- [ ] Lock file used (ensure version consistency)

---

## ⚖️ Compliance and Regulations

- [ ] If involving user data, complies with GDPR / local privacy law
- [ ] Cross-border data storage risk
- [ ] Data processing agreement (DPA / ToS) exists

---

## Risk Level Judgment

| Level | Criteria |
|---|---|
| **Low** | Open source, well-known, actively maintained, no known vulnerabilities, clear permissions, no privacy red flags |
| **Medium** | Open source but inactive maintenance, old vulnerabilities already patched, permissions need verification, external data transmission but encrypted |
| **High** | Closed / no license, unmaintained, unpatched vulnerabilities, excessive permissions, sensitive data external transfer, unverifiable origin |

**Decision recommendation**: Low risk integrate directly; Medium risk needs Code Review + isolation; High risk recommend abandoning or finding alternatives.
