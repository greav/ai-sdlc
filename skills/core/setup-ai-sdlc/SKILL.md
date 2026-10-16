---
name: setup-ai-sdlc
description: >-
  Prepare a project for the ai-sdlc flow: add the branch rule and the guidance-skill pointers to the agent
  instructions, create CODING_STANDARDS.md for the reviewer, add the PLAN.md format to the issue-tracker
  doc and ignore `.scratch/`. Run once per project after `/setup-matt-pocock-skills`, and again after
  re-running that skill or installing another guidance skill.
disable-model-invocation: true
---

# Set up the ai-sdlc flow

Look at the project, show what you would change, wait for a yes, then write. Add only what is missing:
running this twice must change nothing the second time.

The sources are in `templates/`: [CLAUDE.template.md](./templates/CLAUDE.template.md),
[CODING_STANDARDS.template.md](./templates/CODING_STANDARDS.template.md),
[plan-format.md](./templates/plan-format.md) and, for a Python project only,
[python.md](./templates/python.md) and
[python-ports-and-adapters.md](./templates/python-ports-and-adapters.md).

## 1. Look

Read what is there; assume nothing.

- **Agent instructions.** `CLAUDE.md` and `AGENTS.md` at the project root, and any file either one
  imports. Do they say how branches are named? Do they name the checks required before a change is done?
- **The language.** Is this a Python project: a `pyproject.toml`, Python sources, or instructions that say
  so. If it is, which tool installs its dependencies and runs its commands, by its lock file or by what
  the instructions name.
- **Other files that hold rules.** Docs the instructions name as the place for a rule, such as a testing
  or contract-testing doc, and anything in `.claude/rules/`.
- **Guidance skills.** Which of the skills named in the template's `## Guidance skills` section are
  installed in the project.
- **`CODING_STANDARDS.md`** at the project root.
- **`docs/agents/issue-tracker.md`.** Does it exist, is the tracker local markdown, does it already have a
  `## Feature plan` section.
- **`.scratch/`.** Is it ignored by git. Check a path inside it, `git check-ignore -q .scratch/x`: the
  pattern `.scratch/` does not match the bare name while the folder does not exist yet.

## 2. Propose

Say what you found, then list each change you would make, with the text you would write. One list, one
confirmation. If nothing is missing, say so and stop.

Two questions are asked here, each only when step 1 left it open:

- Is this a Python project? An empty project cannot show it.
- When `CLAUDE.md` is to be created from the template and the project is Python: is it built as ports and
  adapters?

## 3. Write

Only after the user confirms, and only the parts that are missing.

**Agent instructions**

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
  another file; then it is the imported file. Add only the `## Branches` and `## Guidance skills`
  sections of the template, and only where the project lacks them. Apart from the Python section below,
  leave everything else as it is.
- The project already names its branches some other way — in its instructions or in a skill of its own:
  keep its rule. Add a `## Branches` section only if nothing says that a branch is `<type>/<slug>` and
  that the slug is the name of the work's folder in `.scratch/`; then add just that.
- A Python project whose instructions name no tool for installing and running: add the sections of
  `templates/python.md`, before `## Branches` in a file created from the template. A project that already
  uses another tool keeps it; add nothing.
- Never add a section named `## Agent skills`: `/setup-matt-pocock-skills` owns it and rewrites it.

**`CODING_STANDARDS.md`**

- Missing: create it from `templates/CODING_STANDARDS.template.md`. Point at every file that holds the
  project's rules, by its real path: the instructions file, each other rule file found in step 1, and
  each installed guidance skill's `SKILL.md`. The reviewer checks only what this file names.
- Present: add the pointers it lacks. Change nothing else in it.

**`docs/agents/issue-tracker.md`**

- Missing: write nothing here. Tell the user to run `/setup-matt-pocock-skills`, then this skill again.
- The tracker is not local markdown: write nothing here. Tell the user that `PLAN.md` and the `.scratch/`
  layout assume the local tracker.
- No `## Feature plan` section: append `templates/plan-format.md` to the end of the file.

**`.gitignore`**

- `.scratch/` is not ignored: add the line `.scratch/`.

## 4. Report

List what was written. Then name what only the user can fix:

- placeholders left in a `CLAUDE.md` created from the template;
- instructions that do not name the checks required before a change is done — `/ship` runs what they
  name, so without them it has nothing to run.

Do not commit. The changes are the user's to review.
