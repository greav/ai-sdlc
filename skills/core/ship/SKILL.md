---
name: ship
description: >-
  Finish a feature built through the `.scratch/<slug>/` flow and put it up for merge: confirm every ticket
  in PLAN.md is done and the checks pass, move what should outlive the feature into GLOSSARY.md and
  docs/adr/, then push the branch and open a pull request. Run once, after the final review session.
disable-model-invocation: true
---

# Ship a feature

Everything up to the open PR; merging stays with the user, and removing `.scratch` belongs to `/cleanup`.
See `reference.md` for why each step is where it is.

## Find the feature

1. **The slug comes from the branch.** The branch is `<type>/<slug>` and the feature's files are in
   `.scratch/<slug>/`. On the default branch, on a name without a `/`, or with no `.scratch/<slug>/PLAN.md`,
   stop and ask — never guess which feature is meant.

## Check before anything leaves the machine

2. **Every ticket in PLAN.md is done.** If one is not, stop and name it. Do not finish it here: unfinished
   work goes back to a build session.
1. **The working tree is clean.** Uncommitted changes are either the user's or leftovers from a session;
   either way they are not yours to commit or discard. Stop and show them.
1. **The project's checks pass.** Run what `CLAUDE.md` names as required before a change is done — the
   full test suite at least, plus type checks and linters if it lists them. If anything fails, stop and
   report it. Do not fix it here.

## Keep what should outlive the feature

5. **Compare `spec.md` with `GLOSSARY.md` and `docs/adr/`.** Look for domain terms the spec relies on that
   the glossary lacks, and for decisions that pass the ADR test: hard to reverse, surprising without
   context, the result of a real trade-off. Most were captured while grilling, so expect few.
1. **Propose, then write only what the user accepts.** Use the `domain-modeling` skill's formats. Commit
   the additions on their own, before pushing, so they reach `main` together with the feature.
1. **Ask whether anything is worth keeping beyond this project.** Name the candidate and stop there; it is
   the user's to carry into their practices, not yours to write outside the repository.

## Open the pull request

8. **Push the branch with upstream tracking.** Never force-push.
1. **Open the PR against the default branch.** Title in the project's domain language, describing what a
   user can now do. Let the `pr` skill shape the body.
1. **Nothing in the PR points into `.scratch/`.** It is ignored by git, so a link to it is broken for
   everyone, and it is about to be deleted.
1. **Stop at the open PR.** Report its URL. Do not merge it and do not touch `.scratch/`.
