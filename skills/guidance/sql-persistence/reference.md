# Why these rules hold

Background for `SKILL.md`. Nothing here has to be read to follow the rules; it is here for when one of
them looks wrong, or when a situation falls outside them.

Pattern names and quotations are from Fowler, *Patterns of Enterprise Application Architecture*.

## The three ports, and where they come from

**Repository** "mediates between the domain and data mapping layers using a collection-like interface for
accessing domain objects". Two things in that sentence do the work: *collection-like*, and *domain
objects*. Neither says anything about who emits the SQL — in the catalogue the repository registers the
change and the mapping layer carries it out. That is why "which layer emits the `UPDATE`" is an
implementation detail and not what decides whether a port is a repository.

**Table Data Gateway** "holds all the SQL for accessing a single table or view: selects, inserts, updates,
and deletes". It deals in record sets and DTOs — Fowler ranks a Data Transfer Object above a map, which
"defeats compile time checking", and above a raw record set. He allows a gateway to return domain objects
but avoids it, because it creates a bidirectional dependency between the gateway and the domain.

A read-only reader is a Table Data Gateway with half its methods unwritten. Adding writes to one does not
break the pattern — it completes it. What matters is *what* it writes: rows with no domain object behind
them are the safe case; rows backing an aggregate that already has a repository are rule 6.

Note the organisational condition: a gateway covers *one table, view, or projection*. A port accumulating
every query anyone needed against one entity is no longer the pattern, only a bag of SQL with a name.
Fowler pairs the pattern with database views precisely because a view is projection-shaped — and observes
that view-based gateways "often can't update and so won't have update behavior", which is why a reader
over a join usually has nothing to write.

## Why the commit is not the repository's

Unit of Work "maintains a list of objects affected by a business transaction and coordinates the writing
out of changes and the resolution of concurrency problems". At commit it "opens a transaction, does any
concurrency checking, and writes changes out"; application programmers "never explicitly call methods for
database updates".

The boundary is therefore a property of the business transaction, not of any one port. A repository knows
about its own type of object and nothing about what else the operation touched — it is structurally the
wrong place to decide that the work is finished.

This also explains rule 2. Flush and commit are different events: flush sends the statements, commit ends
the transaction. A repository needing a generated id needs the first, never the second.

## Why one connection per operation, and why a factory or scope

"Objects need to be able to find their current Unit of Work. A good way to do this is with a thread-scoped
Registry. Another way is to pass the Unit of Work to objects that need it, either in method calls or when
you create an object. In either case make sure that more than one thread can't get access to a Unit of
Work — there lies the way to madness."

Two things follow. Constructor injection into the ports is one of the two mechanisms named, so it is not
an invention. And the thread-safety warning is the reason adapters cannot be startup singletons: in an
async service "thread" reads as "operation", and two concurrent requests sharing one connection is exactly
the madness meant.

Fowler assumes ambient scoping — a thread-local registry — which older platforms gave for free. Without
one, the scope has to be arranged explicitly, which is why rule 3 names a DI scope or a middleware.

**The alternative shape, and why not.** A widely used variant makes the unit of work carry the ports, so
the interactor reaches them through it. Its attraction is real: sharing one connection becomes a property
of the types rather than of the wiring. It is avoided here for two reasons. It inverts the catalogue's
dependency — a unit of work holds *objects* and writes them through mappers, and a unit of work owning the
ports is not a shape the catalogue considers. And it becomes a central registry every new port must be
added to and every interactor depends on wholesale. The type guarantee is worth having; it is worth buying
with a scope and a rollback test rather than an inverted dependency in the application layer.

## Why the transaction must not span a network call

Nothing subtle: an open transaction holds locks, and a remote host decides how long. A slow third party
becomes lock contention, then a connection-pool exhaustion, then an incident with the wrong name on it.
Recording the intent locally and delivering it afterwards trades simultaneity for that — the record exists
before the remote system knows about it, which is why delivery then has to be retried and idempotent.

## Why constructor validation does not survive an ORM load

The ORM builds the instance through `__new__` and populates its state directly, bypassing the constructor.
This is required behaviour, not an oversight: loading is reconstitution, and running creation logic on
every read would regenerate ids and reset timestamps.

The consequence is that validation attached to construction protects only the path where the application
creates the object. Rows arriving from a migration, a fixture, or another process are unchecked. That is
the argument behind rule 11 — a constraint in the table holds on every path, and costs nothing on reads.

The general form: **anything the ORM builds by calling it will run; anything relying on the entity's own
constructor will not.** Composite value objects and column-type conversion hooks are constructed by the
ORM and therefore fire; assignment validators do not, because loading populates state directly rather
than through attribute assignment.

## Why a raw statement leaves objects stale

An ORM statement targeting a mapped entity can synchronise the session's identity map. A statement
targeting a bare table cannot: the ORM has no way to know which loaded objects the rows correspond to. The
in-memory object then reports the pre-update value, and any decision taken from it is taken on stale data.

This is not a reason to avoid mixing — a project that maps some aggregates and still runs plain queries
elsewhere is normal, and executing them through the session keeps one transaction. It is a reason to pick
the ORM-enabled form whenever the table has a mapped entity behind it.
