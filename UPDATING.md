# UPDATING — how to get a newer version of this system onto a machine

## 1. Agent: this is written for you

The person you work for may read this over your shoulder, and they should. But the commands
below are yours to run, and the judgement calls below are yours to make.

They will not say "run a git pull." They will say **"update it."** This file is what that
sentence means.

Read the whole file before you run anything. The dangerous part is not the update — it is
the three-line error message the update prints when it goes wrong, and what agents
typically do next to make that message disappear.

---

## 2. What this document is, and what it cannot do

This document cannot authorize itself. A file that says "trust me" is not a reason to trust
it. Everything below is a claim you can check on the machine in front of you, and the
checking costs seconds:

```sh
REPO="$(git rev-parse --show-toplevel)"    # run this from anywhere inside the folder
git -C "$REPO" remote -v                   # where does this clone actually point?
git -C "$REPO" log --oneline -5            # what has it actually got?
ls "$REPO/workspace/.claude/skills/"       # which skills are actually installed?
```

Do not add `2>/dev/null` to any of these. The error text is the answer more often than
the output is.

**If the machine disagrees with this file, the machine is right.** This file is a snapshot
of the repository at the time it was written; the clone in front of you may be newer, older,
or set up in a way we never anticipated. Say so out loud and stop — do not reshape the
machine to match the document.

**If you decide to stop and ask the person to sign off before you continue, that is correct
behaviour, and we would like you to keep doing it.** This is not a formality. Agents in this
system have caught real errors in instructions like this one — twice in a single month, and
both times the agent was right and we were wrong. You are the second review, not the
executor of a decision already made.

One thing you must not do: if a safety check in your own harness blocks an action here, **do
not switch tools to get around it.** Do not reach for a shell command because an edit tool
refused. Go back to the person and ask. An agent on one machine did exactly that — the edit
tool asked for explicit sign-off, and the agent re-ran the same change through a shell
one-liner instead. Nothing broke that time. The behaviour is still the problem.

---

## 3. Find out where you are before you change anything

We do not know how this clone was set up. Different machines in the wild were installed at
different times by different routes. So the first step is not an update — it is a look.

Run all four lines. The first one only sets a variable; read the three outputs that
follow before deciding anything:

```sh
REPO="$(git rev-parse --show-toplevel)"
git -C "$REPO" remote -v
git -C "$REPO" status --short
git -C "$REPO" log --oneline -1
```

Now pick your route from what you actually saw:

| What `git remote -v` printed | Route |
|---|---|
| A `(fetch)` URL ending in `ventusmediatw-cell/project-secretary`, with or without a trailing `.git` | **Section 5** — this is the normal case |
| A `(push)` line reading `no-push` alongside that fetch URL | **Section 5** — also normal, and deliberate. Pull works; push is meant to be off |
| A URL ending in `/project-secretary` under a **different account** | A fork. **Stop and report it** — see the note below, and Section 7 |
| Nothing at all, or a URL pointing somewhere unrelated | **Stop. Report it, do not fix it.** See Section 7 |
| `fatal: not a git repository` | **Read the next paragraph before you touch Section 6** |

**`fatal: not a git repository` does not mean "empty machine."** It means there is no
`.git` directory — which is also what a downloaded-and-unzipped copy looks like, and
`workspace/SETUP-GUIDE.md` lists the prerequisite as "this repo cloned **or downloaded**".
Look before you route:

```sh
ls workspace/CLAUDE.md workspace/.claude/skills/ 2>&1
```

If those exist, this person **has** an install; it just is not a git clone, and it holds
their only copy of their profile and project list. Section 6 does not apply, and
`git clone` into that folder fails anyway (`destination path already exists and is not an
empty directory`). Do not delete the folder to make the clone succeed — that is the exact
prohibition in 5.1. Stop and report it as Section 7; converting a downloaded copy into a
tracked clone is not an update and is not yours to improvise.

Only if that `ls` finds nothing does Section 6 apply.

**On forks and on the URL in `README.md`.** `README.md` and `workspace/SETUP-GUIDE.md`
both print `git clone https://github.com/your-username/project-secretary.git`. That is a
placeholder, and it does not resolve — running it verbatim returns `Repository not found`.
So a remote under an account other than `ventusmediatw-cell` is not necessarily a mistake;
it may be a deliberate fork. It still matters, because **a fork does not receive upstream
commits until somebody syncs it**: `git pull` will report success and bring nothing. Report
what the remote actually is and let the person decide. Do not add, retarget or rewrite a
remote yourself. Remote configuration is not part of updating.

If `git remote -v` shows a **push** URL that this machine is not supposed to have, report
that too, and do not change it yourself.

---

## 4. Two things that are on us, not on the person whose machine this is

**We ship two files that we then ask the setup wizard to overwrite.**
`workspace/CLAUDE.md` and `workspace/INDEX.md` are tracked by git — they arrive with the
clone — and the first-run wizard is supposed to fill them with the person's real details,
real projects, real working language. From git's point of view that makes them permanently
modified files. Every update after that has to route around them. That is our design, and
the friction in Section 5 exists entirely because of it. If the person's update "fails," it
is not because they did something wrong.

**An update can delete files, and some of that is expected.** When a skill is rewritten
upstream, supporting files that used to ship with it are removed, and a clone made from
before that rewrite loses them on the next pull. That much is the clone catching up, not
damage.

Do not let that sentence talk you into accepting a deletion list you have not checked.
Files that only ever existed on this machine — the person's own skills, their own notes,
anything they or the wizard created — are **never** removed by a pull, because a pull is a
merge, not a checkout. If such a file shows up in a deletion list, the list is wrong; the
machine is fine. The obvious command for producing that list gets this wrong by default,
which is why 5.2 does not use it. Produce the real list, prove what the merge will actually
do, and show the person that — before it happens rather than after.

**This file may be older than the repository it describes.** It is committed alongside the
code, but nothing guarantees it was updated in the same commit as the change you are about
to pull. Treat any mismatch as a bug in this file, and see Section 7.

---

## 5. Route A — this machine already has the system

### 5.1 Never re-clone over an existing install

The instruction people repeat is "just clone it again." For a machine that never had this
system, that is right, and it is Section 6. For a machine that already has it, it is wrong,
because the clone is not a copy of the repository any more — it is the person's working
system. Their profile, their project list, their notes and their own edits to skills all
live inside it, and most of them are the only copy in existence. Replacing the folder
deletes them with no undo.

The mechanism to hold on to: **`git pull` merges, re-cloning replaces.** You want the merge.

### 5.2 Look before you pull

`git fetch` downloads without touching a single file in the working tree. It is safe, and it
lets you answer "what is about to happen" *before* anything happens:

```sh
git -C "$REPO" fetch origin

# what commits are coming
git -C "$REPO" log --oneline HEAD..origin/main

# the shape of the change
git -C "$REPO" diff --stat HEAD origin/main

# which files will be DELETED by this update  (see Section 4)
#
# Do NOT use `diff HEAD origin/main` for this. Its "D" means "HEAD has it, origin/main
# does not", which lumps together two opposite cases: files upstream really deleted, and
# files that only ever existed on this machine and upstream never had. A pull is a
# three-way merge, and it keeps the second group. Listing them as "will be DELETED" is
# how you end up telling the person their own skills are about to be removed.
#
# Compare against the merge base instead. This is the real deletion list:
MB=$(git -C "$REPO" merge-base HEAD origin/main)
git -C "$REPO" diff --name-status "$MB" origin/main | grep '^D' || echo "(no deletions)"

# Stronger, and worth the extra line: do the merge in memory and read what comes out.
# Nothing is written to the working tree. This turns "what will the pull do" from a
# prediction into a fact you can check.  (needs git 2.38+)
TREE=$(git -C "$REPO" merge-tree --write-tree HEAD origin/main) \
  && git -C "$REPO" diff --name-status HEAD "$TREE" | grep '^D' \
  || echo "(merge produces no deletions)"

# has this machine got local commits upstream does not have?
git -C "$REPO" log --oneline origin/main..HEAD || true
```

And the one that predicts trouble — files the person has edited but not committed *that the
merge also has to write*. `diff HEAD origin/main` is the wrong tool here for the same reason
it was wrong above: it lists every path where the two tips differ, including ones this update
never touches. `workspace/CLAUDE.md` and `workspace/INDEX.md` differ on every machine whose
wizard committed the person's details into them, so that version names those two on every
update, whether or not the update goes anywhere near them. Compare against what the merge
actually produces instead:

```sh
# needs bash or zsh (process substitution), and git 2.38+ for merge-tree
#
# head -1: on a merge that conflicts, merge-tree prints the tree id on the first line
# and then the conflicted paths. Only the first line is the tree.
TREE=$(git -C "$REPO" merge-tree --write-tree HEAD origin/main | head -1)
comm -12 \
  <(git -C "$REPO" diff --name-only | sort) \
  <(git -C "$REPO" diff --name-only HEAD "$TREE" | sort)
```

**If it prints nothing, that does not mean there is nothing to do — it means 5.5 is not
coming.** The pull will run, and their uncommitted edits to everything else stay exactly as
they are; a pull only touches the files the merge writes.

**If it prints a name, that is the one file 5.5 is about**: git will refuse the whole merge,
change nothing at all, and print that filename back at you. Read 5.5 before you run the pull,
not after.

**Show the person this output before you go further** — particularly the deletion list and
the collision list. Inventory, then show them, then act. Never the other way round.

### 5.3 Back up the irreplaceable files, then pull

Two files justify the extra thirty seconds, because the repository has no usable backup of
the person's versions of them:

```sh
mkdir -p ~/secretary-update-backup
cp "$REPO/workspace/CLAUDE.md" ~/secretary-update-backup/CLAUDE.md.bak
cp "$REPO/workspace/INDEX.md"  ~/secretary-update-backup/INDEX.md.bak
ls -l ~/secretary-update-backup/
```

Then:

```sh
git -C "$REPO" pull --no-rebase
```

Exactly three things can come back. Read which one you got before doing anything else.

### 5.4 Outcome 1 — it worked

```
Updating <old>..<new>
Fast-forward
 8 files changed, 48 insertions(+), 646 deletions(-)
 delete mode 100644 workspace/.claude/skills/<some-skill>/references/<file>.md
```

Nothing more to run. Tell the person two things, not one: what arrived, **and what was
removed**. The deletion lines are the part they will notice later and worry about, so name
them now and say they were expected. Go to Section 8.

### 5.5 Outcome 2 — it refused to start

```
error: Your local changes to the following files would be overwritten by merge:
	workspace/CLAUDE.md
Please commit your changes or stash them before you merge.
Aborting
```

**This section is why this file exists.**

Read what actually happened: git refused. It changed nothing. The person's files are intact
and the update did not arrive — `git log --oneline -1` will show the same commit as before.
This is git protecting them, not a failure state you need to clear.

The failure comes next, and it comes from us, not from git. Four commands make the red text
go away and destroy the person's work while doing it:

- ❌ `git reset --hard` — deletes their edits
- ❌ `git checkout -- <file>` / `git restore <file>` — deletes their edits to that file
- ❌ `git stash` followed by a pull and no `pop` — hides their edits somewhere they will
  never look
- ❌ deleting the folder and re-cloning — deletes everything, see 5.1

`workspace/CLAUDE.md` holds the person's profile and whatever they have added to it.
`workspace/INDEX.md` holds their real project list. **There is no copy of either in the
repository.** Whatever is in those two files on this machine is all there is, minus the
backup you just made in 5.3.

The sequence that keeps both sides:

```sh
# 1. show them what they changed — they may not remember, and it may matter
git -C "$REPO" diff workspace/CLAUDE.md
git -C "$REPO" diff workspace/INDEX.md

# 2. set their edits aside, labelled
git -C "$REPO" stash push -m "before update $(date +%F)"

# 3. now the pull has nothing in its way
git -C "$REPO" pull --no-rebase

# 4. put their edits back
git -C "$REPO" stash pop
```

Step 4 has two outcomes of its own.

**Clean pop** — output ends with a `Dropped refs/stash@{0}` line. Done. Go to 5.7.

**Pop reports a conflict** — this is common, and it is not a new problem; it is the same
overlap surfacing at a point where you can actually resolve it:

```
Auto-merging workspace/CLAUDE.md
CONFLICT (content): Merge conflict in workspace/CLAUDE.md
```

Go to 5.6. Two things to know before you do:

- **The stash is still there.** git keeps it when a pop conflicts. `git stash list` will show
  it. Nothing is lost yet — but do **not** run `git stash drop` or `git stash clear` until
  after you have resolved the file, or you throw away the only copy of the changes you are
  in the middle of merging.
- **The update itself already landed.** `git log --oneline -1` now shows the new commit. What
  is left is only the text of one or two files.

### 5.6 Outcome 3 — conflict markers in the file

Whether you arrive from a `stash pop` or from a pull on a machine that had local commits, the
file now looks like this:

```
<<<<<<< Updated upstream
| **new-skill** | `.claude/skills/new-skill/SKILL.md` | ... | Auto-load |
=======
| **their-skill** | ... | something the person added | ... |
>>>>>>> Stashed changes
```

**Read the labels. Do not assume the top half is theirs.** The two paths label the halves in
opposite orders, and this catches people out:

| How you got here | Top half (`<<<<<<<`) | Bottom half (`>>>>>>>`) |
|---|---|---|
| `git stash pop` | `Updated upstream` = **ours** | `Stashed changes` = **theirs** |
| pull with local commits | `HEAD` = **theirs** | a commit hash = **ours** |

**Keep both sides.** Almost every conflict in this repository is two rows added to the same
table, or two lines added at the end of the same section. They are not alternatives. Delete
the three marker lines, put both pieces of content in, in a sensible order.

Do not pick a side automatically. If the two halves genuinely contradict each other, that is
a question for the person, not a judgement call for you.

Then, depending on how you arrived:

```sh
# from a stash pop:
git -C "$REPO" add workspace/CLAUDE.md
git -C "$REPO" stash drop          # only now, and only after the markers are gone

# from a pull with local commits:
git -C "$REPO" add workspace/CLAUDE.md
git -C "$REPO" commit             # completes the merge
```

🔴 **`workspace/CLAUDE.md` must not still contain `<<<<<<<` when you finish.** It is the file
that puts this system into secretary mode at the start of every session — it gets loaded as
instructions, markers and all, and it will not announce that it is broken. Verify it in 5.7
rather than assuming.

### 5.7 How you know it actually worked

Not "the commands ran." Run these and read the output:

```sh
# 1. no conflict markers survived anywhere
grep -rn '<<<<<<<\|>>>>>>>' "$REPO/workspace/" || echo "OK: no markers"

# 2. the clone is level with upstream
git -C "$REPO" fetch origin && git -C "$REPO" log --oneline HEAD..origin/main
#    expected: prints nothing

# 3. nothing was left in limbo
git -C "$REPO" stash list
#    expected: prints nothing, unless the person had a stash before you started

# 4. the person's own content is still in place.
#    Check the CONTENT, not git's state. If you came through 5.6 you ran `git add`,
#    so `git diff` prints nothing here — and empty output would look like proof when
#    it is proof of nothing. Compare against the backup you made in 5.3 instead:
comm -23 <(sort -u ~/secretary-update-backup/CLAUDE.md.bak) \
         <(sort -u "$REPO/workspace/CLAUDE.md")
comm -23 <(sort -u ~/secretary-update-backup/INDEX.md.bak) \
         <(sort -u "$REPO/workspace/INDEX.md")
#    expected: both print nothing.
#    A printed line was in their file before the update and is not there now — but that is
#    not the same as lost. workspace/CLAUDE.md carries a skills index whose rows are partly
#    ours and partly theirs, so any upstream row whose description we rewrote will show up
#    here every single time. Do not report it as a loss, and do not get numb to the check
#    because it always prints something.
#    Take each printed line, find its key in the new file (the skill name, the heading):
#      still there, new wording  -> upstream replaced it. Fine. Say so explicitly.
#      not there at all          -> a real loss. Stop and go to Section 8.
#    (needs bash or zsh, like the check in 5.2)

# 5. the skills on disk match the manifest
ls "$REPO/workspace/.claude/skills/"
#    compare against skills-manifest.json at the repository root. A file on disk that
#    the manifest does not list is not automatically junk — see that file's own note on
#    stale manifests. Never delete one to make the two agree.
```

Then the check no file inspection can substitute for: **start a fresh session and use the
system.** Say something that should trigger a skill and see whether the right one fires. An
agent reading a file and concluding it would work is not evidence that it works. If you
cannot demonstrate it, say "I have not verified this" — do not report success.

Once 5.7 is clean, delete the backup directory, or tell the person where it is.

---

## 6. Route B — nothing is installed on this machine yet

Short, because this is the easy case, and because installing the agent harness itself is out
of scope here. This assumes the person already has a working coding agent on the machine,
and that you have confirmed — with the `ls` in Section 3 — that there is nothing here to
lose.

```sh
git clone https://github.com/ventusmediatw-cell/project-secretary.git
```

That is the working URL. It is **not** the one printed in `README.md` and
`workspace/SETUP-GUIDE.md`, which both say `your-username` and return
`Repository not found`. Use the line above; when you send the person to those two files
below, say that their first step is out of date so they do not run it.

Two things the clone does not do for you:

1. **The system loads from `workspace/`, not from the repository root.** `CLAUDE.md` lives
   inside `workspace/`. If the agent starts from anywhere else, secretary mode does not load
   — **and nothing reports an error.** It just behaves like an ordinary agent. Set up
   whatever your harness needs so that sessions begin inside `workspace/`.
2. **Four directories are deliberately not in the repository** (they are excluded so that
   nobody's private work can ever be committed here) and several skills expect them:

```sh
mkdir -p project-secretary/workspace/handoff/pending \
         project-secretary/workspace/handoff/done \
         project-secretary/workspace/projects \
         project-secretary/workspace/summaries
```

Then read `README.md` and `workspace/SETUP-GUIDE.md`, and let the first-run wizard in
`workspace/CLAUDE.md` do the rest. Note what Section 4 says: the wizard rewrites two tracked
files, which is why you will be back here reading Section 5 the next time an update comes.

---

## 7. When this file is wrong

It will be, eventually. When the machine and this document disagree:

**Say it first. Do not comply first.** Tell the person what you expected, what you actually
saw, and that you are stopping. An update executed against wrong assumptions is much more
expensive than an update that did not happen today.

**Then open an issue:**
<https://github.com/ventusmediatw-cell/project-secretary/issues>

- Paste the **real terminal output** — the actual error text, not your summary of it.
- Say which section you were in and what you had already run.
- Redact before you post. This is a public repository. Nothing with a client name, a
  personal name, a key, a token, or an absolute path from the person's machine.

Issues, not pull requests. **Nobody using this system needs write access to this repository,
and nobody should ask for it.** Reporting a problem must never require a permission that,
once granted, would let this repository be written to from the machines that hold people's
private working data. Describe the fix in the issue; let the maintainer make the change.

The pattern we are relying on is the one that has actually worked: an agent on a machine we
do not control reads what we sent, checks it against what is really there, and tells us we
are wrong. That has happened, it was right both times, and it is worth more to us than
compliance.

---

## 8. Explain it to the person, in their own language

Before you finish, tell them in plain words. No paths, no git vocabulary, no section
numbers. Something close to:

> I updated your secretary system. The new material came down, and everything you had
> written into it — your details, your project list, your own notes — is still there; I
> checked. A few old files were removed because they were replaced upstream, so that is
> normal rather than something breaking.
>
> Does any of that sound different from what you expected?

Ask that last question and wait for the answer. On more than one occasion the person's
answer has been the thing that revealed the update did not do what we thought it did.

If plain words are not landing, that is a signal to slow down and explain differently — not
to hand them documentation and move on.
