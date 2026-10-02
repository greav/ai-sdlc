# Coding standards

Read by the reviewer, not loaded into every session: the Standards axis of `/code-review` looks for this
file and checks the diff against everything it points to. The rules themselves live in one place each;
this file only says where.

## Where the rules are

- Architecture, layers, ports, naming, errors: `CLAUDE.md`
- Code that reads or writes the database: `.claude/skills/sql-persistence/SKILL.md`
- Code that calls a remote API: `.claude/skills/http-integration/SKILL.md`

\<Adjust the skill paths if the skills reach this project through a plugin rather than being copied into
`.claude/skills/`. Drop the lines for skills this project does not use.>

## Project-specific rules

\<Judgement calls the reviewer should enforce in this project and nowhere else. A rule that a linter, a
type check or a test could enforce belongs there instead.>
