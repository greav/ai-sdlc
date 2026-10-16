# ai-sdlc

How I build a feature with an AI agent, from "I want X" to a merged PR. Two parts:

- **The flow** — which commands to run, in which order, in which session.
- **The kit** — skills to install into a project, one of which writes the project's starting files, and
  practices to read before a decision.

The flow runs on [mattpocock/skills](https://github.com/mattpocock/skills) and adds three things they
leave out:

| Gap                                          | What fills it                 |
| -------------------------------------------- | ----------------------------- |
| tracking progress from session to session    | `PLAN.md`                     |
| finishing a feature                          | `/ship` and `/cleanup`        |
| making the reviewer check the project's rules | `CODING_STANDARDS.md`         |

Checked against mattpocock/skills as of 2026-10-10 (1.3.1 plus the changes queued after it).

## The flow

```
idea → Shape → Build → Review → [Follow-up] → Finish → merged PR
```

A stage in brackets runs only when needed.

One rule holds it together: **every stage runs in its own agent session, and a new session starts from
files, not from the previous chat.** A long session makes the agent worse; files keep what matters.

### 1. Choose a route

| The task is…                                                          | Route         | What you do                                                                   |
| --------------------------------------------------------------------- | ------------- | ----------------------------------------------------------------------------- |
| a small fix: you can say what should happen in one sentence           | **Just ask**  | ask the agent; no skills, no files                                            |
| one piece of work with a design choice in it (a new table, a new API) | **Short**     | `/grill-with-docs` and `/implement` in one session, then a review and `/ship` |
| several pieces, each testable on its own                              | **Full**      | the five stages below                                                         |
| an idea `/grill-with-docs` could not settle in one session            | **Wayfinder** | `/wayfinder` first, then the Full route                                       |

**Anything bigger than a small fix starts with `/grill-with-docs`.** What happens in the interview picks
the route:

- The task is one piece of work → run `/implement`. This is the Short route.
- The task is several pieces → run `/to-spec`. This is the Full route.
- The interview does not fit in the session, or question after question needs reading or a prototype to
  answer → run `/handoff the next session charts a /wayfinder map`, then start the Wayfinder route from
  the file it writes. This is the Wayfinder route, and it is rare.

**When a fact is missing, find it out before the interview.** An interview settles what you want; it
cannot tell you what an API allows or whether an approach works.

- `/research <the question>` reads the sources and leaves a file with what it found, for the interview to
  use. It needs web access.
- `/prototype <the question>` builds something throwaway to try, when the question is how it should
  behave or look.
- To learn whether a system call or an API works at all, ask the agent for a throwaway script on a branch
  of its own. No skill is needed.

### 2. The Short route

1. `/grill-with-docs <what you want>`
1. Ask the agent to create a branch.
1. `/implement`
1. In a new session: `/code-review <default-branch>`, then ask the agent to fix what it found. Skip this
   for a trivial change.
1. `/ship`, merge the PR, `/cleanup` — the same as Stage 5 of the Full route.

### 3. The Full route

**Stage 1 — Shape.** Decide what to build. One session; do not `/clear` inside it.

```
/grill-with-docs <what you want, not how to build it>
/to-spec
/to-tickets then write PLAN.md
<ask the agent to create the branch for this feature and commit the glossary and ADRs on it>
/clear
```

- The agent stops three times for your approval: the shared understanding, where the tests will sit, the
  list of tickets. These are your only checkpoints, so read them carefully.
- Put only a space after a command's name. With a comma there, as in `/to-tickets, then…`, the command is
  not recognised and the skill does not load.
- You get `GLOSSARY.md` and ADRs in git, and three kinds of file in `.scratch/<slug>/`:

```
spec.md              what is being built, as a whole — changed only after a new interview
issues/NN-<slug>.md  the pieces it was cut into — one ticket per file
PLAN.md              which pieces are done and which is next — updated after every ticket
```

**Stage 2 — Build.** Write the code. A new session for every ticket.

```
/implement the next ticket from @.scratch/<slug>/PLAN.md and update the plan
/clear
```

- Repeat the same prompt until `PLAN.md` shows every ticket as `done`.
- Each session commits its ticket to the branch.
- If a session went badly — the agent searched for a long time or lacked information — run `/retro`
  in it before `/clear`.

**Building every ticket in one run.** For work that is large but not critical, one session can build the
whole plan instead of you starting a session per ticket:

```
/implement-spec @.scratch/<slug>/spec.md
Work on the branch named in @.scratch/<slug>/PLAN.md, not a new one; if it does not exist, stop and tell me.
Keep the plan up to date yourself. Leave the criteria only I can check unticked and list them at the end; they do not block the next ticket.
Do not put ticket numbers in commit messages.
Final review: fix plain defects only, and list the findings that need my decision.
```

- It hands each ticket to a subagent in a working copy of its own, runs at the same time the tickets that
  do not block each other, merges them into the branch and reviews the whole of it at the end.
- `/implement-spec` creates a branch of its own. The line about the branch keeps it on the feature's
  branch from Stage 1, and stops it if that branch was never created.
- You do not see each ticket as it lands, only the result. Stage 3 is your first look at the code.
- A check only you can do — a real device, a permission — reaches you only through the list at the end
  of the run.
- Tickets built at the same time can clash when merged. If two of them touch the same file, make one
  block the other when you approve the list of tickets.
- The ticket files are deleted at the end, so a ticket number in a commit message would point at nothing.
- Commit the project's instructions, glossary and ADRs before the run. A subagent's working copy holds
  only committed files.
- Without the last line it fixes every review finding itself, including the ones that are yours to decide.

**Stage 3 — Review.** Check the whole feature. A new session.

```
/code-review <default-branch>, spec: @.scratch/<slug>/spec.md, already decided: the Notes in @.scratch/<slug>/PLAN.md
<ask the agent to fix what the review found>
```

- `/implement` already reviews each ticket before committing it. This review covers the whole branch and
  catches what no single ticket shows: a file nobody committed, a requirement that fell between tickets.
- The Notes in `PLAN.md` hold the deviations already decided during Build. Naming them keeps the review
  from raising them again.
- The review will list findings that are yours to decide. Ask the agent to fix only the rest.
- If the review found real problems, run `/retro` after the fixes. Skip it when the review is clean.

`/retro` looks at one session and proposes changes around the code, not to it: a check, a rule for the
reviewer, a pointer to a file. It changes nothing until you pick a proposal. Drop any proposal you cannot
trace to a moment in that session.

Run it in the session where the problem happened. If you already ran `/clear`, start a new session and ask
`/retro` to look at the previous one: it reads that session's log.

**Stage 4 — Follow-up.** Only when you want something changed. A new session.

```
I just implemented @.scratch/<slug>/PLAN.md. One last change I need: … Note it in PLAN.md.
```

- A change that needs its own tests is a new ticket: add it to `PLAN.md` and build it as in Stage 2.
- If the change alters behaviour, review it in a new session. Give `/code-review` the commit before the
  change, and it checks only what came after:

```
/code-review <commit-before-the-change>, spec: @.scratch/<slug>/spec.md
```

**Stage 5 — Finish.**

```
/ship          checks everything, updates the glossary and ADRs, pushes, opens the PR
<squash-merge the PR>
/cleanup       deletes .scratch/<slug>/ and the branch
```

After `/implement-spec`, merge with a merge commit instead of a squash. The branch holds one merge per
ticket, and a squash would fold the whole feature into a single commit.

### 4. When the plan changes

**Changing the plan midway.** New ideas come up while tickets are being built. The plan is files, so
changing it is editing them; the next Build session picks the change up from `PLAN.md`.

| The idea is…                                   | Do this                                                                 |
| ---------------------------------------------- | ----------------------------------------------------------------------- |
| a detail of a ticket not started yet           | edit that ticket's file and add a line to the Notes in `PLAN.md`        |
| another piece of work for this feature         | add a ticket: a new file in `issues/` and a row in `PLAN.md`            |
| a change to a ticket already done              | add a new ticket that changes it; leave the done one as it is           |
| a different idea of what is being built        | a new session with `/grill-with-docs`, given the spec and the plan; then update the spec and the tickets not started |
| a better approach to something that works      | finish this one first; try the approach as an experiment, then make it the next feature |
| a separate feature                             | keep it out of this plan: hand it over (below) and finish this one      |

To add a ticket, ask in a new session:

```
Add a ticket to @.scratch/<slug>/PLAN.md: <the idea>. Write its file in issues/ like the others and add its row.
```

- **Change only tickets that are still `todo`.** A session may be building the others.
- **Write every change of intent down**: a small one in the Notes, a large one in the spec. The review
  compares the code with the spec and reports anything else as not asked for.
- **Decide behaviour in an interview, not by editing a ticket.** The interview asks about consequences
  you did not think of.
- **Answer the agent's questions in the session that asked them.** A build can end with questions for
  you. Only that session knows where each came from, so answer there and have it write the answers down:
  in the Notes, in the spec if behaviour changes, as a new ticket if there is work to do. Build those
  tickets in a new session.

**Trying another approach is an experiment, not a spec.** A spec records decisions already made. To learn
whether a new approach beats the one already built:

1. Name the question and the measure before you start.
2. Try it in throwaway code, in a new session, outside the feature's branch.
3. Have the numbers and the conclusion written into a file.
4. If the answer is worth building, go on to `/grill-with-docs` and a spec.

**Starting the next feature from this one.** In the session that knows the idea:

```
/handoff a new feature: <the idea>
```

- Move the file it writes into `.scratch/`.
- Start the new feature in a new session with that file and `/grill-with-docs`. It gets a folder and a
  branch of its own.
- The handoff points at this feature's spec and plan instead of repeating them. `/cleanup` warns you
  before it deletes a folder that something in `.scratch/` still points at.

### 5. The Wayfinder route

1. Start the map. With no interview yet, run `/wayfinder <the idea>`. From an interview that outgrew its
   session:

   ```
   /handoff the next session charts a /wayfinder map
   <move the file it writes into .scratch/>
   /clear
   /wayfinder @.scratch/<file>
   ```

   Either way it asks what the work should end in, then writes the **map**: a file listing the questions
   that must be answered before anything is built. `/clear`.
1. `/wayfinder @.scratch/<slug>/map.md` — it picks the next open question, works through it with you
   and writes the answer into the files. One question per session: `/clear`, then the same command again,
   until no question is left.
1. Run Stage 1 of the Full route, starting with `/to-spec @.scratch/<slug>/map.md` instead of
   `/grill-with-docs`.

The map and the feature share one folder. Stage 1 adds the spec, the build tickets and the plan to it:

```
.scratch/<slug>/
  map.md               the goal, the decisions made so far, what is still unclear
  issues/NN-<slug>.md  one question per file; build tickets come later, numbered after the questions
  prototypes/          what was built to answer a question
```

- **Keep the goal small.** When `/wayfinder` asks what the work should end in, name one piece that ends in
  a single merged PR ("users can create and delete decks"), not the whole product. Once it is merged, run
  `/wayfinder` again for the next piece: each piece gets its own map.
- **`/wayfinder` decides; it does not write product code.** A question that reads "build X" belongs to
  Build.
- **A question that needs reading is answered by a subagent**, as soon as the map is written. It needs web
  access. Its findings land on a branch `research/<name>`, in a working copy under `.claude/worktrees/`.
  The branch is pushed and never merged: keep it if you want the findings, and delete the working copy.
- **Save a prototype before `/cleanup`.** It sits in `prototypes/`, which git ignores, and goes with the
  folder. Commit it to a branch if you want to keep it.

### 6. Four habits

- **A new session lacks something? Put it in a file.** Add it to the Notes in `PLAN.md`, to the glossary
  or to an ADR. Do not paste the old chat.
- **Start a new session early** when the agent forgets something already agreed, when you correct it
  twice on the same point, or when the context was compacted automatically.
- **Keep the branch and the folder named alike**: `<type>/<slug>` and `.scratch/<slug>/`, for example
  `feat/collection-stats`. That is how `/ship` and `/cleanup` find the feature. The agent does this when
  it creates the branch; `CLAUDE.md` tells it to.
- **Use `/handoff` only when work has to move somewhere else**: to a prototype in another folder, to a
  second session for a side problem found mid-ticket, to a `/wayfinder` session when an interview outgrew
  its own, or to the next feature. Stages already hand over through files. It writes its file to the temp
  folder, so move it into `.scratch/` if the next session does not start right away.

### 7. What lives where, and for how long

| Lives as long as | Files                                                                          | Where                              |
| ---------------- | ------------------------------------------------------------------------------ | ---------------------------------- |
| the feature      | `spec.md`, `PLAN.md`, tickets                                                  | `.scratch/<slug>/`, ignored by git |
| the project      | `CLAUDE.md`, `CODING_STANDARDS.md`, `GLOSSARY.md`, `docs/adr/`, `docs/agents/` | the project's git                  |
| this repository  | skills, practices                                                              | here                               |

Before a feature's files are deleted, anything still worth knowing moves up a row: a new term goes to
`GLOSSARY.md`, a decision that must not be undone goes to an ADR. `/ship` checks this for you.

An ADR is one short paragraph, written only for a decision that is hard to reverse, surprising without
context, and a real trade-off. The `domain-modeling` skill writes it, in its own format.

## Setting up a project

Four steps, once per project.

### Step 1. Install the skills from mattpocock/skills

```
npx skills@latest add mattpocock/skills
```

Install into the project, not globally. The installer asks which skills to take; pick these seventeen:

| Skill                      | Who runs it             | What it is for                                              |
| -------------------------- | ----------------------- | ----------------------------------------------------------- |
| `setup-matt-pocock-skills` | you, once               | configures the project for the other skills (step 3)        |
| `wayfinder`                | you, before Shape       | plans work too big for one session as a map of questions    |
| `grill-with-docs`          | you, in Shape           | the interview that settles what to build                    |
| `to-spec`                  | you, in Shape           | writes `spec.md` from the interview or from the map         |
| `to-tickets`               | you, in Shape           | cuts the spec into tickets                                  |
| `implement`                | you, in Build           | writes the code for one ticket                              |
| `code-review`              | you, in Review          | checks the branch against the spec and the coding standards |
| `retro`                    | you, after a bad run    | proposes checks and rules so a mistake is caught next time  |
| `handoff`                  | you, when work moves    | writes the conversation into a file for another session     |
| `grilling`                 | another skill           | the interview itself; `grill-with-docs` calls it            |
| `domain-modeling`          | another skill           | writes `GLOSSARY.md` and ADRs; `grill-with-docs` calls it   |
| `tdd`                      | another skill           | test first, then code; `implement` calls it                 |
| `codebase-design`          | another skill           | module-design vocabulary; `tdd` calls it                    |
| `research`                 | you, or `wayfinder`     | answers a question that needs reading the sources           |
| `prototype`                | you, or `wayfinder`     | answers a question only running code can                    |
| `pr`                       | another skill           | shapes the PR description when `/ship` opens the PR         |
| `writing-for-agents`       | another skill           | writing style for agent instructions; `retro` calls it      |

Do not skip the last eight: the skills you type do nothing without them.

One more is optional: `implement-spec`, to build every ticket of a plan in one run.

### Step 2. Install the skills from this repository

The same installer takes this repository as a source, in either of two ways:

```
npx skills@latest add <path to this repository> --skill setup-ai-sdlc --skill ship --skill cleanup    # from a local folder
npx skills@latest add <owner>/ai-sdlc --skill setup-ai-sdlc --skill ship --skill cleanup              # from its git repository
```

| Skills                                | Which to install                                                                                                 |
| ------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `setup-ai-sdlc`, `ship`, `cleanup`    | always                                                                                                           |
| `sql-persistence`, `http-integration` | only in a project built as ports and adapters, and only the ones its code needs: add `--skill <name>` for each |

### Step 3. Run the setup skill from mattpocock/skills

```
/setup-matt-pocock-skills
```

When it asks where issues live, choose **Local markdown**. It writes `docs/agents/` and adds an
`## Agent skills` block to the project's instructions: `CLAUDE.md`, or `AGENTS.md` when `CLAUDE.md` only
imports it.

### Step 4. Run the setup skill from this repository

```
/setup-ai-sdlc
```

It looks at the project, shows what it would change, and writes only after you confirm:

| What it sets up                | In a new project                    | In a project that already has instructions            |
| ------------------------------ | ----------------------------------- | ----------------------------------------------------- |
| agent instructions             | creates `CLAUDE.md` from a template | adds only the branch rule and the guidance-skill lines |
| `CODING_STANDARDS.md`          | creates it                          | creates it, pointing at the project's own rules       |
| `docs/agents/issue-tracker.md` | appends the `PLAN.md` format        | the same                                              |
| `.gitignore`                   | adds `.scratch/`                    | the same                                              |

Afterwards it tells you what is left for you: placeholders to fill in a new `CLAUDE.md`, or instructions
that do not name the checks required before a change is done (`/ship` runs what they name).

Two things depend on the kind of project, and the skill asks when it cannot tell:

- **Python**: it adds a `## Tooling` section telling the agent to use `uv`, unless the project already
  uses another tool.
- **Python built as ports and adapters**: a new `CLAUDE.md` also gets the architecture sections — layers,
  ports, naming, errors. Any other new project gets a `## Structure` placeholder for you to fill in.

`CLAUDE.md` is for the agent writing code. `CODING_STANDARDS.md` is for the agent reviewing it: it points
at the same rules, so they are checked even if nobody invoked the skill while writing.

### What the project has afterwards

```
CLAUDE.md or AGENTS.md           rules for writing code, plus the Agent skills block
CODING_STANDARDS.md              pointers for the reviewer
.gitignore                       contains .scratch/
skills-lock.json                 written by the installer: which skills are installed, and from where
.claude/skills/                  seventeen from mattpocock/skills, three from here, your guidance skills
docs/agents/issue-tracker.md     how tickets are tracked, with the PLAN.md format at the end
docs/agents/domain.md            how the skills use the glossary and ADRs
```

### Keeping the flow to yourself in a shared project

When others work in the project and the flow is only yours, keep its files on disk and out of git. Claude
Code reads skills from `.claude/skills/` whether git tracks them or not.

1. **Hide the files from git through `.git/info/exclude`, not `.gitignore`.** It works the same way, but
   it is not committed, so nobody else sees it:

   ```
   .claude/skills/
   skills-lock.json
   .scratch/
   docs/agents/
   CODING_STANDARDS.md
   ```

   If the project has shared skills of its own, list the flow's skill folders one by one instead of the
   whole `.claude/skills/`.
1. **Move what the two setup skills added to the shared instructions into `CLAUDE.local.md`**: the
   `## Agent skills` block, the branch rule, the guidance-skill lines. Claude Code loads that file next to
   `CLAUDE.md` and keeps it out of git. There is no `AGENTS.local.md`.
1. **If the project has `AGENTS.md` and no `CLAUDE.md`, start `CLAUDE.local.md` with the line
   `@AGENTS.md`.** Otherwise Claude Code stops reading `AGENTS.md` once `CLAUDE.local.md` exists.

`GLOSSARY.md` and `docs/adr/` describe the project, not the flow: leave them shared.

What this costs: no history of the skills, a fresh clone or another machine needs the setup again, git
worktrees do not get the skills, and `git clean -x` removes them.

### Updating the skills later

```
npx skills update
```

- This updates everything installed from a git repository. For skills installed from a local folder, run
  the `add` command from step 2 again.
- Run `/setup-ai-sdlc` again after re-running `/setup-matt-pocock-skills` or installing another guidance
  skill. It adds only what is missing.
- After updating mattpocock/skills, check that three things still hold: tickets live in
  `.scratch/<slug>/`, `/implement` neither creates a branch nor closes a ticket, and `/code-review` finds
  the spec in `.scratch/` and the standards in `CODING_STANDARDS.md`. Then update the date at the top of
  this file.

## Splitting a project's instructions

A project starts with all its rules in one file, `CLAUDE.md` or `AGENTS.md`, loaded into every session.
That is fine until the file gets long.

### When to split

- The file is past about 200 lines.
- A whole section matters only in one part of the code, such as testing rules.
- `/retro` reports lines that do not change what the agent does, or the agent keeps forgetting a rule
  that is written down.

Split one section at a time, the largest first.

### What stays in the root file

What the agent needs before it opens any file: what the project is, the layer map, naming, the commands
to run, and pointers to everything below.

### Where the rest goes

| The content is…                                     | Put it in                                         | It is loaded…                               | Other agents read it |
| --------------------------------------------------- | ------------------------------------------------- | ------------------------------------------- | -------------------- |
| rules needed only in some situations                | a file in `docs/agents/`, with a pointer to it in the root file | when the situation in the pointer comes up | yes |
| rules for one folder                                | `AGENTS.md` or `CLAUDE.md` inside that folder     | when the agent reads a file in the folder   | yes                  |
| rules for files matching a pattern, across folders  | `.claude/rules/<name>.md` with `paths:`           | when the agent reads or edits such a file   | no, Claude Code only |
| rules for a kind of code, the same in every project | a guidance skill                                  | when the agent sees the code fits           | yes                  |
| a procedure of several steps                        | a skill you invoke                                | when you type it                            | yes                  |
| rules only the reviewer needs                       | `CODING_STANDARDS.md`                             | at review                                   | yes                  |
| a fixed pattern a tool can catch                    | a linter rule or a test                           | on every commit, and it cannot be forgotten | yes                  |

The first row is the default: it works in every agent and needs nothing but a file and a line pointing at
it. This is how mattpocock/skills organises its own repository.

### Rules for splitting

- **Write each pointer as a condition.** "When you add or change a test, read `docs/agents/testing.md`"
  gets the file read; "see also `docs/agents/testing.md`" does not. If an important file is not being
  read, sharpen the pointer before moving the text back.
- **One home for each rule.** Everything else links to it.
- **Do not restate what the agent can look up**: commands in a Makefile, settings in a config file, the
  folder layout. Write down what it cannot find by looking: an unwritten convention, the reason behind a
  choice, a trap.
- **List every rule file in `CODING_STANDARDS.md`.** The reviewer gets a diff, so rules behind a pointer,
  a folder or a path may never load for it.
- **An `@import` saves nothing.** The imported file is loaded in full at the start, like the file that
  imports it.
- **A folder file is named for the agents you use.** For Claude Code alone, `CLAUDE.md`. With other agents
  too, put the text in `AGENTS.md` and add a one-line `CLAUDE.md` next to it containing `@AGENTS.md`.
- **With more than one agent, keep the text out of `.claude/rules/`.** Use it only for a short pointer to a
  rule that lives in `AGENTS.md`, a doc or a skill.

## This repository

How this repository is organised, for when you change it.

### Where a new file goes

To decide where a new file goes in this repository, ask **when the agent needs it**, not what it is about.

| When it is needed                              | Put it in                                  | Why                                                                           |
| ---------------------------------------------- | ------------------------------------------ | ----------------------------------------------------------------------------- |
| on every request                               | `CLAUDE.template.md` in `setup-ai-sdlc`    | it ends up in `CLAUDE.md`, which is always loaded: keep it short              |
| whenever a certain kind of work comes up       | `skills/<kind>/<name>/`                    | only its description is always loaded; the rest loads when the work comes up  |
| once per project, to be written into it        | `templates/` in `setup-ai-sdlc`            | `/setup-ai-sdlc` writes it into the project; the copy belongs to the project  |
| when a decision in its area has to be made     | `practices/`                               | options and trade-offs useful in more than one project; copied in when needed |
| never by the agent: it is for a person to read | the project's own `docs/`                  | it explains and records; nothing acts on it                                   |

If a document fits two rows, split it into two files, one for each row.

### Skill layout

Each skill is a directory:

- `SKILL.md` — required. The description that triggers the skill, then steps or rules in imperative form.
  It loads every time the skill fires, so keep it short.
- `reference.md` — optional. Why the rules hold: the reasoning, the trade-offs, the sources. Add it when
  that reasoning would bloat `SKILL.md`; it is read only when someone needs to know *why*. The guidance
  skills have one; `ship` and `cleanup` do not.
- Other files — optional. Whatever the skill reads or copies while it runs: `setup-ai-sdlc` carries a
  `templates/` folder with the files it writes into a project.

Skills come in two kinds, one folder each, split the way mattpocock/skills splits them:

- **Core skills** (`skills/core/`) are steps of the flow itself — `setup-ai-sdlc`, `ship`, `cleanup`. Each is a workflow
  the user starts; they carry `disable-model-invocation: true`, so only typing them runs them. Every
  project using the flow gets all of them.
- **Guidance skills** (`skills/guidance/`) are rules for a kind of code — `sql-persistence`,
  `http-integration`. The agent loads them itself when the code fits; they hold no workflow, because the
  code they govern is written inside `/implement`'s. A project gets the ones its code needs. Both assume
  a project built as ports and adapters and use its port names — repository, reader, gateway.
  `/setup-ai-sdlc` writes those sections only into a new Python project built that way; any other project
  must define them in its own instructions.

A rule goes in `guidance/` even when every project would want it; `core/` holds only the flow's steps.
The folders exist only here: in a project, skills sit flat in `.claude/skills/`.

Write the description for the situation, not for the request. A core skill triggers on what the user
asks for; a guidance skill triggers on the shape of the code being written or reviewed ("a port whose
adapter makes network calls"). Guidance skills are the ones that get forgotten, so their descriptions name
the code, not the intent — and `CLAUDE.md` and `CODING_STANDARDS.md` point at them as well.

#### When to add a guidance skill

Add one when all three are true:

- **The rules are for a kind of code**, such as database access or calls to a remote API, not for one
  project.
- **You want the same rules in every project, kept in one place.** This is what a skill gives over a file
  in a project's `docs/agents/`: it installs and updates with one command.
- **A reviewer could point at a violation in a diff.** A choice between options that is made once is a
  practice, not a rule.

Rules that belong to one project stay in that project: see "Splitting a project's instructions".

#### How to add one

1. Create `skills/guidance/<name>/SKILL.md`. The description names the code the rules apply to. The body
   is the rules in imperative form, each with what goes wrong when it is broken.
1. Add `reference.md` if the rules need their reasoning written down.
1. Add a line for the skill to both templates in `skills/core/setup-ai-sdlc/templates/`: the Guidance
   skills section of `CLAUDE.template.md` and the pointer list of `CODING_STANDARDS.template.md`. The
   first is how the agent writing code finds the skill, the second is how the reviewer does.
1. In each project that needs it: install it with `npx skills add … --skill <name>`, then run
   `/setup-ai-sdlc` again.

### Practices

`practices/` holds what is worth knowing before making a decision in some area — the options, what each
costs, the traps, what was measured — written so it can serve more than one project. A draft stays in the
project it came from; a document comes here once it has been generalised.

The folder is flat. A file's name starts with its area — `persistence-`, `http-`, `packaging-` — so
sorting groups an area together without a directory per area; add one only once an area outgrows a few
files.

What a project chose does not belong here: that is the project's ADR. When a decision comes up, copy the
practice into the project's `docs/`, adapt it, and let the ADR link to that copy.
