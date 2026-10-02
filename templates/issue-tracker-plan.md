## Feature plan

Alongside its tickets, every feature folder holds `.scratch/<feature-slug>/PLAN.md`: the one place that says
which tickets are done. Each build session starts from it, and `/ship` reads it to decide whether the
feature is finished.

`/to-tickets` writes it once the ticket files exist:

```markdown
# <Feature title>

Branch: `feat/<feature-slug>` · Spec: [spec.md](spec.md)

| #  | Ticket                         | Blocked by | Status |
| -- | ------------------------------ | ---------- | ------ |
| 01 | [<title>](issues/01-<slug>.md) | —          | todo   |
| 02 | [<title>](issues/02-<slug>.md) | 01         | todo   |

## Notes
```

- **Status** is `todo`, `in-progress` or `done`. The session implementing a ticket sets `in-progress` when
  it starts and `done` once its commit lands, and ticks the ticket's acceptance criteria in its file.
- **The next ticket** is the first `todo` whose blockers are all `done`.
- **Notes** hold what a later ticket's session must know and the code does not show: a deviation from the
  spec, a seam that moved. Not a log of what happened.
- Ticket files keep the `Status:` line `/to-tickets` wrote; progress is tracked here only.
