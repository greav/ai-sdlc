# Why cleanup works this way

Background for `SKILL.md`. It runs after `/ship` has opened a PR and the user has merged it.

## Why a skill for two commands

The deletion itself is `rm -rf` and `git branch -D`. The skill exists for the checks in front of them.
`.scratch/` is ignored by git, so it is in no commit, no stash and no reflog: once deleted, the spec, the
plan and the tickets are gone. A step that destroys unrecoverable data on every feature deserves a fixed
procedure with a refusal built in, not a command typed from memory.

## Why only after the merge

Until the PR is merged, the plan is still live. Review on the PR can ask for a change, and the follow-up
session that makes it starts from `.scratch/<slug>/PLAN.md`. Deleting at PR time — what the original post
this flow grew from did — leaves that session nothing to start from.

A PR closed without merging is the ambiguous case: the feature may be abandoned, or about to be reopened
from a new branch. The skill cannot tell which, so it refuses and leaves the call to the user.

## Why `git branch -d` is not enough, and what replaces it

`git branch -d` deletes only a branch whose commits are reachable from the current branch. A squash merge
writes one new commit on the default branch; the branch's own commits never become reachable, so `-d`
refuses every time and `-D` is the only way. `-D` checks nothing, so the check has to be done first.

The check is that the local branch tip is the PR's head commit. If it is, every local commit went into the
PR and so into the squash. If the local branch is ahead — a commit made after the PR was opened and never
pushed — deleting it would lose that commit along with the branch.

## Why only `.scratch/<slug>/`

Several features can be in flight at once, each in its own folder. Cleaning up "the scratch directory"
would take the others with it.

## Why the remote branch is conditional

GitHub can delete a head branch automatically when its PR merges. Whether it does is a repository
setting, so the skill checks rather than assumes, and prunes the remote-tracking reference either way so
the deleted branch does not linger in `git branch -a`.
