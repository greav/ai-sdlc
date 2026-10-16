#!/bin/bash
# Installs the hooks from this folder into ~/.claude/hooks/, where the settings point.
# A hook is copied only if it parses: a syntax error in a hook can block the session it runs in.

set -u
src="$(cd "$(dirname "$0")" && pwd)"
dest="$HOME/.claude/hooks"
mkdir -p "$dest"

status=0
for hook in "$src"/*.sh; do
    name="$(basename "$hook")"
    [ "$name" = "install.sh" ] && continue
    if ! bash -n "$hook"; then
        echo "skipped  $name (syntax error, the installed copy is unchanged)" >&2
        status=1
        continue
    fi
    if cmp -s "$hook" "$dest/$name"; then
        echo "current  $name"
    else
        cp "$hook" "$dest/$name" && chmod +x "$dest/$name" && echo "updated  $name"
    fi
done
exit $status
