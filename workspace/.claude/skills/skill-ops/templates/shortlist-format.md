# Skill-Mining Shortlist 範本（reader 抄了改用）

> 用途：跑 skill-ops §1 Phase 3 結束時、抄此範本寫 shortlist。
> 限制：Hard cap = 5 skill 候選 + 1 automation 候選 + 不限「延伸既有」+ 明列 Skip。

---

# Skill Mining Shortlist — YYYY-MM-DD

時間窗：______ 天（預設 14、user 可指定）
掃描範圍：handoff / memory / inbox+lessons / 既有資產

## 主表格

| # | 重複 workflow | 證據（檔名 + 日期）| 頻率 / Confidence | 建議形式 | 為何值得 / 不值得 |
|---|---|---|---|---|---|
| 1 | ____________________ | ____________________ | 出現 X 次 / High | Skill / Subagent / Automation / 延伸既有 | ____________________ |
| 2 | ____________________ | ____________________ | 出現 X 次 / Med | _____ | ____________________ |
| ... | ... | ... | ... | ... | ... |

## Summary

- **Skill 候選總數**：N （cap 5）
- **Automation 候選總數**：M （cap 1）
- **延伸既有 建議數**：K
- **Skip 數**：J（連同 Skip 理由列出，避免「沒被掃」誤會）

## Skip 清單（明列、避免假漏）

| Skipped pattern | 為何 Skip |
|---|---|
| ____________________ | 太一次性 / 模糊 / 敏感 / 證據不足 |
| ... | ... |

## 4 source 分項摘要

- **Source 1 Handoff** 發現：____________________
- **Source 2 Memory** 發現：____________________
- **Source 3 Inbox+Lessons** 發現：____________________（須回活系統 verify）
- **Source 4 既有資產** 重疊提醒：____________________

## 問使用者拍板

「以上 N 個候選，要建立哪幾項？（回我編號）」

→ User 圈選後走 skill-ops §2 A→E（new skill）或直接 Edit（延伸既有）或 `/schedule` / `/loop` / hook（automation）。

---

> 抄改提示：複製本範本 → 填入 Phase 1+2 產出 → ship 為 inbox 或 handoff/pending/ 一份檔。
