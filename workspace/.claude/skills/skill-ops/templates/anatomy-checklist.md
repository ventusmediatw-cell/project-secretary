# SKILL Anatomy Checklist（reader 抄了改用）

> 用途：SKILL ship 前對照、或對既有 SKILL 跑 audit Tier 1 時填。
> 抄一份到 audit report 或 SKILL ship checklist、勾選 ✅ / ❌。
> 來源規格：anthropic anthropics/skills + agentskills.io spec + 本系統 emergent voice。

---

# Skill: `___________________`
# 日期：YYYY-MM-DD
# 操作者：___________________

## 前置：這支是「外來原樣保留」嗎？

- [ ] SKILL.md 標題後第一行是 `> 🔒 **外來原樣保留**：<來源>` ？
  → **是**：只勾下方 Frontmatter 前兩格（`name` / `description` 字元數），**其餘全部跳過、不算 ❌**，本表到此結束。
  → **否**：照常往下跑全表。

## Frontmatter

- [ ] `name` kebab-case、64 字元 max
- [ ] `description` 1024 字元 max
- [ ] `description` 第三人稱：**不得以第一人稱敘述本 skill**。⚠️ 引號內照抄的 user 觸發語（如「找我的盲點」「audit 我的 skill」）**不算違規**——本檔「Description 四段樣板」章本來就要 user 會說出口的原話、且明訂「觸發詞清單不設上限、寧多勿刪」；2026-08-29 實測 13/35 支命中全屬此類
- [ ] `description` 含 WHAT + WHEN（功能 + 觸發語）
- [ ] `description` pushy 風格（「Make sure to use this skill whenever...」directive）
- [ ] （對外輸出版）`license` 欄位有寫

## Body

- [ ] < 500 行（超長 → 拆 references/）
- [ ] 觸發條件明文列出使用者觸發語句
- [ ] **做什麼 / 不做什麼 / 何時觸發 / 何時不觸發** 四段全有
- [ ] body 用 imperative form（祈使句）；declarative 只用於解釋
- [ ] 鐵則寫硬規則（grep-able）、不寫 soft（「應該」「考慮」）
- [ ] 引用的 references/ / templates/ / scripts/ 全部存在（無「被引用-不存在-未揭露」第三態）
- [ ] 不含個人化舉例（日期、私有事件名、private memory link）— 必須去敏化或移 references/
- [ ] **冷讀者測試**：以第一次讀的 agent 視角掃 body——不得有預設歷史背景才讀得懂的句子（「回收先前／降為備用／反轉／原本是 X」類系譜語法；拍板・量測時戳不算）。現況直述、演化史進 references/changelog.md。（2026-08-29 加：逐格 dated 檢查抓得到 instance、抓不到「整份是疊寫本」這個 class，要單獨一格）

## 結構

- [ ] `SKILL.md`：邏輯本體
- [ ] `references/*.md`（可選）：reader **讀懂用** — 教學 / 原則討論 / changelog / 三源比較
- [ ] `templates/*.md` 或 `templates.md`（可選）：reader **抄了改用** — 含 `- [ ]` 勾選 / 起手骨架 / report 範本
- [ ] `scripts/*.py|sh`（可選）：執行碼、SKILL.md 提及怎麼跑

## 拆分硬規則（2026-05-28 user 拍板）

對 SKILL.md body 純度的驗證：

- [ ] **「來源 / 從哪裡來 / 取捨過程」** 不在 SKILL.md 本體（在 references/）
- [ ] **「Patches 歷史 / changelog」** 不在 SKILL.md 本體（在 references/changelog.md 或 git log）
- [ ] **「個人化舉例」**（特定日期、私有事件、內部 memory link 範例）不在 SKILL.md 本體
- [ ] **「含 `- [ ]` 勾選的 checklist」** 不在 SKILL.md 本體（在 templates/）
- [ ] SKILL.md 本體不管誰看都看得懂、不依賴個人系統背景知識

## 跨平台

- [ ] SKILL.md 純 markdown、不依賴 hook 或 plugin runtime
- [ ]（**選配**，2026-08-20 起）Cowork 不可達的副作用（git / 寫 `.claude/`）明文 fallback：handoff 給 Code — Cowork 線已擱置，缺此段**不算 ❌**
- [ ] Wiki link 慣例（`[[name]]`）對非 Claude family agent 有翻譯指南、或全換絕對路徑

## 命名與分發

- [ ] 與既有 SKILL 不重名、不功能重疊
- [ ] 觸發條件不會誤觸（用 §1 找候選的 shortlist 檢查）
- [ ] 與相鄰 SKILL 的邊界明文（在 SKILL.md `## §與既有 SKILL 的關聯` 段）

## Audit Tier 1 結論

對既有 SKILL 跑時、本表填完後得：
- ❌ 項目清單：________________________________
- 進 Tier 4 retrofit 排序的 finding：________________________________

---

> 抄改提示：建議使用者把本範本 cp 到 audit report 或 PR 描述、勾選後 commit。


## Description 四段樣板（權威版；SKILL.md §3 為其摘要入口）

1. **一句定位**（做什麼＋關鍵預設，限一句）
2. **觸發語**：`Make sure to use this skill whenever the user says 「…」 — even when they describe the same intent without these exact words.`（觸發詞清單**不設上限**、寧多勿刪）
3. **獨佔宣告**（僅防 keyword-hijack 的 skill 有；原樣保留、瘦身 pass 不得刪）
4. **不處理路由表**：`**不處理**：X → skill-A；Y → skill-B`（完整保留）

❌ 不進 description：工作流步驟摘要、內容物枚舉、演化史/日期、「詳見 references/…」尾 pointer。✅ 例外：兼作觸發線索的枚舉（副檔名、輸入型態、平台名）保留。

### 🔒 外來原樣保留的標記規則

- **加標記本身需 user 拍板**；agent 不得自行為任何 skill 補上——否則整份 anatomy 可被一行字關掉。加標記＝改規則語義，走 SKILL.md §2.5 大改。
- 標記寫在被保留那支自己身上（跟著 skill 走、單一真相源），**不另設豁免名單**——名單會與入口漂開。
