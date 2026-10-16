# <project>

<One or two sentences: what this is and who uses it.>

## Structure

\<Project-specific: the layers or modules, what may depend on what, how things are named.>

## Branches

Name a branch `<type>/<slug>`: type is `feat`, `fix`, `refactor`, `docs`, `test` or `chore`; the slug is a
few lowercase words joined by hyphens, in the glossary's terms. When the work has a folder in `.scratch/`,
the slug is that folder's name. A single ticket may be built on a short-lived branch of its own, which is
merged into the feature's branch and then deleted. Never commit feature work to the default branch.

## Guidance skills

Invoke the matching skill before writing or changing such code. The reviewer checks the same rules through
`CODING_STANDARDS.md`.

- Code that reads or writes the database → `sql-persistence`
- Code that calls a remote API → `http-integration`

## Configuration

\<Project-specific: where configuration lives, how it reaches each class.>

## Testing

\<Project-specific: what runs, what is required before a change is considered done.>
