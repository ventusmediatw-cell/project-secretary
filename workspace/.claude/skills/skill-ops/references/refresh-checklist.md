# §5 巡全部 — 排程維護詳細 SOP

> 來源：個人 AI-secretary 系統的實戰演進；本出貨版已去識別化（實名／內部代號 → 佔位符）。
> ⚠️ **隨貨註記**：主動面 hook 隨附於本 repo `extras/claude-code/scripts/startup_skillops_nudge.sh`，安裝步驟見該目錄 README。文中 `~/.claude/` 路徑為原系統掛點示例，公開版對應 `workspace/.claude/`。
> 來源：原 `skill-refresh` SKILL，2026-08-29 併入 `skill-ops` §5。

## 目錄

- **§5.1 Local drift** — 對全 portfolio 逐支跑量化指標
- **§5.2 Upstream drift** — 官方 spec / plugin 版本對標（雙模式）
- **§5.3 排程節奏** — 週 / 月 / ad-hoc
- **§5.4 跨平台**

> **何時讀**：週日 / 月底排程觸發、官方升版、或使用者說「全 skill 體檢」時。SKILL.md §5 引用點是入口。

## 定位

**§4 是一支的深度 audit（trigger 觸發），§5 是全部的量化巡檢（排程）。**

🔴 **六項指標與閾值的單一真相源＝本檔 §5.1**；「觸發頻率」的查法與 `audit-checklist.md` Tier 3 共用同一把尺、不得互相漂移。
本檔另負責兩件 §4 沒有的事：**排程節奏** ＋ **upstream drift 偵測**。

## 核心原則

1. **量性、不靠手感** — 每個指標都有明確閾值；不寫「最近好像沒在用」這種 soft
2. **propose-only** — 只列 retrofit shortlist、不擅自改 SKILL；user 拍板才動（同 SKILL.md §核心原則 8）
3. **跳過 not halt** — 單一 SKILL 檢查失敗（如 WebFetch 官方版本失敗）→ skip + 寫 lesson + 繼續下一支
4. **不重複 audit 邏輯** — anatomy / boundary / 健康度 metric 全部走 §3 / §4，本檔只管排程 + drift

## §5.1 Local drift（對全 portfolio 逐支跑）

對每支 `.claude/skills/*/SKILL.md` 跑 **§4 Tier 3 的指標**，套下列閾值：

| 指標 | 黃旗 | 紅旗 | 來源 |
|---|---|---|---|
| **mtime 老化** | > 60 天未動 | > 120 天未動 | `stat -f %m` |
| **觸發頻率**（過去 30 天）| ≤ 2 次 | 0 次 | 掃 transcript（查法見下）|
| **應觸發未觸發** | 1 次 | ≥ 2 次 | grep inbox 「忘記用 X」「沒走 X」 |
| **Lesson 累積**（SKILL 內未消化 lesson 引用）| ≥ 3 條 | ≥ 5 條 | grep `L#####` 在 SKILL.md |
| **引用斷鏈**（SKILL 提到的路徑是否還存在）| 1 條 | ≥ 2 條 | 路徑逐一 `ls` 驗證 |
| **required-skills 覆蓋率**（`workspace/projects/*/INDEX.md` 首行）| < 100%（列缺漏）| 缺漏 ≥ 3 案 | `head -1` 掃描 |

> **觸發頻率查法（2026-08-28 user 裁換尺）**：掃 transcript 的**顯式 skill 呼叫**，**不用 inbox/handoff**——
> 不寫 inbox 的 SKILL 在舊尺下永遠 0 次紅旗、卻從沒被 surface 過。
> ```bash
> cd ~/.claude/projects/<你的專案目錄> && find . -name '*.jsonl' -mtime -30 \
>   | xargs grep -l '"skill":"<name>"' | wc -l
> ```
> 量的是「30 天內出現顯式呼叫的 transcript 數」；**寫查法不寫死數字**——次數逐日變動，寫死當天就過期。

> 🔴 **量測工具壞掉時「零使用」是假結論**：跑之前先確認每個 source 路徑真的存在（`ls`）。
> grep 不存在的目錄會回 0 且不報錯，而 0 在本表＝紅旗＝建議退場。

**處置**：任何紅旗 → retrofit shortlist top section、需 user 拍板。2+ 黃旗 → mid section，優先級照 SKILL.md §核心原則 8 的公式排。

## §5.2 Upstream drift（雙模式）

> **孿生機制**：同時 cover (a) 既有 SKILL 對標官方升版 + (b) build 新 skill 前的 upstream check。兩者共用對標來源、差別在觸發時機。

**對標來源**：
- `anthropics/skills` GitHub repo（官方 skill 數會變，**用 `marketplace.json` 的 `plugins` 陣列現數、別抄本檔**）
- 官方 plugin marketplace（**用其 manifest 現數、別抄本檔**）
- `agentskills.io/specification`（spec 變更）
- MCP Registry / GitHub 高星 repo（補充 upstream signal）

**模式 A：每月排程 — existing SKILL drift 對標**
- WebFetch GitHub commits 看有沒有新 skill / 新版 spec
- 對比本地對應 SKILL
- 官方有相應更新 → 評估 retrofit ROI

**模式 A2：每月排程 — 社群競品 refresh**
- 對象：**top-N 常用 SKILL**（N=5、按 §5.1 觸發頻率選；非全 portfolio——控成本）
- 每支過 `tool-scout` 跑一輪**社群面**搜尋（來源清單以該 SKILL 為準，本檔不複寫；關鍵詞＝該 skill 的**領域詞而非 skill 名**）——問的不是「官方有沒有同名品」而是「這個領域社群有沒有更強的做法可抄」
- 產出：可抄的做法 → retrofit shortlist；無發現 → inbox 一行存目，**不寫報告**
- 成本閘：每支 ≤ 3 次 WebSearch；全程唯讀、不 install（install 要 user 拍板）

**模式 B：build-time trigger — 防白做工**
- 觸發：build 新 skill 之前、§1 抓到 candidate 之後
- 過 `tool-scout` 跑一輪 → 找到官方對應則 install + 評估 / 小改、放棄自製；沒找到才走 §2 A→E
- 🔴 **這與 SKILL.md §核心原則 1 的 upstream 掃描、§1 Phase 1 source 5 是同一個動作。同一次進來只跑一次。**

**已採用的官方資產（2026-06-27 登記）**：`claude-code-setup`（官方 plugin marketplace 上架、read-only 掃 codebase 推薦 hook/subagent/MCP/skill/command）＝本系統「專案基建推薦」採用的官方引擎，由 `project-setup` 分支 C 觸發。monthly upstream check 一併看它升版。同理 `claude-md-management`（**會改檔非 read-only**）與 `wrap-up` §B 窄重疊 → 只 watch、不取代。

## §5.3 排程節奏

| 節奏 | 內容 | 落點 |
|---|---|---|
| **每週日晚** | §5.1 Local drift（全 portfolio）| `inbox/{週日}.md` § Skill Ops weekly |
| **每月最後週日** | §5.1 + §5.2 Full audit + 模式 A2 社群競品（top-5）| `inbox/{月底}.md` § Skill Ops monthly |
| **官方升版主動 trigger** | §5.2 Upstream-only check | `inbox/{當日}.md` ad-hoc |
| **user 手動觸發** | full + ad-hoc 都可 | 當日 inbox |

### 排程實作狀態（2026-08-29 掛上）

**機制：SessionStart hook 提醒制**，不是自動執行。

| 元件 | 內容 |
|---|---|
| 腳本 | `extras/claude-code/scripts/startup_skillops_nudge.sh` |
| 掛點 | `workspace/.claude/settings.local.json` → `hooks.SessionStart`（與 `startup_link_check` 並列）|
| 水位檔 | `.claude/.last-skillops-sweep`（workspace 相對；內容＝上次跑本 § 的日期 `YYYY-MM-DD`）|
| 每日 gate | `.claude/.last-skillops-nudge-run`（一天只提一次）|
| 閾值 | ≥ 7 天 → 溫和提醒；≥ 30 天 → 🔴 升級措辭（因已超過 §5.1「30 天 0 次觸發」的偵測窗）|

🔴 **刻意只做「提醒」不做「自動檢查」**——對齊 2026-08-28 user 裁「不建自動化 script」。
腳本不算指標、不下判斷，只讀水位、報天數。**§5.1 的六個指標仍是手動跑。**

> **why 選這個機制**（照 memory `reference_claude_code_scheduling` 三選一）：
> - ❌ **Cloud routine**：無本機檔案存取，而 §5.1 要掃 `.claude/skills/*/SKILL.md` 的 mtime 與 transcript → 出局
> - ⚠️ **桌面 scheduled task**：要 Mac 醒著 + App 開著，memory 已記其為 `daily-secretary-review` cadence 不穩的根因
> - ✅ **SessionStart hook**：每次開 session 必跑、有現成兩支同型 pattern 可抄。代價＝Cowork 端不觸發（無 hooks），Cowork 走行為規則
>
> **根因**：2026-08-29 實測，原 `skill-refresh` 全機 transcript **0 次顯式呼叫**、最近提及 2026-06-30（60 天前）。
> 那個 0 不是「不需要」，是**沒有東西會主動叫它**——user 原話：「沒人建議我跑這個，外加我不知道要怎麼啟動」。
> 排程型 SOP 沒有主動面就等於不存在。

**跑完務必寫水位**，否則下次還是會提醒：
```bash
date +%Y-%m-%d > .claude/.last-skillops-sweep
```

## §5.4 跨平台

- **Claude Code**：完整權限、可跑 cron、可 WebFetch、可改 inbox
- **Cowork**：可讀 SKILL.md、可寫 inbox、**不可 cron**
- **Antigravity Gemini**：可讀 SKILL.md 邏輯，跑檢查需透過 file scan + WebFetch

## §5.5 配套

- `scripts/check_entry_superset.py` — 入口 superset 不變式檢查（入口對本體的描述必須是子集、禁止增添）
- §5.1 量化指標＝**手動跑**；§5.2 upstream 對標＝**手動 WebFetch**
- 2026-08-28 user 裁：**不建自動化 script**（手動跑 cost 實測 > 30 min/週再議）

> **閾值 caveat**：§5.1 黃旗 60 天 / 紅旗 120 天目前是 N=0 estimate、需要 N=2 dogfood 校準。跑時若 shortlist 全綠 / 全是 false positive → 回頭調閾值。
