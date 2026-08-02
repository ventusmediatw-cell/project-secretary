---
name: audio-transcribe
description: "錄音轉錄 SOP — Groq cloud（自動壓縮 25MB）為預設、router `~/workspace/tools/transcribe.sh` 為唯一入口、本機 faster-whisper 僅 fallback。Make sure to use this skill whenever the user says 「新錄音來了 / 這個錄音 / 幫我轉錄 / transcribe」、列出 `.m4a` / `.mp3` / `.wav` / `.mp4` / `.MOV` 檔案路徑、或詢問 transcribe 工具/SOP — even when they describe the same intent without these exact words. **不處理**：B/E 軸後續分流（→ 下游 project path、落點對照見 references/system-config.md）/ KB ingest（→ knowledge-base）。"
---

# Audio Transcribe — 錄音轉錄 SOP

> 📝 **Placeholder 慣例**：本 SKILL 主體用 placeholder（`{COLLABORATOR-PRIMARY}` / `{TEAM-MEMBER-A}` / `{CLIENT-PROJECT-A}` / `{INTERNAL-ORG}` 等）。實名 ↔ placeholder 對照在 `references/_private-glossary.md`（**gitignored、不對外**）。SKILL 對外乾淨、user / AI grounded 時讀 glossary。

## 觸發條件

- 使用者提到：新錄音、錄音檔、這個錄音、幫我轉錄、transcribe
- 列出 `.m4a` / `.mp3` / `.wav` / `.mp4` / `.MOV` 檔案路徑
- 詢問 transcribe 工具或 SOP

## 何時不觸發

- 純 LLM 對話、不需轉錄
- 使用者明確說「不轉錄」/「之後再說」
- B/E 軸下游分流動作（已在後續分流段定義、不二次觸發本 SKILL）

## 做什麼

- 走 router `~/workspace/tools/transcribe.sh`（Groq cloud 預設）
- 自動壓縮（25MB 上限）+ 不手動切片
- 軸線判斷（A/B/C/E）+ 對應語言預設 + 對應下游落點
- A/C 軸：自動 link {PERSONAL-CORPUS} + speaker attribution（in-house、整檔 Summary block）
- B/E 軸：cp 到下游 project path（`{TEAM-COMMS-PATH}` / `{CLIENT-MEETINGS-PATH}` / `{INTERNAL-OPS-PATH}`）
- A/C 軸內容分流（個人行動 / 投資 thesis / 教學素材 / 平台情報 / 知識）
- Whisper 諧音 entity sanity check（複製到 pushed content **之前** 必跑）
- Entity 校正塊：user 核完寫檔頭表格覆蓋、**正文永不改**（含行號位移註記）
- 多檔一次匯出 → **先跑批次前置**：音訊 hash 去重 ＋ 內容錨點反推錄音日（metadata 不可信）
- 批次會談錄音（≥3 檔同場）→ 收斂成**單一 debrief**，不逐檔分流逐檔回報
- 最終回給 user 的輸出：分流完 + 諧音 surface 後、default 主動給一份「內容摘要」（對話主軸 / 重要發現 / 新 idea/lead / 分流落點）、不等 user 喊「給個摘要」

## 不做什麼

- ❌ 不手動 ffmpeg 切片（cloud 會自動壓）
- ❌ 不用本機 faster-whisper（除非明確 `--local` fallback）
- ❌ 不直接呼叫 `transcribe-cloud.sh` 繞過 router
- ❌ 不寫 dated changelog / 個案 narrative / 實名到本 SKILL.md → 走 `references/`（實名走 `_private-glossary.md`）
- ❌ 不派 sub-agent 做 speaker attribution（in-house only、2026-05-22 拍板）
- ❌ A/C 軸 transcript 不可留 `status: pending`（分流是轉錄的一部分、必同 session 完成）

## 唯一正確入口：Router

**`~/workspace/tools/transcribe.sh`** — Router。預設走 Groq cloud，`--local` fallback faster-whisper。**統一入口，未來 router 升級全部 inherit**。

```bash
bash ~/workspace/tools/transcribe.sh /path/to/audio.m4a zh         # 基本：cloud；語言 en（預設）/ zh / auto
bash ~/workspace/tools/transcribe.sh "https://youtu.be/<id>" auto  # YouTube URL 模式 → Gemini ASR
```

完整 flag（`--keep-audio` / `--out` / `--local` / `--prompt "領域詞"` / `--no-trad`…）見 `transcribe.sh` 檔頭 usage / `--help`。

**YouTube URL 模式**：第一個位置參數是 `http(s)://` URL 時，router 自動轉交 `yt_transcribe.py` → 用 Gemini `gemini-3.5-flash` 直讀 YouTube URL 做 ASR（Google 讀自己的影片、零下載、繞過 PO Token/SABR 牆），輸出一樣落 `transcripts/`、一樣過 s2tw。**取代已死的 yt-dlp 下載路線**（見 [[reference_youtube_potoken_wall]]）；KB 的 `fetch_youtube.py` 也已接同一條 fallback。私人/登入牆影片走 `browser-ops` UC1。長片單次輸出截斷會自動分時段重抓。

**中文預設自動繁體化**：語言為 `zh*` 時，輸出自動過 `opencc s2tw` 轉台灣繁體（Whisper 對 zh 架構級偏簡體）。用 `s2tw` 不用 `s2twp`——避免把口語「腳本」誤在地化成 IT 詞「指令碼」。`--no-trad` 可關閉。
**`--prompt "領域詞..."`**：餵 initial prompt 降低專有名詞誤聽（如「短影音」被聽成「丹盈盈」）；cloud=Groq prompt、local=faster-whisper initial_prompt。領域詞多的內容（教學課、專業訪談）建議帶。共用後處理 `_s2tw.py`。

**底層實作（一般不直接呼叫）**：
- `transcribe-cloud.sh` — Groq Whisper Large v3 Turbo（router 預設走這個）
- `transcribe.sh --local` 內部分派 → `faster-whisper`（CPU-only fallback）

**處理時間參考**：7 min → 6 秒；60 min → ~17 秒(含自動壓縮)。

## 反模式（不要做）

| ❌ 錯誤 | ✅ 正確 |
|--------|--------|
| 看到大檔（>25MB）就手動 ffmpeg 切片 | cloud 會自動壓縮 mono/16kHz/32kbps，60 min 壓完約 14MB |
| 用本機 faster-whisper（CPU 跑 30+ 分鐘） | cloud 10-20 秒 |
| 跑 {INTERNAL-ORG} 專案下的 `scripts/transcribe.sh` | 已 deprecated，走 `~/workspace/tools/transcribe.sh` router |
| 直接呼叫 `transcribe-cloud.sh` 繞過 router | 走 router `transcribe.sh`（router 預設就是 cloud，且未來升級會 inherit）|
| 看 `{TEAM-COMMS-PATH}/sop.md` 舊段落自己 SOP | 該檔已指向本 skill，以本檔為準 |
| {INTERNAL-ORG} 場景預設 zh 或 auto | {INTERNAL-ORG} 預設 `en`（{COLLABORATOR-PRIMARY}↔{TEAM-MEMBER-A} / 外籍合作對象英文為主） |

## 唯一需要切片的情況

`transcribe-cloud.sh:76-102` 已內建 25 MB 自動壓縮。**只有壓縮後仍 >25 MB 才需要切**（極少見，3 小時以上才會踩到）。要切時用 ffmpeg `silencedetect` 找自然停頓（避免切到中句）：

```bash
ffmpeg -i input.m4a -af "silencedetect=noise=-30dB:d=0.8" -f null - 2>&1 \
  | grep silence_end | awk '{print $5, $8}'
# 挑 silence_duration 最長的點切
ffmpeg -y -i input.m4a -ss 0 -to <split_sec> -c copy part1.m4a
```

**切片後合併必用 python、不要用 shell `echo`／`sed`**：多位元組中文（會議名/label）經 shell `echo` 組標題或 `sed -i ''` 改 frontmatter，會把 CJK 位元組截成非法 UTF-8（標題行損毀、`sed: illegal byte sequence`）。合併＝各段取第 3 個 `---` 後的 body、接在一份乾淨 frontmatter＋標題下；frontmatter 的 `status`/`extracted_to` 編輯同理走 python。（Lesson 2026-07-14：女裝/男裝/Selfmade記錄 標題行被 sed/echo 損毀、python 重合併修復。）

**Groq 免費 tier 每小時音訊上限（ASPH 7200s＝2hr/hr）**：除 25MB 單檔上限，一次轉多場長會議（總時長 >2hr）會連續 429 `rate_limit`。解法：切 15min 小段（每段 900s 易回補）＋解析 429 的「try again in Xs」等待重試（floor ~240s、skip-not-halt）＋`caffeinate -i` 防長 job 睡眠中斷。是額度天花板非 bug，>2hr 本就要分批等 ~1.5-2hr。


## 語言預設邏輯

| 場景 | 預設 |
|------|------|
| {INTERNAL-ORG} 任何錄音（{COLLABORATOR-PRIMARY}↔{TEAM-MEMBER-A}、客戶 intake、{REGION-COLLEAGUES}） | `en` |
| 使用者個人中文 1on1 / 會議 | `zh` |
| 不確定 / 中英混雜 | `auto` |
| **高棉/寮/緬等低資源語言、或高棉夾雜的會議** | **不走本 router**（Whisper 出亂碼）→ `~/workspace/tools/km_translate.py`（Gemini 多模態、鎖語言、出繁中或英文譯文；[[reference_low_resource_lang_stt]]。2026-07-11 補路由 — 原缺口：工具在用但 SKILL 無指向） |

## 輸出路徑

`transcribe-cloud.sh` 預設輸出 `~/workspace/transcripts/<date>-<slug>.md`，含 frontmatter：

```yaml
audio_file: <basename>
audio_deleted:
created: <YYYY-MM-DD>
language: en|zh|auto
model: groq-whisper-large-v3-turbo
status: pending      # 待後續 extract 後改 extracted
extracted_to:        # 後續萃取目的地
expires: <30d 後>    # transcripts/ sweep 邊界
```

音檔自動 mv 到 `~/Downloads/_transcribed/`（Mac）或 `workspace/transcripts/_audio_buffer/`（Cowork），7 天後 `transcripts-sweep.sh` 清掉。

**誰在跑 sweep**：launchd `com.ventus.secretary.transcripts-sweep`（週日 18:30、`--apply --yes --audio-only`、log → `~/Library/Logs/transcripts-sweep.log`）。只自動砍音檔；過期 `.md` 只列進 log 等人拍板，要砍手動跑 `bash tools/transcripts-sweep.sh --apply`。孤兒閘：音檔在 workspace 全樹查無 `.md` 引用其檔名 → 保留不砍（＝沒轉錄過的檔不會被靜默刪掉）。

## Corpus link → {PERSONAL-CORPUS}（2026-05-22 user 拍板）

> 所有 **A 軸**（user 獨白 / user 與 AI）+ **C 軸**（user 與朋友線下）transcript 自動 link 進 `~/workspace/ideas/{PERSONAL-CORPUS}/INDEX.md` 的「已連結的素材」段。{PERSONAL-CORPUS} = user 自我蒸餾 personal corpus idea，A/C 軸 transcript 都是 corpus 素材。

### 軸線判斷

| 軸線 | 觸發條件 | 例 | 處置 |
|------|---------|-----|-----|
| **A 軸** | user 獨白 / 規劃 / 思考 / 解釋 / user 跟 AI 對話 | 「明天要做的事」「解釋AI」 | 自動 link {PERSONAL-CORPUS} |
| **C 軸** | user 跟非業務朋友的線下對話 | 「{FRIEND-A}閒聊」「{FRIEND-B} 向量篇」 | 自動 link {PERSONAL-CORPUS} + 做 attribution |
| **B 軸** | user 與員工（{COLLABORATOR-PRIMARY}/{TEAM-MEMBER-A}/{TEAM-MEMBER-B}/{TEAM-ROLE-AM}）| {COLLABORATOR-PRIMARY}↔{TEAM-MEMBER-A} meetings | **不 link {PERSONAL-CORPUS}**，走 {TEAM-COMMS-PATH} |
| **E 軸** | user 對外輸出（letters / 公告） | outbox | **不 link {PERSONAL-CORPUS}**，走 {INTERNAL-OPS-PATH} |

### 動作

1. 轉錄完成 + 走完 entity sanity check 後
2. 判斷軸線（A/C → 自動 link；B/E → 走原下游分流；混合 → 走主軸 + flag）
3. Edit `~/workspace/ideas/{PERSONAL-CORPUS}/INDEX.md` 的「W21 / 本 session 已連結的素材」段，append 一條：
   ```
   - `transcripts/<file>.md`（字數 / 軸線 / 對話對象 / 主題 keywords / attribution status）
   ```
4. C 軸（多人對話）必跑 attribution（見下段）

### Speaker attribution（C 軸多人對話）— in-house

**現況**：無 pyannote/WhisperX diarization（b9 候選未升）。**2026-05-22 user 拍板 in-house only，不派 sub-agent**（gemini-worker 已 archive）。

#### 流程

1. Claude 讀 transcript 全文、用語氣 + 內容線索 + project context 判斷
2. **不要 inline 標每段**（2026-05-22 user push back「不能判斷就跳過 信心指數就好 不用拘泥」）— **整檔加 Summary block 即可**
3. 線索來源：{PERSONAL-CORPUS} thesis 細節（user 提的專案 / 框架 / 術語）+ 朋友 voice profile（從歷史 transcripts 累積）
4. 校稿完將 `pending verification` 改 `verified`；{PERSONAL-CORPUS} corpus 才採用 verified attribution

#### Speaker attribution 模板（多人 / solo 雙版本）

兩個模板（multi-speaker + user solo）+ best-effort 心法 → `templates/speaker-attribution.md`。

抄改提示：
- **不能判斷就跳過、整檔給信心指數即可**（不要拘泥每段標）
- 多人對話信心通常 50-65%；獨白 100%
- 諧音 entity 列得越完整、user 校稿越快

## 後續分流（讀完內容才知道）

**轉錄完不算結案**。要讀 transcript 判斷會議性質：

| 內容類型 | 目的地 |
|---------|--------|
| {COLLABORATOR-PRIMARY}↔{TEAM-MEMBER-A} 會議（內部營運/招募/制度/confrontation） | `{TEAM-COMMS-PATH}/meetings/raw/YYYY-MM-DD-topic.md` |
| 客戶 intake / 商務會議 | `<project>/refs/client-meetings/YYYY-MM-DD-<client>.md` |
| 員工 1on1（HR 性質） | `{HR-PATH}/1on1/YYYY-MM-DD-<name>.md` |
| user 個人 / 朋友線下 | 留在 `~/workspace/transcripts/`（30 天過期）+ **自動 link {PERSONAL-CORPUS}** |
| 其他不歸專案 | 留在 `~/workspace/transcripts/` |

**萃取流程**（如需 cp 到 project）：
1. `cp ~/workspace/transcripts/<source>.md <project_path>/<topic-renamed>.md`
2. 更新原 transcript frontmatter：`status: pending → extracted`、`extracted_to: <project_path>`
3. 後續產生 digest（`summaries/daily/`）時再做第二層萃取

## A/C 軸內容分流 protocol（2026-05-22 user 拍板：分流是轉錄的一部分、不可斷在 pending）

> **轉錄 + corpus-link ≠ 結案：A/C 軸 transcript 的內容分流必須在同一個收尾流程（同 session）做完、不可斷在 `pending`。**（起源實例見 `references/cases.md` §A/C 軸分流斷鏈）

### 內容分流決策表（A/C 軸讀完內容後逐條歸位）

| 內容類型 | 目的地 | 寫法 |
|---------|--------|------|
| 個人行動 / 規劃 / 排序 / deadline | 主 `INDEX.md` W21 plan（surgical edit 進對應 P 項）+ 待辦事項 | 標來源 transcript + 行號；新行動項用 `[專案]` tag |
| 財務 / 投資 thesis / 策略線索 | 對應財務專案 `memory.md`（`{FINANCE-PROJECT-A}` / `{FINANCE-PROJECT-B}` / `{FINANCE-PROJECT-C}` / `{FINANCE-PROJECT-D}`、glossary 對照） | **標 lead（未驗證）+ attribution 信心**；多人對話來源信心通常 50-65% |
| 對外教學 / AI 哲學 / 框架素材 | `projects/project-secretary/refs/`（V1.0 課綱）| 整理成教學骨架、連回 P1.e/P3.e |
| 平台 / 工具情報（新 model / IDE / 對手動向）| 主 `INDEX.md` 對應研究 todo **定錨**（把模糊 surface 補成具體結論）| 標諧音來源行號 |
| 外部知識 / 方法論（非 user 原創）| `knowledge-base/`（走 KB SKILL 入庫流程）| — |
| 純 personality / voice / 自我蒸餾訊號 | `ideas/{PERSONAL-CORPUS}/INDEX.md`（已 corpus-link）| 必要時抽 2-3 句金句進 thesis 段、否則 link 即可 |
| entity 諧音待 user 確認 | 標 ⏳ 待確認、**不阻擋其他內容分流** | 列進「可疑 Whisper 諧音」+ surface 給 user |

> 一個 transcript 常跨多個目的地（如「{FRIEND-A}閒聊」→ `{FINANCE-PROJECT-A}` + `{FINANCE-PROJECT-D}` + {PERSONAL-CORPUS}）。逐類分流、`extracted_to` 用分號分隔全部落點。

### 狀態機 enforcement（收尾必跑）

1. A/C 軸 transcript 內容分流完 → 回填 frontmatter：`status: pending → extracted`、`extracted_to: <落點1>; <落點2>; ...`
2. **轉錄 session 結束前自檢**：每個 A/C transcript 的 `status` **不該留 `pending`**。留 `pending` = 分流未完成的紅旗。
3. 確實無可分流內容（純閒聊、零行動/知識）→ 仍翻 `extracted`，`extracted_to:` 寫 `{PERSONAL-CORPUS} (corpus link only, 無實質分流)`，避免下次誤判未處理。
4. 諧音 entity 待確認**不算**未分流：照常 extracted、待確認項另標 ⏳ 留 transcript 內。

> **參考實作**：`inbox/2026-05-22.md` Cowork 分流 session（5 檔 A/C 軸全分流 + 本 protocol ship）。

## 批次前置：去重 ＋ 錄音日判定（多檔一次匯出時必跑）

**1. 去重用「解碼後音訊 hash」，不是檔案 MD5。**
重新匯出會改 container metadata → 檔案 MD5 不同、音訊相同。照檔案 MD5 判會重轉、重分流、在 corpus 產生重複條目。

```bash
# 對 _transcribed/ 同名檔比對音訊本體
ffmpeg -v error -i "$f" -map 0:a -f md5 -
ffmpeg -v error -i "_transcribed/$f" -map 0:a -f md5 -
```

**2. 錄音日一律不能信 metadata。**
`format_tags=creation_time` 在匯出時會被蓋成匯出當下時間（實例：10 檔全 stamped 同一秒）。改用**內容錨點反推**：

| 錨點 | 例 |
|---|---|
| 內容引用了某個有時間戳的產物 | 「6 萬／28 小時」命中 7/25 23:59 才交付的報告 → 錄音必在其後 |
| 內容講「昨天／今天」＋已知事件 | 「昨天的經驗…雷大已經跑完了」→ 昨天＝7/25 導入日 |

**推論鏈寫出來給 user 確認後才進檔名**——檔名日期會汙染 corpus 索引，改一次要動全批檔案。

**3. 序號跳號 ≠ 檔案遺失。**
iOS 語音備忘錄序號會被使用者改名／刪除打斷。盤點只能證明「現在沒有」、不能證明「本來該有」→ **先問 user，不要寫進耐久檔當缺檔警示**。

**4. collision 檢查有時效。**
動檔前重跑一次，不沿用幾分鐘前的結果（實例：驗完 hash 到動手之間隔 13 分鐘，user 自己把檔刪了）。

（Lesson #305、#306）

## 批次會談錄音 → 單一 debrief

**觸發**：同一場會談／同一趟出差產出 **≥ 3 檔**錄音，且 user 問的是「這些東西該怎麼辦 / 該怎麼組織」。

**不要**逐檔分流逐檔回報。**要**收斂成一份 debrief，理由：批次會談的議題是交錯的（同一件事散在三個檔），逐檔摘要會把它切碎。

### 流程

1. **一批轉完再讀**，不邊轉邊摘。先算總時長對 Groq 每小時 7200s 上限（超過分批等 ~1.5-2hr）
2. **全檔讀進來**再判斷主軸——檔名不可靠（「星巴克」可能是地點不是主題），最長的那檔通常是主軸
3. **收斂成一份** `refs/YYYY-MM-DD-<對象>-<地點>-debrief.md` → 套 paired 模板出 HTML（[[feedback_deliverable_html_format]]）
4. **entity 校正塊**寫進密度最高的那檔（見 §Entity 校正塊），其餘檔在 debrief 引用
5. 全部 transcript `extracted_to` 指向該 debrief

### debrief 骨架

| 段 | 內容 |
|---|---|
| 結論先行 | 一句話。user 問什麼就先答什麼 |
| 逐檔是什麼 | 每檔一段，含**可查證的數字表**（單位經濟／分潤／成本），不要只有敘事 |
| 問題的答案 | 若涉結構決策 → 必附**證據**與**翻盤條件**（Lesson #283） |
| 必須 surface 的 | 撞題／未追蹤的口頭承諾／entity 待核 |
| 待拍板 | A/B/C 選項，不要開放式問句 |

### 硬規則

- **結構性提問先驗「素材落檔了沒」**：user 問「該怎麼組織這批東西」時，先查 inbox/專案有無該次會談紀錄。沒落檔前的任何結構裁決都是猜的（Lesson #282）
- **口頭承諾必單獨列**：會談錄音裡的「我幫你做 X」「開價多少」「答應了」在系統中通常零紀錄，逐檔摘要最容易漏掉
- **user 裁示「先不動」的項目照樣落檔**，只是不執行——`extracted_to` 註明「內容決策 user YYYY-MM-DD 裁示暫不動」，避免下次誤判未處理
- **不預設 user 會接受邀約**：會談中的合夥／投資／分潤提議 = 事實，不是決定。落檔記事實，專案 INDEX 改寫要等明確拍板

## 逐字稿 → 對外交付：四維核對（產物要給 user 以外的人看時強制）

**觸發**：轉錄產物要變成**發給第三方**的東西（客戶／合作方團隊／學員／對外報告）。內部消化不必跑。

派 4 個 finder，**每維各配 1 個 verifier**（prompt 明寫「預設懷疑、你的任務是推翻它、不確定就判為有問題」）：

| 維 | 找什麼 |
|---|---|
| entity | 諧音／未知專名／數字 anchor／**音質崩壞不可採信區段**（列出行號範圍，這些不得進對外產物） |
| 敏感 | 在場他人的自白（資安習慣／帳號狀態）／來源坦白／第三方隱私／存取憑證與命名規則／金流稅務／貶抑性比較 |
| 完整性 | 逐檔獨有內容 → 跨檔骨架 → **有沒有哪一檔零覆蓋** |
| 口頭承諾 | 「我等下傳給你」「你回去做 X」／未解技術問題／未定案後續，各標「後續有沒有回頭處理」 |

### 硬規則

- **verifier prompt 必含「去檔案裡實際核對行號」**——finder 的行號會系統性偏移，這是最常出錯的一軸（Lesson #296）
- **必查「有沒有哪一檔完全沒被引用」**——整檔零覆蓋是靜默失敗，不主動問就看不見（實例：sensitive agent 從沒讀檔1，唯一那句檔1 引文被標成檔2）
- **給 finder 的真相源詞表要標「防呆用、不得寫進結果當作稿內出現過」**——否則會被當成稿內事實回填（實例：`Haiku` 被寫進模型階梯並掛上假行號，全 6 檔從未出現該詞）
- **數字 anchor 兩兩對帳＋回本地檔案驗**：口語場合的數字是氣氛值不是事實。實例：「第 32 週、超過半年」與同批「3/16 第一次創造」互斥，`date` 算出 131 天＝18.7 週（Lesson #297）
- **從別處 `cp` 進交付資料夾的檔案，打包前重跑 `cp` 並比 mtime**；交付物含 ≥2 檔時**跑跨檔數字一致性複驗**——來源可能正被另一條 session 改（Lesson #298）
- **在場他人的自白一律去識別改寫，不是刪掉了事**——留通則、拿掉主詞與可辨識細節

## 敏感性

- `{TEAM-COMMS-PATH}/meetings/` 在 `{INTERNAL-VCS-EXCLUDE}` 排除清單，本地 only，不推 {INTERNAL-ORG} repo
- `~/workspace/transcripts/` 不該推 git（原始逐字稿含敏感對話）
- 引用原話僅供 user 內部 / 私人參考

## 常見錯誤回顧（L1-L3）

3 條案例（L1 誤讀舊 SOP / L2 漏看 inventory / L3 批次漏檔）→ `references/cases.md`。

## Transcript 後處理：未知 entity sanity check

> 教訓 N=2 達閾值成硬規則：(1) 靜音 + 非英文段會湧出訓練 corpus 高頻幻覺；(2) language=en 設定下短專案名仍被諧音成常見英文字、曾直接進 pushed content 才被 user 抓包。兩案 postmortem 全文見 `references/cases.md` §Whisper 幻覺案例。

### 三類典型 Whisper 幻覺

1. **語言切換段幻覺**：非英文段 + 靜音 → 訓練 corpus 高頻段（YouTube subscribe / lalaschool / Ghiền Mì Gõ）。處理：**Claude in-house 過一輪**（2026-05-22 user 拍板砍 gemini-worker、改 in-house）、可疑段標 `[可能幻覺?]` 前綴
2. **短英文諧音幻覺**：短專案名 / 業務術語被諧音替換為常見英文單字（`{CLIENT-PROJECT-A}` → looming / `{TEAM-MEMBER-C}` → so phone / `{TEAM-MEMBER-B}` → Belina / Berlina 偶有；實名見 `_private-glossary.md`）。處理：見下方 sanity check 流程
3. **語法不通強制成句**：Whisper 對破碎句、語法錯誤仍 force-output 完整句、可能加料

### Sanity check 流程（複製 transcript 內容到 pushed content **之前**必跑）

> 與 `{TEAM-COMMS-PATH}/sop.md` §5 抓全文鐵律同根：**「不對照 ledger 就動筆」家族**（Lesson #149）。Transcript 場景 forward apply。

1. **識別 entity 類別**：人名 / 專案名 / 數字 anchor / 業務術語 / 框架 code
2. **grep 對照本地真相源**：
   - 人名 → `{INTERNAL-MEMBER-PROFILES}`（注意內部版可能 vcg-excluded）
   - 專案名 → 主 `workspace/INDEX.md` + sub-project INDEX
   - 數字 anchor / financial figures → 對應 `memory.md` 或 `refs/finance/`
   - 框架 code（B2-2 / B2-5 等）→ grep `outbox/replies/` 找 framework 全文
3. **找不到 / 不確定** → 標 `[?未知 entity，待核]` 或 attribute 來源（"user 5/15 拍板"），**不直接複製進 pushed content**；surface 給 user 校稿時、表格必含 **transcript 行號 + 前後 ±2-3 行 raw 引文**、不能只給 candidate 詞 + 信心數字（user 無 context 無法校）
4. **英文短詞（≤ 6 字母）+ transcript 含柬籍 / 非英文母語 speaker → 預設可疑、強制 sanity check**（不論 language=en 設定）
5. **數字 anchor 必對照本地 baseline**（如「110 天」vs INDEX 寫的「5 個月窗口」/「9/30 deadline」是否一致）— 不一致即可疑
6. **user 核完 → 寫「entity 校正塊」進 transcript 檔頭，正文一律不改**（見下段）

### Entity 校正塊（user 核完後必寫）

**正文＝原始證據，永遠保持 Whisper 原始輸出未修改。** 校正只以檔頭表格覆蓋，不做 find-replace。

理由：改了正文就再也分不出「Whisper 聽到什麼」與「我們認定是什麼」，日後 re-check 諧音、換模型重跑對照、追錯誤來源全部失據。

插在 frontmatter 之後、正文 `---` 分隔線之前：

```markdown
## Entity 校正對照（YYYY-MM-DD user 核）

> 下方逐字稿正文為 **Whisper 原始輸出，未修改**。專有名詞以本表為準。
> ⚠️ 表中行號為**原始轉錄**編號；本校正塊插入後，正文實際行號 **+N**（例：原 L519 → 現 L534）。

| 逐字稿寫法 | 正確 | 狀態 |
|---|---|---|
| {Whisper 聽出} | {正確寫法} | ✅ user 核 |
| {Whisper 聽出} | {推測}？ | ⏳ 待核 |
| {Whisper 聽出} | — | ⏸ user 表示先不處理 |
```

三個狀態標記缺一不可：`✅ user 核` / `⏳ 待核` / `⏸ user 表示先不處理`——**「先不處理」必須與「待核」分開**，否則下次進來會重問已經問過的。

**行號位移註記是硬要求**：插入校正塊會讓正文行號整體位移，不註記則表中行號全部失效、user 點過去看到錯的段落。位移量 ＝ 插入的行數。

多檔批次時，校正塊只寫進 **entity 密度最高的那一檔**，其餘檔在 debrief 引用該表，不重複維護。

（Lesson #282-284 家族：對照 ledger 後的結論要留痕，不要就地覆蓋原始輸入。）

### 反模式（不要做）

| ❌ 錯誤 | ✅ 正確 |
|--------|--------|
| transcript 直接 copy-paste 進 INDEX / outbox letter / digest | 先過 sanity check、不確定的 entity 標 `[?]` 或留 internal-only |
| Whisper language=en 設定 = transcript 無諧音風險 | Whisper 對柬籍 / 非英文母語 speaker 短英文詞仍會諧音替換 |
| 「3 個獨立 grep 都無命中 = entity 不存在」推論「Whisper 對」 | 反過來：grep 無命中是「entity 可疑」最強訊號，必 surface 給 user 核 |
| 諧音表只列「Whisper 聽出 / 行號 / 推測 / 信心」 | 必附「**前後 ±2-3 行 raw snippet**」、行號可 click 但 user 不會去翻檔 |

## References

- 設計演化 + dated patches → `references/changelog.md`
- 軸線 / 語言 / 落點 internal mapping（B/E 軸下游落點對照）→ `references/system-config.md`
- L1-L3 + Whisper 諧音 / 分流斷鏈案例 → `references/cases.md`；Speaker attribution 雙模板 → `templates/speaker-attribution.md`
