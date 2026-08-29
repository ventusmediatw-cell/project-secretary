# §1 找候選 — 自我盤點詳細 SOP

> 來源：個人 AI-secretary 系統的實戰演進；本出貨版已去識別化（實名／內部代號 → 佔位符）。
> 來源：原 `skill-mining` SKILL（2026-05-28 由 workflow-mining 改名），2026-08-29 併入 `skill-ops` §1。

## 目錄

- **預設範圍** — 時間窗 / hard cap / 主題範圍
- **Phase 1 平行掃描** — 5 個 source 同時跑
- **Phase 2 Synthesis** — 篩選條件與推薦形式
- **Phase 3 硬停** — 本 SOP 最重要的一條
- **Phase 4** — 使用者圈選後才執行
- **反模式** — 5 條
- **為何這樣設計**

> **何時讀**：使用者要做自我盤點、或秘書察覺某段重複手工活 N≥2 時。SKILL.md §1 引用點是入口。

**核心原則：模型負責 discovery + shortlist，使用者負責拍板要建什麼。不要自己決定 high-confidence 就動手建。**

## 預設範圍

- **時間窗：14 天**（首跑建議；產出品質好再考慮拉到 30 天）
- **Hard cap**：shortlist 最多 5 個 skill 候選 + 1 個 automation 候選 + 不限數量的「延伸既有」建議
- **不限主題**：寫 code、研究、寫作、規劃、溝通、營運、分析、個人行政都算

使用者若指定不同範圍（例：「掃 30 天」「只看 KB 相關」），以使用者指定為準。

## Phase 1：平行掃描（5 個 subagent 同時跑）

五個 source 互相獨立，**必須平行**（單一訊息內發 5 個 Agent tool call）。主 agent 只做 synthesis，不要親自掃。

**subagent 類型用 `general-purpose`，不要用 `Explore`** — Explore 適合定位檔案 / grep symbol，這裡是 open-ended pattern mining，會 miss content。
🔴 **派 sub 必帶 `model` 且固定 opus**——省略＝繼承＝可能落 Fable＝違規。

**每個 subagent prompt 必須包含**：
- 明確 source 路徑（絕對路徑）+ 時間窗
- 明確排除條件（避免硬湊）
- 「誠實回報沒找到 ≥2 次重複 pattern」的退場條款
- 輸出字數上限（建議 600 字）+ 純 markdown 格式

五個 subagent 各自負責：

| # | source | 掃什麼 |
|---|---|---|
| 1 | `workspace/handoff/`（pending / done / done-archive-*）| 重複出現的「session 結束時做了什麼」pattern |
| 2 | `~/.claude/projects/<你的專案>/memory/`（MEMORY.md index + 各 feedback/project 檔）| 跨 session 重複出現的手工流程或踩坑 |
| 3 | `workspace/inbox/` + `docs/lessons-learned.md`（repo 根） | Claude Code 之外的重複工作 |
| 4 | `.claude/skills/`、`.claude/agents/`、`.claude/settings.json`（hooks）、`/schedule`、`/loop` | 既有覆蓋面，避免重複造輪 |
| 5 | upstream | 對每個 candidate 反查「官方有沒有現成的」 |

> 🔴 **source 3 僅作 discovery**，重要細節需回到對應活系統（檔案、git log、實際 skill）驗證。
> 🔴 **source 4 與 source 5 就是 SKILL.md §核心原則 1 的「先找既有」兩階段。**
> 同一次進來若 §2 也要跑 A.2，**共用這一次的結果、不重跑**。source 5 的來源清單與篩選門檻以 `tool-scout` SKILL Step 2–3 為準，本檔不複寫。

每個 subagent 回傳：找到的 candidate pattern + 引用具體檔名 + 日期 + 頻率估計。

## Phase 2：Synthesis（主 agent 做）

合併五個 source 的發現，去重，套入篩選條件。**只有同時滿足全部才進 shortlist**：

- 至少出現過兩次，或明顯會重複且重做成本高
- 有穩定的輸入、可重複的程序、明確的輸出或停止條件
- 能在速度、品質、一致性、可靠性上有實質改善
- 尚未被既有 skill / agent / automation 充分涵蓋（用 source 4 對照）
- **尚未被官方 plugin / skill / MCP 覆蓋**（用 source 5 對照）— 若上游有現成 → 進「Skip + 推薦官方版」分流，不打包自製

對每個進入 shortlist 的候選，標記推薦形式：

| 形式 | 落點 | 適合 |
|---|---|---|
| **Skill** | `.claude/skills/<name>/SKILL.md` | 可重用的 workflow 或 playbook |
| **Subagent** | `.claude/agents/<name>.md` | 有邊界的專家角色、可委派的調查任務 |
| **Automation** | `/schedule`、`/loop`、hooks | 排程檢查、報告、提醒、監控 |
| **延伸既有** | Edit 現有 SKILL.md | 加段落、調 frontmatter、補 trigger |
| **Skip** | — | 太一次性 / 模糊 / 敏感 / 證據不足。**仍要列出並註明為何 skip** |

## Phase 3：硬停在 shortlist，等使用者圈選

**這是本 SOP 最重要的一條：產完 shortlist 直接停，不要自己決定 high-confidence 就動手建。**

抄 `templates/shortlist-format.md` 起手 — **何時讀**：Phase 2 synthesis 完、要寫 shortlist 表格 + summary 時。

該範本含：主表格骨架 / Summary / Skip 清單 / 5 source 分項摘要 / 問使用者拍板段。

## Phase 4（使用者圈選後才執行）

依圈選的編號建立資產。**建 skill 走 SKILL.md §2 A→E**（不要在本 SOP 內就地建）。

- Skill → §2 A→E
- Subagent → 寫到 `.claude/agents/<name>.md`
- Automation → `/schedule` 或 `/loop`，或走 `update-config` skill 寫 hook
- 延伸既有 → 屬 §2.5，判小 patch 還是大改

完成後彙報：建立了什麼、刻意 skip 了什麼、哪些還需要更多證據。

## 反模式（不要做）

| ❌ | ✅ |
|---|---|
| 主 agent 親自掃 5 個 source | 平行派 5 個 subagent（context 爆炸 + 偏食）|
| Phase 3 不停、自己決定 high-confidence 就建 | 硬停等圈選 |
| Shortlist 超過 cap（5 skill + 1 automation）| 強迫排序才有篩選價值 |
| 引用 inbox / lessons 內容卻沒回活系統驗證 | 回檔案 / git log / 實際 skill 驗 |
| 建立 speculative、overlapping、範圍過大的資產 | — |

## 為何這樣設計

- **5 source 平行**：互相獨立，平行能省 context 且減偏食
- **Hard cap 5 skill**：已 30+ skills，**bloat 風險 > gap 風險**，cap 強迫排序
- **硬停在 shortlist**：autonomous 模式下「high-confidence」是模型主觀判斷，模型有「想做點事證明有用」偏見，把判斷權還給使用者
- **預設 14 天而非 30 天**：lessons + inbox 量大，14 天首跑品質較穩，產出好再拉長
