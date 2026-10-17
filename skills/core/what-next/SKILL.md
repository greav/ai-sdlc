---
name: what-next
description: >-
  Tell the user which step of the ai-sdlc flow comes next: the command to type, the prompt to give it and
  whether to start a new session first, worked out from this conversation, the branch and the files in
  `.scratch/`. Use when the user asks what to do next, how to go on, which command or prompt follows the
  one just run, or seems unsure between stages of the flow.
---

# The next step of the flow

Answer with the next step; do not take it. Most of the flow's commands only run when the user types them,
and many steps must start in a new session, which only the user can open.

## 1. Look

- **This conversation.** Which flow command ran here last and how it ended: an interview that settled one
  piece of work or several, a spec written, tickets approved, a ticket built, a review with findings left.
  Nothing ran yet: what the user wants to do.
- **The branch.** The current one and the default one. A feature branch is `<type>/<slug>`, and its work's
  folder, if it has one, is `.scratch/<slug>/`.
- **The work's folder.** Which of `map.md`, `spec.md`, `PLAN.md` exist. In `PLAN.md`: each ticket's
  status, the `Branch:` line, and Notes marked `Open:`. In `map.md`: whether questions are still open.
- **Git.** Uncommitted changes, commits ahead of the default branch, and the branch's PR on the hosting
  service: none, open or merged.
- **The project.** `docs/agents/issue-tracker.md` missing means the flow is not set up. Whether there is
  any product code yet, beyond the files the setup wrote. The top row of
  `.scratch/backlog/BACKLOG.md`, if there is one, is the next piece of work the user picked.

## 2. Decide

Take the first row that fits. What happened in this conversation outranks the files: they lag behind it.

**After a command in this conversation**

| What just happened                                                  | Next                                                                                                    |
| ------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| `/setup-ai-sdlc` finished                                           | what its last message names: a restart with `claude -c`, `/setup-matt-pocock-skills`, `/setup-ai-sdlc` again. Once it has written the project files: the row for a project with no code yet, or the route table |
| `/grill-with-docs` settled one piece of work                        | Short route, same session: `Create the branch <type>/<slug>`, then `/implement`                          |
| `/grill-with-docs` settled several pieces, each testable on its own | Full route, same session: `/to-spec`                                                                    |
| the interview outgrew the session, or kept needing a prototype      | `/handoff the next session charts a /wayfinder map`, move the file into `.scratch/`, `/clear`, then `/wayfinder @.scratch/<file>` |
| `/to-spec` wrote the spec                                           | same session: `/to-tickets then write PLAN.md`                                                          |
| `/to-tickets` wrote `PLAN.md`                                       | same session: `Create the branch named in @.scratch/<slug>/PLAN.md and commit GLOSSARY.md and docs/adr/ on it`, then `/clear` |
| `/wayfinder` wrote or advanced the map                              | `/clear`, then the row for a map below                                                                  |
| `/implement` committed a ticket of a plan                           | `/clear`, then the rows for a plan below                                                                |
| `/implement` finished the Short route, or `/diagnosing-bugs` a fix  | a new session: `/code-review <default-branch>`                                                          |
| `/improve-codebase-architecture` ended its interview                | same session: `Create the branch refactor/<slug>`, then `/implement` for one piece or `/to-spec` for several |
| `/code-review` reported findings                                    | same session: `Fix the findings that are not mine to decide; list the rest`. If they were real problems, `/retro` after the fixes |
| the session searched long, lacked information or went badly         | `/retro` here, before `/clear`                                                                          |
| a test fails and the agent cannot say why after a try or two        | `/diagnosing-bugs` in this session                                                                      |

**From the files, in a new session**

| What the files show                                           | Next                                                                                       |
| ------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| no `docs/agents/issue-tracker.md`                             | `/setup-ai-sdlc`; if the flow's skills are installed already, `/setup-matt-pocock-skills` (choose **Local markdown**), then `/setup-ai-sdlc` again |
| no product code yet: only what the setup wrote                | `/grill-with-docs <what the project is for, who uses it, what its first version must do>`; when the stack is still open and needs comparing, `/research <which stack fits …>` first |
| default branch, nothing in progress                           | the top backlog item, `/grill-with-docs @.scratch/backlog/<slug>.md`, or the route table below |
| a map with open questions                                     | `/wayfinder @.scratch/<slug>/map.md`                                                        |
| a map with no open question and no spec                       | `/to-spec @.scratch/<slug>/map.md`                                                          |
| a spec and no `PLAN.md`                                       | `/to-tickets @.scratch/<slug>/spec.md then write PLAN.md`                                   |
| `PLAN.md`, but its branch does not exist                      | `Create the branch named in @.scratch/<slug>/PLAN.md and commit GLOSSARY.md and docs/adr/ on it` |
| Notes marked `Open:`                                          | answer them first, in the session that asked if it is still open; have the answers written into `PLAN.md` |
| a ticket `in-progress` waiting for the user's own check       | the check: a real device, a permission; then tell the agent the result                     |
| tickets still `todo`                                          | `/implement the next ticket from @.scratch/<slug>/PLAN.md and update the plan`, or the one-run prompt below when every ticket is `todo` |
| every ticket `done`                                           | `/code-review <default-branch>, spec: @.scratch/<slug>/spec.md, already decided: the Notes in @.scratch/<slug>/PLAN.md` — or `/ship` if the review already ran |
| a feature branch with commits and no folder (Short, Bug)      | `/code-review <default-branch>` — or `/ship` if the review already ran                     |
| an open PR                                                    | merge it: a squash merge, or a merge commit for a branch built by `/implement-spec`        |
| a merged PR, the branch still here                            | `/cleanup`                                                                                 |

Whether a review already ran is not in the files. Ask, or give both steps with the condition for each.

**Choosing a route** when the user has only an idea:

| The task is…                                                 | Next                                                                     |
| ------------------------------------------------------------ | ------------------------------------------------------------------------ |
| a small fix that fits one sentence                           | just ask the agent; no command                                           |
| a bug nobody can explain                                     | `Create the branch fix/<slug>`, then `/diagnosing-bugs <what you did, what you expected, what happened>` |
| code that works but is hard to change                        | `/improve-codebase-architecture <the area>`                              |
| needs a fact first: what an API allows, whether an idea works | `/research <the question>` or `/prototype <the question>`, then the interview |
| anything else                                                | `/grill-with-docs <what you want, not how to build it>`                  |

**The one-run prompt**, for a plan that is large but not critical:

```
/implement-spec @.scratch/<slug>/spec.md
Work on the branch named in @.scratch/<slug>/PLAN.md, not a new one; if it does not exist, stop and tell me.
Keep the plan up to date yourself. Leave the criteria only I can check unticked and list them at the end; they do not block the next ticket.
Do not put ticket numbers in commit messages.
Final review: fix plain defects only, and list the findings that need my decision.
```

**A change wanted after the review**, in a new session:
`I just implemented @.scratch/<slug>/PLAN.md. One last change I need: <the change>. Note it in PLAN.md.`

## 3. Answer

- **One line on where the work stands**, from what you saw: the route, the stage, what is done.
- **Whether to `/clear` or open a new session first.**
- **What to type**, in a code block, ready to paste: the real slug, branch and paths in place of the
  placeholders. Leave a placeholder only for what only the user knows, such as what they want.
- **Two options at most**, each with the condition that picks it, when the state allows both.

Keep commands and prompts in English, as written above; the rest in the user's language.

- **Nothing after the command's name but a space.** `/to-tickets, then…` is not recognised as a command,
  and the skill does not load.
- **Name only installed skills.** Check `.claude/skills/`. A missing one means `/setup-ai-sdlc` has to run
  again; say so instead of naming the skill.
- **Uncommitted changes come first.** Name them before the next step: a new session does not see what was
  never written down or committed.
