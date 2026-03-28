---
name: subagent-guide
description: "Sub Agent Guide: applicable scenarios (parallel research/verification/large-scale scan/independent subtasks), not applicable scenarios, usage notes, Cowork vs Claude Code differences, lessons learned. Load when launching Sub Agent."
disable-model-invocation: true
---

# Sub Agent Guide

Cowork and Claude Code support launching Sub Agents—open independent sub-flows within same session, each with tools to execute tasks, **can run in parallel**.

> **Platform limit**: This feature only available on Cowork / Claude Code. Agents on Antigravity (Gemini / Sonnet) don't support it.

## Suitable Scenarios

| Scenario Type | Example | Approach |
|---|---|---|
| Parallel research | Simultaneously query multiple independent sources (web search + local files + API) | Open sub agent for each source, main agent consolidates |
| Verification type | After writing code, need review / run tests / find bugs | After completing work, open sub agent for verification |
| Large-scale scan | Scan multiple folders, multiple files | Split regions, allocate to different sub agents |
| Independent subtasks | Task can split into 2-3 mutually independent parts | Launch in parallel, merge results later |

## Not Suitable Scenarios

- Strong dependency between tasks (B must wait for A's result before starting)
- Single brief task (launching cost higher than benefit)
- Interactive work requiring back-and-forth with user

## Usage Notes

- Launch multiple sub agents **in same message** for true parallelism
- Sub agent ends, return result; main agent consolidates and QA
- Sub agent prompt must be **complete and explicit**, doesn't auto-inherit dialogue context
- Can specify sub agent model in frontmatter (e.g., `model: sonnet` to downgrade and save tokens)

## Cowork vs Claude Code Differences

| | Cowork | Claude Code |
|---|---|---|
| Sub Agent | ✅ Supported | ✅ Supported |
| Agent Teams | ❌ CLI only | ✅ Experimental feature |
| Subagent definition | No `.claude/agents/` | ✅ `.claude/agents/*.md` |

## Lessons Learned

- Before writing "infrastructure" scripts, check if platform has native features. AI tools release new features every few weeks
- When sub agent prompt not specific enough, it spends tons of tokens "understanding the task" → Write paths, parameters, expected output clearly
- Don't launch too many sub agents (3-5 is sweet spot); too many increases coordination cost and token usage explodes
