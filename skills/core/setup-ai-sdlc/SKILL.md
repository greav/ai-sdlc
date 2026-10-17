---
name: setup-ai-sdlc
description: >-
  Set up a project for the ai-sdlc flow, or bring it up to date: install the flow's skills from
  mattpocock/skills, at the version the flow was checked against, and from ai-sdlc; then add the branch,
  backlog and guidance-skill rules to the agent instructions, create CODING_STANDARDS.md for the
  reviewer, add the PLAN.md and backlog formats to the issue-tracker doc and ignore `.scratch/` — or, when
  the flow is the user's alone, keep all of its files out of git. Installed once per machine; run it in a
  project as often as needed.
disable-model-invocation: true
---

# Set up the ai-sdlc flow

Look at the project, show what you would change, wait for a yes, then act. Add what is missing, and offer
to bring up to date what an earlier version of the flow installed or wrote; leave the project's own text
alone. Running this twice with the same answers must change nothing the second time.

The project files come from `templates/`: [CLAUDE.template.md](./templates/CLAUDE.template.md),
[CODING_STANDARDS.template.md](./templates/CODING_STANDARDS.template.md),
[plan-format.md](./templates/plan-format.md), [backlog-format.md](./templates/backlog-format.md) and, for
a Python project only,
[python.md](./templates/python.md) and
[python-ports-and-adapters.md](./templates/python-ports-and-adapters.md).

## The skills

**From mattpocock/skills, pinned to `49dd158d1076134a641b33efb035946536778336`** — the version the flow
was checked against. Install every one: the skills the user types call the others.

```
setup-matt-pocock-skills  wayfinder  grill-with-docs  to-spec  to-tickets  implement  implement-spec
code-review  diagnosing-bugs  improve-codebase-architecture  retro  handoff  wait-what  grilling
domain-modeling  tdd  codebase-design  research  prototype  pr  writing-for-agents
```

**From ai-sdlc (`greav/ai-sdlc`):**

- `ship`, `cleanup`, `what-next` — always.
- `sql-persistence` — only in a project built as ports and adapters whose code talks to a database.
- `http-integration` — only in a project built as ports and adapters whose code calls a remote API.

Not `setup-ai-sdlc` itself: it is installed once per machine, globally.

The commands, with a `-s <name>` for each skill to install:

```
npx -y skills@latest add "mattpocock/skills#49dd158d1076134a641b33efb035946536778336" -y -a claude-code -s <name> …
npx -y skills@latest add greav/ai-sdlc -y -a claude-code -s <name> …
```

When the user asks to install ai-sdlc from a local folder, or `skills-lock.json` already gives one as the
source of `ship`, put its path in place of `greav/ai-sdlc`.

## Shared or personal

The flow is **shared** when its files go into the project's git, and **personal** when the user may not
commit them: a team that does not use the flow, a repository that is not theirs. Claude Code reads skills
and instructions from disk whether git tracks them or not, so a personal flow works the same; git just
never sees it.

The mode is personal when `.git/info/exclude` names `.scratch/`, shared when `.gitignore` does. When
neither does, ask.

In personal mode:

- **Hide from git through `.git/info/exclude`**, one line per path: `.claude/skills/`, `skills-lock.json`,
  `.scratch/`, `docs/agents/`, `CODING_STANDARDS.md`, `GLOSSARY.md`, `docs/adr/`, `CLAUDE.local.md`,
  `.worktreeinclude`, and a `CLAUDE.md` this skill creates. Leave out a path git already tracks: the team
  committed it, and it stays shared. If git tracks skills of the project's own in `.claude/skills/`,
  list the flow's skill folders one by one instead. Claude Code treats every file in `.git/` as
  sensitive and asks the user before writing to it: append all the lines with one shell command, and say
  beforehand that this prompt is coming. If the user declines, give them the lines to add themselves.
- **Write the agent instructions into `CLAUDE.local.md`**, which Claude Code loads next to `CLAUDE.md`:
  the sections step 5 would add to the shared file go there. If the project has `AGENTS.md` and no
  `CLAUDE.md`, start `CLAUDE.local.md` with the line `@AGENTS.md`: once `CLAUDE.local.md` exists, Claude
  Code reads `AGENTS.md` only through it. A project with no instructions at all gets its `CLAUDE.md` from
  the template, hidden from git, and needs no `CLAUDE.local.md`.
- **Move the `## Agent skills` block.** `/setup-matt-pocock-skills` writes it into the shared `CLAUDE.md`
  or `AGENTS.md`. When git does not have it there yet — `git diff` shows it as added — move it unchanged
  to `CLAUDE.local.md`, replacing the copy already there. A block git already has belongs to the team:
  leave it.
- **List in `.worktreeinclude`** those of `GLOSSARY.md`, `docs/adr/`, `docs/agents/` and
  `CODING_STANDARDS.md` that git does not track. Claude Code copies them into the working copy of a
  subagent run in isolation, such as each of `/implement-spec`'s; the instructions and the skills reach
  the subagent without it. Never list `.scratch/`: a subagent must update the one `PLAN.md`, not a copy.
  If git tracks `.worktreeinclude`, change nothing in it and tell the user which lines it lacks.

## 1. Look

Read what is there; assume nothing.

- **Git.** Is the project a git repository. If not, stop: tell the user to run `git init` and start
  again.
- **Installed skills.** `skills-lock.json` lists each skill with its source and, when one was given, its
  `ref`. A skill from mattpocock/skills is current only when its `ref` is the pinned commit; one with no
  `ref` or another one is not. Note which of the skills above are missing or not current, and whether
  `.claude/skills/` exists at all.
- **The ai-sdlc source.** An ai-sdlc skill comes from `greav/ai-sdlc` or from a local folder: for the
  project's skills `skills-lock.json` says which, for this one the `source` that
  `npx -y skills@latest list -g --json` gives for `setup-ai-sdlc`. Make a shallow clone of the repository
  into a temporary folder outside the project; read a local folder as it is.
  - Compare this skill's own folder with `skills/core/setup-ai-sdlc/` in its source. If they differ, stop
    before anything else: this copy is out of date, and comparing the project with it would propose
    going back. Tell the user to update it — `npx skills update -g`, or its `add` command again when it
    was installed from a folder — and to run `/setup-ai-sdlc` again.
  - Compare each installed ai-sdlc skill with its folder in its source, under `skills/core/` or
    `skills/guidance/`. One that differs is not current.
- **A project copy of `setup-ai-sdlc`.** If `.claude/skills/setup-ai-sdlc/` exists, it is a leftover
  from before this skill was installed globally.
- **Matt's setup.** It has run when `docs/agents/issue-tracker.md` exists.
- **The mode**, shared or personal, as above.
- **Agent instructions.** `CLAUDE.md`, `AGENTS.md` and `CLAUDE.local.md` at the project root, and any file
  one of them imports. Do they say how branches are named, and where work found outside the plan goes? Do they name
  the checks required before a change is done?
- **The language.** Is this a Python project: a `pyproject.toml`, Python sources, or instructions that say
  so. If it is, which tool installs its dependencies and runs its commands, by its lock file or by what
  the instructions name. Is it built as ports and adapters, and does its code talk to a database or call
  a remote API.
- **Other files that hold rules.** Docs the instructions name as the place for a rule, such as a testing
  or contract-testing doc, and anything in `.claude/rules/`.
- **`CODING_STANDARDS.md`** at the project root.
- **`docs/agents/issue-tracker.md`.** Is the tracker local markdown, does it already have a
  `## Feature plan` section and a `## Backlog` section.
- **`.scratch/`.** Is it ignored by git. Check a path inside it, `git check-ignore -q .scratch/x`: the
  pattern `.scratch/` does not match the bare name while the folder does not exist yet. Check the other
  paths the same way.
- **In personal mode:** which paths `.git/info/exclude` lacks, whether `.worktreeinclude` lists what it
  should, and whether a `## Agent skills` block git does not have yet sits in the shared instructions.
- **What an earlier run wrote.** Render each template part the way step 5 would write it for this
  project, and compare it with the section under the same heading in the project:
  - in the agent instructions: `## Branches`, `## Backlog`, `## Guidance skills`, and in a Python project
    `## Tooling` and the sections of `python-ports-and-adapters.md`;
  - in `CODING_STANDARDS.md`: the paragraph above `## Where the rules are`;
  - in `docs/agents/issue-tracker.md`: `## Feature plan` and `## Backlog`.

  A section that is the template's text with lines changed, added or removed was written by an earlier
  version of the flow, or edited since: note the difference. A section that says something else under
  the same heading is the project's own rule: leave it. Never compare a placeholder section.

## 2. Propose

Say what you found, then list each change you would make: the skills to install, the project copy of
`setup-ai-sdlc` to remove, and — when Matt's setup has run — the text you would write into each file.
One list, one confirmation. If nothing is missing or out of date, say so and stop.

Show each section that differs from its template as a diff, one per section, and let the user accept
each one separately. Say that you cannot tell which side changed: a line may be the user's own edit, and
taking the template's text would undo it.

Ask, in the same message, only what step 1 left open:

- Is the flow shared or personal? Say what personal means: nothing of the flow is committed, the glossary
  and ADRs included, and on another machine the setup has to run again.
- Is this a Python project? An empty project cannot show it.
- Is it built as ports and adapters? Ask when `CLAUDE.md` is to be created from the template and the
  project is Python, or when it decides whether to install a guidance skill.
- Which guidance skills to install, when the code does not show whether it talks to a database or calls
  a remote API. Ask only on the run that first installs the flow's skills: on a later run, propose a
  guidance skill only when the code shows the need or the user asks for it.

## 3. Install

Only after the user confirms.

- In personal mode, first add to `.git/info/exclude` the paths "Shared or personal" lists, so neither the
  installed skills nor what Matt's setup writes ever shows up in `git status`.
- Run the install commands for the missing and not-current skills only. Never remove a skill the user
  installed, from mattpocock/skills or elsewhere.
- A project copy of `setup-ai-sdlc`: remove it with `npx -y skills@latest remove setup-ai-sdlc -y`.

## 4. Hand over to Matt's setup

If `docs/agents/issue-tracker.md` does not exist, stop here and tell the user:

1. If `.claude/skills/` did not exist before this run, restart Claude Code first: exit and run
   `claude -c`. A session does not see skills in a folder created after it started.
1. Type `/setup-matt-pocock-skills`. When it asks where issues live, choose **Local markdown**. In
   personal mode, if it asks which instructions file to create, choose `CLAUDE.md`.
1. Type `/setup-ai-sdlc` again. It writes the project files.

Write no project files in this run: what they say depends on what Matt's setup writes.

## 5. Write the project files

**Agent instructions**

In personal mode, what this part adds to an existing shared file goes into `CLAUDE.local.md` instead; see
"Shared or personal".

- Neither file exists: create `CLAUDE.md` from `templates/CLAUDE.template.md`. Keep in its
  `## Guidance skills` section only the lines for skills that are installed; drop the section if none is.
- A file that holds nothing but the `## Agent skills` block is a new project too:
  `/setup-matt-pocock-skills` has just created it. Build the rest from the template around that block,
  and leave the block itself untouched.
- The template's `## Structure` section is a placeholder for the user to describe the project's own
  layers and naming. In a Python project built as ports and adapters, write the sections of
  `templates/python-ports-and-adapters.md` in its place. In any other project leave the placeholder: do
  not invent a structure for the user.
- One exists: edit the file that holds the rules. That is `CLAUDE.md`, unless `CLAUDE.md` only imports
  another file; then it is the imported file. Add only the `## Branches`, `## Backlog` and
  `## Guidance skills` sections of the template, and only where the project lacks them. Apart from the Python section below,
  leave everything else as it is.
- The project already names its branches some other way — in its instructions or in a skill of its own:
  keep its rule. Add a `## Branches` section only if nothing says that a branch is `<type>/<slug>` and
  that the slug is the name of the work's folder in `.scratch/`; then add just that.
- The project already says where work found outside the plan goes: keep its rule. Add the `## Backlog`
  section only if nothing does.
- A Python project whose instructions name no tool for installing and running: add the sections of
  `templates/python.md`, before `## Branches` in a file created from the template. A project that already
  uses another tool keeps it; add nothing.
- Never add a section named `## Agent skills`: `/setup-matt-pocock-skills` owns it and rewrites it.

**Sections an earlier version wrote**

- Replace each section the user accepted with the template's text, as rendered for this project, in
  place. Leave the sections the user declined as they are.

**`CODING_STANDARDS.md`**

- Missing: create it from `templates/CODING_STANDARDS.template.md`. Point at every file that holds the
  project's rules, by its real path: the instructions file, `CLAUDE.local.md` in personal mode, each
  other rule file found in step 1, and each installed guidance skill's `SKILL.md`. The reviewer checks only what this file names.
- Present: add the pointers it lacks. Change nothing else in it.

**`docs/agents/issue-tracker.md`**

- The tracker is not local markdown: write nothing here. Tell the user that `PLAN.md` and the `.scratch/`
  layout assume the local tracker.
- No `## Feature plan` section: append `templates/plan-format.md` to the end of the file.
- No `## Backlog` section: append `templates/backlog-format.md` to the end of the file.

**Keeping files out of git**

- Shared: `.scratch/` is not ignored: add the line `.scratch/` to `.gitignore`.
- Personal: add to `.git/info/exclude` the paths it lacks, write `.worktreeinclude`, and move the
  `## Agent skills` block, all as "Shared or personal" says. Touch neither `.gitignore` nor any other
  file git tracks.

## 6. Report

List what was installed, written and updated. Then name what only the user can fix:

- placeholders left in a `CLAUDE.md` created from the template;
- instructions that do not name the checks required before a change is done — `/ship` runs what they
  name, so without them it has nothing to run;
- in personal mode: a re-run of `/setup-matt-pocock-skills` writes the `## Agent skills` block into the
  shared file again, so run `/setup-ai-sdlc` after it to move the block back.

Do not commit. The changes are the user's to review.
