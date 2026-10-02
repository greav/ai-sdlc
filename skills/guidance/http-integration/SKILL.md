---
name: http-integration
description: >-
  Rules for writing or reviewing a port whose adapter calls a remote API over the network — gateways, API
  clients, retries, idempotency, and failure handling. Use whenever code crosses a network boundary: a new
  adapter for an external service, a change to one, a question about retries, timeouts, or partial
  failure, or a review of any of those. Applies even when the request never says "HTTP" — an interactor
  gaining a port backed by someone else's service is enough.
---

# Data access against a remote API

Port shapes and naming are in CLAUDE.md — follow them; this skill is the rules that apply once a port is
backed by a network call. See `reference.md` for why each holds.

## Choosing the port

1. **Gateway is the default.** Most remote calls are actions — log in, submit, trigger — or data no rule
   is consulted through. A repository claims something stronger: that the caller holds a collection of
   domain objects. A remote source is legitimate for a repository, but only under that condition.
1. **Write the gateway for this application, not for the API.** It exposes the operations this codebase
   needs, in this codebase's vocabulary. It is not a faithful client library.
1. **Keep it thin.** Translation only. Rules belong in the domain, orchestration in the interactor. Split
   the gateway in two — a wire-level back end and a domain-shaped front end — when one class is visibly
   doing both jobs badly, and not in advance.

## There is no transaction

4. **Nothing can be rolled back.** A `POST` that succeeded stays succeeded. Do not design as though two
   calls can be made atomic; there is no boundary object to commit.
1. **Design idempotency in before the first write call.** A retry against a non-idempotent endpoint is a
   duplicate record, not an error. Use the API's request key or conditional header; if it offers none,
   keep a local record of what was sent and check it before sending. Retrofitting this means reconciling
   whatever the duplicates already did.
1. **A compensating call is not a rollback.** It is an ordinary call that can itself fail. Write one only
   where the API genuinely offers the inverse operation, and treat its failure as something to report
   rather than swallow.
1. **If the application also owns a database, commit locally first, then call out.** Never hold a database
   transaction open across the network. Where the two must appear atomic, record the intent inside the
   transaction and deliver it afterwards with retries.

## Failures are part of the contract

8. **Name these in the application layer and raise them from the adapter:** timeout (the dangerous one —
   the work may or may not have happened), partial success, rate limiting, auth expiry, transport error.
1. **Nothing about the transport crosses the port.** No client types, no wire-format messages, no status
   codes. The interactor branches on "the session expired"; only the adapter knows a 403 carried the news,
   so the day it becomes a 401 only the adapter changes.
1. **Rate limiting is expected, not exceptional.** Back off; do not fail the operation on the first
   refusal.
1. **Retry policy is configuration, not constants.** Attempt counts and backoff delays live in the
   adapter's config object so a test can set the delay to zero and exercise the retry branches without
   sleeping. Deciding this when the retry is written costs nothing; retrofitting means slow tests or a
   refactor.

## Cost and trust

12. **Round trips are the performance model.** A loop making one call per item is not a slow query, it is
    a slow operation. Prefer batch endpoints; otherwise fetch once and pass the result around. The code
    that causes this looks unremarkable, so watch for it at review time.
01. **Parse, do not trust.** Turn the payload into a declared type at the adapter boundary and let
    construction refuse what is invalid. Never pass a raw response dictionary inward — it is untyped and
    silently tolerant of a renamed field.
01. **A parse failure is a bug report.** Say which field disappointed which expectation; the person
    reading it is debugging someone else's deployment with no access to it.
