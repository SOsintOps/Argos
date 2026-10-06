#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Ramingo (SOsintOps)
#
# Argos shared launcher library. Launchers source this file; it is not meant
# to be executed on its own. See docs/ARCHITECTURE.md for the design.

ARGOS_VERSION="3.0.0-beta"

# Settings that the environment may override (the tests rely on this).
ARGOS_HOME="${ARGOS_HOME:-$HOME/.local/share/argos}"
ARGOS_CONFIG_DIR="${ARGOS_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/argos}"
ARGOS_CONFIG="$ARGOS_CONFIG_DIR/argos.conf"
ARGOS_TOOLS_DIR="${ARGOS_TOOLS_DIR:-$ARGOS_HOME/tools}"
ARGOS_BIN_DIR="${ARGOS_BIN_DIR:-$HOME/.local/bin}"
ARGOS_TITLE="Argos"
ARGOS_UI="${ARGOS_UI:-auto}"
# Values that must never be written to command.txt (API keys, session IDs).
ARGOS_SECRETS=()

_argos_env_cases_root="${ARGOS_CASES_ROOT:-}"
_argos_env_case="${ARGOS_CASE:-}"
ARGOS_CASES_ROOT="$HOME/Documents/Argos/cases"
ARGOS_CASE=""

# ── Start-up ────────────────────────────────────────────────────────────────

# argos_init TITLE: load settings and choose the user interface.
argos_init() {
    ARGOS_TITLE="${1:-Argos}"
    argos_load_config
    [ -n "$_argos_env_cases_root" ] && ARGOS_CASES_ROOT="$_argos_env_cases_root"
    [ -n "$_argos_env_case" ] && ARGOS_CASE="$_argos_env_case"

    case "$ARGOS_UI" in
        tty|zenity) ;;
        *)
            if [ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ] && command -v zenity >/dev/null 2>&1; then
                ARGOS_UI="zenity"
            else
                ARGOS_UI="tty"
            fi
            ;;
    esac
    # zenity dialogs are more reliable through XWayland on some desktops.
    if [ "$ARGOS_UI" = zenity ] && [ "${XDG_SESSION_TYPE:-}" = wayland ]; then
        export GDK_BACKEND=x11
    fi
    case ":$PATH:" in
        *":$ARGOS_BIN_DIR:"*) ;;
        *) export PATH="$ARGOS_BIN_DIR:$PATH" ;;
    esac
}

# argos_load_config: read KEY=VALUE lines without executing the file.
argos_load_config() {
    local key value
    [ -f "$ARGOS_CONFIG" ] || return 0
    while IFS='=' read -r key value || [ -n "$key" ]; do
        case "$key" in
            ARGOS_CASE) ARGOS_CASE="$value" ;;
            ARGOS_CASES_ROOT) ARGOS_CASES_ROOT="${value/#\~/$HOME}" ;;
        esac
    done < "$ARGOS_CONFIG"
}

# argos_set_config KEY VALUE: store one setting, keeping the others.
argos_set_config() {
    local key=$1 value=$2 tmp
    mkdir -p "$ARGOS_CONFIG_DIR"
    tmp=$(mktemp "$ARGOS_CONFIG_DIR/.argos.conf.XXXXXX")
    if [ -f "$ARGOS_CONFIG" ]; then
        grep -v "^${key}=" "$ARGOS_CONFIG" > "$tmp" || true
    fi
    printf '%s=%s\n' "$key" "$value" >> "$tmp"
    mv "$tmp" "$ARGOS_CONFIG"
}

# ── User interface ──────────────────────────────────────────────────────────
# Every ui_* function works with zenity or in a terminal. Functions that ask
# for input print the answer on stdout and return 1 when the user cancels.

_zen() { zenity "$@" --title "$ARGOS_TITLE" 2>/dev/null; }

ui_info() {
    if [ "$ARGOS_UI" = zenity ]; then _zen --info --width=460 --text "$1"; else printf '[i] %s\n' "$1"; fi
}

ui_warn() {
    if [ "$ARGOS_UI" = zenity ]; then _zen --warning --width=460 --text "$1"; else printf '[!] %s\n' "$1" >&2; fi
}

ui_error() {
    if [ "$ARGOS_UI" = zenity ]; then _zen --error --width=460 --text "$1"; else printf '[x] %s\n' "$1" >&2; fi
}

# ui_entry TEXT [DEFAULT]
ui_entry() {
    local text=$1 default=${2:-} answer
    if [ "$ARGOS_UI" = zenity ]; then
        answer=$(_zen --entry --width=460 --text "$text" --entry-text "$default") || return 1
    else
        if [ -n "$default" ]; then
            printf '%s [%s]: ' "$text" "$default" >&2
        else
            printf '%s: ' "$text" >&2
        fi
        IFS= read -r answer || return 1
        [ -z "$answer" ] && answer=$default
    fi
    printf '%s\n' "$answer"
}

# ui_secret TEXT: like ui_entry, without echoing what is typed.
ui_secret() {
    local answer
    if [ "$ARGOS_UI" = zenity ]; then
        answer=$(_zen --entry --hide-text --width=460 --text "$1") || return 1
    else
        printf '%s: ' "$1" >&2
        IFS= read -rs answer || return 1
        printf '\n' >&2
    fi
    printf '%s\n' "$answer"
}

# ui_choice TEXT OPTION...: one choice; the first option is preselected.
ui_choice() {
    local text=$1 answer i n
    shift
    if [ "$ARGOS_UI" = zenity ]; then
        local rows=() first=TRUE option
        for option in "$@"; do
            rows+=("$first" "$option")
            first=FALSE
        done
        answer=$(_zen --list --radiolist --width=480 --height=$((160 + 30 * $#)) \
            --text "$text" --column "" --column "Option" "${rows[@]}") || return 1
        [ -n "$answer" ] || return 1
    else
        printf '%s\n' "$text" >&2
        i=1
        for option in "$@"; do
            printf '  %d) %s\n' "$i" "$option" >&2
            i=$((i + 1))
        done
        printf 'Choice [1]: ' >&2
        IFS= read -r n || return 1
        [ -z "$n" ] && n=1
        case "$n" in ''|*[!0-9]*) return 1 ;; esac
        [ "$n" -ge 1 ] && [ "$n" -le $# ] || return 1
        answer=${!n}
    fi
    printf '%s\n' "$answer"
}

# ui_checklist TEXT "key|label|on" ... : prints the selected keys, one per line.
ui_checklist() {
    local text=$1 spec key label state
    shift
    if [ "$ARGOS_UI" = zenity ]; then
        local rows=() answer
        for spec in "$@"; do
            IFS='|' read -r key label state <<< "$spec"
            if [ "$state" = on ]; then rows+=(TRUE); else rows+=(FALSE); fi
            rows+=("$key" "$label")
        done
        answer=$(_zen --list --checklist --width=560 --height=$((180 + 30 * $#)) \
            --text "$text" --column "" --column "Key" --column "Option" \
            --hide-column=2 --print-column=2 --separator=$'\n' "${rows[@]}") || return 1
        [ -n "$answer" ] && printf '%s\n' "$answer"
    else
        local i=1 defaults=() keys=() picks n
        printf '%s\n' "$text" >&2
        for spec in "$@"; do
            IFS='|' read -r key label state <<< "$spec"
            keys+=("$key")
            if [ "$state" = on ]; then
                printf '  %d) [x] %s\n' "$i" "$label" >&2
                defaults+=("$i")
            else
                printf '  %d) [ ] %s\n' "$i" "$label" >&2
            fi
            i=$((i + 1))
        done
        printf 'Numbers separated by spaces [%s]: ' "${defaults[*]:-none}" >&2
        IFS= read -r picks || return 1
        [ -z "$picks" ] && picks="${defaults[*]:-}"
        for n in $picks; do
            case "$n" in ''|*[!0-9]*) continue ;; esac
            [ "$n" -ge 1 ] && [ "$n" -le ${#keys[@]} ] && printf '%s\n' "${keys[$((n - 1))]}"
        done
    fi
    return 0
}

# ui_file TEXT: choose an existing file.
ui_file() {
    local answer
    if [ "$ARGOS_UI" = zenity ]; then
        answer=$(zenity --file-selection --title "$1" 2>/dev/null) || return 1
    else
        printf '%s (path): ' "$1" >&2
        IFS= read -r answer || return 1
        answer=${answer/#\~/$HOME}
    fi
    [ -f "$answer" ] || return 1
    printf '%s\n' "$answer"
}

# ui_dir TEXT: choose an existing folder.
ui_dir() {
    local answer
    if [ "$ARGOS_UI" = zenity ]; then
        answer=$(zenity --file-selection --directory --title "$1" 2>/dev/null) || return 1
    else
        printf '%s (path): ' "$1" >&2
        IFS= read -r answer || return 1
        answer=${answer/#\~/$HOME}
    fi
    [ -d "$answer" ] || return 1
    printf '%s\n' "$answer"
}

# ui_question TEXT: yes returns 0. The default answer is no.
ui_question() {
    local answer
    if [ "$ARGOS_UI" = zenity ]; then
        _zen --question --width=460 --default-cancel --text "$1"
    else
        printf '%s [y/N]: ' "$1" >&2
        IFS= read -r answer || return 1
        case "$answer" in y|Y|yes|YES) return 0 ;; *) return 1 ;; esac
    fi
}

# ui_text_file FILE: show a text file.
ui_text_file() {
    if [ "$ARGOS_UI" = zenity ]; then
        _zen --text-info --width=760 --height=520 --filename "$1"
    else
        cat "$1"
    fi
}

# ── Validation ──────────────────────────────────────────────────────────────

is_username() { [[ $1 =~ ^[^[:space:]/\\]{1,100}$ ]]; }
is_email()    { [[ $1 =~ ^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$ ]]; }
is_url()      { [[ $1 =~ ^https?://[^[:space:]]+$ ]]; }

is_domain() {
    local d=${1,,}
    [[ $d =~ ^([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\.)+([a-z]{2,63}|xn--[a-z0-9-]{1,59})$ ]]
}

is_ipv4() {
    local IFS=. octet
    local -a parts
    [[ $1 =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]] || return 1
    read -ra parts <<< "$1"
    for octet in "${parts[@]}"; do
        [ "$((10#$octet))" -le 255 ] || return 1
    done
}

is_phone() {
    local digits=${1//[^0-9]/}
    [[ $1 =~ ^\+?[0-9\ ().-]{6,24}$ ]] && [ "${#digits}" -ge 6 ] && [ "${#digits}" -le 15 ]
}

# safe_name TEXT: a string that is safe as part of a file name.
safe_name() {
    local s
    s=$(printf '%s' "$1" | tr -c 'A-Za-z0-9._@-' '_' | cut -c1-80)
    s=${s##.}
    s=${s##.}
    printf '%s\n' "${s:-target}"
}

# ── Cases and runs ──────────────────────────────────────────────────────────

case_name() { printf '%s\n' "${ARGOS_CASE:-unsorted}"; }
case_root() { printf '%s/%s\n' "$ARGOS_CASES_ROOT" "$(case_name)"; }

# new_run_dir TOOL TARGET: create a run folder, start its command.txt with
# the run context, and print the folder path. Usually called inside $( ).
new_run_dir() {
    local tool=$1 base dir n=2
    base="$(case_root)/$tool/$(date -u +%Y%m%dT%H%M%SZ)_$(safe_name "$2")"
    dir=$base
    while [ -e "$dir" ]; do
        dir="${base}-$n"
        n=$((n + 1))
    done
    mkdir -p "$dir" || return 1
    {
        printf 'Argos: %s\n' "$ARGOS_VERSION"
        printf 'Case: %s\n' "$(case_name)"
        printf 'Tool: %s\n' "$tool"
        printf 'Target: %s\n' "$2"
        printf 'Operator: %s@%s\n' "$(id -un)" "$(hostname)"
    } > "$dir/command.txt"
    printf '%s\n' "$dir"
}

# ── Tools ───────────────────────────────────────────────────────────────────

# find_tool NAME [CANDIDATE_PATH...]: print the path of an executable.
find_tool() {
    local name=$1 candidate
    shift
    for candidate in "$@"; do
        if [ -x "$candidate" ]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done
    if command -v "$name" >/dev/null 2>&1; then
        command -v "$name"
        return 0
    fi
    ui_error "$name is not installed or cannot be found.
Run setup.sh again, or check its installation log in ~/Downloads."
    return 1
}

# record_version DIR LABEL COMMAND...: add a tool version line to command.txt.
record_version() {
    local dir=$1 label=$2 version
    shift 2
    version=$(timeout 30 "$@" 2>&1 | sed 's/\x1b\[[0-9;]*m//g' | grep -m1 -E '[0-9]+\.[0-9]+' || true)
    printf 'Tool version (%s): %s\n' "$label" "${version:-unknown}" >> "$dir/command.txt"
}

# _last_line FILE: the last readable line of a log, for the progress window.
_last_line() {
    tail -c 4000 "$1" 2>/dev/null | tr '\r' '\n' | sed 's/\x1b\[[0-9;?]*[A-Za-z]//g' \
        | grep -v '^[[:space:]]*$' | tail -n 1 | cut -c1-90
}

# _markup_escape: zenity reads dialog text as Pango markup.
_markup_escape() { sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'; }

# run_logged DIR LABEL -- COMMAND...: run a tool, log everything, allow cancel.
# Returns the tool exit code, or 130 when the user cancels.
run_logged() {
    local dir=$1 label=$2 rc pid
    shift 2
    [ "${1:-}" = "--" ] && shift
    local log="$dir/output.log" meta="$dir/command.txt" arg secret shown
    {
        printf 'Started (UTC): %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
        printf 'Command:'
        for arg in "$@"; do
            shown=$(printf '%q' "$arg")
            for secret in "${ARGOS_SECRETS[@]}"; do
                [ -n "$secret" ] && [ "$arg" = "$secret" ] && shown="<redacted>"
            done
            printf ' %s' "$shown"
        done
        printf '\n'
    } >> "$meta"

    if [ "$ARGOS_UI" = zenity ]; then
        setsid "$@" >> "$log" 2>&1 < /dev/null &
        pid=$!
        (
            while kill -0 "$pid" 2>/dev/null; do
                printf '# %s  ·  %s\n' "$label" "$(_last_line "$log" | _markup_escape)"
                sleep 1
            done
            echo 100
        ) | zenity --progress --pulsate --auto-close --width=560 \
                --title "$ARGOS_TITLE" --text "$label" 2>/dev/null
        if kill -0 "$pid" 2>/dev/null; then
            kill -TERM -- "-$pid" 2>/dev/null
            sleep 2
            kill -KILL -- "-$pid" 2>/dev/null
            wait "$pid" 2>/dev/null
            rc=130
            printf '\n[Argos] Cancelled by the user.\n' >> "$log"
        else
            wait "$pid"
            rc=$?
        fi
    else
        printf '%s\n' "$label" >&2
        "$@" 2>&1 | tee -a "$log"
        rc=${PIPESTATUS[0]}
    fi

    {
        printf 'Finished (UTC): %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
        printf 'Exit code: %s\n' "$rc"
    } >> "$meta"
    return "$rc"
}

# finish_run DIR: hash every file of the run, then open the folder.
finish_run() {
    local dir=$1 sums
    sums=$(
        cd "$dir" || exit 1
        find . -type f ! -name SHA256SUMS -print0 | sort -z | xargs -0 -r sha256sum
    ) && printf '%s\n' "$sums" > "$dir/SHA256SUMS"
    open_path "$dir"
}

# open_path PATH_OR_URL: open with the desktop default application.
open_path() {
    [ "${ARGOS_NO_OPEN:-0}" = 1 ] && return 0
    if [ "$ARGOS_UI" = zenity ] && command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$1" >/dev/null 2>&1 &
    else
        printf 'Results: %s\n' "$1"
    fi
}

# report_outcome DIR RC TOOL: tell the user how the run ended.
report_outcome() {
    local dir=$1 rc=$2 tool=$3
    case "$rc" in
        0) return 0 ;;
        130) ui_warn "$tool was cancelled. Partial results are in:
$dir" ;;
        *) ui_warn "$tool ended with an error (exit code $rc).
The full output is in $dir/output.log" ;;
    esac
}

# ── OPSEC ───────────────────────────────────────────────────────────────────

# confirm_third_party SERVICE WHAT: explicit consent before sharing a target.
confirm_third_party() {
    ui_question "This option sends $2 to $1.
That service will see what you are investigating.

Enable it for this run?"
}
