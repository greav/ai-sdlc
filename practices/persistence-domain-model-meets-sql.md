# How the domain model meets SQL

How domain objects get into and out of a SQL database: four approaches, what each costs, where validation
actually fires, and what it takes to switch later. Read it when a project first needs persistence; the
choice it leads to is recorded as an ADR in that project.

## The constraint that shapes everything

**An ORM does not call `__init__` when it loads a row.** It builds the instance through `__new__` and
populates its state directly. This is not a wart: loading is reconstitution, not creation, and running a
constructor would re-generate ids, reset timestamps, and re-run creation rules on every read.

Two consequences drive the whole choice:

- Constructor-time validation does not run on load. A row written by a migration, a fixture, or another
  process comes back into the domain unchecked.
- An immutable (frozen) class cannot be mapped at all: the ORM must attach its own state attribute to the
  instance, and immutability forbids the assignment.

Constructing objects yourself — which is what a non-ORM approach means — sidesteps both.

## The four approaches

### 1. Core / hand-written mapping

Tables declared in the infrastructure layer; rows translated to domain objects by a function the team
writes.

- **Good:** constructor validation actually runs; the domain imports nothing from the ORM; immutability
  stays available; the emitted SQL is what was written; no identity map, session states, or cascade rules
  to explain.
- **Bad:** a translation per entity and per result shape; no change tracking, so updates are explicit; an
  object graph means writing the joins and the assembly; no identity map, so the same row loaded twice is
  two objects.
- **Use when:** the schema is shallow and the domain small enough that hand-written assembly stays under
  control.

### 2. Imperative mapping

The domain class is bound to the table from the infrastructure layer; the domain module itself is
untouched.

- **Good:** the domain still imports nothing from the ORM; object graphs load declaratively; dirty
  tracking writes the `UPDATE` for you; the session provides an identity map.
- **Bad:** entities must be mutable; constructor validation does not run on load; async needs discipline
  so a lazy load cannot fire outside the session; more concepts in play — flush order, expiry, detached
  instances, cascades; mapping modules must be imported for the mapping to register at all.
- **Use when:** an aggregate acquires two or three child collections and hand-assembly starts costing
  more than the mapping would.

### 3. Declarative mapping inside the domain

- **Good:** the least code of any option; columns and attributes cannot drift apart.
- **Bad:** the domain imports the ORM, weakening the boundary at its innermost layer; importing the domain
  now configures mappers, so pure-logic tests depend on the mapping being valid; schema detail reads over
  the business rules; still no immutability and still no validation on load — the cost is paid without
  those returns.
- **Use when:** the domain is thin enough that there is nothing to isolate — mostly data with a few
  methods, no invariant needing protection from the schema. Also defensible for a spike, or where a team
  convention already settles it.
- **What makes it a bet:** all of the above is contingent on the domain staying thin. It is the one choice
  whose reversal rewrites the domain and its tests rather than one adapter.

### 4. Separate persistence models

Domain classes stay pure; the infrastructure layer defines its own models and translates both ways.

- **Good:** total independence — the domain can be immutable and shaped however it likes; the schema can
  be denormalised without touching it.
- **Bad:** two shapes and two translations per entity, kept in sync by hand. The most code of any option,
  and the translation is where drift bugs hide.
- **Use when:** the stored shape genuinely diverges from the domain shape — event sourcing, heavy
  denormalisation, or a schema owned by someone else. Approach 1 already provides purity for less.

## Where invariants live

Which validation actually fires depends on the approach. Verify these against the ORM version in use
rather than trusting them; the shape of the answer is stable, the details are not.

| Mechanism                               | Runs on ORM load?               | Sees other fields?   |
| --------------------------------------- | ------------------------------- | -------------------- |
| Constructor / post-init on the entity   | no                              | yes                  |
| Constructor of a composite value object | **yes** — the ORM calls it      | only its own columns |
| An attribute-assignment validator       | **no** — intercepts writes only | no                   |
| A column type's result-processing hook  | **yes**                         | one column           |
| A load event handler                    | **yes**                         | yes                  |
| `CHECK` / `UNIQUE` / `NOT NULL`         | n/a — refuses the write         | within the row       |
| Constructing the object yourself        | **yes**                         | yes                  |

The pattern behind the table: **anything the ORM builds by calling it will fire; anything relying on the
entity's own constructor will not.**

Guidance:

- **Prefer table constraints.** They stop bad data from being written at all, which is strictly stronger
  than noticing it at read time, and they cost nothing on the read path.
- With a hand-written mapping, constructor validation is enough — it runs on both paths.
- With an ORM mapping, use a load event when read-time validation is genuinely needed, keeping the rule in
  the domain and the wiring in infrastructure.

## Switching later

| From → To                | Trigger                                      | Cost                  |
| ------------------------ | -------------------------------------------- | --------------------- |
| Core → Imperative        | an aggregate grows child collections         | small, per entity     |
| Imperative → Core        | the mapping fights you; queries hard to tune | small to medium       |
| Either → Separate models | stored shape diverges from domain shape      | medium, additive      |
| Declarative → anything   | wanting the domain back                      | **the expensive one** |

Every migration except the last touches infrastructure only. The asymmetry in that last row is the real
argument against starting declarative — it is the only option whose migration cost lands on the domain and
its tests instead of on one adapter, which makes it a one-way door in practice.

Migrations can be partial: a hand-mapped repository and a mapped entity coexist, so one aggregate can move
while the rest stay.

## Recording the decision

The choice belongs to the project, so it is recorded in that project's `docs/adr/`, not here. One paragraph
is enough: the approach taken, and the one or two facts that decided it — usually how deep the schema is
and how much behaviour the domain objects carry. Add what it obliges when that is not obvious: which
validation mechanism is used, whether repositories have a `save()`, what would trigger a switch.

When this guide is copied into the project's `docs/` to make the decision, re-check the invariants table
against the ORM version in use before relying on it, and link the ADR to that copy.
