---
name: tool-scout
description: "Tool scout: search MCP Registry, Plugin Marketplace, GitHub high-star repos, assess security risks, produce comparison table for user decision. Trigger anytime user wants to find a tool/automation solution."
---

# Tool Scout

When the user wants to know "is there an existing tool for X," execute this flow.

## Trigger Moments

- "Is there a tool for..." "Help me find..." "Can this be automated"
- In project mode encountering new needs, looking for off-the-shelf solutions
- project-setup Step 3 tool chain exploration (directly load this Skill)

## Flow

### Step 1: Clarify Requirements (30 seconds)

Confirm with user:
- **What problem to solve** (one sentence)
- **Which project is it for** (or general use)
- **Preference**: Official integration vs open source vs either

Ask directly if unsure, don't guess.

### Step 2: Search Official Resources

Search in order:

1. **MCP Registry** (`search_mcp_registry`)
   - Use 2-3 keyword groups (English primary, cover synonyms)
   - Found relevant → Record name, description, API key requirement

2. **Plugin Marketplace** (`search_plugins`)
   - Same 2-3 keyword groups
   - Found relevant → Record name, features, installation method

3. **Cowork Built-in Connectors**
   - Check deferred tools list in system-reminder
   - Any already-available but overlooked ones?

### Step 3: Search Open Source Solutions

Use WebSearch for GitHub:
- Keywords: `{requirement} site:github.com`
- Filter criteria: ⭐ > 100, updated within last 6 months, issue response speed
- Record 2-3 candidates

### Step 4: Quick Security Assessment

Quickly evaluate each candidate (5 quick checks):

| Check Item | Description |
|---|---|
| Permission scope | What permissions needed? Over-requesting? |
| Data flow | Where does data go? Local processing or cloud? |
| Source code auditability | Open source? Can you see code? |
| Maintainer reputation | Official / known org / individual? |
| Known issues | Do GitHub issues have security-related ones? |

Rating: ✅ Safe / ⚠️ Needs attention / ❌ Not recommended

> **Deep assessment**: High-importance projects or medium/high-risk tools, use complete checklist → `workspace/refs/security-checklist.md` (7 dimensions + risk level judgment).

### Step 5: Integrate Comparison Table

Produce decision table for user:

```markdown
## Tool Scout Results: {Requirement}

| Solution | Type | Feature Match | Security Rating | Cost | Notes |
|---|---|---|---|---|---|
| {Name} | MCP / Plugin / Open source | High/Medium/Low | ✅/⚠️/❌ | Free/Paid | {One sentence} |

### Secretary's Recommendation
{Which one, why, what to watch for}
```

After user decides, record decision to corresponding project INDEX.md or main INDEX.md.

## Notes

- If nothing found, say so, don't force a match
- Official integration > Open source > Build from scratch (maintenance cost)
- If requirement is too vague, go back to Step 1 to clarify, don't waste search
- When finding good stuff, remember to update `refs/lessons-learned.md` (if it's a general discovery)
