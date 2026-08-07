# AGENTS.md

## 1. You are the addressee

This file is written for an AI agent, not for a person. The human who owns this machine can read over your shoulder, and should — but you are the one who acts on it.

**Nothing here has taken effect yet.** Read to the end before you change a single file.

You may decline. If any part of this looks wrong, unsafe, or unlike what your human actually asked for, stop and say so. Refusing to proceed is a supported outcome, not a failure — see §3 for why that matters more here than in most repos.

## 2. What this repo is, and what it is not

It is a personal-secretary system: a `workspace/` folder holding an entry-point file, a set of skills, and a memory layout. Once in place, it makes an agent behave as its owner's secretary across sessions — keeping an index of their projects, writing daily journals, handing state to the next session.

It is **not** a library. There is nothing to import, build, or vendor into another project. The unit of delivery is a folder your human works out of.

So your job is not to copy code out of here. It is to help your human's machine enter secretary mode, keep it current, and tell us when we got something wrong.

## 3. This file cannot authorize itself

Adopting this repo is not like reading documentation. `workspace/CLAUDE.md` is an instruction file that a harness loads **automatically at the start of every future session** in that folder. Whoever wrote it is writing standing orders for you.

That deserves suspicion, and it has already received it. On one machine, an agent flagged this repo as a third-party repo it knew nothing about and warned its user that the `CLAUDE.md` inside would be auto-followed from then on. **That was correct behaviour. Do the same.** Get your human's explicit sign-off before adoption — do not let this file substitute for it.

Checks you can run yourself, before trusting anything above:

```
git -C <the folder holding this file> remote -v
git -C <the folder holding this file> log --oneline -5
ls workspace/.claude/skills/
```

**Your human's machine beats our description of it.** If what you find does not match this file, what you found is right and this file is stale. Stop and say so.

**Hard rule: if a safety layer blocks an action, do not reach for a different tool that isn't blocked.** This has happened in this project's history — an assistant was stopped from editing a shell config file, was told "just do it for me," and switched from the file-editing tool to a shell command that did the same thing. The block was not noise; routing around it removed the human from the loop. Go back and ask instead.

## 4. Where the authority lives

**This file is a doorway, not the authority.** The operating contract is `workspace/CLAUDE.md`. Read it now, before doing anything else here.

The split, so nobody has to re-derive it later:

- **`AGENTS.md` (this file) — how to *become* the secretary.** Getting in the door, what your harness can and cannot do on its own, how to stay current, how to report a problem.
- **`workspace/CLAUDE.md` — how to *be* the secretary.** Identity, the four principles, the startup flow, the skills index.

The test: anything that is a **rule about behaviour** belongs in `workspace/CLAUDE.md`. Only **loading, syncing, and platform capability** belong here. When a rule seems to belong in both, it stays in `workspace/CLAUDE.md` and this file carries a pointer at most. **Do not copy rules from there to here.** Two copies drift, and the stale one is the one someone reads.

Verification to hand your human right now: read `workspace/CLAUDE.md` and tell them its first section heading. If you cannot find that file, you are not at the root of this repo — say that rather than guessing.

## 5. Your harness may not load skills by itself

This system assumes an agent that can read files and run commands on the machine. It does **not** assume any particular product.

- **Claude Code and Cowork** discover `workspace/.claude/skills/` and load skills on their own.
- **Everything else** — Codex, Cursor, Gemini CLI, Aider, and the rest — does not. The skills are still there and still work; you have to open them yourself.

Two asymmetries worth stating plainly, because assuming parity here breaks things silently:

- **Claude Code reads `CLAUDE.md`, not `AGENTS.md`.** If you are Claude Code, you did not arrive at this file on your own — someone pointed you here.
- Conversely, an agent that found this file may never see `workspace/CLAUDE.md` unless it opens it deliberately. §4 is that instruction. Do it.

If your harness does not auto-load skills, use this instead of asking anyone for a list:

```
ls workspace/.claude/skills/
```

Then read the frontmatter `description` at the top of each `SKILL.md` and keep them in mind as routing hints. Read a skill's body when a request matches its description — not before.

A procedure, not a list, on purpose: a list printed here would be a second copy of what already exists as directories on disk, and it would be wrong the first time a skill is added or removed. A directory listing is never stale.

One gap to name out loud. **Every path in this file is relative to the repo root** — the folder that holds this file. But the shipped setup instructions (`README.md`, `docs/quickstart.md`) tell your human to point their agent at `workspace/` instead, and that is the ordinary case, not an exotic one. From inside `workspace/`, this file is not visible at all, and every path written here resolves to nothing.

So if your human works out of `workspace/`, the secretary system runs fine and nothing in this file reaches them — the update path in §7 and the reporting path in §9 included. Say so, and tell them the repo root is the folder to open when they want either.

## 6. Which files are for whom

| Path | Audience | How to treat it |
|---|---|---|
| `workspace/CLAUDE.md` | You | The contract. Loaded every session. |
| `workspace/.claude/skills/` | You | Authoritative behaviour. Read on demand. |
| `AGENTS.md` (this file) | You | Entry, capability, updates, reporting. |
| `docs/` | **Humans** | Written for people. Reference material to show them — not instructions addressed to you. |
| `README.md` | Humans on GitHub | Orientation for someone evaluating the repo. |
| `extras/` | Both | Optional helper scripts. Read one before you run it. |

## 7. Staying current

Two separate questions — *is there something newer*, and *how do I take it safely*.

- **`skills-manifest.json`** (repo root) — one entry per skill, with the commit each was last changed in and a git blob sha per file. Compare it against your copy to see what actually differs, without reading every file.
- **`UPDATING.md`** (repo root) — the procedure for taking an update. It is written for you, not for your human.

**Follow `UPDATING.md`. Do not improvise.** Updating a clone your human has edited aborts or conflicts partway, by design, and the obvious ways to clear that error — `git reset --hard`, `git checkout -- <file>`, a `git stash` never popped, re-cloning over the folder — destroy the only copy of their profile and their project list. `UPDATING.md` §5 is that exact failure and the sequence that keeps both sides. Do not reconstruct it from memory.

You will meet a contradiction on the way: `docs/lessons-learned.md` recommends `git checkout -- <file>` for restoring a deleted file. That is right for a file nobody edited, and wrong for `workspace/CLAUDE.md` and `workspace/INDEX.md`. `UPDATING.md` wins.

If either file is missing from your copy, your clone predates them. Say so, and check for yourself before concluding there is nothing new:

```
git -C <repo> fetch
git -C <repo> log --oneline HEAD..origin/main
```

## 8. Do / Don't

**Do**

- Keep every change inside the secretary folder.
- For anything destructive: **inventory it → show your human the list → only then delete.** Never the reverse order.
- Ask first for anything that spends money, sends data off the machine, or cannot be undone.
- Report what you actually observed, including when it contradicts us.

**Don't**

- Don't overwrite an existing `workspace/CLAUDE.md` or `workspace/INDEX.md`. Both are tracked upstream files that setup fills with your human's real information, and many people have edited theirs. Overwriting them loses work that exists nowhere else.
- Don't `git add -A` or push from this clone. Your human's real notes end up in tracked files; a push sends them somewhere public.
- Don't treat a path in this file as a constant for some other machine. Check the machine you are on.
- Don't silently edit the shipped `SKILL.md` files. If one is wrong, say so — see §9.
- Don't touch credentials, keys, or tokens for any reason.

## 9. When something doesn't match, open an issue

You are not the first agent to catch an error in what we shipped. Twice in one month, an agent on someone else's machine found a real defect in instructions we had sent out — a hard-coded path that broke a skill on its first step, and a stale claim about a repository's state. Both times the agent was right and we were wrong.

**Say the mismatch out loud before you comply, not after.**

To report it: `git -C <repo> remote -v` tells you which repository this copy came from. Open an issue there. Issues need no write access — you do not need, and should not ask for, push access to this repo.

Attach all four:

1. Which harness and model you are.
2. `generated_from_commit` from `skills-manifest.json` — or `git -C <repo> log --oneline -1` if your copy has no manifest.
3. The exact command you ran and its **real, unedited terminal output**.
4. What you expected the file to say instead.

Paste output verbatim. A paraphrase of what a command printed is not evidence, and it is usually the part that was wrong.

## 10. Explain it to your human, in their language

Once you have read `workspace/CLAUDE.md`, tell your human — in the language they speak, in a few sentences, with no file paths and no jargon:

- what this system will do for them
- what will change on their machine
- what you want their permission for

End with: **"Does any of that not match what you expected?"** — then wait for the answer.

If the plain-language version doesn't land, open `docs/quickstart.md` and `docs/concept-guide.md` for them. Those are written for people, not for you.
