# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Ramingo (SOsintOps)
#
# Shared set-up for the Argos bats tests. Every test runs in a fresh
# temporary HOME with test doubles in place of the real OSINT tools.

REPO="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
LAUNCHERS="$REPO/launchers"

setup_argos() {
    export HOME="$BATS_TEST_TMPDIR/home"
    export ARGOS_UI=tty
    export ARGOS_NO_OPEN=1
    export ARGOS_CASES_ROOT="$HOME/cases"
    export ARGOS_CONFIG_DIR="$HOME/config"
    export ARGOS_BIN_DIR="$BATS_TEST_TMPDIR/bin"
    export ARGOS_TOOLS_DIR="$BATS_TEST_TMPDIR/tools"
    export CALLS="$BATS_TEST_TMPDIR/calls.log"
    unset ARGOS_CASE
    mkdir -p "$HOME" "$ARGOS_BIN_DIR" "$ARGOS_TOOLS_DIR"
    : > "$CALLS"
}

# double NAME [BODY]: create a fake executable that records its arguments
# in $CALLS (one line: NAME arg1 arg2 ...) and then runs BODY.
double() {
    local path=$1 body=${2:-}
    case "$path" in /*) ;; *) path="$ARGOS_BIN_DIR/$path" ;; esac
    mkdir -p "$(dirname "$path")"
    cat > "$path" <<EOF
#!/usr/bin/env bash
printf '%s' "$(basename "$path")" >> "$CALLS"
printf ' %s' "\$@" >> "$CALLS"
printf '\n' >> "$CALLS"
$body
EOF
    chmod +x "$path"
}

# answers LINE...: feed the given answers to a launcher's prompts.
answers() { printf '%s\n' "$@"; }

# only_run_dir TOOL: path of the single run folder created for TOOL.
only_run_dir() {
    local dirs=("$ARGOS_CASES_ROOT"/*/"$1"/*/)
    [ "${#dirs[@]}" -eq 1 ] || { echo "expected 1 run dir for $1, found ${#dirs[@]}" >&2; return 1; }
    printf '%s\n' "${dirs[0]%/}"
}

# arg_after FLAG LINE: the value that follows FLAG in a recorded call.
arg_after() { awk -v f="$1" '{for (i = 1; i < NF; i++) if ($i == f) print $(i + 1)}' <<< "$2"; }
