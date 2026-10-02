# Architecture Decision Records

An ADR records **one decision**, the context that forced it, and the consequences accepted with it. It
answers "why is it this way here?" — the question code cannot answer, because the alternatives that were
rejected leave no trace in it.

The files here are templates. A filled-in ADR belongs to the project that made the decision, in that
project's `docs/adr/`, never in this repository — a decision carries its context with it, and somebody
else's context is not reusable.

## Is this an ADR or a skill?

|                                                  | ADR | Skill                      |
| ------------------------------------------------ | --- | -------------------------- |
| Several valid options existed and one was chosen | yes | no                         |
| Depends on this project's context                | yes | no                         |
| Frozen at a date; changed by writing a successor | yes | no, edited in place        |
| Written for someone asking about the past        | yes | no, for someone acting now |

"We deliver through an outbox rather than calling synchronously" is an ADR. "Nothing about the transport
crosses a port" is not — nobody chose it on a particular day, there is no rejected alternative, and it
holds in the next project too. That belongs in a skill or in `CLAUDE.md`.

A useful pairing: the skill raises the question and lists the options; the ADR records which one this
project took and why.

## Two formats

Most ADRs are short: a title and one paragraph saying what was decided and why. That is the format the
`domain-modeling` skill writes while grilling, and it is the default. Write one only when the decision is
hard to reverse, surprising without context, and the result of a real trade-off — all three.

`0000-template.md` is the full form, with context, options, decision and consequences as sections. Reach
for it when the options were close enough that the reasons for rejecting each need to be on record.

Both follow the conventions below.

## Conventions

- **Number in the filename**, zero-padded, in the order decisions were taken:
  `0001-persistence-approach.md`, `0002-outbox-for-delivery.md`. Sorting by name gives the history.
  `0000-template.md` is the blank form and is not a decision.
- **One decision per record.** If the title needs "and", it is two ADRs.
- **Title in the imperative or as a noun phrase**, naming the decision rather than the area:
  `0004-retry-with-exponential-backoff.md`, not `0004-retries.md`.
- **Do not edit an accepted ADR.** The only permitted change is setting `Status: superseded by ADR-0011`.
  Changing your mind means writing a new record that references the old one. Once records get amended in
  place, the history stops being a history.
- **Record the rejected options when the rejection is not obvious.** That part saves the next person from
  re-arguing a settled question, and it is the only part that cannot be recovered by reading the code.
- **Write it when the decision is made**, not afterwards. An ADR reconstructed six months later records
  the justification, not the reasoning — and those differ in exactly the places that matter.

## Status values

- `proposed` — written, not yet agreed.
- `accepted` — in force. From here the file is immutable except for its status line.
- `superseded by ADR-NNNN` — replaced. The record stays; the successor explains what changed.
- `deprecated` — no longer applies and nothing replaced it.

## Using a template

Copy it into the project's `docs/adr/`, give it the next number, fill in the bracketed sections, and
delete the guidance. The reference material needed to *make* a decision lives in `practices/`, not in the
record: link to the project's copy of it, so the record stays a record rather than becoming a textbook.
