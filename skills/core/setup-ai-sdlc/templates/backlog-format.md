## Backlog

Work found along the way that no feature's plan covers — an idea, a bug, a task — waits in
`.scratch/backlog/` until the user takes it on: one file per item, plus the index
`.scratch/backlog/BACKLOG.md`. `.scratch/` is ignored by git, so the backlog lives only on this machine.

An item is `.scratch/backlog/<slug>.md`, with no number: it gets numbers only when a feature's tickets are
cut from it. Write it so a session that never saw the work it came from can act on it:

```markdown
# <What is wrong, or what should become possible, in the glossary's terms>

**What:** what happens now, what should happen, and the evidence: where it shows, how to reproduce it.

**From:** the feature, review or conversation it came from, and the date.

**Blocked by:** what must happen first, or None.

- [ ] Acceptance criterion
```

The user's own idea, not yet thought through, needs only the title, **What:** — what they want and why,
in their words — and **From:** `idea, <date>`. Leave out **Blocked by:** and the criteria rather than
guess them: the interview that takes the idea on settles them.

The index lists every item, in the user's order of priority: the top row is the next to take on. The first
item added creates it:

```markdown
# Backlog

| Item                 | From   | What                     | Taken by |
| -------------------- | ------ | ------------------------ | -------- |
| [<slug>](<slug>.md)  | <from> | <one line: what it is>   | —        |
```

### How to keep the backlog

- Add, take on or remove an item and its row in the same step: no file without a row, no row without a
  file. A new row goes at the bottom unless the user places it.
- Detail lives in the item's file; the row holds only the link, where it came from and one line.
- An item taken on stays where it is: its row's `Taken by` gets the slug of the work, `<type>/<slug>`
  without the type. `/cleanup` asks about it after that work is merged; an item finished is deleted, one
  not finished goes back to `—`.
- An item the user drops is deleted with its row.
- A new finding about an item goes under a `## Comments` heading at the bottom of its file, dated.
