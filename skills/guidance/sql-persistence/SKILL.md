---
name: sql-persistence
description: >-
  Rules for writing or reviewing data access against a SQL database — repositories, readers, gateways,
  transaction boundaries, and queries. Use whenever code reads or writes rows: a new repository or reader,
  a change to one, a unit-of-work or session/connection question, a query holding business meaning, or a
  review of any of those. Applies even when the request never says "database" — an interactor gaining a
  port that persists something is enough.
---

# Data access against SQL

Port shapes and naming are in the project's instructions — follow them; this skill is the rules that
apply once a port is backed by a database. See `reference.md` for why each holds.

## Transactions

1. **The commit belongs to the interactor, never to a repository.** A repository emits its statements when
   told to; making them durable is a property of the whole operation. A `save()` that committed puts two
   ports' writes in two transactions, and no caller can ask for them to land together.
1. **A repository may `flush()`, to obtain a generated id — it must not `commit()`.** Flush sends SQL;
   commit ends the operation. Only the second is the interactor's to call.
1. **One connection or session per operation, shared by every write-side port in it.** Nothing in the type
   system enforces this — a port built on another connection writes outside the transaction and the
   operation half-commits with nothing raised. Construct adapters per operation from a DI scope or a
   middleware, never once at startup.
1. **Never hold a transaction open across a network call.** It ties row locks to somebody else's latency.
   Commit first, then call out; if the two must appear atomic, record the intent locally and deliver it
   afterwards.
1. **Read ports take no part in the transaction.** A reader on its own connection will not see the
   operation's uncommitted writes — read before you write, or read back through the repository.

## Writes

6. **One table has one write path.** If an aggregate has a repository, nothing else writes its rows.
   Table-shaped operations like `update_interval(card_id, 10)` walk past the rule that decides what the
   interval should be.
1. **Set-based writes are the exception**, when doing it per-aggregate would be absurd. Three conditions:
   name it for the operation and not the column (`expire_overdue(user_id, now)`); put it on the
   operation's connection; and pin it with a test asserting the bulk form and the per-object rule agree on
   the same data.
1. **Without change tracking, load once per operation.** The same row loaded twice is two objects, and if
   both are saved the second write wins. Pass the object around instead of re-fetching.

## Queries

9. **Keep domain predicates out of `WHERE`.** Mechanical aggregation — `COUNT`, `GROUP BY`, pagination,
   ordering — belongs in SQL. What counts as *due*, *mature*, or *accepted* is a rule that then exists
   twice and will drift; the symptom is a counter disagreeing with the list it counts. If duplication is
   unavoidable, make it deliberate and pin both formulations with one test.
1. **A gateway is right for rows with no domain object behind them** — telemetry, an outbox, an
   idempotency key. Before accepting that, check three things: is there a rule about which values are
   valid; would a wrong value be a bug in business terms; does anything read it back and decide on it. A
   yes to any means there is a domain object waiting to be recognised.

## Schema

11. **Put invariants in the table.** `CHECK`, `UNIQUE`, `NOT NULL` hold on every write path, including
    migrations and other processes — strictly stronger than validating on read.
01. **`ON DELETE CASCADE` belongs in the foreign key**, not in ORM cascade rules, so it holds regardless
    of what deleted the row.
01. **Constructor validation does not run when an ORM loads a row.** If the code relies on it, either
    construct the objects yourself or wire a load-time hook — do not assume it fires.

## Mixing an ORM with raw statements

14. **One transaction owner per operation.** If any aggregate is mapped, the session owns the transaction
    and raw statements execute through it. Opening a separate connection alongside a live session gives
    two transactions that cannot commit together and can block each other.
01. **A raw statement against a mapped table leaves loaded objects stale** — it does not update the
    identity map. Use the ORM-enabled form so the session synchronises, or expire the affected objects.
    Tables with no mapped entity have nothing to go stale.
