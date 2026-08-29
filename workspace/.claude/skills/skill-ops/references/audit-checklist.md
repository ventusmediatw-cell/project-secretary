# Audit 既有 skill — Benny 4 Tier 詳細程序

> ⚠️ **隨貨註記**：本檔中 `workspace/inbox/`、`workspace/handoff/`、lessons 檔等路徑為原系統的工作紀錄落點**示例**——換成你自己的紀錄落點。
> 來源：個人 AI-secretary 系統的實戰演進；本出貨版已去識別化（實名／內部代號 → 佔位符）。

> 來源：Benny pm-workflow-teaching A · skillset-audit + 本系統「對外部 audit 也要驗 source-of-truth」教訓
> 重要前置（本系統教訓）：對外部 audit 也要驗證 source-of-truth、不照單全收

## 目錄

- **觸發**：何時跑 audit
- **Tier 1: anatomy 對照**（最便宜）— frontmatter / body / 結構 / 跨平台檢查
- **Tier 2: boundary 與重複** — 與其他 18+ SKILL 比對
- **Tier 3: 實際使用驗證**（最重要）— 證據 / 評估 / 警示模式
- **Tier 4: retrofit 排序** — (impact × frequency) / cost
- **7 條 agent 硬規則** — 執行 audit 時嚴守
- **對外部 audit 的驗證機制** — 對齊 5/25 ASSESSMENT 教訓
- **輸出格式** — → 抄 `templates/audit-report.md`（拆出範本）

> **何時讀**：使用者要 audit 既有 skill、或本份報告要走 Tier 1-4 時。SKILL.md §4 引用點是入口。

## 觸發

- 使用者說：「audit 我的 skill / skillset-audit / 跑一次 skill 體檢」
- 秘書察覺：N=3+ 觀察期到期、需要評估 SKILL 該升 / 該退 / 該整併
- 官方 spec 出更新（agentskills.io / anthropics/skills）、需評估本地是否漂移

## 4 Tier 程序（必須依序、不可跳）

### Tier 1：anatomy 對照（最便宜）

> 🔒 **前置閘**：被檢 SKILL.md 標題後第一行為 `> 🔒 **外來原樣保留**：<來源>` 者，**Tier 1 整層跳過**（只確認 `name` / `description` 兩格），直接進 Tier 2。判準與範圍見 SKILL.md §3。

對 `templates/anatomy-checklist.md` 全表跑一遍（入口在 SKILL.md §3）：

**Frontmatter**
- [ ] `name` kebab-case？
- [ ] `description` 含 WHAT + WHEN？third-person？1024 字元內？
- [ ] 是否該加 `license`（對外輸出用）？

**Body 結構**
- [ ] < 500 行？
- [ ] 觸發語句明文？
- [ ] 做什麼 / 不做什麼 / 何時不觸發？
- [ ] 硬規則 vs soft 區分清楚？
- [ ] references/ 引用的檔案全部存在？

**檔案分布**
- [ ] 短的 inline、大的 isolate references/、scripts/ 有沒有 fold？

**輸出**：每支 SKILL 的 ❌ 項目清單，含對應 ✅ 範例（取 anthropics/skills 17 個其中一個示範）

### Tier 2：boundary 與重複

跟其他 18+ SKILL 比對：
- **觸發重疊**：「使用者說 X 時觸發」有沒有兩支以上 SKILL 都會搶？
- **做什麼衝突**：兩支 SKILL 都宣稱「處理 Y」？
- **互補/取代關係**：兩支 SKILL 該合成一支？該明文寫互不取代邊界？

**輸出**：boundary 衝突矩陣（哪兩支衝突、衝突點是什麼、建議處置）

### Tier 3：實際使用驗證（最重要）

對齊 Benny 規則 1「只看證據、不推測」：

#### 證據來源
- `workspace/inbox/` 過去 30 天：grep 「使用 X SKILL」「跑 X SKILL」「X SKILL 觸發」
- `workspace/handoff/` 過去 30 天：grep skill 名稱
- `docs/lessons-learned.md`（repo 根、workspace 的上一層）全期：grep skill 名稱 + 觀察候選

> 🔴 **觸發頻率查主尺（2026-08-28 user 裁換；§5 巡全部共用同一把尺）**：掃 transcript 的**顯式 skill 呼叫**（`~/.claude/projects/*/*.jsonl` 內 `tool_use` name=`Skill` 且 `input.skill==<name>`），**不用 inbox/handoff**——不寫 inbox 的 SKILL 在舊尺下永遠 0 次、是假紅旗。上列三個來源降為輔助佐證，不單獨用來判 N=0。
> ```bash
> # 30 天窗；同時算「顯式呼叫」與「分佈天數」
> find ~/.claude/projects -name '*.jsonl' -mtime -30 | xargs grep -l '"skill":"<name>"' 2>/dev/null | wc -l
> ```
> ⚠️ **寫查法、不寫死數字**（對齊 §5）——對照組次數會逐日變動，寫死當天就過期。

#### 評估
- **觸發頻率**：過去 30 天觸發過幾次？
- **規則 follow ratio**：觸發後實際照 SKILL 規則做的 ratio
- **應觸發未觸發**：grep 看有沒有「忘記用 SKILL」「沒走 SKILL」這類自我糾正
- **觸發成功 vs 失敗**：成功定義 = 達 SKILL 宣稱的輸出 / 失敗 = 中途繞過 / 改規則

#### 警示模式
- **N=0 觸發**：SKILL 30 天沒被觸發 → 候選退場
- **觸發但 ratio 低**：SKILL 觸發但實際只 follow 30% → 規則寫過頭 / 規則漂移
- **應觸發未觸發 N≥2**：SKILL 該觸發但 agent 沒走 → 觸發語句不對

**輸出**：每支 SKILL 的使用度報告 + 警示模式

### Tier 4：retrofit 排序

對所有 finding 排優先級：

#### 三項分數（Benny 規則 7）
- **impact**（1-5）：不修這個會發生什麼壞事
- **frequency**（1-5）：這個壞事多常發生
- **cost**（1-5）：修需要多少 token / 多少 session

#### 排序公式
`priority = (impact × frequency) / cost`

#### 排序輸出
排序表（top 10 finding）+ 每個 finding 對應的 retrofit action plan（要動哪個檔、估計工作量、是否需要 user 拍板）

#### N=1 觀察 / N=2 才動 原則
- N=1 finding（單次觀察到）→ 寫進 lessons、不動 SKILL
- N=2+ finding（跨 session 重複）→ 開動

## Audit 7 條 agent 硬規則（執行 audit 時嚴守）

1. **只看證據、不推測**：過去 inbox + handoff = 證據；沒看到的 = 沒發生、不腦補
2. **抓三種過擬合**：
   - (a) 為單一 session 寫的規則沒去掉
   - (b) 使用者一次性偏好寫成永久規則
   - (c) 規則彼此衝突沒抓
3. **抓一種倖存者偏差**：只看到 skill 觸發成功的、沒抓觸發失敗 / 該觸發沒觸發
4. **只能 propose，不能 dispatch 改檔**：user 拍板、agent 不動既有 SKILL
5. **不准超 500 行 audit 報告**：超 500 行 = 過度發散、強制精簡
6. **每條 finding 必須附證據檔名 + 日期**：「inbox/2026-05-24.md §14:23 觸發 X SKILL 但繞過規則」這種具體
7. **retrofit 排序明文 (impact × frequency) / cost 三項分數**

## 對外部 audit 的驗證機制

對齊本系統「外部 review 先驗對象」教訓：

外部 agent 對 SKILL 體系做 audit 時、**必先驗證指控針對「散播模板」還是「作者活系統」**。常見三 class verified pattern：
- 報告失真（claim 缺失但實際存在）— 通常 review agent 沒看到該檔
- 真缺（claim 缺失、實際真不存在）— 直接補
- 歷史 drift（claim 數字不一致、實為 stale 記錄）— 對齊真相源

**處置**：照單全收 = 危險；逐項 verify against live system 後分流 P0/P1/P2/P3。

## 輸出格式（500 行內）

抄 `templates/audit-report.md` 起手 — **何時讀**：執行 Tier 4 retrofit 排序完、要寫 audit report 時。

該 template 含：TL;DR / Tier 1-4 表格骨架 / 對 user 的 propose / Memory + Lessons / 外部 review 驗證機制。cp 該 template → 填入實際數據 → ship 為 inbox 或 handoff/pending/ 一份檔。
