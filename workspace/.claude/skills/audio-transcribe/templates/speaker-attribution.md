# Speaker Attribution Templates

> 抄了改用：兩種版本（多人對話 / user solo 獨白）。
> 配套規則見 SKILL.md §Speaker attribution 段。

---

## Template — 多人對話版

```markdown
## Speaker Attribution Summary（best-effort by Claude in-house、YYYY-MM-DD）

- **方法**：無 pyannote diarization、Claude 讀全文用內容線索 + 語氣 + project context 判斷
- **整體信心指數**：**~XX%**（解釋低/高的主因：人數 / Whisper 諧音密度 / turn-taking 切碎程度）
- **狀態**：pending user verification

### 段落主導者概略（行號對應原 transcript）

| 行號 | 主題 | 主導者 | 信心 |
|------|------|-------|------|
| L?-? | ... | **user / friend_name** | 高/中/低 |

### 高信號段（{PERSONAL-CORPUS} 視角）

- 列 2-3 條對 {PERSONAL-CORPUS} corpus 高價值的段（user identity / framework / project context）

### 可疑 Whisper 諧音 entity（待 user sanity check）

- 按類別列：金融 / AI 術語 / 人名 / 業務 / 地名 / 不明
```

---

## Template — user solo 獨白版

```markdown
## Speaker Attribution Summary（user solo、YYYY-MM-DD）

- **狀態**：100% user 獨白
- **信心**：~100%
- **A 軸定位**：（user 個人規劃 / metacognition / 內化框架對外解釋版 / 思考流式自言自語）

### user 引用他人

| 行號 | 引用對象 | 內容 |
|------|---------|------|
| L?-? | <name> | "<引用內容片段>" |

無外部引用則寫「無外部引用（純自己規劃）」

### 主題大綱

1. **L?-?**：...
2. ...

### 高信號段（{PERSONAL-CORPUS} 視角 / 週計畫對照）

- 列關鍵段 + 對應主 INDEX 週計畫條目

### 可疑 Whisper 諧音 entity

- 列清單、標已 user 校稿 ✅ vs 待確認 ⚠️
```

---

## 抄改提示

- 多人對話信心通常 50-65%（≥3 人會更低）；獨白 100%
- 諧音 entity 列得越完整、user 校稿越快
- **不能判斷就跳過、整檔給信心指數即可**（不要拘泥每段標）
