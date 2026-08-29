#!/usr/bin/env python3
"""check_entry_superset.py — 入口 superset 不變式檢查（skill-ops §0 入口不變式 / §5.5 配套）

規則（RFC 6596 superset 不變式的本地化）：
  入口對某個本體 SKILL 的描述，內容必須是本體的**子集**。
  允許刪減（摘要），**禁止增添**——出現在入口而不在本體的「方法性語句」即違規。

本版只做**可機械判定**的那一類：來源／指令／URL 名詞。
散文式的同義改寫抓不到，那需要人看或 LLM 判——本腳本不假裝做得到。

用法：  python3 check_entry_superset.py            # 檢查全部已登記的 canonical
        python3 check_entry_superset.py --json
退出碼：0＝乾淨；1＝有違規（供 cron / wrap-up 用）
"""
from __future__ import annotations
import json, re, sys
from pathlib import Path

SKILLS = Path(__file__).resolve().parents[2]  # skills/ 根：隨安裝位置解析，不假設 ~/.claude

# canonical 本體 → 引用它的入口清單。新增入口必須同時登記在此。
REGISTRY = {
    "tool-scout": [
        "skill-ops/SKILL.md",
        "skill-ops/references/build-checklist.md",
        "skill-ops/references/mining-checklist.md",
        "skill-ops/references/refresh-checklist.md",
        "project-setup/SKILL.md",
    ],
}

# 「方法性語句」的可機械判定 token：來源名、指令名、URL 主機
TOKEN_RE = re.compile(
    r"(agentskills\.io|MCP Registry|/plugin search|claudemarketplaces\.com|aitmpl\.com"
    r"|registry\.modelcontextprotocol\.io|claude-plugins-official|claude-community"
    r"|ListMcpResourcesTool|apify\.com|claude plugin list|claude mcp list)",
    re.IGNORECASE,
)

def tokens(text: str) -> set[str]:
    return {m.group(1).lower() for m in TOKEN_RE.finditer(text)}

def entry_context(text: str, canonical: str) -> str:
    """只取提到 canonical 的段落（前後各 3 行），避免掃到入口自己的無關內容。"""
    lines, out = text.split("\n"), []
    for i, l in enumerate(lines):
        if canonical in l:
            out.extend(lines[max(0, i - 3): i + 4])
    return "\n".join(out)

def main() -> int:
    violations = []
    for canonical, entries in REGISTRY.items():
        body_path = SKILLS / canonical / "SKILL.md"
        if not body_path.is_file():
            print(f"❌ 本體不存在: {body_path}"); return 1
        body_tokens = tokens(body_path.read_text(encoding="utf-8"))
        for rel in entries:
            p = SKILLS / rel
            if not p.is_file():
                violations.append({"entry": rel, "kind": "missing", "detail": "入口檔不存在"})
                continue
            ctx = entry_context(p.read_text(encoding="utf-8"), canonical)
            extra = tokens(ctx) - body_tokens
            for tok in sorted(extra):
                violations.append({"canonical": canonical, "entry": rel,
                                   "kind": "superset_violation", "token": tok,
                                   "detail": f"入口提到 '{tok}'，本體沒有 ⇒ 回填本體或刪掉"})
    if "--json" in sys.argv:
        print(json.dumps(violations, ensure_ascii=False, indent=2))
    else:
        if not violations:
            print(f"✅ superset 檢查通過（{sum(len(v) for v in REGISTRY.values())} 個入口、0 違規）")
        else:
            print(f"🔴 {len(violations)} 條違規：")
            for v in violations:
                print(f"   {v['entry']}: {v.get('token','—')} — {v['detail']}")
    return 1 if violations else 0

if __name__ == "__main__":
    sys.exit(main())
