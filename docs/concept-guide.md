# Concept Guide — What This System Is and Why It Exists

> Read this before `quickstart.md`. Takes about 5 minutes.
> [繁體中文版 →](#繁體中文)

---

## The Problem

Every time you start a new conversation with an AI, you face three frustrations:

1. **It forgets.** Context windows have limits. Past a certain point, earlier parts of your conversation simply vanish.
2. **It makes things up.** Without access to *your* specific knowledge, the AI pulls answers from its general training — or worse, fabricates them.
3. **You repeat yourself.** Every new session, you re-explain your preferences, your workflows, your project context. That eats into the very context window that's already too short.

These seem like three separate problems. They're not.

**They all come from the same root: AI has no persistent, structured memory.**

---

## The Insight

If we could give AI a memory system — one that persists across sessions, organizes itself over time, and loads only what's relevant — all three problems disappear at once.

That's what this system does.

---

## The Metaphor

Imagine a brilliant colleague who wakes up every morning with complete amnesia.

They're smart, capable, and eager to help — but they remember nothing from yesterday. How do you make this person productive?

**Step 1 — A pocket card.**
A tiny note on the nightstand: "You are Alex. You work at Ventus. Read your journal."
This is **CLAUDE.md** — a boot file the AI reads first, every session.

**Step 2 — A journal.**
Every evening before "sleep," they write down what happened today. Every morning, they read it back.
This is the **inbox/** — daily logs that preserve what happened.

**Step 3 — A table of contents.**
After a year of journals, reading everything takes all day. So they write a one-page summary: active projects, current priorities, open questions.
This is **INDEX.md** — the master index, read every session, always current.

**Step 4 — A knowledge notebook.**
Some things aren't events — they're conclusions. "We chose Market A because of X." "This API returns data in format Y." These get written in a separate notebook.
This is **memory.md** — accumulated knowledge per project, read on deep dives.

**Step 5 — A skills manual.**
Recurring workflows get their own instruction cards: "How to do a weekly review." "How to launch a new project." Instead of re-explaining every time, just hand them the card.
These are **Skills** — modular behavior files that the AI loads on demand.

**Step 6 — Compression.**
Daily journals get summarized into weekly reports, then monthly reports. Older records get coarser-grained. The table of contents stays slim. Nothing is lost — it's just layered.
This is the **memory hierarchy** — INDEX → inbox → summaries → memory.

Now your amnesiac colleague can wake up, read their pocket card, scan the table of contents, pull the right notebook, and pick up exactly where they left off.

**That's this system.**

---

## How It Maps to Real Files

```
workspace/
├── CLAUDE.md                    ← The pocket card (boot file)
├── .claude/skills/              ← The skills manual
│   ├── secretary/SKILL.md       ← How to be your secretary
│   ├── review/SKILL.md          ← How to do wrap-up reviews
│   └── ...
├── INDEX.md                     ← The table of contents
├── inbox/                       ← The journal (daily logs)
├── projects/
│   └── {name}/
│       ├── INDEX.md             ← Project-level table of contents
│       ├── memory.md            ← The knowledge notebook
│       └── daily/               ← Project-specific journal
├── knowledge-base/              ← Articles, videos, compiled insights
└── summaries/                   ← Weekly / monthly compression
```

Everything is plain Markdown. You can read it. The AI can read it. Any AI model can read it. This is intentional — it means you're never locked into one platform.

---

## What Makes This Different

### "Can't I just use Claude Projects / ChatGPT memory?"

You can, and for simple use cases, you should. Here's when you outgrow them:

| Capability | Native Memory | This System |
|---|---|---|
| Remembers your preferences | ✅ | ✅ |
| Manages multiple projects in parallel | ❌ Single-project focus | ✅ Secretary has global awareness |
| Self-organizes over time | ❌ | ✅ Daily → weekly → monthly compression |
| Hands off work between sessions | ❌ Manual copy-paste | ✅ Structured handoff protocol |
| Works across different AI models | ❌ Platform-locked | ✅ All Markdown, any model reads it |
| Learns from mistakes | ❌ | ✅ 13-item review checklist, lessons-learned accumulation |
| Builds a personal knowledge base | ❌ | ✅ URL → summarize → synthesize → bridge to projects |

The key difference: **native AI memory is a notepad. This system is a filing cabinet with a librarian.**

### "Can't I just throw a bunch of files in a folder?"

You can. The difference is the *process* — not the files. This system defines:

- **When** to write and what to write (review checklist, handoff protocol)
- **Where** each type of information goes (INDEX for status, memory for knowledge, inbox for events)
- **How** old information gets compressed without being lost (weekly/monthly summaries)
- **Who** manages all of this (the secretary Skill — so you don't have to)

Without process, files become a graveyard. With process, they become institutional memory.

---

## What You Get

Once set up, you have an AI secretary that:

- **Wakes up knowing who it is** — reads CLAUDE.md, loads your preferences and rules
- **Knows what's happening** — scans INDEX.md for project status, priorities, and to-dos
- **Picks up where it left off** — reads handoff files from the last session
- **Manages multiple projects** — secretary mode for the big picture, project mode for deep focus
- **Gets smarter over time** — review checklist catches mistakes, knowledge base compounds, lessons accumulate
- **Works with any AI model** — swap Claude for GPT for Gemini, the memory stays

---

## Quick Answers

**How much does it cost?**
The AI subscription. For Claude, that's the Max plan (~$100/month) for the best experience with Opus. The Pro plan (~$20/month) works too with Sonnet. The files themselves are free — just Markdown on your computer. If you need 24/7 background tasks, a small cloud VM adds ~$5-10/month.

**Do I need to know how to code?**
No. Everything is written in natural language (Markdown). You edit text files, not code. The AI writes any code it needs by itself.

**Is it safe? Will the AI delete my files?**
The AI can modify files in its working directory. Best practices: (1) back up to a private GitHub repo, (2) review what the AI does before approving, (3) use a dedicated folder rather than your entire home directory. The author has been running this system daily for 3+ weeks. One file was accidentally deleted early on — git backup saved it. That lesson is now built into the system's safety guidelines.

**Can I use this with ChatGPT / Gemini / other models?**
Yes. The memory files are plain Markdown. Any model that can read files can use this system. Cross-model handoff is documented in the handoff Skill.

---

## Next Steps

Ready to try it?

1. **Read [`quickstart.md`](quickstart.md)** — 5 minutes to set up
2. **Read [`BEGINNER-TIPS.md`](BEGINNER-TIPS.md)** — practical usage tips
3. **Check [`faq.md`](faq.md)** — detailed answers to common questions

---

---

# 繁體中文

# 概念導讀 — 這套系統是什麼、為什麼需要它

> 在 `quickstart.md` 之前讀這份。約 5 分鐘。

---

## 問題

每次你跟 AI 開始新對話，都會遇到三個挫折：

1. **它會忘記。** Context window 有長度限制，超過就消失。
2. **它會亂講。** 沒有你的專屬資料，AI 只能從通用訓練裡撈，甚至直接編造。
3. **你要重複講。** 每次新 session，重新解釋你的偏好、工作流、專案背景。這又吃掉本來就不夠長的 context。

這看起來是三個問題。其實不是。

**根源只有一個：AI 沒有持久的、結構化的記憶。**

---

## 洞察

如果我們能給 AI 一套記憶系統——跨 session 持久、隨時間自動整理、只載入相關部分——三個問題同時消失。

這就是這套系統在做的事。

---

## 比喻

想像你有一個才華洋溢的同事，但他每天早上醒來都會完全失憶。

聰明、有能力、很想幫忙——但昨天的事完全不記得。你怎麼讓這個人有生產力？

**第一步——口袋小卡。**
床頭放一張小紙條：「你是阿昭。你在 Ventus 工作。先讀你的日記。」
這就是 **CLAUDE.md**——AI 每次 session 第一個讀的開機檔。

**第二步——日記。**
每天「睡前」寫下今天發生什麼事。每天早上讀回來。
這就是 **inbox/**——每日紀錄，保存發生過的事。

**第三步——目錄。**
寫了一年日記後，每天全部讀完就天黑了。所以寫一頁摘要：進行中的專案、當前優先事項、待解問題。
這就是 **INDEX.md**——主索引，每次 session 都讀，永遠保持最新。

**第四步——知識筆記本。**
有些東西不是事件，是結論。「我們選了市場 A 因為 X。」「這個 API 回傳格式是 Y。」這些寫在另一本筆記。
這就是 **memory.md**——每個專案的累積知識，深入工作時才讀。

**第五步——技能手冊。**
重複出現的工作流做成指令卡：「怎麼做週報」、「怎麼開新專案」。不用每次重新教，把卡片遞過去就好。
這就是 **Skills**——模組化的行為檔案，AI 按需載入。

**第六步——壓縮。**
日記彙整成週報，週報收斂成月報。越舊的紀錄顆粒度越粗。目錄保持精簡。什麼都不會丟——只是分層了。
這就是**記憶層級**——INDEX → inbox → summaries → memory。

現在你的失憶同事可以每天醒來，讀口袋小卡、掃目錄、拿出對的筆記本，精準接上昨天的進度。

**這就是這套系統。**

---

## 對應到真實檔案

```
workspace/
├── CLAUDE.md                    ← 口袋小卡（開機檔）
├── .claude/skills/              ← 技能手冊
│   ├── secretary/SKILL.md       ← 怎麼當你的秘書
│   ├── review/SKILL.md          ← 怎麼做收尾 Review
│   └── ...
├── INDEX.md                     ← 目錄（主索引）
├── inbox/                       ← 日記（每日紀錄）
├── projects/
│   └── {name}/
│       ├── INDEX.md             ← 專案級目錄
│       ├── memory.md            ← 知識筆記本
│       └── daily/               ← 專案日記
├── knowledge-base/              ← 文章、影片、編譯洞察
└── summaries/                   ← 每週/每月壓縮
```

全部都是純 Markdown。你看得懂，AI 看得懂，任何 AI 模型都看得懂。這是刻意的——代表你永遠不會被鎖在某一個平台。

---

## 跟其他方案有什麼不同

### 「用 Claude Projects / ChatGPT 記憶不就好了？」

可以，簡單場景應該用。以下是你會長大到需要這套系統的時候：

| 能力 | 原生記憶 | 這套系統 |
|------|---------|---------|
| 記住你的偏好 | ✅ | ✅ |
| 平行管理多個專案 | ❌ 單一專案視角 | ✅ 秘書有全局觀 |
| 隨時間自動整理 | ❌ | ✅ 日→週→月壓縮 |
| 跨 session 無縫交接 | ❌ 手動複製貼上 | ✅ 結構化交接協議 |
| 跨 AI 模型使用 | ❌ 鎖平台 | ✅ 全 Markdown，任何模型都能讀 |
| 從錯誤中學習 | ❌ | ✅ 13 條 Review 清單 + 踩坑累積 |
| 建立個人知識庫 | ❌ | ✅ URL → 摘要 → 編譯 → 橋接到專案 |

核心區別：**原生記憶是便條紙。這套系統是帶館員的圖書館。**

### 「我自己丟一堆檔案在資料夾裡不行嗎？」

行。差別在於**流程**，不是檔案。這套系統定義了：

- **什麼時候**寫、寫什麼（Review 清單、交接協議）
- **什麼東西**放哪裡（INDEX 放狀態、memory 放知識、inbox 放事件）
- **舊的資訊**怎麼壓縮而不遺失（週報/月報）
- **誰來管**這些事（secretary Skill——所以你不用自己管）

沒有流程，檔案變墳場。有了流程，檔案變組織記憶。

---

## 你會得到什麼

設定好之後，你有一個 AI 秘書：

- **醒來就知道自己是誰**——讀 CLAUDE.md，載入你的偏好和規則
- **知道正在發生什麼**——掃 INDEX.md 看專案狀態、優先事項、待辦
- **接上上次的進度**——讀上個 session 的交接檔案
- **管理多個專案**——秘書模式看全局、專案模式深入專注
- **隨時間變聰明**——Review 清單抓錯、知識庫累積、踩坑經驗疊加
- **用任何 AI 模型**——換 Claude 換 GPT 換 Gemini，記憶不動

---

## 快問快答

**要花多少錢？**
AI 訂閱費。以 Claude 來說，Max plan 約 $100/月（用 Opus 最佳體驗），Pro plan 約 $20/月（用 Sonnet 也能跑）。檔案本身免費——就是你電腦上的 Markdown。如果需要 24/7 背景任務（例如定時爬資料），一台小型雲端 VM 約 $5-10/月。

**需要會寫程式嗎？**
不需要。所有東西都是自然語言（Markdown）。你編輯的是文字檔，不是程式碼。AI 需要寫的程式它自己會寫。

**安全嗎？AI 會不會刪我的檔案？**
AI 可以修改它工作目錄裡的檔案。最佳實踐：(1) 備份到 GitHub private repo，(2) 核准前先看 AI 在做什麼，(3) 用專用資料夾，不要掛整個家目錄。作者已經每天使用這套系統超過三週。早期有一次檔案被意外刪除——靠 git 備份救回。這個教訓已經寫進系統的安全指引。

**可以用 ChatGPT / Gemini / 其他模型嗎？**
可以。記憶檔案都是純 Markdown，任何能讀檔案的模型都能用。跨模型交接有文件（見 handoff Skill）。

---

## 下一步

準備好了？

1. **讀 [`quickstart.md`](quickstart.md)**——5 分鐘完成設定
2. **讀 [`BEGINNER-TIPS.md`](BEGINNER-TIPS.md)**——實用操作技巧
3. **看 [`faq.md`](faq.md)**——常見問題詳細解答
