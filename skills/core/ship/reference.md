# Why ship works this way

Background for `SKILL.md`. It assumes the flow this repository describes: grilling, spec and tickets in
one session, one build session per ticket, a final review in a fresh session — with mattpocock/skills
providing `to-spec`, `to-tickets`, `implement`, `code-review`, `domain-modeling` and `pr`.

## The gap it fills

None of those skills finishes a feature. `implement` commits to whatever branch is checked out and never
closes the ticket it worked on; `code-review` reports and stops; `pr` only shapes a body when something
else opens a PR. What happens between "the last ticket is done" and "the change is up for merge" was a
paragraph of prompt retyped every time, which is exactly the kind of repeated procedure a user-invoked
skill is for.

## Why the slug comes from the branch

The flow names the branch after the feature folder: `feat/<slug>` and `.scratch/<slug>/`. Reading one from
the other means the skill needs no argument, and a mismatch — wrong branch checked out, folder renamed —
shows up as a missing PLAN.md instead of as work shipped under the wrong name.

## Why it stops instead of fixing

Ship runs at the end, usually in the review session or a fresh one, and its context holds none of the
reasoning behind the code. An unfinished ticket or a red test fixed here is a change made without that
context and without review. Stopping sends the work back to where it belongs — a build or follow-up
session — and keeps `/ship` a step that either passes or reports, never one that quietly writes code.

The same goes for a dirty working tree: the changes may be half of an edit the user is still making.
Committing them ships something nobody reviewed; discarding them loses work.

## Why the glossary and ADRs come before the PR

`.scratch/` dies with the feature. Anything in the spec that should outlive it — a term the code now uses,
a decision a later session must not undo — has to be committed somewhere durable first. It goes on the
feature branch so that it reaches `main` in the same merge as the code it describes; after the merge the
only way in is another PR.

The ADR test is mattpocock/skills' own (`domain-modeling`): hard to reverse, surprising without context,
the result of a real trade-off. All three, or no ADR. Most features pass it rarely, and `domain-modeling`
already writes terms and decisions inline while grilling, so this step is a check for what slipped through,
not a second write-up.

Knowledge that outlives the *project* — a practice worth reusing elsewhere — is only named. Writing it
means writing outside this repository, into the user's own collection, and adapting it is the user's call.

## Why the PR is the stopping point

The merge is the user's decision: CI has to run, and the user may want to read the diff on GitHub first.
Squash-merging on GitHub also means the per-ticket commits stay visible in the PR while `main` gets one
commit, with no local history rewriting and no force-push.

Cleanup is a separate skill because it can only run after an event this skill does not control. See the
`cleanup` skill's `reference.md`.
