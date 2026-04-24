---
name: subagent-guide
description: "Sub Agent Guide: applicable scenarios, main/sub collaboration strategy, cost-aware division, conflict resolution, Cowork vs Claude Code differences, lessons learned. Load when launching Sub Agent."
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
- **Operations involving credentials / API keys** (sub agent security filters will reject; main agent should run these directly)

## Usage Notes

- Launch multiple sub agents **in same message** for true parallelism
- Sub agent ends, returns result; main agent consolidates and does QA
- Sub agent prompt must be **complete and explicit**—paths, parameters, expected output format all written clearly. It does not auto-inherit dialogue context. When prompt is not specific enough, sub agent spends massive tokens on "understanding the task"
- Can specify sub agent model in frontmatter (`model: sonnet` to downgrade and save tokens)
- Don't launch too many sub agents (3-5 is sweet spot); too many increases coordination cost and token usage explodes

## Main/Sub Collaboration Strategy

> Inspired by: Anthropic Advisor Tool (2026-04) validated executor/advisor division pattern.

### Cost-Aware Division

| Task Nature | Executor | Reason |
|---|---|---|
| Bulk mechanical execution (scanning, batch, format conversion, translation) | Sonnet sub agent | Cheap, fast, quality sufficient |
| Judgment, planning, conflict arbitration, architecture decisions | Opus main agent | Needs deep reasoning |
| Quality verification (QA / review / sanitization check) | Sonnet sub agent | Independent perspective + low-cost coverage |

Rule of thumb: **Most token output on cheaper model, only use expensive model for key decisions.**

### Four Key Timing Points

Main agent should make its own judgment at these moments—don't blindly delegate to sub agent:

1. **After exploration, before action** — After sub agent finishes data collection, main agent consolidates and plans before dispatching next round of execution. Don't rush upon receiving data
2. **After completion, before declaring done** — After writing files / running tests, open a verification sub agent to review (echoes review Skill's wrap-up flow)
3. **When stuck** — Same error repeating, approach not converging: main agent should reassess strategy, don't let sub agent retry endlessly
4. **Before changing direction** — Don't silently switch; lay out known facts vs new direction conflicts. Escalate to user for decision if necessary

### Conflict Resolution Principles

- When sub agent findings contradict main agent judgment, **don't silently adopt either side**. Flag the conflict, let user decide
- Passing tests ≠ problem doesn't exist (tests might not cover the blind spot sub agent found)
- When multiple sub agents reach contradictory conclusions, main agent lists the differences before making judgment, don't randomly pick one

## Cowork vs Claude Code Differences

| | Cowork | Claude Code |
|---|---|---|
| Sub Agent | ✅ Supported (Agent tool) | ✅ Supported (Agent tool / `.claude/agents/`) |
| Agent Teams | ✅ Supported | ✅ Supported |
| Subagent definition file | No persistent definition | ✅ `.claude/agents/*.md` |
| Worktree isolation | ✅ `isolation: "worktree"` | ✅ `isolation: "worktree"` |

## Lessons Learned

| # | Lesson | Source |
|---|---|---|
| 1 | Before writing "infrastructure" scripts, check if platform has native features. AI tools release new features every few weeks | Orchestrator script replaced by Agent Teams |
| 2 | Sub agent prompt not specific enough → spends massive tokens "understanding task." Write paths, parameters, expected output clearly | Multiple experiences |
| 3 | Don't launch too many sub agents (3-5 sweet spot); too many = high coordination cost + token explosion | Multiple experiences |
| 4 | Sub agent will reject operations containing credentials (security filter). API key / token operations should be run by main agent directly | Gemini API operations |
| 5 | Debate sub agents can confuse regional context (e.g., different market conditions). Background data must be precisely scoped in the prompt | Debate experience |
| 6 | After translation / sanitization, always open an independent QA sub agent to scan all keywords. Same sub agent reviewing its own output has blind spots | Template sanitization residual leak |
| 7 | Bulk API operations should not be delegated to sub agents (security filter too sensitive); main agent runs via Bash directly | Knowledge base batch processing |
