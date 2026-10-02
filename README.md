# ai-sdlc

How I take a feature from "I want X" to a merged PR with an AI agent, and the reusable artifacts that flow
needs: the rules a project always follows, the guidance that applies when particular code is being
written, the templates that produce a project's own records, and the practices worth knowing before a
decision.

The flow is built on [mattpocock/skills](https://github.com/mattpocock/skills) and adds what those skills
leave open: progress tracking across sessions, finishing a feature, and the project's own coding rules.

## The flow

The principle underneath: **context arrives in portions**. Each stage is its own session, and stages hand
over through files, never through a conversation. If a fresh session needs something only an earlier chat
knew, the artifact is missing it — fix the artifact rather than pasting the chat.

### Pick the route by the task

| Route        | When                                                                                    | Stages                                   |
| ------------ | --------------------------------------------------------------------------------------- | ---------------------------------------- |
| **Just ask** | the expected behaviour fits in one sentence and you know where the code is              | one session, no artifacts                |
| **Short**    | there is a design decision (a new port, table, external service), but the work does not split | `/grill-with-docs`, then `/implement` in the same session |
| **Full**     | the work splits into pieces that can each be verified on their own, or the end is not in sight | the pipeline below                       |

A route can be raised midway: when grilling shows the task is bigger than it looked, carry on to `/to-spec`
in the same session. The short route has no PLAN.md, so `/ship` and `/cleanup` do not apply: create the
branch before `/implement`, then ask for the PR directly.

### The full pipeline

```
Shape — one unbroken session
  /grill-with-docs <what you want, not how to build it>
      → you confirm the shared understanding before anything else happens
  /to-spec        → you confirm the seams the tests will sit at
  /to-tickets     → you approve the breakdown; it also writes PLAN.md
  git switch -c feat/<slug>
  /clear

Build — one session per ticket
  /implement the next ticket from @.scratch/<slug>/PLAN.md, keeping PLAN.md up to date
      as docs/agents/issue-tracker.md describes
  /clear, then the same prompt again until every ticket is done

Review — a fresh session
  /code-review main — then fix what it finds
  /retro

Follow-up — a fresh session, only if needed
  I just implemented @.scratch/<slug>/PLAN.md. One last change I need: …

Finish
  /ship           → checks, glossary and ADRs, push, PR
  squash-merge on GitHub
  /cleanup        → .scratch/<slug>/ and the branch are removed
```

What each stage relies on:

- **Shape stays in one session.** Spec and tickets are built on the reasoning of the grilling, not on a
  summary of it. If the session nears the point where the model stops reasoning sharply (~150k tokens)
  before `/to-tickets`, `/compact` at the nearest stage boundary rather than pushing on.
- **There are three human checkpoints, all in Shape**: the shared understanding, the seams, the breakdown.
  Past Shape the spec is not re-read; these are what it rests on.
- **The branch is created before the first build session**, because `/implement` commits to whatever is
  checked out. Branch and folder share the slug, which is how `/ship` and `/cleanup` find the feature.
- **PLAN.md is the only progress state.** `/implement` neither closes a ticket nor ticks its criteria; the
  build prompt makes the session do it, in the format the project's `docs/agents/issue-tracker.md` holds.
- **The review in a fresh session is the one that counts.** The review `/implement` runs happens before its
  commit, against an empty diff. The fresh session reviews the whole branch against the spec and against
  `CODING_STANDARDS.md`.
- **`/retro` runs in the review session**, which has just seen what the build sessions missed. It proposes
  checks and standards, not code.

Start a fresh session early, outside the stage boundaries too, when the agent forgets a constraint already
agreed, when you correct it twice on the same thing (that correction is also a glossary or ADR candidate),
or when the context has been compacted automatically.

### What each artifact lives for

| Lives as long as | Artifact                                                                    | Where                         |
| ---------------- | --------------------------------------------------------------------------- | ----------------------------- |
| this repository  | templates, skills, practices                                                | here                          |
| the project      | `CLAUDE.md`, `CODING_STANDARDS.md`, `GLOSSARY.md`, `docs/adr/`, `docs/agents/` | the project's git             |
| the feature      | `spec.md`, `PLAN.md`, `issues/NN-<slug>.md`                                 | `.scratch/<slug>/`, ignored by git |

Content moves to a longer-lived artifact or dies with its own. `/ship` asks the question before the PR: a
term the code now uses goes to `GLOSSARY.md`, a decision a later session must not undo goes to an ADR.
Anything worth keeping beyond the project is a candidate for `practices/` here, carried over by hand.

**ADRs** are written by mattpocock/skills' `domain-modeling` in its short format by default: a paragraph,
and only for a decision that is hard to reverse, surprising without context and the result of a real
trade-off. `templates/adr/0000-template.md` is for the decision whose rejected options need spelling out.
Either way an accepted ADR is not edited; a change of mind is a new ADR that supersedes it.

## Setting up a project

1. **Install the skills from mattpocock/skills** into the project, not globally:
   `npx skills@latest add mattpocock/skills`, picking `setup-matt-pocock-skills`, `grill-with-docs`,
   `grilling`, `domain-modeling`, `to-spec`, `to-tickets`, `implement`, `tdd`, `codebase-design`,
   `code-review`, `pr` and `retro`. Several are only called by others — `grill-with-docs` is nothing but
   `grilling` plus `domain-modeling`, and `implement` drives `tdd` — so leaving them out breaks the ones
   you type. Update deliberately with `npx skills update`.
1. **Run `/setup-matt-pocock-skills`** and choose the local-markdown issue tracker. It writes
   `docs/agents/` and an `## Agent skills` block in `CLAUDE.md`; re-running it rewrites both.
1. **Append `templates/issue-tracker-plan.md` to `docs/agents/issue-tracker.md`.** That is where the
   skills look for how the tracker works, so it is where PLAN.md's format lives. Re-running the setup
   drops it again.
1. **Copy `templates/CLAUDE.md` and `templates/CODING_STANDARDS.md` to the project root** and fill in the
   project-specific parts. The first is for the agent writing code; the second is for the agent reviewing
   it, and points it at the same rules so that a skill nobody invoked while writing is still checked.
1. **Copy the skills from this repository** into `.claude/skills/`, flat: everything in `skills/core/`,
   and from `skills/guidance/` the skills the project's code needs. Drop the lines for the others from the
   two templates above.
1. **Copy `templates/adr/README.md` to `docs/adr/README.md`**, so the ADR conventions sit next to the
   records the agent reads.
1. **Add `.scratch/` to `.gitignore`.**

## Where a new artifact goes

The placement rule is **cadence**, not topic. Ask how often the material has to be in play.

| Cadence                                             | Home                      | Why                                                                             |
| --------------------------------------------------- | ------------------------- | ------------------------------------------------------------------------------- |
| Every turn, and short                               | `templates/CLAUDE.md`     | Always in context; anything long here is paid for on every request              |
| On a recognisable, recurring situation              | `skills/<kind>/<name>/`   | Only the description is always loaded; the body arrives when the situation does |
| Once per project, producing a document              | `templates/`              | The template is reusable; its filled-in output belongs to the project, not here |
| When a decision in its area comes up                | `practices/`              | Options, trade-offs and traps that outlive one project; copied in when needed   |
| Written for a human to read, not an agent to follow | the project's own `docs/` | Reference and reasoning that nothing needs to act on turn by turn               |

A document that mixes two cadences is two artifacts. Split it before deciding where it lives — that is
the most common mistake, and it is why "where do I put this?" so often has no single answer.

## Skill layout

Each skill is a directory with two files:

- `SKILL.md` — the trigger in its frontmatter description, then rules in imperative form. This is what
  loads when the skill fires, so it stays short and actionable.
- `reference.md` — the reasoning, the trade-offs, the sources. Read only when the agent or a human needs
  to know *why*. Keeping it out of `SKILL.md` is what makes invoking the skill cheap.

Skills come in two kinds, one folder each, split the way mattpocock/skills splits them:

- **Core skills** (`skills/core/`) are steps of the flow itself — `ship`, `cleanup`. Each is a workflow
  the user starts; they carry `disable-model-invocation: true`, so only typing them runs them. Every
  project using the flow gets all of them.
- **Guidance skills** (`skills/guidance/`) are rules for a kind of code — `sql-persistence`,
  `http-integration`. The agent loads them itself when the code fits; they hold no workflow, because the
  code they govern is written inside `/implement`'s. A project gets the ones its code needs.

A rule goes in `guidance/` even when every project would want it; `core/` holds only the flow's steps.
The folders exist only here: in a project, skills sit flat in `.claude/skills/`.

Write the description for the situation, not for the request. A core skill triggers on what the user
asks for; a guidance skill triggers on the shape of the code being written or reviewed ("a port whose
adapter makes network calls"). Guidance skills are the ones that get forgotten, so their descriptions name
the code, not the intent — and `CLAUDE.md` and `CODING_STANDARDS.md` point at them as well.

A rule belongs in a guidance skill when a reviewer could point at its violation in a diff. A choice between
options that is made once is a practice.

## Practices

`practices/` holds what is worth knowing before making a decision in some area — the options, what each
costs, the traps, what was measured — written so it can serve more than one project. A practice can start
as a project's draft and be generalised later.

The folder is flat. A file's name starts with its area — `persistence-`, `http-`, `packaging-` — so
sorting groups an area together without a directory per area; add one only once an area outgrows a few
files.

What a project chose does not belong here: that is the project's ADR. When a decision comes up, copy the
practice into the project's `docs/`, adapt it, and let the ADR link to that copy.

## Contents

```
templates/
  CLAUDE.md                      project rules skeleton — layers, ports, naming
  CODING_STANDARDS.md            pointers for the reviewer to every rule it should check
  issue-tracker-plan.md          PLAN.md format, appended to docs/agents/issue-tracker.md
  adr/
    README.md                    what belongs in an ADR, numbering, superseding
    0000-template.md             full decision record, for when the options need spelling out
skills/
  core/
    ship/                        finish a feature and open its PR
    cleanup/                     remove a merged feature's branch and .scratch folder
  guidance/
    sql-persistence/             data access against a database
    http-integration/            data access against a remote API
practices/
  persistence-domain-model-meets-sql.md   choosing how the domain model is stored in SQL
```

Open questions about this repository itself are tracked in `TODO.md`.
