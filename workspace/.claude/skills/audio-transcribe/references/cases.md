# audio-transcribe — Cases & Lessons

> SKILL.md 本體外的「踩坑案例 / Whisper 幻覺 narrative」歸這。
> SKILL.md 本體只引「規則」、不寫 narrative。

---

## L1（2026-05-08）：誤讀舊 SOP 文件

**情境**：準備跑本機 large-v3 + 手動切 61 min 大檔（按舊 SOP `{TEAM-COMMS-PATH}/sop.md:244` 指引、實際路徑見 `_private-glossary.md`）。

**抓包**：協作者即時擋下「我記得我們默認的做法是走 API？」

**Root cause**：舊 nested SOP 跟新 router 不同步、agent 直接照舊 SOP 做。

**教訓**：Auto-load SKILL > nested SOP 的權威階序、衝突時 SKILL 是真相源。對應 [[lesson-#125]] 工具 SKILL 化只解 SOP 跨平台、舊 nested SOP 沒同步是漏洞。

## L2（2026-05-08）：建 SKILL 漏看 inventory

**情境**：建本 SKILL 第一版時直接指 `transcribe-cloud.sh`、漏看 `workspace/tools/README.md` line 11 明寫的「統一介面：`transcribe.sh`（4/26 升級為 router）」。第二輪收尾才發現。

**教訓**：建新 SKILL 前必先讀 `workspace/tools/README.md` inventory。否則 SKILL 入口指錯、所有 trigger 都拿不到新版升級。

## L3（2026-05-22）：批次轉錄漏檔

**情境 (a)**：user 5/20 朋友錄音被秘書漏掉、只跑 5/22 凌晨 4 檔。

**情境 (b)**：user 補拍板「未來 A/C 軸 transcript 自動 link {PERSONAL-CORPUS}」+「attribution in-house、砍 gemini-worker」。

**改動**：本 SKILL 新增「Corpus link → {PERSONAL-CORPUS}」+「in-house attribution」兩段、L116 反模式改 in-house、gemini-worker 已 archive。

**教訓**：
1. 多檔批次轉錄掃 Downloads 要看 7 天範圍、不只挑「今日批次」
2. sub-agent 派工成本（context 隔離 / 校稿不便）跟 in-house 比要重新評估

---

## Whisper 幻覺案例

> 教訓 N=2 達閾值（2026-05-15 收尾 review B6/B9 觸發）→ sanity check 升為 SKILL.md 硬規則。下列案例 1+2 即當時的兩段 postmortem。

### 案例 1：Khmer + 越南 + 靜音段大量幻覺（2026-05-14）

3 段 AI 教學音檔 Whisper auto language，靜音 + Khmer 段跑出大量訓練 corpus 高頻段：
- `lalaschool`
- `Ghiền Mì Gõ`
- 「請訂閱頻道」

**處理（當時走 gemini-worker、現已砍）**：清理移除 26-38% 字數。

**現規則**：Claude in-house 過一輪、可疑段標 `[可能幻覺?]` 前綴。

### 案例 2：短英文諧音幻覺（2026-05-09）

純英文音檔、Whisper language=en 設定下仍把短專案名（柬籍 speaker 唸法）聽成英文常見字：
- 短專案名 → 英文常見動詞（短詞諧音；具體案：`{CLIENT-PROJECT-A}` 被聽成 "looming"）
- 同事姓名 → 英文人名（諧音替換）

**踩坑**：諧音字（"looming"）被直接複製進 `{INTERNAL-OPS-PATH}/INDEX.md` 5/17 deadline 表、pushed 到 {INTERNAL-ORG}/main，user 親自掃 INDEX 才發現「這是什麼」抓包。

**教訓**：英文短詞（≤ 6 字母）+ transcript 含非英文母語 speaker → 預設可疑、強制 sanity check（不論 language=en 設定）。

### 案例 3：語法不通強制成句

Whisper 對破碎句、語法錯誤仍 force-output 完整句、可能加料。

**處理**：sanity check 時對「文法太完美但內容偏離 context」的句子警示、回查原音檔。

---

## 三類典型 Whisper 幻覺（規則摘要）

1. **語言切換段幻覺**：非英文段 + 靜音 → 訓練 corpus 高頻段
2. **短英文諧音幻覺**：短專案名 / 業務術語被諧音替換為常見英文單字
3. **語法不通強制成句**：Whisper 對破碎句 force-output

詳完整 sanity check 流程 → SKILL.md §Sanity check 流程。

---

## A/C 軸 corpus link 起源

2026-05-22 user 拍板「所有 A 軸（user 獨白）+ C 軸（user 與朋友線下）transcript 自動 link 進個人 corpus 容器」。

**Implementation 記錄**：見 SKILL.md §Corpus link 段。

---

## A/C 軸分流斷鏈（2026-05-22）— 「分流是轉錄的一部分」protocol 起源

**問題背景**：SKILL.md「後續分流」表偏 B/E 軸會議檔（→ 內部會議路徑 / 客戶會議路徑 / HR 路徑）。A/C 軸（user 獨白 / 朋友線下）過去只做了 corpus-link 進 {PERSONAL-CORPUS}，**實質內容（行動項 / 投資 thesis / 教材 / 平台情報）卻沒分流到各專案** → frontmatter 卡在 `status: pending`、`extracted_to:` 空白。

**2026-05-22 實例**：Code 轉錄完 5 檔、corpus-link 完，user 一切換任務、實質分流就斷在 pending、隔天才補。

**結論（已升 SKILL.md 硬規則）**：轉錄 + corpus-link ≠ 結案。A/C 軸 transcript 的內容分流必須在同一個收尾流程做完。protocol 本體見 SKILL.md §A/C 軸內容分流 protocol；參考實作 `inbox/2026-05-22.md` Cowork 分流 session（5 檔 A/C 軸全分流 + protocol ship）。
