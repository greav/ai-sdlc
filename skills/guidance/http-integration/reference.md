# Why these rules hold

Background for `SKILL.md`. Nothing here has to be read to follow the rules; it is here for when one of
them looks wrong, or when a situation falls outside them.

Pattern names and quotations are from Fowler, *Patterns of Enterprise Application Architecture*.

## Gateway is not a database pattern

Fowler defines it without mentioning databases: "an object that encapsulates access to an external system
or resource", reached for "whenever you have an awkward interface to something that feels external". The
examples given are relational tables, transaction monitors, and XML — a database is one case among
several, and a remote API is the central one.

What separates a Gateway from a Facade is authorship. "While Facade simplifies a more complex API, it's
usually done by the writer of the service for general use. A Gateway is written by the client for its
particular use." That is rule 2: a gateway that mirrors the vendor's API faithfully has become a client
library, and the awkwardness it was supposed to contain is now spread across every caller.

"Keep a Gateway as simple as you can… Any more complex logic should be in the Gateway's clients" is rule
3\. And the two-object variant is Fowler's own: "a back end acts as a minimal overlay to the external
resource and doesn't simplify the resource's API at all. The front end then transforms the awkward API
into a more convenient one." He is explicit that this pays off only when both jobs are individually
complicated — otherwise one class handles both.

The other reason to keep the boundary crisp: a gateway "makes a system easier to test by giving you a
clear point at which to deploy Service Stubs". Fowler considers this reason enough on its own, "even if
the external system's interface is fine". For a network dependency it is decisive — it is what lets every
use case be exercised without a network.

## A repository over a remote source

The catalogue permits it explicitly: "the object source for the Repository may not be a relational
database at all, which is fine as Repository lends itself quite readily to the replacement of the
data-mapping component via specialized strategy objects." The worked example is a feed over the internet,
served by a strategy that "reads from the feed and creates domain objects from the XML".

So rule 1 is not a restriction inherited from databases. The condition is the one that always applies to a
repository — it hands back domain objects, things a rule is consulted through — and it is worth checking
honestly, because over HTTP most payloads are data in transit and calling their port a repository claims a
collection nobody can point at.

One thing comes free: because the adapter constructs the domain object itself rather than an ORM
populating it, the constructor runs and whatever validation lives in it actually fires. That is the
opposite of the database case, and it is why rule 13 puts validation at the boundary.

## Why the transaction has no counterpart

"Unit of Work works with any **transactional** resource, not just databases, so you can also use it to
coordinate with message queues and transaction monitors."

The load-bearing word is *transactional*. An HTTP endpoint is not: there is no protocol for "prepare",
nothing to hold open across two calls, and no way to undo the first when the second fails. So the pattern
does not transfer, and neither does anything built on it — no boundary object, no commit, no
all-or-nothing across two calls.

What replaces each guarantee is weaker on purpose:

| Guarantee      | Replacement                                                              |
| -------------- | ------------------------------------------------------------------------ |
| Atomicity      | idempotency — a request key, so a retry cannot double-apply              |
| Rollback       | a compensating call, where the API offers the inverse operation          |
| All-or-nothing | an outbox: record the intent locally, deliver it afterwards with retries |

Rule 5 is first among these because the failure it prevents is silent. A timeout gives no information
about whether the work happened, retrying is the only sensible response, and against a non-idempotent
endpoint that response creates a duplicate nobody notices until a user does.

## The outbox, and what it costs

```
interactor
  ├── write intent   ──▶ own database, inside the transaction
  └── after commit   ──▶ remote gateway, with retries
```

The local half keeps every transactional guarantee. The remote call happens after that commit because an
open transaction holds locks and a remote host decides how long — a slow third party otherwise becomes
lock contention, then pool exhaustion, then an incident filed against the wrong system.

The cost is that intent and delivery are no longer simultaneous: the local record exists before the remote
system knows about it. That is the trade made on purpose, and it is the reason delivery must be retried
and idempotent rather than assumed.

## Why the transport must not cross the port

A status code is a fact about a protocol, not about the business. An interactor branching on `403` has
absorbed a decision that belongs to the adapter, and it will keep working right up until the vendor
returns `401` for the same condition — at which point the bug is in a layer that never should have known.

The same argument covers client exception types and wire-format messages. The port's exception vocabulary
should read like a list of things that can go wrong with the *work*, not with the *call*.

This is also what makes stubbing honest. A stub can produce "the session expired" without pretending to be
an HTTP server; if the port speaks in status codes, the stub has to fake a transport it does not have.

## Why chattiness outranks everything else

Against a database an extra query costs milliseconds and is invisible until profiling. Against a remote
API it is a round trip — tens to hundreds of milliseconds, sometimes with rate-limit headroom consumed —
and the loop that causes it looks like ordinary code. Ten items become ten calls; a hundred become an
operation that visibly hangs.

There is no clever fix, which is why the rule is about noticing rather than solving: batch where the API
offers it, fetch once and pass the value around where it does not, and treat a per-item call inside a loop
as something that has to be justified rather than explained afterwards.
