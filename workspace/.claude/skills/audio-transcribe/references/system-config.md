# audio-transcribe — System Config（結構說明、實際值外置）

> ⚠️ **內部人名 / 路徑 / 內部編號** 等敏感資料：見 `_private-glossary.md`（**gitignored、不對外**）。
> 本檔只說明**結構**和 **placeholder 對應**、不寫實際個資。
> 2026-05-28 redact：原本實際員工 / 朋友姓名直接寫在此 → 已全部抽象化、本檔留 pointer。
> 2026-05-28 update（Lesson #182 + user 拍板）：對照改寫進同目錄 `_private-glossary.md`（gitignored）、不再跨 hop 到 `~/CLAUDE.md`。

---

## 軸線判斷對照（placeholder → 實際 mapping）

| SKILL.md 抽象標籤 | 實際對應 placeholder |
|---|---|
| **B 軸**：user ↔ 員工 / 內部營運 | `{COLLABORATOR-PRIMARY}` ↔ `{TEAM-MEMBER-{N}}` |
| **B 軸**：客戶 intake / 商務會議 | `{CLIENT-PROJECT-{N}}` |
| **C 軸**：user ↔ 非業務朋友 | `{FRIEND-{N}}` |
| **E 軸**：user 對外輸出 | outbox letters / 公告 |
| **A 軸**：user 獨白 / user ↔ AI | 個人 corpus → `ideas/{PERSONAL-CORPUS}/` |

> 實際人名 ↔ placeholder 對照表：`_private-glossary.md`（**gitignored、不對外**）。

## 語言預設對照

| SKILL.md 抽象 | 實際 |
|---|---|
| 任何 internal team 錄音 | `{COLLABORATOR-PRIMARY}` ↔ team / 外籍合作對象 → 預設 `en` |
| user 個人中文會議 | 1on1 / 內部 → `zh` |
| 中英混雜 | `auto` |

## 落點對照（B/E 軸下游分流）

| SKILL.md 抽象 | 實際路徑（placeholder）|
|---|---|
| 內部營運 / 招募 / 制度 / confrontation 會議 | `{INTERNAL-OPS-PATH}/meetings/raw/YYYY-MM-DD-topic.md` |
| 客戶 intake / 商務會議 | `<project>/refs/client-meetings/YYYY-MM-DD-<client>.md` |
| 員工 1on1（HR 性質） | `{HR-PATH}/1on1/YYYY-MM-DD-<name>.md` |
| user 個人 / 朋友線下 | `~/workspace/transcripts/`（30 天過期）+ 自動 link `ideas/{PERSONAL-CORPUS}/` |

## 諧音 entity 對照（已踩坑、placeholder 化）

- 短專案名 → 易被諧音為英文常見動詞
- 同事姓名（柬籍 / 越籍 speaker 唸法）→ 易被諧音為英文常見人名

> 具體案例（哪些專案、哪些人名）→ `references/cases.md` + `_private-glossary.md`（**gitignored、不對外**）。

## 敏感性

- 內部營運 meetings 在 `.vcg-exclude` 排除清單、本地 only、不推 remote repo
- `~/workspace/transcripts/` 不該推 git（原始逐字稿含敏感對話）
- 引用原話僅供 internal 私人 / 內部參考
