---
name: cleanup
description: >-
  Remove a shipped feature's working files once its pull request is merged: switch to the default branch,
  update it, delete `.scratch/<slug>/` and the feature branch. Refuses while the PR is open, closed
  unmerged, or missing. Run after the merge of a PR opened by `/ship`.
disable-model-invocation: true
---

# Clean up after a merge

`.scratch/` is ignored by git, so deleting it cannot be undone. Every step below exists to make sure
nothing is lost when it goes. See `reference.md` for why each holds.

## Find the feature

1. **The slug comes from the branch** `<type>/<slug>`. If the default branch is checked out, list the
   folders in `.scratch/` and ask which feature; never pick one yourself.

## Prove the work is in the default branch

2. **The PR for the branch is merged.** Look it up on the hosting service by its head branch. Open, closed
   without merging, or no PR at all: stop and report. A feature abandoned on purpose is the user's to
   clean up by hand.
1. **The local branch holds nothing the PR did not.** Its tip must equal the PR's head commit. If the local
   branch has commits beyond it, stop: they were never merged.
1. **The working tree is clean.** Stop and show any uncommitted change.

## Delete, with confirmation

5. **Show exactly what will be removed** — the `.scratch/<slug>/` folder with its files, the local branch,
   the remote branch if it still exists — and wait for the user to confirm.
1. **Switch to the default branch and update it** with a fast-forward-only pull.
1. **Delete `.scratch/<slug>/`, and nothing else in `.scratch/`.** Other folders belong to other features.
1. **Delete the local branch by force** once step 3 has passed: a squash merge leaves its commits
   unreachable from the default branch, so a safe delete always refuses.
1. **Delete the remote branch only if it still exists**, then prune remote-tracking references.
1. **Report what was removed.**
