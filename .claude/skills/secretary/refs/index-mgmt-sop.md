# INDEX / memory 管理 SOP

> 完整 SOP。指針在 secretary SKILL.md，本檔按需讀取。
> 建立：2026-04-15。來源：index-mgmt-upgrade-discussion.md 三輪討論。

---

## 1. 檔案定位

| 檔案 | 定位 | 目標行數 |
|------|------|---------|
| **INDEX.md** | 身份證 — 當前狀態 + 未完成待辦 + 導航 | < 150 行 |
| **memory.md** | 累積知識 — 3 個月後仍有效的設計、決策、技術常識 | < 100 行 |
| **refs/** | 長流程 / 模板 / 填空格式 | 不限 |
| **refs/index-archive-*.md** | 已完成項 / 歷史快照 | 不限 |

INDEX/memory 只留一行導航指向 refs/，不放完整流程。

### 活躍專案列 schema

```
| [專案名](path/INDEX.md) | {定位 ≤10字} {狀態emoji} {里程碑 ≤15字} |
```

**狀態 emoji**：🟢 運作中 / 🟡 需注意 / 🔴 阻塞 / ✅ 階段完成 / ⏳ 待啟動 / ⛔ 暫停

**不放**：具體數字、下一步行動、期限（這些歸 W?? 週計畫 + 待辦 + 該專案 INDEX）。

**更新觸發**：
1. 里程碑達成/放棄 → 更新該列
2. 狀態降級（🟢→🟡 / 🟡→🔴）→ 立即更新 + 近期重點記錄原因
3. 停滯門檻：14 天無動靜 → 🟡，30 天 → 🔴，60 天 → ⛔ 候選
4. 每日晨檢比對各列狀態與該專案 INDEX last update，異常列入健康報告

---

## 2. SOP 抽離判準

### 前置過濾

**事件敘述類（已完成項 / 歷史快照）直接走 archive，不進入下方判準流程。** §2 判準只適用於活躍內容的抽離決策。已完成的 P0/P1/P2 事項、特定 event 復盤、歷史快照 → `projects/{name}/refs/index-archive-YYYYMMDD.md`。

### 活躍內容抽離判準

瘦身時主動掃描，符合 **2 項以上** → 候選抽離：

1. 有明確步驟或固定流程
2. 有固定格式 / 模板 / 填空範例
3. 會被重複觸發（同類任務每月至少發生 1 次，如 checkpoint 報告、handoff、週報）
4. 3 個月後仍有效
5. 長度 > 15 行 OR 與 memory/refs 既有內容重複 OR 屬已完成事件敘述

### 抽離前先問

「這是**怎麼做**還是**為什麼這樣設計**？」

- **怎麼做** → 抽 SOP / template 到 refs/
- **為什麼這樣** → 進 memory.md

例：「V2 策略三層架構設計」是設計常識（→ memory），不是 SOP。

### 抽出位置四層

| 類型 | 位置 | 例子 |
|------|------|------|
| 專案專屬 SOP/spec | `projects/{name}/refs/` | Elon `checkpoint-report-spec.md` |
| 跨專案流程模板 | `.claude/skills/{name}/` 或升級既有 Skill | debate-protocol |
| 純填空模板 | 對應 Skill 的 `templates/` 子目錄 | handoff templates |
| 已完成事件敘述 | `projects/{name}/refs/index-archive-YYYYMMDD.md` | Elon `index-archive-20260415.md` |

**archive 命名慣例**：`index-archive-YYYYMMDD.md`。同日多次瘦身同檔追加，不同日新檔。

**archive 檔案首段必含**：
1. 來源檔案（`INDEX.md` / `memory.md`）
2. 時間範圍（哪段期間的內容）
3. 觸發原因（哪次瘦身 / 何事驅動）

格式：`# {來源檔} 歸檔內容（YYYY-MM-DD {觸發原因}）`

---

## 3. 灰色地帶判準（memory vs INDEX）

- 3 個月後仍有效 → **memory**
- 會隨時間失效 → **INDEX / daily**
- 具時間性的觀察結論（live 運行數據、特定 event 復盤）超過 1 批新數據後進 archive，memory 只留通則
- **已驗證假設**：結論壓成 1 行留 memory，推理過程與數據佐證抽 archive。未驗證的假設留原位

### 範例

| 內容 | 去向 | 理由 |
|------|------|------|
| V2 策略三層架構設計 | memory | 設計常識 |
| 當前 event 350722 | INDEX | 快照，會過期 |
| CLOB API 用法 | memory | 技術常識 |
| 本週計畫 W16 | INDEX | 時效性 |

### memory 延伸閱讀

refs/ 超過 3 個時建議在 memory 尾段加「延伸閱讀」區塊，列出最重要的 3-5 個。不強制。

---

## 4. 整理節奏（分層）

| 頻率 | 動作 | 執行主體 | 成本 |
|------|------|---------|------|
| **每次收尾** | 只更新主 INDEX + 寫 inbox 日記（零檢查） | agent（review Skill） | 低 |
| **每日凌晨 02:09** | 秘書 Review（含晨檢職責，§5 詳述） | Cowork scheduled task `daily-secretary-review` | ~10K token |
| **每日首次 Code session** | 開機檔案斷鏈掃描 | SessionStart hook + daily-gate | ~500 token |
| **每週（週報 Step 6）** | 結構性瘦身：行數體檢 + SOP 抽離候選 + 搬 archive | agent | 高，15-30 分鐘 |
| **手動** | 使用者說「瘦身」「impact check」 | agent | 按需 |

---

## 5. 每日秘書 Review 內含晨檢三項

> 2026-04-15 更新：原獨立 `daily-secretary-morning-check`（08:30）已併入 `daily-secretary-review`（02:09）。Scheduled task 的 prompt 已包含下列 B7/B8/D3 步驟。

### 晨檢三項（由 Review Phase B7 / B8 / D3 執行）

1. **刷新主 INDEX 的 W?? 週計畫表狀態欄**（Review Phase D2 既有動作）
2. **呼叫 `.claude/scripts/impact_check.sh`** 掃開機檔案斷鏈（Phase B7）
3. **掃所有活躍專案 INDEX 行數**，> 150 行列入清單（Phase B8）
4. **健康報告整合至 Review 報告的「掃描範圍」與「診斷發現」區塊**（不再另寫獨立 sub-section）
5. **寫 / 替換 / 清除主 INDEX 警示行區塊**（Phase D3）：

#### 有問題時

在主 INDEX「系統狀態」區塊下方 insert 或 replace：

```
<!-- impact-check-alert -->
⚠️ YYYY-MM-DD 體檢：{專案A} {N}行 / {專案B} {N}行 / {M} 斷鏈 — 詳見 inbox/YYYY-MM-DD.md
<!-- /impact-check-alert -->
```

#### 無問題時

整個 `<!-- impact-check-alert -->` ... `<!-- /impact-check-alert -->` 區塊刪除（含 marker）。

#### 已存在今日警示時

替換為最新狀態，**不追加**。

### Scheduled task 註冊規格

晨檢三項已併入 `daily-secretary-review`（02:09 cron），不再單獨註冊 `daily-secretary-morning-check`。原 task 已於 2026-04-15 停用（`enabled: false`）。

> Code 端不建對等 scheduled task（防寫入衝突，SessionStart hook 已覆蓋）。

---

## 6. 影響性檢查 SOP

### 觸發時機

- **Claude Code**：SessionStart hook 每日自動（`.claude/scripts/startup_link_check.sh`）
- **Cowork**：scheduled task 每日自動 / 手動呼叫
- **手動**：使用者說「跑 impact check」

### 開機檔案（五大 + refs）

1. `CLAUDE.md`
2. `workspace/INDEX.md`
3. 任一 `projects/*/memory.md`
4. `.claude/skills/handoff/` 下任一檔
5. `.claude/skills/review/` 下任一檔
6. 上述檔案指向的任一 refs（`workspace/refs/`、`projects/*/refs/`）

### 執行步驟

1. 呼叫 `.claude/scripts/impact_check.sh <檔案路徑>`
2. 解讀輸出：
   - **BROKEN**（目標不存在）→ 必修
   - **SUSPICIOUS**（路徑存在但 anchor 不對）→ 評估
   - **CLEAN** → 通過
3. 修復所有 BROKEN 項
4. 搬動檔案時舊位置留一行 `> 已搬至 {新路徑}`（保留 3 個月，由週報 Step 6 清理過期導航）

### Cowork 手動呼叫方式

```bash
# Cowork 環境下（路徑可能需依掛載調整）
bash .claude/scripts/impact_check.sh workspace/INDEX.md CLAUDE.md
```

腳本會自動從自身位置推算根目錄，無需傳入絕對路徑。
