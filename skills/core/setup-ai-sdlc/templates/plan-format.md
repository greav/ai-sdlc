## Feature plan

Alongside its tickets, every feature folder holds `.scratch/<feature-slug>/PLAN.md`: the one place that says
which tickets are done. Each build session starts from it, and `/ship` reads it to decide whether the
feature is finished.

`/to-tickets` writes it once the ticket files exist, exactly in this shape — the rules at the end are part
of the file, so a session that opens it knows how to keep it:

```markdown
# <Feature title>

Branch: `<type>/<feature-slug>` · Spec: [spec.md](spec.md)

| #  | Ticket                         | Blocked by | Status |
| -- | ------------------------------ | ---------- | ------ |
| 01 | [<title>](issues/01-<slug>.md) | —          | todo   |
| 02 | [<title>](issues/02-<slug>.md) | 01         | todo   |

## Notes

## How to keep this plan

- Status is `todo`, `in-progress` or `done`. Set `in-progress` when you start a ticket and `done` once its
  commit lands; tick the ticket's acceptance criteria in its own file.
- The next ticket is the first `todo` whose blockers are all `done` or wait only for the user's checks.
- A ticket with a check only the user can do, such as granting a permission or trying a real device, stays
  `in-progress` after its commit lands, until the user has done the check. A check the user drops is
  removed from the ticket and noted here with what it leaves unverified.
- Notes hold what a later session must know and the code does not show: a deviation from the spec, a seam
  that moved, a change made after the review. Not a log of what happened.
- A question waiting for the user's decision goes into the Notes, marked `Open:`, and stays there until it
  is answered. A question left only in the chat is lost with the session.
- Ticket files keep the `Status:` line `/to-tickets` wrote; progress is tracked here only.
```
