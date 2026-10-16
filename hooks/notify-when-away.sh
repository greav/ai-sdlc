#!/bin/bash
# Notifier for Claude Code hooks (Stop, PreToolUse:AskUserQuestion, Notification:permission_prompt).
# Nags only when you are not looking at the session that needs you.
#
# - another app is frontmost, or the same app shows another project -> sound + notification right away
# - you are looking at this project -> wait DELAY seconds; notify only if you have looked away by then
#
# The notification says which project it is and what is wanted: finished, a question, or a permission.
#
# Settings (environment):
#   CLAUDE_NOTIFY_APP    process name of the app Claude runs in; guessed from TERM_PROGRAM when unset
#   CLAUDE_NOTIFY_DELAY  seconds to wait when you are looking at the session (default 30)
#   CLAUDE_NOTIFY_DRY    set to 1 to print what would be shown instead of notifying

DELAY="${CLAUDE_NOTIFY_DELAY:-30}"
SOUND=/System/Library/Sounds/Morse.aiff

# --- what happened: the hook's JSON arrives on stdin -------------------------------------------------
input=""
[ -t 0 ] || input=$(cat)
field() { [ -n "$input" ] && printf '%s' "$input" | jq -r "$1 // empty" 2>/dev/null; }

event=$(field '.hook_event_name')
dir="${CLAUDE_PROJECT_DIR:-$(field '.cwd')}"
folder=$(basename "${dir:-$PWD}")

case "$event" in
    PreToolUse)
        what="Has a question for you"
        detail=$(field '.tool_input.questions[0].question')
        ;;
    Notification)
        what="Needs your permission"
        detail=$(field '.message')
        ;;
    *)
        what="Finished, waiting for you"
        detail=""
        ;;
esac
detail=$(printf '%s' "$detail" | tr '\n' ' ' | cut -c1-140)

# --- which app Claude runs in ------------------------------------------------------------------------
case "${CLAUDE_NOTIFY_APP:-$TERM_PROGRAM}" in
    vscode)         app="Code" ;;
    Apple_Terminal) app="Terminal" ;;
    iTerm.app)      app="iTerm2" ;;
    "")             app="Code" ;;
    *)              app="${CLAUDE_NOTIFY_APP:-$TERM_PROGRAM}" ;;
esac

frontmost() {
    osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null
}

# The terminal device of the claude process that started this hook, e.g. /dev/ttys014.
session_tty() {
    local pid=$PPID tty
    for _ in 1 2 3 4 5; do
        tty=$(ps -o tty= -p "$pid" 2>/dev/null | tr -d ' ')
        [ -n "$tty" ] && [ "$tty" != "??" ] && { echo "/dev/$tty"; return; }
        pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
        [ -z "$pid" ] || [ "$pid" -le 1 ] && return
    done
}

# Is the frontmost window of the app this project's window?
# Answers "yes", "no", or "unknown" when macOS does not let us look.
this_window() {
    local title tty
    if [ "$app" = "Terminal" ]; then
        tty=$(osascript -e 'tell application "Terminal" to get tty of selected tab of front window' 2>/dev/null)
        [ -z "$tty" ] && { echo unknown; return; }
        [ "$tty" = "$(session_tty)" ] && echo yes || echo no
        return
    fi
    # Other apps: the window title normally carries the folder name. Reading it needs the
    # Accessibility permission for the app Claude runs in; without it we cannot tell.
    title=$(osascript -e "tell application \"System Events\" to get name of front window of process \"$app\"" 2>/dev/null)
    [ -z "$title" ] && { echo unknown; return; }
    case "$title" in *"$folder"*) echo yes ;; *) echo no ;; esac
}

# Are you looking away from this session?
away() {
    [ "$(frontmost)" != "$app" ] && return 0
    [ "$(this_window)" = "no" ] && return 0
    return 1
}

notify() {
    if [ -n "$CLAUDE_NOTIFY_DRY" ]; then
        echo "notify: [Claude Code · $folder] $what${detail:+ — $detail}" >&2
        return
    fi
    afplay "$SOUND" >/dev/null 2>&1 &
    osascript -e 'on run {t, s, m}' -e 'display notification m with title t subtitle s' -e 'end run' \
        "Claude Code · $folder" "$what" "$detail" >/dev/null 2>&1
}

if away; then
    notify
else
    (
        sleep "$DELAY"
        away && notify
    ) >/dev/null 2>&1 &
fi

exit 0
