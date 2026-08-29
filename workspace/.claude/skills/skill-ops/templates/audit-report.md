# Skillset Audit Report — 範本（reader 抄了改用）
> 來源：個人 AI-secretary 系統的實戰演進；本出貨版已去識別化（實名／內部代號 → 佔位符）。

> 用途：跑 skill-ops §4 4 Tier audit 後、抄此範本寫 report。
> 限制：≤ 500 行。每條 finding 必須附證據檔名 + 日期（Benny 7 條 agent 硬規則第 6 條）。

---

# Skillset Audit Report — YYYY-MM-DD

## TL;DR

- 共 N 支 SKILL audit
- 進入 retrofit 排程 K 支（top 5 detailed）
- 候選退場 M 支（N=0 觸發、user 拍板）
- 共識 finding L 條（跨家族 review 或多次 audit 重現）

## Tier 1: anatomy 對照

> 對每支 SKILL 跑 `templates/anatomy-checklist.md`、列 ❌ 項目。

| SKILL | ❌ 項目 | 嚴重度 |
|---|---|---|
| skill-A | description 非 third-person / body > 500 行 | P0 |
| skill-B | references 第三態 / TOC 缺 | P1 |
| ... | ... | ... |

## Tier 2: boundary 與重複

> 跟其他 SKILL 比對：觸發重疊 / 做什麼衝突 / 互補/取代關係

| 衝突對 | 衝突點 | 建議處置 |
|---|---|---|
| skill-A vs skill-B | 觸發語 X 兩支都搶 | 改其一觸發語 |
| ... | ... | ... |

## Tier 3: 實際使用驗證

> 過去 30 天證據（inbox / handoff / lessons grep）

| SKILL | 觸發頻率 | follow ratio | 應觸發未觸發 | 警示模式 |
|---|---|---|---|---|
| skill-A | 5 次 | 80% | 0 | OK |
| skill-B | 0 次 | — | — | 退場候選 |
| ... | ... | ... | ... | ... |

## Tier 4: retrofit 排序

> priority = (impact × frequency) / cost、三項分數明文

| Rank | Finding | impact | frequency | cost | priority | action plan |
|---|---|---|---|---|---|---|
| 1 | skill-A description 非 pushy | 4 | 5 | 1 | 20.0 | 改 description |
| 2 | skill-B 退場 | 3 | 3 | 2 | 4.5 | 移 archived/ |
| ... | ... | ... | ... | ... | ... | ... |

## 對 user 的 propose

> 不動檔、列出 K 個 retrofit 候選請 user 拍板

- [ ] retrofit-1: ____________________
- [ ] retrofit-2: ____________________
- [ ] ...

## Memory + Lessons

- 升 N=1 條目：____________________
- 升 N=2 候選：____________________
- 達 N=3 升 SKILL：____________________

## 外部 review 驗證機制

> 對齊本系統「對外部 audit 也要驗 source-of-truth」原則

- 跨家族 review（第二家族模型）共識項：____________________
- 報告失真項（外部報告 vs 實際）：____________________

---

> 抄改提示：複製本範本 → 填入實際數據 → ship 為 inbox 或 handoff/pending/ 一份檔。
