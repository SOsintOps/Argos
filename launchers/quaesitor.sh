#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Ramingo (SOsintOps)
#
# Argos launcher: Quaesitor, the case as a graph in the browser (fork of
# OSInt Graph). Its archive is kept with the cases, outside the program.

set -uo pipefail
# shellcheck source=lib/argos.sh
. "$(dirname "$(readlink -f "$0")")/lib/argos.sh"
argos_init "Quaesitor"

QUAESITOR_DIR="$ARGOS_TOOLS_DIR/quaesitor"
QUAESITOR_DATA="$(dirname "$ARGOS_CASES_ROOT")/quaesitor"
PORT=5000
URL="http://127.0.0.1:$PORT"

# wait_for_http URL SECONDS: true once the address answers.
wait_for_http() {
    local i
    for ((i = 0; i < $2; i++)); do
        curl -s -o /dev/null "$1" && return 0
        sleep 1
    done
    return 1
}

if [ ! -f "$QUAESITOR_DIR/app.py" ]; then
    ui_error "Quaesitor is not installed. Run: setup.sh quaesitor"
    exit 1
fi
py=$(find_tool quaesitor-python "$QUAESITOR_DIR/.venv/bin/python") || exit 1

if ! curl -s -o /dev/null "$URL"; then
    mkdir -p "$QUAESITOR_DATA"
    (cd "$QUAESITOR_DIR" && DATA_DIR="$QUAESITOR_DATA" PORT="$PORT" \
        setsid "$py" app.py >> "$QUAESITOR_DATA/server.log" 2>&1 < /dev/null &)
    if ! wait_for_http "$URL" 40; then
        ui_error "Quaesitor did not start. See $QUAESITOR_DATA/server.log"
        exit 1
    fi
fi
open_path "$URL"
