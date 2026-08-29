# 建立新 skill — A→E 詳細 checklist

> ⚠️ **隨貨註記**：`tool-scout`／`wrap-up`／`plan-discuss` 皆隨本 repo 附上（為較原系統精簡的版本、引用照概念對應）。C.3 提及的 fanout 腳本與多模型基建**未隨附**——跨家族 review 照 `plan-discuss` SKILL 的原則執行：多找一個模型家族做獨立審查即可。

> 來源：本系統 ad-hoc 蹲下教訓（含資料庫升級 + parser bug class）+ G-stack 工作流形狀 + Anthropic skill-creator iteration loop

## 目錄

- **A. before building** — 防 over-build（質疑前提 / 找既有 / 確認 N≥2 / 兩段式設計 / 拍板形式）
- **B. while building** — 防 bug 與斷裂（對齊權威 parser / DRY / 容錯+正規化+validator / inline-或-isolate / soft→hard / 25K token 邊界）
- **C. verify** — 防自我盲區（做了才知道 / 列舉勝過計數 / 跨家族 review / wrap-up 13 條 / 第一個 user case dogfood）
- **D. maintain** — 防膨脹（「更新」= 加 + 減 + 整併 + 硬化 / 歷史進 archive / 零散動作 → 整併成工作流）
- **E. cross-platform** — 防環境陷阱（平台限制 / 跨平台 md 鏡像 / handoff 模式）

> **何時讀**：使用者要建新 skill、或 §1 shortlist 圈選後要開動時。SKILL.md §2 引用點是入口。

## A. before building — 防 over-build

> 多數想抽 skill 的東西其實**不該抽**。這一階段擋下假需求。

### A.1 質疑前提

問三遍：
1. 「這真的需要嗎？」— 列出不做會發生什麼壞事，能用具體 case 描述
2. 「這個壞事一年會發生幾次？」— 預估頻率，N<3/年 通常不值得
3. 「現有 SOP / SKILL / 工具能不能 cover 80%？」— 翻過全部 SKILL + `workspace/refs/`（扁平結構、無 `sop/` 子目錄；SOP 型檔不限 `*-sop.md` 命名）後再回答

### A.2 找既有（兩階段必跑、防白做工）

**階段 1：本地掃描**
- grep `.claude/skills/*/SKILL.md` 看有沒有功能重疊
- grep `workspace/refs/` 看有沒有 SOP 形式存在（扁平結構、無 `sop/` 子目錄；別只靠 `*-sop.md` glob，會漏）
- grep `workspace/refs/templates/` 看有沒有模板存在
- 看 `ideas/` 有沒有相關 idea 已落在那（升級成 skill 比新建好）

**階段 2：upstream 掃描**（**強制**、防白做工 anti-pattern）
- 過 `tool-scout` SKILL 跑一輪（來源清單與篩選門檻以該 SKILL Step 2–3 為準，本檔不複寫）
- 🔴 **要用 agent 平行跑，也必須在 tool-scout 的流程內派工——不得用 agent 取代 SKILL**（L00479）
- 找到官方對應 → install + 評估 / 小改、找不到才自製

**Why 強制兩階段**：本系統 N=1 觀察 2026-05-28 webwright case — 先做完本地 Playwright 移植、做完才發現 anthropic 官方有同類 plugin、整套工作白做。N=2 累積條件 = 下次又踩同類坑 → 升 hard rule。

### A.3 確認 N≥2

判準（權威＝SKILL.md §9）：
- **N=1 觀察**：只跑過 1 次成功、寫進 lessons / inbox、等下次
- **N=2 才升 SKILL**：跨 session 重做過 + 證明 stable

### A.4 兩段式設計

對齊 KB 升級教訓：
- **便宜前篩**（tag / index 切片 / 規則 filter）→ 縮窄範圍
- **貴的判斷**（top-down / LLM / 全文掃）→ 只跑前篩剩下的

**永不 brute-force 全庫** — index/tag 就是用來綁成本的。

### A.5 拍板形式

- **指引式 SKILL.md**（baseline）— agent 自己讀規則去做
- **互動式工作流**（slash command + AskUserQuestion）— 適合複雜決策樹
- **scripts/**（python/shell）— 適合確定性自動化
- **automation**（hook / cron / scheduled task）— 適合事件觸發
- **🔒 外來原樣保留**（一字不改抄自外部來源）— 不套本地 anatomy，改寫即毀。標記與豁免範圍見 SKILL.md §3

預設先做 baseline；複雜決策才升互動式；確定性才上 scripts/。

---

## B. while building — 防 bug 與斷裂

### B.1 對齊權威 parser

讀既有資料的工具，**解析必須對齊權威來源**：
- 例 1：權威 parser 認雙格式 → 衍生工具必須抄一樣、否則漏邊界 case
- 例 2：把共用解析抽出獨立模組（如 `<domain>_common.py`）、別只在主工具裡有

**反例 class**：多支工具各自寫一半 parser、共用邏輯沒抽出 → bug 在沒看到的 fallback path 出現（多次踩坑）。

### B.2 DRY — 共用邏輯抽出來

- 重複是 bug 的溫床
- 重複是「未來改 1 處變改 N 處」的伏筆
- 共用模組（`kb_common.py`、`utils/` 等）必須提名清楚、不是「我也不知道叫什麼」

### B.3 資料異構容錯 + 正規化 + validator

三件套：
1. **工具容錯**：parser 認雙格式 / 大小寫不一致 / null
2. **源資料正規化**：定期跑 normalize 把舊資料對齊新標準
3. **ingest validator**：寫入時擋住髒資料、根治污染

### B.4 inline-或-isolate（第三態 anti-pattern）

對齊本系統「被引用-不存在-未揭露」第三態的歷史踩坑：
- **短** inline 進 SKILL.md（< 50 行的 checklist / 例子）
- **大** isolate 成 `references/*.md`（教材、超長 checklist、原則討論）
- **scripts** isolate 成 `scripts/*.py` 並在 SKILL.md 提及怎麼跑

**禁止「被引用-不存在-未揭露」的第三態**：
- ❌ SKILL.md 寫 `見 references/foo.md`、檔案不存在
- ❌ SKILL.md 提某 script、檔案在 workspace 外部
- ✅ 引用的都存在、所有外部依賴明文 disclose

### B.5 soft → hard（context-window 結論）

- **soft**（會被抽樣忽略）：「請盡量做 X」「應該 X」「考慮 X」
- **hard**（grep-able 明文）：「必須先 X 才能 Y」「X 不存在時 always 走 Z 分支」
- execution 鐵則 100% 寫 hard、解釋為何要這樣做才寫 soft

### B.6 25K token 邊界

單檔 < 25K token；否則：
- 拆 references/ 多檔
- 配 paginated-read SOP（明文寫「讀 §X 段時 offset N、limit M」）

### B.7 拆分硬規則前置檢查（2026-05-28 ship、Lesson #180、N=3 達閾值）

寫新 SKILL 過程中遇到下列情境 → **立即 isolate 到 references/、不寫進 SKILL.md body**：

| 情境 | 落點 |
|---|---|
| 「YYYY-MM-DD 加 / 起源 / 實戰演進 / 升級條件」 | `references/changelog.md` |
| 「回收先前 / 降為 / 反轉 / 原本是 X」系譜語法（跟自己的過去對話） | 現況直述寫 body；演化史進 `references/changelog.md`（audit 側對應＝anatomy「冷讀者測試」格） |
| 「Bug X」「Lesson #Y」內部編號引用 | `references/lessons-cases.md` |
| 特定人名 / chat ID / 帳號 / 內部路徑 / API key | `references/system-config.md`（必要時 gitignore）|
| design rationale 超過 1 行（「為什麼這樣做」） | `references/*-design.md` |
| 已凍結 / 待解凍 / 低頻 workflow | `references/cold-workflows.md` |

**為什麼前置檢查**：5/27 前 ship 的 SKILL 100% 違反此規則（N=3 evidence、Lesson #180 + KB + handoff Wave 1 audit）。事後 retrofit 比寫的當下擋下成本高 3-10×。

**對 audit Tier 1 連動**：`templates/anatomy-checklist.md` 同 5 條已 ship、本規則是 build 階段對應。

### B.8 retrofit 完成 8 步檢查（2026-05-28 ship、Lesson #181、N=2 達閾值）

**何時觸發**：對既有 SKILL 做 retrofit（body 改 / 拆 references/ / rename / description 升級）完成後、claim 「retrofit done」前。

**Why**：5/28 W22 audit batch 觸發 N=2 evidence「retrofit statement ≠ actual」— Wave 1 KB + audio-transcribe 都 claim「retrofit 完成」但實際漏：
- 個資 leak 在 references/system-config.md（沒過 PII redact）
- CLAUDE.md skill 索引 description 沒同步
- inbox / handoff 內 dated 引用沒對齊新檔名 / 新行數
- cross-trigger 跟其他 SKILL 沒比對

retrofit ≠ ship checklist 不對等 → 完成度漏估、後手 audit 必抓。本 8 步是強制 closing protocol。

**8 步（按序跑、勿跳）**：

| # | 步驟 | grep / 動作 |
|---|---|---|
| 1 | SKILL.md body 改完、行數 / 結構符合預期 | `wc -l SKILL.md`、人工掃 anchor 段 |
| 2 | **PII redact 全掃**（強制 keyword grep 列表、N≥4 evidence 升級）| 範圍：**SKILL.md body + references/ + templates/**（不只 references/）。Keyword list：`{自建——原系統實名表不隨貨；照 §B.8 末尾三類定義建你自己的清單}`。**任一 keyword 命中即 reject**、必須 redact（協作者實名 → 「協作者 X」/ project name → 「專案 A/B」）或加 CONFIDENTIAL banner（內部 only 不對外）。詳見 §B.8 末尾 keyword list 詳版。 |
| 3 | ~~CLAUDE.md skill 索引同步~~ → **改查 sibling 檔的 description 引用** | ⚠️ CLAUDE.md 已無 skill 索引段（現寫「session 啟動時系統訊息會列出全部 Skill…不需另查索引」）。改跑：`grep -rn '<skill-name>' ~/.claude/skills/*/SKILL.md` 找其他 SKILL 內對本支的舊 description 引述並對齊 |
| 4 | sibling refs / templates / usage-guide rename 一致 | grep `<old-name>` 全 workspace + `.claude/`、找 stale 引用 |
| 5 | inbox / handoff 內 dated 引用 grep + 標 stale | grep `inbox/` `handoff/`、舊行數 / 舊路徑要標 `(超齡、現況見 ...)` 或修 |
| 6 | cross-trigger 跟其他 SKILL 比對（substring + by-design 區分）| grep 其他 SKILL description 重疊觸發語、判斷是搶觸發（要修）還是 by-design 共享（不修、寫 disambiguator）|
| 7 | 派 sub agent 跑影響性評估 | 用 general-purpose subagent 跑 P0/P1/P2/P3 分級 finding、確認沒漏。🔴 **必帶 `model` 且固定 opus**——省略＝繼承＝可能落 Fable＝違規 |
| 8 | **ship 後立即自跑 dogfood、不等 user**（2026-05-28 Lesson #182、N=4 dogfood evidence）| 自跑 3 類 grep：(a) PII keyword（同步 2）/ (b) cross-skill propagation（sibling SKILL 內對本支的 description 引用）/ (c) self-narrative consistency（前後段 supersession / errata / 行數）。Hit > 0 必 surface 給 user、不採信自己「應該 OK」直覺。**LLM 自發 dogfood 傾向 = 0、必須 enforce** |

**典型踩坑**：
- 跳步 2 → 個資 leak 進 references/、git push 後撈不回
- 跳步 3 → sibling SKILL 內引述的舊 description stale、外部 agent 看到舊描述跑錯流程
- 跳步 6 → 兩 SKILL 搶同 trigger、user 觸發後 silently 跑錯 skill
- **跳步 8** → 自己 ship 完 step 7、轉頭做下個 SKILL 又跳 step 7、N≥4 連 user 主動觸發才補（W4 self-recursive evidence、強度極高）

**對齊**：本檔 §A.2 兩階段 upstream 掃 = build 階段；本步 §B.8 8 步檢查 = retrofit 階段；兩者都是 anti-pattern 防護機制。

### §B.8 step 2 強制 keyword grep 詳版（2026-05-28 W22 audit dogfood N≥4 升級）

**為什麼升級**：2026-05-28 W22 Wave 4 retrofit 後跑 3 輪 dogfood、抓到 9 P0 PII 跨 8 支 SKILL— W3 retrofit spec 自稱「個資抽象化」實際完全沒做。Lesson #181「retrofit statement ≠ actual」真實 N≥4 evidence（W1 KB / W2+W3 / W4-5 主 retrofit / W4 dogfood 自己跳 step 7）。

**強制 keyword 三類**：

| 類別 | keyword | 處理 |
|---|---|---|
| **協作者實名** | `{自建：你的協作者實名清單}` | redact → 「協作者 X」/ 「外部範式 A/B」/ project name → 抽象化 |
| **project / 平台代號** | `{自建：你的內部專案代號清單}` | redact → 「專案 A/B」或加 CONFIDENTIAL banner（內部 only）|
| **帳號 / 密鑰 / ID** | `{自建：mail domain / token 前綴 / chat_id / phone 等樣式}` | 必 redact 為 `[redacted]` / 移 `~/workspace/refs/` 不對外、絕不可放 references/ |

**掃描範圍**（必跑全部）：
1. `SKILL.md` body（不只 references/）
2. `references/*.md`
3. `templates/*.md`
4. SKILL frontmatter description

**操作**：
```bash
cd .claude/skills/<target>
grep -nE "{你的 keyword list，以 | 分隔}" SKILL.md references/*.md templates/*.md 2>&1 || echo "CLEAN"
```

**判斷**：grep 任一命中 → 不可宣稱 retrofit done、必先處理。

**Hit 後處置：3 類 leak risk 分類**（2026-05-28 sample N=5 衍生、配 Lesson #182）：

> 5/28 W4 接手實測校正：「預期 0 hit」框架過嚴。實際 references/ ~34 hits 全是 by-design reference。應按 leak risk 分類處置：

| 類 | 定義 | 例子 | 處置 |
|---|---|---|---|
| **A 類（必 redact）** | 協作者私人實名 + 客戶 + 員工（私人脈絡）| {NAME-A} / {NAME-B} / 個人 chat ID / API key | 必 redact → 「協作者 X」/「[redacted]」、或加 CONFIDENTIAL banner（internal-only） |
| **B 類（保留 by-design）** | 公開作者 + 公開 repo + 公開框架代稱（設計來源歸屬命名）| Benny pm-workflow / G-stack v1.42 / Sherman CTPS 講義（公開教材） | **不 redact**、redact 會破壞設計語義 |
| **C 類（可選抽象化）** | project name 在內部 SOP / 案例敘述 | {PROJECT-A} / {PROJECT-B} 在案例敘事 | 視 audience 選擇：對內可讀性 vs 對外隔離 |

**判斷流程**：
1. grep hit → 看 keyword 屬哪類
2. A 類 → 立即 reject、必 redact
3. B 類 → 保留、加註解說明「by-design 引用」（option）
4. C 類 → 看 SKILL 是否對外分發：若對外 → 抽象化；若 internal-only → 保留可讀性

**典型錯誤**：把 B 類也當 A 類 redact、破壞 skill-ops / edu-doc 的「三源融合」設計語義（Anthropic / G-stack / Benny 命名歸屬必要）。

**正確處置範例**（2026-05-28 audio-transcribe P1-A 首次落地、配本系統 PII placeholder 教訓）：
- SKILL 主體 `.claude/skills/audio-transcribe/SKILL.md` 用 placeholder（`{COLLABORATOR-PRIMARY}` / `{TEAM-MEMBER-A/B/C}` / `{CLIENT-PROJECT-A}` / `{INTERNAL-ORG}`）
- 實名對照寫 `references/_private-glossary.md`（`.gitignore` 加 pattern `.claude/skills/*/references/_private-*.md` 確保不對外）
- 其他 tracked references（cases / changelog / system-config）也用 placeholder、不寫實名
- 比「CONFIDENTIAL banner internal-only」mitigation 更精明：SKILL 對外乾淨 / 內部 grounded / pattern 可推廣其他 internal-only SKILL

---

## C. verify — 防自我盲區

> ★ 過往 ad-hoc 蹲下教訓：自我 review 抓不夠（同家族 LLM 一輪抓 10+ 條漏網 finding）；plan 本身也要先被 review 再執行。

### C.1 做了才知道

build → run → 讀**實際輸出**、別只靠推理：
- 跑一次完整 workflow
- 讀 stdout / 產出檔案
- 對比預期 vs 實際

多數 bug 是跑了才現形。

### C.2 列舉勝過計數

- 不要信 aggregate 數字（「AI Agent 16 篇」、實際列舉只 3 篇）
- 對 ground truth 必須 enumerate
- 計數和列舉不一致時、信列舉

### C.3 跨家族 review（必跑）

> §2.5 大改的適用門檻：涉及**多檔語義**的大改必跑本節；單檔措辭級大改可由 `wrap-up` review 取代（見 SKILL.md §2.5）。

build SKILL 完先過跨家族 review——目的是抓「同一個 LLM 的盲區」，**不是**特定某支 skill。

🔴 **不要試圖 invoke `plan-discuss`**：它設了 `disable-model-invocation: true`，agent 結構上叫不動。查法（不寫死數字）：掃 `~/.claude/projects/*/*.jsonl` 的 `tool_use` name=`Skill` 且 `input.skill=='plan-discuss'`——實跑會看到它是 0，而同階段無此旗標的 `wrap-up` 是三位數。差別在旗標，不在習慣。

**三步，缺一不可**：

1. **先寫 request 檔**（腳本吃的是**已存在的 `.md` 絕對路徑**，不是一句文字請求）
   落點依 `plan-discuss` 慣例：`workspace/handoff/pending/discuss-{date}-{time}-{shortname}.md`
   內容須是 plan-discuss 的 briefing 格式——reviewer 回覆要命中「### 保留 / 修改 / 新增 / 刪除」四區塊且 ≥250 字才會被寫檔。

2. **跑 fanout**
   ```bash
   python3 <你的 fanout 腳本路徑> <request.md 的絕對路徑>   # 腳本未隨附
   ```
   slot b = `gemini-3.1-pro-high`（Google）、slot c = `gpt-oss-120b-medium`（OpenAI），**兩者都經 Antigravity 出境**。產出與 `fanout-report.json` 寫在 **request 檔同一層**（不是另一個目錄）。

3. 🔴 **必須另跑反集中錨**——否則整輪是單一供應商，會被記成「跨家族已過」的假通過：
   ```bash
   bash <你的反集中錨腳本路徑> <request.md 的絕對路徑>   # 未隨附；或手開第二家族 session 當 slot D
   ```
   或手開一個 Claude session 當 slot D。腳本自己會在結尾印這條警告。

**邊界**：reviewer 可用輔助家族模型；**synthesis 與 final-check 必須留主模型**（判斷層不外包；`plan-discuss` 亦明訂 final-check 不得外包）。要完整走協議（含獨立 session 的 Final Checker）→ 請 user 手動觸發。


### C.4 wrap-up 13 條

build SKILL 完跑 `wrap-up` skill（原 `review`、2026-05-27 rename）的 13 條 checklist：
- 完整性 / synthesis-correction / 邊界 / 跨平台...

### C.5 第一個 user case 必須 dogfood

- SKILL ship 之後第一個觸發必須是 user 真實 case
- 不要假觸發、不要拿 fixture 跑
- 過了 N=1，記在 lessons / inbox

---

## D. maintain — 防膨脹

### D.1 「更新」= 加 + 減 + 整併 + 硬化

不是只加：
- **加**：新 case / 新規則
- **減**：過期 N=1 觀察未升的條目
- **整併**：兩條相似的合一條、寫明邊界
- **硬化**：soft → hard 升級（觀察期過後）

對齊過往 reviewer 點破的「只加不減」anti-pattern。

### D.2 歷史進 archive、SKILL.md 只留導航

- 主 SKILL.md 是入口、< 500 行、純導航 + 核心原則
- 教材 / 例子 / 詳細 checklist 進 references/
- 老掉的 case 進 references/archive/ 或刪除

### D.3 零散動作 → 整併成工作流

本系統教訓：多支 ad-hoc 腳本 → 統一 CLI + 一條 happy path 健康工作流（如 count_sync → lint → route → graph 這種串接）。

SKILL 的 references/ 也適用：別散落多檔互相 cross-link、合一條 happy path。

---

## E. cross-platform — 防環境陷阱

> ⚠️ **狀態（2026-08-20 user 拍板）**：Cowork 線**擱置**（非廢除）——預設走 Claude Code、不做 md 對等。**E.2 的「純 md 可被非 Claude family agent 直讀」仍必做**；**E.2 的 Cowork fallback 與 E.3 handoff 模式降為選配，只在 user 明確要求 Cowork 時跑**，缺此兩段不算 ❌。

### E.1 平台限制

- **Cowork**：不能 git / 不能改 `.claude/skills/`（受保護）→ handoff 給 Code 接力
- **Claude Code**：完整權限、但 macOS 沙箱有 FDA / TCC 邊界
- **Antigravity Gemini**：不認 SKILL 格式、要直接 Read SKILL.md，所以 SKILL.md 必須是純 markdown 可讀

### E.2 跨平台 md 鏡像

對齊本系統跨平台教訓：
- SKILL 邏輯本體 = 純 markdown
- 不依賴 hook / settings.json / plugin runtime 在邏輯路徑上
- ⚠️（**選配**，2026-08-20 起）Cowork 不可達的副作用（git、寫 `.claude/`）明文 fallback：handoff 給 Code — Cowork 線已擱置，缺此段不算 ❌

### E.3 handoff 模式

對齊 `handoff` SKILL：
- Cowork 寫 SKILL 邏輯（純 md）→ Code 落地 `.claude/skills/`
- 寫 handoff bundle 進 `workspace/handoff/pending/`
- Code session 自動 surface
