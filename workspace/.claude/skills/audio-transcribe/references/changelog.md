# audio-transcribe Changelog

> SKILL.md 本體外的「dated 演進歷史 / 拍板紀錄 / patches」歸這。
> Source-of-truth：本檔 + git log。

---

## 2026-07-21 — Entity 校正塊 + 批次會談 debrief（N=1 ship、user 拍板寫入）

**來源**：4 檔同場會談錄音（88 min / 29,284 字）一次消化，暴露兩個既有 SOP 沒覆蓋的缺口。

**缺口 1 — 諧音校正沒有落地格式**：原 SOP 只說「surface 給 user 核」，沒說核完之後怎麼記。實作時直覺會 find-replace 正文，但那會讓「Whisper 聽到什麼」與「我們認定是什麼」永久混同、日後換模型 re-check 全部失據。
→ ship §Entity 校正塊：檔頭表格覆蓋、正文永不改、三狀態標記（✅ 核 / ⏳ 待核 / ⏸ 先不處理）、**行號位移註記為硬要求**（插入校正塊會讓表中行號全數失效）。多檔批次只寫進 entity 密度最高那檔。

**缺口 2 — 批次會談逐檔分流會把議題切碎**：同一場會談的議題交錯散在多檔（結案報告、合夥邀約、營運數據分屬三檔），逐檔摘要無法還原全貌。且會談中的口頭承諾（「我幫你做 X」「開價多少」）在逐檔視角下最容易漏。
→ ship §批次會談錄音 → 單一 debrief：≥3 檔同場觸發、一批轉完再讀、收斂成一份 debrief + paired HTML、debrief 骨架五段（結論先行 / 逐檔含數字表 / 答案含翻盤條件 / 必須 surface / 待拍板 A-B-C）。

**四條硬規則**（皆為本次實戰教訓）：
1. 結構性提問先驗「素材落檔了沒」——沒落檔前的結構裁決都是猜的（Lesson #282）
2. 口頭承諾必單獨列（系統中通常零紀錄）
3. user 裁示「先不動」的照樣落檔、`extracted_to` 註明裁示日期，避免下次誤判未處理
4. 不預設 user 會接受邀約——會談中的合夥/投資提議是**事實**不是**決定**，專案 INDEX 改寫要等明確拍板

**同批 lessons**：#282（真缺口是輸入未捕捉非結構）、#283（建議與翻盤條件成對交付）、#284（傘層價值四指標量測）。

## 2026-06-02 — 中文自動繁體化（s2tw）+ 領域詞 prompt（N≥2、user「直接 go」ship）

**來源**：EthanReels 短影音課 42 課轉錄自建管線證明兩件事，且 audio-transcribe 是高頻 skill、過去**每次中文轉錄都繁簡混雜**（N≥2 達閾值）：

1. **中文自動繁體化**：`transcribe.sh` / `transcribe-cloud.sh` 語言為 `zh*` 時，輸出自動過 `opencc s2tw`（共用 helper `workspace/tools/_s2tw.py`）。Whisper-large-v3 對 zh 架構級偏簡體 → 過去輸出繁簡混雜。`--no-trad` 可關。
2. **`--prompt` initial prompt**：cloud 傳 Groq `prompt`、local 傳 faster-whisper `initial_prompt`，降低專有名詞誤聽（實證：無 prompt「短影音」被聽成「丹盈盈/端影音」、加領域詞 prompt 後歸零）。

**關鍵取捨**：用 `s2tw` **不用 `s2twp`——s2twp 會把口語「腳本」誤在地化成 IT 詞「指令碼」、「類型」→「型別」。台灣講者說的本來就是台灣詞、Whisper 抓的是「音」、s2tw 修字形即可。**

**驗證**：macOS `say` 生中文音檔 → cloud 轉錄帶 prompt → 輸出「…短影音的製作…練習網感跟腳本」全繁體、零簡體、腳本未被誤轉。

**可重用管線全貌**（含 Vimeo domain-lock 抽音訊 + Firebase token 繞登入）→ memory `reference_course_transcription_pipeline`。

## 2026-05-29 — 「轉錄完成輸出」+ 諧音 surface 格式硬化（N=1 user 拍板）

**L 案例**：峰哥檔案講解.m4a session 兩次 N=1 user 反饋達 SKILL B7「工具偏好變更」立即 ship 條件：
1. 第一輪諧音表只給「Whisper 聽出 / 行號 / 推測 / 信心」、user 喊「要校稿的前後文給我一下」、重 grep `-B 2 -A 2` 補引文
2. 分流完成只給落點表、user 喊「給個摘要吧」、重補 5 段內容摘要

**Ship 動作**：
- 「做什麼」段 append：分流 + 諧音 surface 後 default 主動給「內容摘要」、不等 user 喊
- 「Sanity check 流程」第 3 點補：surface 諧音必含 transcript 行號 + 前後 ±2-3 行 raw 引文
- 「反模式」表 append：諧音表只列推測詞 + 信心無 raw 引文 → 必附 ±2-3 行 snippet

**配套教訓**：scope 為「直接補一行規則」= meta-skill §觸發 第 4 條「小 patch、不走 A→E」、純 directive 不寫 dated meta-prose（對齊 [[feedback_instruction_file_no_meta_prose]]）、dated lesson hook 留 changelog 不留 SKILL.md 本體（對齊 §7 body 純度）

## 2026-05-28 — Wave 3 audit retrofit

- 264 → 縮減（拆 references/ + templates/）
- 個資 placeholder 化（協作者 / 同事 / 客戶 / 朋友 / 專案名）
- L1/L2/L3 + 諧音案例 → `references/cases.md`
- Speaker attribution 雙模板 → `templates/speaker-attribution.md`

## 2026-05-22 — A/C 軸內容分流 protocol 確立

User 拍板「分流是轉錄的一部分、不可斷在 pending」。

**Trigger**：5/22 Cowork session 跑 5 檔 A/C 轉錄、corpus-link 完，user 一切換任務、實質分流就斷在 pending、隔天才補。

**結論**：轉錄 + corpus-link ≠ 結案。A/C 軸 transcript 的內容分流必須在同一個收尾流程做完。

**Ship 動作**：
- 新增「Corpus link → {PERSONAL-CORPUS} 自動 link」段
- 新增「A/C 軸內容分流 protocol」段（內容分流決策表 + 狀態機 enforcement）
- 改 in-house attribution（砍 gemini-worker，已 archive 至 `~/.claude/agents/_archived/`）
- 修反模式段 L116 改 in-house

## 2026-05-22 — Speaker attribution best-effort 心法

User push back「不能判斷就跳過、信心指數就好、不用拘泥」→ attribution 規則改：
- 不要 inline 標每段
- 整檔加 Summary block 即可
- 多人對話信心通常 50-65%（≥3 人會更低）
- 獨白 100%

## 2026-05-15 — Sanity check 流程確立（N=2 達閾值）

兩個觸發案例：
1. **5/14 Khmer + 越南 + 靜音段大量幻覺**：3 段 AI 教學音檔 Whisper auto language，靜音 + Khmer 段跑出大量「lalaschool」「Ghiền Mì Gõ」「請訂閱頻道」訓練 corpus 高頻段
2. **5/9 純英文音檔短詞諧音幻覺**：用戶英文音檔、Whisper language=en 設定下仍把短專案名（柬籍 speaker 唸法）聽成英文常見字。被直接複製進 INDEX deadline 表 pushed 到 remote，user 親自掃 INDEX 才發現抓包

**Ship 動作**：新增「未知 entity sanity check」段（三類幻覺 + sanity check 5 步 + 反模式）

## 2026-05-08 — Router 升級 + SKILL ship 反思

**L1 案例**：誤讀舊 SOP 文件、準備跑本機 large-v3 + 手動切 61 min 大檔。協作者即時擋下「我記得我們默認的做法是走 API？」

**L2 案例**：建本 SKILL 第一版時直接指 `transcribe-cloud.sh`、漏掉 router（4/26 `transcribe.sh` 已升級為 router、預設 cloud）。第二輪收尾才發現。

**教訓**：建 SKILL 前先讀 `workspace/tools/README.md` inventory，否則複製過時 SOP 的錯誤指引。

## 2026-04-26 — Router 升級

`workspace/tools/transcribe.sh` 從直跑 → router 模式（預設 cloud + `--local` fallback）。
