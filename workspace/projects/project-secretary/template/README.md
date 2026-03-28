# AI Personal Secretary — Template v0.4

> An AI personal secretary system template built on Claude Code / Cowork.
> Fork it, tweak a few parameters, and you're good to go.

[繁體中文版 →](#繁體中文)

## What is This

A system architecture that turns an AI Agent into your personal secretary, featuring:

- **Dual-mode operation**: Secretary mode (global management) + Project mode (focused execution)
- **Cross-platform consistency**: Works on Cowork, Claude Code, and Antigravity
- **Structured memory**: INDEX index layer + inbox journal layer + memory knowledge layer + project layer — older records get coarser-grained
- **Automated handoff**: No dropped balls when Agents switch shifts
- **Personal knowledge base**: URL → fetch → summarize → archive, with project bridging
- **Decision support**: Debate protocol for high-stakes decisions
- **Battle-tested**: Refined through daily production use, 15 documented pitfalls and counting

## Skills Overview

Skills are modular behavior packages that the secretary loads on demand. They live in `.claude/skills/` and are auto-discovered by Claude Code / Cowork.

### Core Skills (always active)

| Skill | What It Does | How to Trigger |
|---|---|---|
| **secretary** | Dual-mode operation, memory architecture, organization rhythm, INDEX routing, output control | Auto-loaded every session |
| **review** | Two-stage wrap-up: project manager closes out → secretary reviews with 12-item checklist (experience extraction + system updates + memory sync) | Say **"wrap up"** |
| **handoff** | Cross-session and cross-platform handoff protocol. Ensures zero information loss between sessions | Auto-loaded; runs at every session end |

### Project & Knowledge Skills

| Skill | What It Does | How to Trigger |
|---|---|---|
| **project-setup** | Six-step project launch flow: background → architecture → research → Debate → decision → execution. Includes branching logic for simple vs complex projects | Say **"start new project"** or **"open a project"** |
| **knowledge-base** | Personal knowledge pipeline: paste a URL → auto-fetch → summarize → archive. Supports articles and YouTube. Bridges knowledge to projects via `kb-digest` | Share a **URL** in conversation, or say **"save this"** |
| **tool-scout** | Discover tools via MCP Registry, Plugin store, and GitHub. Includes security assessment checklist | Say **"find a tool for X"** or **"is there a plugin for X"** |
| **debate-protocol** | Multi-round structured debate for high-stakes decisions. Advocate vs Challenger with word limits, secretary moderates | Triggered during **project-setup Step 4**, or say **"let's debate X"** |

### Tool SOPs (optional, remove if unused)

| Skill | What It Does | How to Trigger |
|---|---|---|
| **chrome-sop** | Standard operating procedure for Chrome browser automation | Load when **operating Chrome** tools |
| **gcp-ops** | GCP VM operations: SSH, firewall, deployment | Load when **using GCP** |
| **github-ops** | GitHub operations: PAT management, clone/push, security | Load when **using GitHub** |
| **subagent-guide** | Best practices for launching and prompting sub-agents | Load when **launching a sub-agent** |

> **Customization tip**: Delete any Tool SOP Skills you don't need. The core system works fine without them.

## Quick Start

### 1. Copy the File Structure

```
your-project/
├── CLAUDE.md                          ← Global entry point (must be in root)
├── .claude/
│   └── skills/
│       ├── secretary/SKILL.md         ← Core secretary behavior
│       ├── review/SKILL.md            ← Wrap-up Review (12-item checklist)
│       ├── handoff/SKILL.md           ← Handoff protocol
│       ├── project-setup/SKILL.md     ← Six-step project launch
│       ├── knowledge-base/SKILL.md    ← Knowledge base pipeline
│       ├── tool-scout/SKILL.md        ← Tool discovery + security
│       ├── chrome-sop/SKILL.md        ← [Optional] Chrome SOP
│       ├── gcp-ops/SKILL.md           ← [Optional] GCP SOP
│       ├── github-ops/SKILL.md        ← [Optional] GitHub SOP
│       └── subagent-guide/SKILL.md    ← [Optional] Sub Agent guide
├── workspace/
│   ├── INDEX.md                       ← Main index (project list, to-dos)
│   ├── BEGINNER-TIPS.md               ← Beginner tips
│   ├── inbox/                         ← Daily journals (auto-created)
│   ├── handoff/
│   │   ├── pending/                   ← Cross-platform pending handoffs
│   │   └── done/                      ← Processed archive
│   ├── projects/
│   │   └── {name}/
│   │       ├── INDEX.md               ← Project index
│   │       ├── memory.md              ← Accumulated knowledge
│   │       ├── daily/                 ← Project daily reports
│   │       ├── refs/                  ← Research materials + kb-digest
│   │       └── debates/               ← Debate transcripts
│   ├── knowledge-base/
│   │   ├── articles/                  ← Saved articles
│   │   ├── videos/                    ← Saved videos
│   │   └── inbox/fetch-queue.md       ← Batch processing queue
│   ├── summaries/
│   │   ├── weekly/                    ← Weekly reports
│   │   └── monthly/                   ← Monthly reports
│   └── refs/
│       ├── debate-agents/             ← Debate protocol + personas
│       └── security-checklist.md      ← Tool security checklist
├── docs/
│   ├── quickstart.md                  ← Quick start guide
│   ├── faq.md                         ← FAQ (11 questions)
│   └── lessons-learned.md             ← 15 pitfalls + best practices
└── README.md                          ← This file
```

### 2. Customize CLAUDE.md

Open `CLAUDE.md` and modify:

- **Identity**: Change "AI personal secretary" to your desired role
- **Model default**: Adjust based on your plan (Max / Pro / other)
- **Cross-platform paths**: Set to your actual paths
- **Skills index**: Remove tool SOP Skills you don't need

### 3. Customize secretary Skill

Open `.claude/skills/secretary/SKILL.md` and modify:

- **Operating modes**: Adjust secretary mode / project mode behavior
- **Memory architecture**: Adjust folder structure (if yours differs)
- **Cleanup rhythm**: Set your preferred Review frequency
- **Tool preferences**: Add your tool choice decisions

### 4. Set Up INDEX.md

Add your project list and to-do items to `workspace/INDEX.md`. Refer to the template examples or see `docs/quickstart.md`.

### 5. Launch

Open your root directory in Claude Code or Cowork. The Agent will auto-read CLAUDE.md → load secretary Skill → detect first use → run setup wizard → enter secretary mode.

## Core Design Principles

### CLAUDE.md is the Single Entry Point

All platform Agents start from CLAUDE.md. Claude Code / Cowork auto-read it; other platforms read manually. CLAUDE.md lives in the root directory, Skills in `.claude/skills/` at the same level.

### Skills Replace Manual Reading

Secretary behavior rules, Review flow, handoff protocol, and tool SOPs are all packaged as Skills. Claude Code / Cowork auto-discover and load them — no more manually reading SYSTEM.md every time.

### Layered Memory

| Layer | Location | Update Frequency | When to Read |
|-------|----------|-----------------|-------------|
| Index | INDEX.md | Every session | Every Agent (required) |
| Events | inbox/, projects/daily/ | Every handoff | On demand |
| Knowledge | projects/memory.md | After accumulation | Cold start |
| Digests | projects/refs/kb-digest.md | When articles saved | On demand |
| Summaries | summaries/weekly/, monthly/ | Weekly/Monthly | On demand |

Older records get coarser-grained; raw records are preserved forever.

### Cross-Platform Handoff via handoff/

Don't mix cross-platform tasks into inbox/ journals. Use the dedicated `handoff/pending/` → `handoff/done/` queue, with timestamped filenames and summaries. See `handoff` Skill for details.

### Knowledge Bridge: kb-digest

When you save an article to the knowledge base, the secretary automatically writes an actionable digest to related projects' `refs/kb-digest.md`. This bridges "I saved this interesting article" to "here's what it means for project X." See `knowledge-base` Skill for details.

### Decision Support: Debate Mechanism

High-stakes business decisions can trigger a Debate — inviting an Advocate and Challenger for multi-round exchanges. The secretary moderates, recording consensus / disagreements / pending items. See `workspace/refs/debate-agents/debate-protocol.md`.

## Getting Started

1. Read `docs/quickstart.md` (5-minute quick start)
2. Read `workspace/BEGINNER-TIPS.md` (usage tips)
3. Check `docs/faq.md` (common questions)
4. Look up `docs/lessons-learned.md` when you hit issues (15 pitfalls)

## Version History

### v0.4 (2026-03-28)

**Added**:
- **knowledge-base Skill**: URL → fetch → summarize → archive pipeline, with YouTube support and project knowledge bridging via kb-digest
- **Skills Overview section** in README: clear feature list and trigger guide for all 10 Skills
- 5 new lessons learned (#11-#15): review depth, knowledge bridging, file recovery, search coverage, token control
- FAQ Q11: How to build a personal knowledge base

**Upgraded**:
- **review Skill**: Single-stage → two-stage flow (project wrap-up → secretary review), 12-item checklist (experience extraction + system updates + memory sync), review level judgment, git auto-save
- **secretary Skill**: Daily Review rhythm, weekly docs update check, expanded cross-platform table (6 → 12 items), project mode exit instruction
- Golden Rules: 3 new principles (extract don't just record, bridge knowledge to action, control output size)

### v0.3 (2026-03-27)

**Added**:
- First-Time Setup Wizard: auto-detects new users, guides through 4-step onboarding
- Output Control Rules: default 300-word responses, scope control, multi-step guardrails

**Improved**:
- Cross-platform difference table corrections

### v0.2 (2026-03-25)

**Added**:
- 8 new Skills: project-setup, tool-scout, chrome-sop, gcp-ops, github-ops, subagent-guide, handoff, review
- Complete Debate protocol (debate-protocol.md + advocate/challenger personas)
- Security assessment checklist (security-checklist.md)
- Three docs: quickstart, faq, lessons-learned
- Memory write-back rules (memory.md layer)
- Cross-platform handoff mechanism (handoff/)

**Improved**:
- secretary Skill adds memory write-back rules and handoff trigger rules
- CLAUDE.md fully fleshed out with complete Skills index
- INDEX.md template more detailed with beginner hints

**Removed**:
- SYSTEM.md content migrated to Skills (no need to read SYSTEM.md anymore)

### v0.1 (Initial)

Basic secretary system with dual modes, layered memory, and INDEX structure.

## Lessons Learned

This system was battle-tested through daily production use. Here are the top pitfalls we hit:

1. **CLAUDE.md and Skills must be at the same level**: Skills go in `.claude/skills/` at the root, same level as CLAUDE.md.
2. **Update CLAUDE.md incrementally**: Every time you build a Skill, update the CLAUDE.md index immediately.
3. **Check for native features before building custom**: AI tools ship new features constantly. Search first.
4. **Tag verification status on cross-session conclusions**: `✅ Verified` / `⚠️ Speculative`.
5. **Timestamps are mandatory in handoff reports**: Run `date` for time. Never use vague terms.
6. **Debate needs word limits**: Opening 200-300 words, exchanges 100-150, max 3 topics.
7. **Memory layering is critical**: memory.md (knowledge) vs INDEX.md (status) vs daily/ (events).
8. **Review is for learning, not just logging**: The 12-item checklist ensures you capture lessons, not just events.
9. **Bridge knowledge to action**: Saved articles must connect to projects via kb-digest, or they'll collect dust.
10. **Control output size**: Default brief, confirm before expanding, one step at a time.

See `docs/lessons-learned.md` for the full list of 15 pitfalls with symptoms, root causes, and solutions.

## External Validation

This architecture has been independently validated by:
- **Anthropic's official Claude Code guide** (23 pages, 10 departments): confirms "the more detailed your CLAUDE.md, the better Claude performs"
- **YC's Garry Tan** released gstack (7,700 GitHub stars in 48 hours): uses the same Skills-based role specialization pattern

## License

Free to use, modify, and distribute. If you make interesting improvements, PRs welcome.

## Contact

Questions, suggestions, or pitfalls to share?
- Open a GitHub Issue
- Submit a PR

---

---

# 繁體中文

# AI 個人秘書 — 模板 v0.4

> 一套基於 Claude Code / Cowork 的 AI 個人秘書系統模板。
> Fork 後改幾個參數就能跑。

## 這是什麼

一套讓 AI Agent 扮演你的個人秘書的系統架構，支援：

- **雙模式運作**：秘書模式（全局管理）+ 專案模式（專注推進）
- **跨平台一致體驗**：Cowork、Claude Code、Antigravity 都能用
- **結構化記憶**：INDEX 索引層 + inbox 日記層 + memory 知識層 + 專案層，越舊顆粒度越粗
- **自動化交接**：Agent 換班時不掉球
- **個人知識庫**：URL → 抓取 → 摘要 → 存檔，自動橋接到相關專案
- **決策支援**：Debate 協議幫助重大決策
- **實戰驗證**：每日實際使用中迭代，已記錄 15 個踩坑和最佳實踐

## Skills 總覽

Skills 是模組化的行為套件，秘書按需載入。放在 `.claude/skills/`，Claude Code / Cowork 會自動發現。

### 核心 Skills（每次啟動）

| Skill | 功能 | 觸發方式 |
|---|---|---|
| **secretary** | 雙模式運作、記憶架構、整理節奏、INDEX 寫入分流、輸出控制 | 每次自動載入 |
| **review** | 兩階段收尾：專案經理收尾 → 秘書 Review（12 條檢查清單：經驗提煉 + 系統更新 + 記憶同步） | 說 **「收尾吧」** |
| **handoff** | 跨 session 和跨平台交接協議，確保零資訊遺失 | 自動載入；每次 session 結束執行 |

### 專案與知識 Skills

| Skill | 功能 | 觸發方式 |
|---|---|---|
| **project-setup** | 六步開案流程：背景 → 架構 → 研究 → Debate → 拍板 → 執行。含簡單/複雜專案分流邏輯 | 說 **「開新專案」** |
| **knowledge-base** | 個人知識管線：貼 URL → 自動抓取 → 摘要 → 存檔。支援文章和 YouTube。透過 `kb-digest` 橋接知識到專案 | 分享 **URL** 或說 **「存一下這個」** |
| **tool-scout** | 透過 MCP Registry、Plugin 商店、GitHub 探索工具。含資安評估清單 | 說 **「幫我找 X 的工具」** |
| **debate-protocol** | 高風險決策的多輪結構化辯論。Advocate vs Challenger，秘書主持 | **開案 Step 4** 觸發，或說 **「來辯論 X」** |

### 工具 SOP（可選，不用的可以刪）

| Skill | 功能 | 觸發方式 |
|---|---|---|
| **chrome-sop** | Chrome 瀏覽器自動化操作 SOP | 操作 **Chrome** 時載入 |
| **gcp-ops** | GCP VM 操作：SSH、防火牆、部署 | 使用 **GCP** 時載入 |
| **github-ops** | GitHub 操作：PAT 管理、clone/push、安全 | 使用 **GitHub** 時載入 |
| **subagent-guide** | 啟動和提示 Sub Agent 的最佳實踐 | 啟動 **Sub Agent** 時載入 |

> **自訂建議**：刪掉你不需要的工具 SOP Skill，核心系統不受影響。

## 快速開始

### 1. 複製檔案結構

```
your-project/
├── CLAUDE.md                          ← 全域入口（必須在根目錄）
├── .claude/
│   └── skills/
│       ├── secretary/SKILL.md         ← 秘書核心行為
│       ├── review/SKILL.md            ← 收尾 Review（12 條檢查清單）
│       ├── handoff/SKILL.md           ← 交接協議
│       ├── project-setup/SKILL.md     ← 六步開案流程
│       ├── knowledge-base/SKILL.md    ← 知識庫管線
│       ├── tool-scout/SKILL.md        ← 工具探索 + 資安
│       ├── chrome-sop/SKILL.md        ← [可選] Chrome SOP
│       ├── gcp-ops/SKILL.md           ← [可選] GCP SOP
│       ├── github-ops/SKILL.md        ← [可選] GitHub SOP
│       └── subagent-guide/SKILL.md    ← [可選] Sub Agent 指南
├── workspace/
│   ├── INDEX.md                       ← 主索引（專案清單、待辦）
│   ├── BEGINNER-TIPS.md               ← 新手提示
│   ├── inbox/                         ← 每日日記（自動建立）
│   ├── handoff/
│   │   ├── pending/                   ← 跨平台待辦交接
│   │   └── done/                      ← 已處理歸檔
│   ├── projects/
│   │   └── {name}/
│   │       ├── INDEX.md               ← 專案索引
│   │       ├── memory.md              ← 累積知識
│   │       ├── daily/                 ← 專案日報
│   │       ├── refs/                  ← 研究資料 + kb-digest
│   │       └── debates/               ← Debate 紀錄
│   ├── knowledge-base/
│   │   ├── articles/                  ← 存檔文章
│   │   ├── videos/                    ← 存檔影片
│   │   └── inbox/fetch-queue.md       ← 批次處理佇列
│   ├── summaries/
│   │   ├── weekly/                    ← 週報
│   │   └── monthly/                   ← 月報
│   └── refs/
│       ├── debate-agents/             ← Debate 協議 + 人設
│       └── security-checklist.md      ← 工具資安清單
├── docs/
│   ├── quickstart.md                  ← 快速開始指南
│   ├── faq.md                         ← FAQ（11 題）
│   └── lessons-learned.md             ← 15 個踩坑 + 最佳實踐
└── README.md                          ← 本檔
```

### 2. 自訂 CLAUDE.md

開啟 `CLAUDE.md`，修改：

- **身份描述**：把「AI 個人秘書」改成你想要的角色
- **模型預設**：根據你的方案調整（Max / Pro / 其他）
- **跨平台路徑**：改成你的實際路徑
- **Skills 索引**：刪掉你不需要的工具 SOP Skill

### 3. 自訂 secretary Skill

開啟 `.claude/skills/secretary/SKILL.md`，修改：

- **運作模式**：調整秘書模式 / 專案模式的行為描述
- **記憶架構**：調整資料夾結構（如果你的不一樣）
- **整理節奏**：改成你想要的 Review 頻率
- **工具偏好**：加入你的工具選擇決策

### 4. 建立 INDEX.md

在 `workspace/INDEX.md` 加入你的專案清單和待辦事項。格式參考範本中的範例，或看 `docs/quickstart.md`。

### 5. 啟動

在 Claude Code 或 Cowork 中開啟你的根目錄，Agent 會自動讀取 CLAUDE.md → 載入 secretary Skill → 偵測首次使用 → 執行設定精靈 → 進入秘書模式。

## 核心設計原則

### CLAUDE.md 是唯一入口

所有平台的 Agent 都從 CLAUDE.md 開始。Claude Code / Cowork 自動讀取；其他平台手動讀取。CLAUDE.md 放在根目錄，Skills 也放在根目錄的 `.claude/skills/`。

### Skills 取代手動讀取

秘書行為規則、Review 流程、交接協議、工具 SOP 都做成 Skill。Claude Code / Cowork 會自動發現和載入，不需要每次手動讀 SYSTEM.md。

### 記憶分層

| 層級 | 位置 | 更新頻率 | 讀取時機 |
|------|------|---------|--------|
| 索引層 | INDEX.md | 每次 session | 每個 Agent（必讀） |
| 事件層 | inbox/、projects/daily/ | 每次交接 | 需要時才讀 |
| 知識層 | projects/memory.md | 累積後寫 | 冷啟動讀 |
| 摘要層 | projects/refs/kb-digest.md | 存文章時 | 需要時才讀 |
| 歸納層 | summaries/weekly/、monthly/ | 每週/每月 | 需要時才讀 |

越舊顆粒度越粗，原始紀錄永遠保留。

### 跨平台交接用 handoff/

不要把跨平台任務混在 inbox/ 日記裡。獨立的 `handoff/pending/` → `handoff/done/` 佇列，檔名帶時間戳和摘要。詳見 `handoff` Skill。

### 知識橋接：kb-digest

存文章到知識庫時，秘書會自動將可行動摘要寫入相關專案的 `refs/kb-digest.md`。把「存了一篇有趣的文章」變成「這對專案 X 意味著什麼」。詳見 `knowledge-base` Skill。

### 決策支援：Debate 機制

高重要性的商業決策可以啟動 Debate，邀請 Advocate 和 Challenger 進行多輪交鋒。秘書主持、記錄共識 / 分歧 / 待決項。詳見 `workspace/refs/debate-agents/debate-protocol.md`。

## 新手入門

1. 讀 `docs/quickstart.md`（5 分鐘快速開始）
2. 讀 `workspace/BEGINNER-TIPS.md`（使用技巧）
3. 看 `docs/faq.md`（常見問題 11 題）
4. 遇到問題查 `docs/lessons-learned.md`（15 個踩坑紀錄）

## 版本歷史

### v0.4（2026-03-28）

**新增**：
- **knowledge-base Skill**：URL → 抓取 → 摘要 → 存檔管線，支援 YouTube，透過 kb-digest 自動橋接知識到專案
- **Skills 總覽段落**：README 新增完整功能列表和觸發方式指南（10 個 Skills）
- 5 條新踩坑紀錄（#11~#15）：Review 深度、知識橋接、檔案復原、搜尋覆蓋率、token 控制
- FAQ Q11：如何建立個人知識庫

**升級**：
- **review Skill**：單階段 → 兩階段（專案收尾 → 秘書 Review），12 條檢查清單（經驗提煉 + 系統更新 + 記憶同步），Review 等級判斷，git 自動存檔
- **secretary Skill**：每日 Review 節奏、每週文件更新檢查、跨平台表 6→12 項、專案模式退出指令
- Golden Rules 新增 3 條（提煉而非記錄、橋接知識到行動、控制輸出量）

### v0.3（2026-03-27）

**新增**：
- 新手設定精靈：自動偵測新用戶，4 步驟引導完成初始設定
- 輸出控制規則：預設 300 字回覆、範圍控制、多步驟防護

**改進**：
- 跨平台差異表修正

### v0.2（2026-03-25）

**新增**：
- 8 個新 Skills：project-setup、tool-scout、chrome-sop、gcp-ops、github-ops、subagent-guide、handoff、review
- 完整的 Debate 協議（debate-protocol.md + advocate/challenger 人設）
- 資安檢查清單（security-checklist.md）
- 三份文檔：quickstart、faq、lessons-learned
- 記憶寫回規則（memory.md 層級）
- 跨平台交接機制（handoff/）

**改進**：
- secretary Skill 增加記憶寫回規則和交接觸發規則
- CLAUDE.md 完整化，包含所有 Skills 索引
- INDEX.md 範本更詳細，加入新手提示

**移除**：
- SYSTEM.md 內容遷移至 Skills（不用再讀 SYSTEM.md）

### v0.1（初版）

基礎秘書系統，包含雙模式、記憶分層、INDEX 結構。

## 外部驗證

這套架構已獲得獨立驗證：
- **Anthropic 官方 Claude Code 指南**（23 頁，10 個部門實測）：確認「CLAUDE.md 越詳細，Claude 表現越好」
- **YC 的 Garry Tan** 開源 gstack（48 小時 7,700 GitHub Stars）：使用同樣的 Skills 角色分工模式

## 授權

自由使用、修改、分發。如果你做了有趣的改進，歡迎 PR 或告訴我們。

## 聯繫

有問題、建議、或踩坑想分享？
- 開 GitHub Issue
- 提交 PR
