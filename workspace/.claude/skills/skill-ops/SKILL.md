---
name: skill-ops
description: "skill 生態的單一入口 — 進來先分三條路：①找候選（掃工作紀錄，撈出該抽成 skill 的重複手工活）②建·改·檢一支（A→E 建 / anatomy 標準 / 4 Tier audit）③巡全部（全 portfolio 健康度 + 官方 drift）。不確定走哪條時**先問使用者**、或給建議請其拍板，不自行認定。Make sure to use this skill whenever the user says 「建一個 skill / 把這流程抽成 skill / 修 skill / 改 skill / 檢查這支 skill / audit 這支 skill / 這支有沒有符合標準 / 這支看起來怪怪的 / 自我盤點 / 掃一下重複的 workflow / 找有沒有該抽 skill 的 / pattern audit / 全 skill 體檢 / 跑一次 skill 體檢 / 看 skill 有沒有過期 / 官方有沒有出新版 / 月底 skill 巡檢 / skill-ops」、或秘書察覺重複工作 N≥2 且重做成本不低時 — even when they describe the same intent without saying 「skill」 explicitly. 本 skill 獨佔「skill-ops / skill 體檢 / 自我盤點 / 抽成 skill」觸發詞（防 keyword hijack）。**不處理**：非 skill 的 workspace 內容老化 → secretary 每日 Review；工具偵察「有沒有現成的」→ tool-scout；跨 model review → plan-discuss；session 收尾 → wrap-up。"
---

# Skill Ops：skill 生態的單一入口

> 三條路、五份 SOP。進來先分路，**不確定就問使用者、不自行認定**。

## §0 進來先分路（本 skill 的主功能）

問使用者一題，或依訊號自行判斷後**給建議請其拍板**：

```
你手上是哪一種？

  1️⃣  一件「一直在重複做的手工活」，還沒有 skill
      → §1 找候選         references/mining-checklist.md

  2️⃣  一支「特定的 skill」
      ├─ 要新建 / 大改      → §2 建     references/build-checklist.md
      ├─ 想看格式對不對      → §3 標準   templates/anatomy-checklist.md
      └─ 懷疑它壞了 / 沒人用 → §4 檢一支 references/audit-checklist.md

  3️⃣  「全部」有沒有爛掉 / 官方出新版了（現役支數用 `ls -d .claude/skills/*/ | grep -v _archive | wc -l`（workspace 相對）查，不寫死）
      → §5 巡全部         references/refresh-checklist.md

```

### 分路訊號表（AI 自行判斷時用；判完仍要 surface 給 user 確認）

| 使用者說的話 | 走哪條 |
|---|---|
| 「最近做了好多重複的事」/ session 內 N≥2 跑同類手工活 | 1️⃣ §1 |
| 「自我盤點 / 掃一下重複的 workflow / 找有沒有該抽 skill 的」 | 1️⃣ §1 |
| 「建一個 skill / 把這流程抽成 skill」 | 2️⃣ §2 |
| 「修 skill / 改 skill」 | 2️⃣ §2（先過 §2.5 判小 patch 還是大改）|
| 「這支 description 對嗎 / frontmatter 對嗎」 | 2️⃣ §3 |
| 「檢查這支 / audit 這支 / 這支看起來怪怪的 / 我懷疑它沒在用」 | 2️⃣ §4 |
| 「全 skill 體檢 / 跑一次 skill 體檢 / 看 skill 有沒有過期」 | 3️⃣ §5 |
| 「官方有沒有出新版 / 我們還對齊嗎」 | 3️⃣ §5（upstream drift）|
| 排程觸發（週日 / 月底） | 3️⃣ §5 |

🔴 **入口 superset 不變式**：本檔對各 § 的描述必須是那份 SOP 的**子集**——允許摘要、**禁止增添**。
出現在本檔而不在 SOP 裡的「方法性語句」即違規。查法 `python3 scripts/check_entry_superset.py`。
⚠️ 腳本只查已登記 canonical 的 token 類語句；各 § ↔ 其 SOP 檔的子集比對目前仍靠人工逐句。

## §不觸發

- 一次性需求（N=1）— 寫 lesson 觀察、不抽 SKILL
- 已有 SKILL / SOP / refs 覆蓋 80% — 走那邊、不重造輪
- 純 LLM 對話 / 純研究查詢 — 走 secretary 預設或 project mode
- 已存在 SKILL 的小 patch（措辭修正、補一行規則）— 直接編輯、不走 §2
- 非 SKILL 的 workspace 內容（INDEX / inbox / lessons）老化 — 走 secretary 的每日 Review
- 使用者明確說「ad-hoc 就好、不要抽 SKILL」 — 尊重

---

## 核心原則（五段共用）

### 1. 反過度封裝（防 over-build）

- **動手前先質疑前提：「這真的需要嗎？」** 多數想抽 skill 的東西其實不該抽
- **先找既有的（兩階段必跑）**：
  - **本地掃描**：grep 全部 SKILL + `workspace/refs/`（扁平結構、無 `sop/` 子目錄；SOP 型檔不限 `*-sop.md` 命名，看內容不要只靠 glob）+ `workspace/refs/templates/` + ideas/
  - **upstream 掃描**：過 `tool-scout` SKILL 跑一輪（來源清單與門檻以該 SKILL Step 2–3 為準，本檔不複寫）。找到官方對應 → install + 評估 / 小改、找不到才自製
    - 🔴 **要用 agent 平行跑，也必須在 tool-scout 的流程內派工——不得用 agent 取代 SKILL**
- **N=2 才升級，N=1 觀察**（判準見 §9）
- 🔴 **同一次進來，本地與 upstream 掃描只跑一次**——§1 與 §2 共用這個結果，不重跑

### 2. SKILL.md 是入口、不是說明書

- 一個 folder + 一個 SKILL.md；`references/` / `templates/` / `scripts/` / `assets/` 都是可選
- frontmatter 只放 `name` + `description`（對外輸出版例外：可加 `license`，見 anatomy）
- body < 500 行；超長即拆 `references/` 或 `templates/`
- description 寫成觸發器：含 WHAT + WHEN、third-person、1024 字元 max、pushy 風格

### 3. 工作流形狀：檔案傳棒

- 每支 skill 只解一件事；多階段用**檔案傳棒**串下一支
- 用共同真相源綁跨 skill 狀態
- 不要寫萬能 skill

### 4. Skill Boundary Enforcement

- 每支明文寫出 4 段：**做什麼 / 不做什麼 / 何時觸發 / 何時不觸發**
- 觸發條件用使用者可能說出的語句，不寫抽象描述

### 5. soft → hard，inline-或-isolate

- execution 鐵則寫成 grep-able 硬規則；soft 只用於解釋為何要這樣
- 短內容 inline、大內容 isolate 成 `references/` 或 `templates/`
- 引用的 reference / template **必須真實存在 + 揭露**；禁止「被引用-不存在-未揭露」第三態

### 6. 跨平台

- skill 邏輯放 `.claude/skills/*/SKILL.md`，邏輯本體須為純 markdown、可被非 Claude family agent（Antigravity Gemini 等）直接 Read——**這一條必做**
- ⚠️ **Cowork 對等已於 2026-08-20 由 user 拍板擱置**：建 Claude Code 專屬功能時不再需要同步建 Cowork 替代方案。Cowork fallback 為**選配**

### 7. SKILL.md body 純度（拆分硬規則）

不在 SKILL.md 本體、必須移出：

| 內容 | 落點 |
|---|---|
| 來源 / 取捨過程 / 三源比較 | `references/` |
| Patches 歷史 / changelog | `references/changelog.md` 或 git log |
| 個人化舉例（特定日期、私有事件、私有 memory link）| 去敏化後移 `references/` |
| 含 `- [ ]` 勾選的 checklist / 抄了改用的範本 / 報告骨架 | `templates/` |

本體**不管誰看都看得懂**、不依賴個人系統背景知識。違反者 §4 audit Tier 1 自動 ❌。

### 8. 產出一律停在「請使用者拍板」

五段的產出形狀相同：**shortlist / 排序表 → user 圈選**。

🔴 **agent 只能 propose，不能 dispatch 改檔。** 模型有「想做點事證明有用」的偏見，判斷權留給使用者。

排序公式（五段共用）：`priority = (impact × frequency) / cost`，三項各 1-5、分數明文。

---

## §1 找候選

走 `references/mining-checklist.md` — **何時讀**：使用者要做自我盤點、或秘書察覺 N≥2 重複手工活時。

掃過去 14 天的工作紀錄找「該被封裝但還沒被封裝」的重複活。五個 source 平行掃、產 shortlist（hard cap 5 skill + 1 automation）、**硬停等使用者圈選**。

圈選後 → 進 §2 建。

## §2 建（A→E）

走 `references/build-checklist.md` — **何時讀**：要建新 skill，或 §1 shortlist 圈選後要開動時。

| 階段 | 動作 | 防呆 |
|---|---|---|
| **A. before** | 質疑前提 / 找既有 / 確認 N≥2 | 防 over-build |
| **B. while** | 對齊權威 parser / DRY / 容錯+正規化+validator / inline-或-isolate / soft→hard | 防 bug |
| **C. verify** | 跑一次 / 讀實際輸出 / 列舉勝過計數 / 跨家族 review + `wrap-up` | 防自我盲區 |
| **D. maintain** | 「更新」= 加 + 減 + 整併 + 硬化 | 防膨脹 |
| **E. cross-platform** | 純 md 可被非 Claude family 直讀（必做）；Cowork fallback 選配 | 防環境陷阱 |

### §2.5 改既有的（不是建新的）

| 改動規模 | 程序 |
|---|---|
| **小 patch**（措辭、補一行、typo）| 直接 Edit，不走下方流程 |
| **大改**（body 重寫 / 拆 references/ / rename / description 升級 / 改規則語義 / 跨檔同步）| `build-checklist.md` **D. maintain** → 完成後**強制**跑 **B.8 closing protocol 8 步** → C 階段送 `wrap-up`（涉及多檔語義才再跑 C.3 跨家族 review）|

> 判準：改動是否動到「規則語義」或「跨多檔」。是 → 大改。只動單檔措辭 → 小 patch。

## §3 標準（anatomy）

跑 `templates/anatomy-checklist.md`（全表，格數以現檔為準）— **何時讀**：ship 前對照、或 §4 audit Tier 1 時。

含：前置閘（外來原樣保留）/ Frontmatter / Body / 結構 / 拆分硬規則 / 跨平台 / 命名與分發。

### 🔒 外來原樣保留（例外類別）

**判準**：SKILL.md 標題後第一行為 `> 🔒 **外來原樣保留**：<來源>` 者。

**豁免範圍（只到這裡）**：
- ✅ 免跑：anatomy 全表 ＋ §4 audit 的 **Tier 1**
- ❌ **不免**：Tier 2 boundary、Tier 3 使用證據、Tier 4 排序
- ❌ **不免**：`name` / `description` 兩格（它們是 routing 介面，不是內容）

🔴 **加標記本身需 user 拍板**。agent 不得自行為任何 skill 補上這行——否則整份 anatomy 可被一行字關掉。加標記＝改規則語義，走 §2.5 大改。

**為什麼**：這類 skill 的價值就在「一字不改」。標記寫在被保留那支自己身上（跟著 skill 走、單一真相源），**不另設豁免名單**——名單會與本檔漂開。

### Description 四段樣板

1. **一句定位**（做什麼＋關鍵預設，限一句）
2. **觸發語**：`Make sure to use this skill whenever the user says 「…」 — even when they describe the same intent without these exact words.`（觸發詞清單**不設上限**、寧多勿刪）
3. **獨佔宣告**（僅防 keyword-hijack 的 skill 有；原樣保留、瘦身 pass 不得刪）
4. **不處理路由表**：`**不處理**：X → skill-A；Y → skill-B`（完整保留）

❌ 不進 description：工作流步驟摘要、內容物枚舉、演化史/日期、「詳見 references/…」尾 pointer。✅ 例外：兼作觸發線索的枚舉（副檔名、輸入型態、平台名）保留。

## §4 檢一支（4 Tier）

走 `references/audit-checklist.md` — **何時讀**：要 audit 某一支既有 skill 時。輸出格式抄 `templates/audit-report.md`。

**必須依序、不可跳**：

- **Tier 1**：anatomy 對照（最便宜、跑 `templates/anatomy-checklist.md`）
- **Tier 2**：boundary 與重複（跟其他 SKILL 觸發／做什麼比對）
- **Tier 3**：實際使用驗證（主尺＝掃 transcript 的顯式呼叫；inbox / handoff / lessons-learned 為輔助佐證）
- **Tier 4**：retrofit 排序

執行時嚴守 audit 7 條 agent 硬規則（詳 `references/audit-checklist.md`）。

## §5 巡全部

走 `references/refresh-checklist.md` — **何時讀**：週日 / 月底排程、或官方升版時。

對全 portfolio 跑量化健康檢查（六個指標配閾值）＋ upstream drift 偵測（官方 spec / plugin 版本對標）。產 retrofit shortlist → 使用者圈選。

**與 §4 的差別**：§4 是**一支的深度 audit**（trigger 觸發），§5 是**全部的量化巡檢**（排程）。六項指標與閾值的權威＝§5 的 SOP（refresh-checklist §5.1）；「觸發頻率」查法與 §4 Tier 3 共用同一把尺。§5 另負責**排程節奏 + upstream drift**。

🗓️ **主動面（2026-08-29 掛上）**：`SessionStart` hook `extras/claude-code/scripts/startup_skillops_nudge.sh`（安裝見該目錄 README）會在距上次巡檢 ≥7 天時提醒（≥30 天升級措辭）。
它**只提醒、不自動跑指標**。跑完本 § 後務必寫水位，否則會一直提醒：
```bash
date +%Y-%m-%d > .claude/.last-skillops-sweep
```

## §6 RATIONALE-TEMPLATE

每支 skill 的核心規則寫成「Layer 1 短規則 + Layer 2 RATIONALE」：

- **Layer 1**：規則 1 句話、硬規則、grep-able
- **Layer 2**：rationale（為何這樣做、根因 lesson 編號、何時不適用）

## §7 三源融合來源

四源：Anthropic anthropics/skills spec + G-stack v1.42 + Benny skillset-audit + 本系統 emergent voice。

## §8 與既有 SKILL 的關聯

| 既有 SKILL | 關聯 | 動作 |
|---|---|---|
| `tool-scout` | 上游 | §1 source 5 與 §2 A.2 共用它跑 upstream 掃描 |
| `wrap-up` | 下游 | §2 階段 C 必跑 13 條 review |
| `plan-discuss` | 下游 | 跨家族 review 的完整協議。⚠️ 該 skill 設 `disable-model-invocation: true`、**agent 叫不動**，§2 階段 C 改直接跑 fanout 腳本（**未隨附**，見 build-checklist C.3——照 plan-discuss 原則手動找第二個模型家族）|
| `handoff` | 跨平台 | Cowork 寫 SKILL 邏輯 → Code 落地 `.claude/skills/` |
| `secretary` | 引薦來源 | 其路由表偵測到 skill 相關訊號時引薦進本 skill §0 |

## §9 N=1 → N=2 升級條件

**N=1 觀察期**：4 週（建立日起算）。

**N=2 升級 criteria（需全部達）**：

1. **跨 session 主動觸發**：user 在**不同 session** 主動觸發 ≥ 2 次（不是同一 session surface）
2. **沒推翻工作流**：給的流程跑下去、user 沒中途 abort
3. **產出有實際 ship**：建出的 SKILL 後續被觸發 / retrofit 有採納執行

🔴 **同一 session 的 self-audit / dogfood / surface 不計入 N**（reflexivity 避免）。

**跑不順 fallback**：第一次不順 → 寫 lesson + inbox 觀察、不立即改；持續不順 N=3 → 評估大改 references/ / 與他支合併 / 退場。

## 隨貨檔案

- `references/QA.md` — 踩過的坑＋設計理由（改本 skill 前先讀）
- `human/explain1min.html`／`human/eli5.html` — 給人看的圖解（中英單檔切換）；改了路由結構要回來同步
- 發現問題：開 issue 回報，不要在自己機器上靜默修完就算

