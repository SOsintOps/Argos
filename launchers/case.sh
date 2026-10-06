#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Ramingo (SOsintOps)
#
# Argos launcher: create, select and open investigation cases.

set -uo pipefail
# shellcheck source=lib/argos.sh
. "$(dirname "$(readlink -f "$0")")/lib/argos.sh"
argos_init "Argos Case"

is_case_name() { [[ $1 =~ ^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$ ]] && [ "$1" != unsorted ]; }

list_cases() {
    [ -d "$ARGOS_CASES_ROOT" ] || return 0
    find "$ARGOS_CASES_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort
}

create_case() {
    local name description dir
    name=$(ui_entry "Name of the new case (letters, digits, dot, dash, underscore)") || return 0
    if ! is_case_name "$name"; then
        ui_error "\"$name\" is not a valid case name."
        return 1
    fi
    dir="$ARGOS_CASES_ROOT/$name"
    if [ -e "$dir" ]; then
        ui_error "The case \"$name\" already exists. Use \"Switch to another case\"."
        return 1
    fi
    description=$(ui_entry "Short description (optional)") || description=""
    mkdir -p "$dir" || return 1
    # Start from the case skeleton installed by setup.sh, when present.
    [ -d "$ARGOS_HOME/case-skeleton" ] && cp -r "$ARGOS_HOME/case-skeleton/." "$dir/"
    {
        printf 'Case: %s\n' "$name"
        printf 'Created (UTC): %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
        printf 'Operator: %s@%s\n' "$(id -un)" "$(hostname)"
        printf 'Description: %s\n' "$description"
    } > "$dir/case.txt"
    argos_set_config ARGOS_CASE "$name"
    ARGOS_CASE=$name
    ui_info "Case \"$name\" created and selected.
Results will be saved in $dir"
}

switch_case() {
    local cases name
    cases=$(list_cases)
    if [ -z "$cases" ]; then
        ui_warn "There are no cases yet. Create one first."
        return 0
    fi
    mapfile -t names <<< "$cases"
    name=$(ui_choice "Select the case to work on" "${names[@]}") || return 0
    argos_set_config ARGOS_CASE "$name"
    ARGOS_CASE=$name
    ui_info "Active case: $name"
}

choice=$(ui_choice "Active case: $(case_name)
Results folder: $(case_root)" \
    "Create a new case" \
    "Switch to another case" \
    "Open the active case folder" \
    "Stop using a case (results go to \"unsorted\")") || exit 0

case "$choice" in
    "Create"*) create_case ;;
    "Switch"*) switch_case ;;
    "Open"*) mkdir -p "$(case_root)" && open_path "$(case_root)" ;;
    "Stop"*)
        argos_set_config ARGOS_CASE ""
        ui_info "No active case. Results will be saved in \"unsorted\"."
        ;;
esac
