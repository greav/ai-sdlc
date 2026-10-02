# <project>

<One or two sentences: what this is and who uses it.>

## Architecture principles

- **Dependency inversion.** The application layer defines protocols; the infrastructure layer implements
  them. Implementations adapt to the interface, never the reverse.
- **Business-first interfaces.** A contract is shaped by what the use case needs, not by a provider or a
  transport. Never leak HTTP, SQL, or SDK specifics into one.
- **Structure by capability, not by type.** A use case is a folder grouping the operations of one
  capability; each operation is a module. No cross-cutting `interactors/`, `dtos/`, or `ports/` folders.

## Layer map

- `<pkg>/application/` — use cases, interactors, DTOs, and the protocols infrastructure must satisfy.
  Must not import from `infra/` or `presentation/`.
- `<pkg>/infra/` — adapters implementing those protocols: API clients, database access, logging.
- `<pkg>/presentation/` — the user-facing layer.
- `<pkg>/bootstrap/` — composition and dependency injection.

A separate `domain/` package is optional. Introduce one when rules outgrow the interactors; until then
keep plain data models under `application/`. The port rules below hold either way.

## Ports

When an operation needs infrastructure — persistence, cache, storage, auth, a remote API — it depends on a
**port**: a `Protocol` named by role, free of transport specifics, declared in `application/` before any
implementation exists.

Three shapes cover data access. Pick by what comes back and whether the caller may write through it.

| Port          | Returns                        | Writes | Use when                                    |
| ------------- | ------------------------------ | ------ | ------------------------------------------- |
| `*Repository` | domain objects                 | yes    | a rule is consulted through what comes back |
| `*Reader`     | read models                    | never  | the result is for display or export         |
| `*Gateway`    | rows or payloads with no rules | yes    | data in transit, or the call is an action   |

Rules that follow from the table:

- **Domain objects come from a repository.** A port handing back an entity is not a gateway, whatever it
  is called.
- **The mechanical test:** if a method returns something the caller cannot hand back to `add()`, it does
  not belong on the repository.
- **A repository has collection semantics** — `get`, `add`, `remove`. A "repository" that grew pagination
  parameters is a reader wearing the wrong name.
- **Group readers by the projection they serve**, not by the entity they mention: `DeckOverviewReader`,
  not `CardReader`. An entity-shaped name is an invitation to become a bag of unrelated SQL.
- **Nothing about the transport crosses a port** — no client types, no wire-format messages, no status
  codes, no SQL constructs. The interactor branches on business meaning; only the adapter knows how the
  news arrived.

## Naming

- **Ports** by role, no technology: `CardRepository`, `FlashcardGenerator`, `PaymentGateway`. No `I`,
  `Base`, or `Abstract` affixes.
- **Adapters** as `<ProviderOrTechnology><PortName>`: `SqlAlchemyCardRepository`, `StripePaymentGateway`,
  `FakePaymentGateway`. The name makes the concrete technology obvious.
- **Use-case folders** by the actor's goal (`manage_cards/`, `user_registration/`); **operation modules**
  by verb and entity (`create_card.py`), with the interactor class matching (`CreateCard`).
- Never let a folder and a module stutter: `issue_invite/issue_invite.py` is wrong.

## Errors

Raise exceptions declared in the application layer, named for what went wrong in business terms. Adapters
translate transport failures into them. An interactor should never catch a library exception.

## Guidance skills

Invoke the matching skill before writing or changing such code. The reviewer checks the same rules through
`CODING_STANDARDS.md`.

- Code that reads or writes the database → `sql-persistence`
- Code that calls a remote API → `http-integration`

\<Drop the lines for skills this project does not use.>

## Configuration

\<Project-specific: where configuration lives, how it reaches each class.>

## Testing

\<Project-specific: what runs, what is required before a change is considered done.>
