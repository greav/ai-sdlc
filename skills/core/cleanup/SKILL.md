---
name: cleanup
description: >-
  Remove what a merged piece of work left behind: switch to the default branch, update it, delete the
  feature branch and its `.scratch/<slug>/` folder if it has one. Refuses while the PR is open, closed
  unmerged, or missing. Run after the merge of a PR opened by `/ship`.
disable-model-invocation: true
---

# Clean up after a merge

`.scratch/` is ignored by git, so deleting it cannot be undone, and a branch deleted by force is gone with
any commit that was only on it. Every step below exists to make sure nothing is lost.

"PR" here means whatever the project's hosting service calls a request to merge a branch: a pull request
on GitHub, a merge request on GitLab. Use the command-line tool for the service the remote points at.

## Find the feature

1. **The slug comes from the branch** `<type>/<slug>`. If the default branch is checked out, list the local
   feature branches and the folders in `.scratch/`, and ask which one; never pick one yourself.
1. **See whether the work has a folder.** `.scratch/<slug>/` exists for work done with a plan and is absent
   for work done without one. Both are fine; only the branch is always there.

## Prove the work is in the default branch

3. **The PR for the branch is merged.** Look it up on the hosting service by its head branch. Open, closed
   without merging, no PR at all, or no way to ask the service: stop and report. Work abandoned on purpose
   is the user's to clean up by hand.
1. **The local branch holds nothing the PR did not.** Its tip must equal the PR's head commit. If the local
   branch has commits beyond it, stop: they were never merged.
1. **The working tree is clean.** Stop and show any uncommitted change.

## Delete, with confirmation

6. **See whether anything else still reads the folder.** Search the rest of `.scratch/` for the path
   `.scratch/<slug>/`: a handoff or another feature's plan may point at this spec or plan instead of
   repeating it. Name every file that does, and say that its pointers will break.
1. **Show exactly what will be removed** — the local branch, the remote branch if it still exists, and the
   `.scratch/<slug>/` folder with its files if there is one — and wait for the user to confirm.
1. **Switch to the default branch and update it** with a fast-forward-only pull.
1. **Delete `.scratch/<slug>/` if it exists, and nothing else in `.scratch/`.** Other folders belong to
   other features.
1. **Delete the local branch by force** once step 4 has passed: a squash merge leaves its commits
   unreachable from the default branch, so a safe delete always refuses.
1. **Delete the remote branch only if it still exists**, then prune remote-tracking references.
1. **Report what was removed.**
