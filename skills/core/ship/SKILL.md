---
name: ship
description: >-
  Finish a piece of work and put it up for merge: confirm the checks pass, and — when the work has a
  `.scratch/<slug>/` folder — that every ticket in PLAN.md is done and that what should outlive it is in
  GLOSSARY.md, docs/adr/ and the backlog; then push the branch and open a pull request. Run once, after the
  review.
disable-model-invocation: true
---

# Ship a feature

Everything up to the open PR; merging stays with the user, and removing the leftovers belongs to
`/cleanup`.

"PR" here means whatever the project's hosting service calls a request to merge a branch: a pull request
on GitHub, a merge request on GitLab. Use the command-line tool for the service the remote points at.

## Find the feature

1. **The slug comes from the branch** `<type>/<slug>`. On the default branch, or on a name without a `/`,
   stop and ask — never guess which work is meant.
1. **See whether the work has a plan.** With `.scratch/<slug>/PLAN.md`, do every step below. With no
   `.scratch/<slug>/` folder at all, the work was done without a plan: skip the steps marked *with a plan*.
   A folder without a PLAN.md is neither: stop and ask.

## Check before anything leaves the machine

3. ***With a plan:* every ticket in PLAN.md is done.** If one is not, stop and name it. Do not finish it
   here: unfinished work goes back to a build session.
1. **The working tree is clean.** Uncommitted changes are either the user's or leftovers from a session;
   either way they are not yours to commit or discard. Stop and show them.
1. **The project's checks pass.** Run what the project's instructions name as required before a change is
   done — `CLAUDE.md` or `AGENTS.md`, and any file they point to for it. The full test suite at least,
   plus type checks and linters if they list them. If anything fails, stop and report it. Do not fix it
   here.

## Keep what should outlive the feature

6. ***With a plan:* compare `spec.md` with `GLOSSARY.md` and `docs/adr/`.** Look for domain terms the spec
   relies on that the glossary lacks, and for decisions that pass the ADR test: hard to reverse,
   surprising without context, the result of a real trade-off. Most were captured while grilling, so
   expect few. Propose them, then write only what the user accepts, in the `domain-modeling` skill's
   formats. Commit the additions on their own, before pushing, so they are merged together with the
   feature. If git ignores `GLOSSARY.md` and `docs/adr/`, the flow is personal in this project: write
   them and commit nothing.
1. ***With a plan:* move work left for later to the backlog.** Read the Notes in PLAN.md and the ticket
   files for work kept out of this feature: an idea set aside, a bug found and not fixed, a check the user
   dropped, a change deferred. Each one `.scratch/backlog/` does not already hold is a candidate: `/cleanup`
   deletes `.scratch/<slug>/` after the merge, and with it whatever was not moved out. Propose them, then
   write only what the user accepts, in the format of the `## Backlog` section of
   `docs/agents/issue-tracker.md`. Nothing to commit: `.scratch/` is ignored by git.
1. **The backlog index matches its files.** If `.scratch/backlog/` exists, name every item file without a
   row in `BACKLOG.md` and every row without a file, and fix them with the user.
1. **Ask whether anything is worth keeping beyond this project.** Name the candidate and stop there; it is
   the user's to carry into their practices, not yours to write outside the repository.

## Open the pull request

10. **Say which branch is about to be pushed and what it contains** — its name and its commits since the
   default branch. Without a plan the branch name is the only thing identifying the work, so this is where
   a wrong branch gets caught.
1. **Push the branch with upstream tracking.** Never force-push.
1. **Open the PR against the default branch.** Title in the project's domain language, describing what a
   user can now do. Let the `pr` skill shape the body.
1. **Nothing in the PR points into `.scratch/`.** It is ignored by git, so a link to it is broken for
   everyone, and it is about to be deleted.
1. **Stop at the open PR.** Report its URL. Do not merge it and do not touch `.scratch/`.
