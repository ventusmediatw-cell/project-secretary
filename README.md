# AI Personal Secretary — Template v0.2

> An AI personal secretary system template built on Claude Code / Cowork.
> Fork it, tweak a few parameters, and you're good to go.

[繁體中文版 →](#繁體中文)

## What is This

A system architecture that turns an AI Agent into your personal secretary, featuring:

- **Dual-mode operation**: Secretary mode (global management) + Project mode (focused execution)
- **Cross-platform consistency**: Works on Cowork, Claude Code, and Antigravity
- **Structured memory**: INDEX index layer + inbox journal layer + memory knowledge layer + project layer — older records get coarser-grained
- **Automated handoff**: No dropped balls when Agents switch shifts
- **On-demand tool SOPs**: Only load when needed, saving tokens
- **Decision support**: Debate protocol for high-stakes decisions

## Quick Start

### 1. Copy the File Structure

```
your-project/
├── CLAUDE.md                          ← Global entry point (must be in root)
├── .claude/
│   └── skills/
│       ├── secretary/SKILL.md         ← Core secretary behavior (modes, memory, cleanup)
│       ├── review/SKILL.md            ← Wrap-up Review flow
│       ├── handoff/SKILL.md           ← Handoff protocol
│       ├── project-setup/SKILL.md     ← Six-step project launch flow
│       ├── tool-scout/SKILL.md        ← Tool discovery and security assessment
│       ├── chrome-sop/SKILL.md        ← [Optional] Chrome browser SOP
│       ├── gcp-ops/SKILL.md           ← [Optional] GCP operations SOP
│       ├── github-ops/SKILL.md        ← [Optional] GitHub operations SOP
│       └── subagent-guide/SKILL.md    ← [Optional] Sub Agent guide
├── workspace/
│   ├── INDEX.md                       ← Main index (project list, to-dos, recent priorities)
│   ├── BEGINNER-TIPS.md               ← Beginner tips
│   ├── inbox/                         ← Secretary-level daily journals (auto-created)
│   ├── handoff/
│   │   ├── pending/                   ← Cross-platform pending handoffs
│   │   └── done/                      ← Processed archive
│   ├── projects/
│   │   └── {category}/{name}/
│   │       ├── INDEX.md               ← Project index
│   │       ├── memory.md              ← Accumulated knowledge (created later)
│   │       ├── daily/                 ← Project daily reports
│   │       ├── refs/                  ← Project research materials
│   │       └── debates/               ← Debate transcripts
│   ├── summaries/
│   │   ├── weekly/                    ← Weekly reports
│   │   └── monthly/                   ← Monthly reports
│   └── refs/
│       ├── debate-agents/
│       │   ├── debate-protocol.md     ← Debate protocol
│       │   ├── advocate.persona.md    ← Advocate persona
│       │   └── challenger.persona.md  ← Challenger persona
│       └── security-checklist.md      ← Tool security assessment checklist
├── docs/
│   ├── quickstart.md                  ← Quick start guide
│   ├── faq.md                         ← FAQ
│   └── lessons-learned.md             ← Pitfalls and best practices
└── README.md                          ← This file
```

### 2. Customize CLAUDE.md

Open `CLAUDE.md` and modify:

- **Identity**: Change "AI personal secretary" to your desired role
- **Model default**: Adjust based on your plan (Max / Pro / other)
- **Cross-platform paths**: Set to your actual paths (`【Your folder】`)
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

Open your root directory in Claude Code or Cowork. The Agent will auto-read CLAUDE.md → load secretary Skill → read INDEX.md → enter secretary mode.

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
| Summaries | summaries/weekly/, monthly/ | Weekly/Monthly | On demand |

Older records get coarser-grained; raw records are preserved forever.

### Cross-Platform Handoff via handoff/

Don't mix cross-platform tasks into inbox/ journals. Use the dedicated `handoff/pending/` → `handoff/done/` queue, with timestamped filenames and summaries. See `handoff` Skill for details.

### Decision Support: Debate Mechanism

High-stakes business decisions can trigger a Debate — inviting an Advocate and Challenger for multi-round exchanges. The secretary moderates, recording consensus / disagreements / pending items. See `workspace/refs/debate-agents/debate-protocol.md`.

## Getting Started

1. Read `docs/quickstart.md` (5-minute quick start)
2. Read `workspace/BEGINNER-TIPS.md` (usage tips)
3. Check `docs/faq.md` (common questions)
4. Look up `docs/lessons-learned.md` when you hit issues (pitfalls)

## Version History

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

This system was battle-tested through iteration. Here are the pitfalls we hit:

1. **CLAUDE.md and Skills must be at the same level**: Skills go in `.claude/skills/` at the root, same level as CLAUDE.md. Placing them in subdirectories only enables dynamic discovery, not auto-loading at startup.

2. **Update CLAUDE.md incrementally**: Every time you build a Skill, update the CLAUDE.md index immediately. Don't wait until everything is done, or new Skills become dead ends.

3. **Check for native features before building custom**: AI tools ship new features every few weeks. Before writing infrastructure, search whether the platform already supports it natively.

4. **Tag verification status on cross-session technical conclusions**: `✅ Verified` / `⚠️ Speculative`. The next Agent shouldn't blindly trust predecessors.

5. **Timestamps are mandatory in handoff reports**: Run `date` for time. Never use vague terms like "evening" or "afternoon."

6. **Debate needs word limits**: Opening 200-300 words, exchanges 100-150 words, max 3 topics. Otherwise length spirals and decisions get muddier.

7. **Memory layering is critical**: Mixing everything becomes a junk pile. memory.md (knowledge) vs INDEX.md (status) vs daily/ (events) — each has its own role.

See `docs/lessons-learned.md` for the full list.

## License

Free to use, modify, and distribute. If you make interesting improvements, PRs welcome.

## Contact

Questions, suggestions, or pitfalls to share?
- Open a GitHub Issue
- Submit a PR

---

---

# 繁體中文

# AI 個人秘書 — 模板 v0.2

> 一套基於 Claude Code / Cowork 的 AI 個人秘書系統模板。
> Fork 後改幾個參數就能跑。

## 這是什麼

一套讓 AI Agent 扮演你的個人秘書的系統架構，支援：

- **雙模式運作**：秘書模式（全局管理）+ 專案模式（專注推進）
- **跨平台一致體驗**：Cowork、Claude Code、Antigravity 都能用
- **結構化記憶**：INDEX 索引層 + inbox 日記層 + memory 知識層 + 專案層，越舊顆粒度越粗
- **自動化交接**：Agent 換班時不掉球
- **工具 SOP 按需載入**：不浪費 token，用到才讀
- **決策支援**：Debate 協議幫助重大決策

## 快速開始

### 1. 複製檔案結構

```
your-project/
├── CLAUDE.md                          ← 全域入口（必須在根目錄）
├── .claude/
│   └── skills/
│       ├── secretary/SKILL.md         ← 秘書核心行為（模式、記憶、整理）
│       ├── review/SKILL.md            ← 收尾 Review 流程
│       ├── handoff/SKILL.md           ← 交接協議
│       ├── project-setup/SKILL.md     ← 專案開案六步流程
│       ├── tool-scout/SKILL.md        ← 工具探索和資安評估
│       ├── chrome-sop/SKILL.md        ← [可選] Chrome 操作 SOP
│       ├── gcp-ops/SKILL.md           ← [可選] GCP 操作 SOP
│       ├── github-ops/SKILL.md        ← [可選] GitHub 操作 SOP
│       └── subagent-guide/SKILL.md    ← [可選] Sub Agent 指南
├── workspace/
│   ├── INDEX.md                       ← 主索引（專案清單、待辦、近期重點）
│   ├── BEGINNER-TIPS.md               ← 新手提示（使用技巧）
│   ├── inbox/                         ← 秘書層級每日日記（自動建立）
│   ├── handoff/
│   │   ├── pending/                   ← 跨平台待辦交接
│   │   └── done/                      ← 已處理歸檔
│   ├── projects/
│   │   └── {category}/{name}/
│   │       ├── INDEX.md               ← 專案索引
│   │       ├── memory.md              ← 累積知識（後期建立）
│   │       ├── daily/                 ← 專案日報
│   │       ├── refs/                  ← 專案研究資料
│   │       └── debates/               ← Debate 對話紀錄
│   ├── summaries/
│   │   ├── weekly/                    ← 週報
│   │   └── monthly/                   ← 月報
│   └── refs/
│       ├── debate-agents/
│       │   ├── debate-protocol.md     ← Debate 辯論協議
│       │   ├── advocate.persona.md    ← Advocate 人設
│       │   └── challenger.persona.md  ← Challenger 人設
│       └── security-checklist.md      ← 工具資安檢查清單
├── docs/
│   ├── quickstart.md                  ← 快速開始指南
│   ├── faq.md                         ← 常見問題
│   └── lessons-learned.md             ← 踩坑紀錄和最佳實踐
└── README.md                          ← 本檔
```

### 2. 自訂 CLAUDE.md

開啟 `CLAUDE.md`，修改：

- **身份描述**：把「AI 個人秘書」改成你想要的角色
- **模型預設**：根據你的方案調整（Max / Pro / 其他）
- **跨平台路徑**：改成你的實際路徑（`【你的資料夾】`）
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

在 Claude Code 或 Cowork 中開啟你的根目錄，Agent 會自動讀取 CLAUDE.md → 載入 secretary Skill → 讀取 INDEX.md，進入秘書模式。

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
| 歸納層 | summaries/weekly/、monthly/ | 每週/每月 | 需要時才讀 |

越舊顆粒度越粗，原始紀錄永遠保留。

### 跨平台交接用 handoff/

不要把跨平台任務混在 inbox/ 日記裡。獨立的 `handoff/pending/` → `handoff/done/` 佇列，檔名帶時間戳和摘要。詳見 `handoff` Skill。

### 決策支援：Debate 機制

高重要性的商業決策可以啟動 Debate，邀請 Advocate 和 Challenger 進行多輪交鋒。秘書主持、記錄共識 / 分歧 / 待決項。詳見 `workspace/refs/debate-agents/debate-protocol.md`。

## 新手入門

1. 讀 `docs/quickstart.md`（5 分鐘快速開始）
2. 讀 `workspace/BEGINNER-TIPS.md`（使用技巧）
3. 看 `docs/faq.md`（常見問題）
4. 遇到問題查 `docs/lessons-learned.md`（踩坑紀錄）

## 版本歷史

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

## 授權

自由使用、修改、分發。如果你做了有趣的改進，歡迎 PR 或告訴我們。
