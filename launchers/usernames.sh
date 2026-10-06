#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Ramingo (SOsintOps)
#
# Argos launcher: search a username or an email address across online services.

set -uo pipefail
# shellcheck source=lib/argos.sh
. "$(dirname "$(readlink -f "$0")")/lib/argos.sh"
argos_init "Usernames & Emails"

BLACKBIRD_DIR="$ARGOS_TOOLS_DIR/blackbird"

# ask_username TOOL: print a valid username; return 1 if cancelled, 2 if invalid.
ask_username() {
    local value
    value=$(ui_entry "$1 — target username") || return 1
    value=${value#@}
    if ! is_username "$value"; then
        ui_error "\"$value\" is not a valid username (no spaces or slashes, 1–100 characters)."
        return 2
    fi
    printf '%s\n' "$value"
}

ask_username_or_email() {
    local value
    value=$(ui_entry "$1 — target username or email address") || return 1
    value=${value#@}
    if ! is_email "$value" && ! is_username "$value"; then
        ui_error "\"$value\" is neither a valid username nor a valid email address."
        return 2
    fi
    printf '%s\n' "$value"
}

# has KEY LIST: true when KEY is one of the lines of LIST.
has() { grep -qx -- "$1" <<< "$2"; }

# ── Sherlock ────────────────────────────────────────────────────────────────

sherlock_run() {
    local user=$1 opts=${2-} bin run args
    bin=$(find_tool sherlock "$ARGOS_BIN_DIR/sherlock") || return 1
    if [ -z "${2+set}" ]; then
        opts=$(ui_checklist "Sherlock — reports and scope" \
            "csv|CSV report|on" "xlsx|Excel report|off" "txt|Text list of found profiles|on" \
            "nsfw|Include adult sites|off") || return 0
    fi
    run=$(new_run_dir sherlock "$user") || return 1
    args=("$user" --folderoutput "$run" --no-color --print-found)
    has csv "$opts" && args+=(--csv)
    has xlsx "$opts" && args+=(--xlsx)
    has txt "$opts" && args+=(--txt)
    has nsfw "$opts" && args+=(--nsfw)
    record_version "$run" sherlock "$bin" --version
    run_logged "$run" "Sherlock: $user" -- env -C "$run" "$bin" "${args[@]}"
    report_outcome "$run" $? Sherlock
    finish_run "$run"
}

# ── Maigret ─────────────────────────────────────────────────────────────────

maigret_run() {
    local user=$1 opts=${2-} scope=${3-} bin run args
    bin=$(find_tool maigret "$ARGOS_BIN_DIR/maigret") || return 1
    if [ -z "${2+set}" ]; then
        opts=$(ui_checklist "Maigret — reports" \
            "html|HTML report|on" "pdf|PDF report|on" "json|JSON report|on" "csv|CSV report|off" \
            "txt|Text report|off" "xmind|XMind mind map|off" "graph|Interactive graph|off" \
            "norecursion|Do not follow usernames found on profiles|off") || return 0
        scope=$(ui_choice "Maigret — how many sites?" \
            "Top 500 sites (faster)" "All sites (3000+, slower)") || return 0
    fi
    run=$(new_run_dir maigret "$user") || return 1
    args=("$user" --folderoutput "$run" --no-color --no-progressbar)
    has html "$opts" && args+=(--html)
    has pdf "$opts" && args+=(--pdf)
    has json "$opts" && args+=(--json simple)
    has csv "$opts" && args+=(--csv)
    has txt "$opts" && args+=(--txt)
    has xmind "$opts" && args+=(--xmind)
    has graph "$opts" && args+=(--graph)
    has norecursion "$opts" && args+=(--no-recursion)
    case "$scope" in All*) args+=(--all-sites) ;; esac
    record_version "$run" maigret "$bin" --version
    run_logged "$run" "Maigret: $user" -- env -C "$run" "$bin" "${args[@]}"
    report_outcome "$run" $? Maigret
    finish_run "$run"
}

# maigret_from_url: extract usernames and IDs from a profile page, then search them.
maigret_from_url() {
    local url bin run
    bin=$(find_tool maigret "$ARGOS_BIN_DIR/maigret") || return 1
    url=$(ui_entry "Maigret — profile URL to start from") || return 0
    if ! is_url "$url"; then
        ui_error "\"$url\" is not an http(s) URL."
        return 1
    fi
    run=$(new_run_dir maigret "$url") || return 1
    record_version "$run" maigret "$bin" --version
    run_logged "$run" "Maigret: $url" -- env -C "$run" "$bin" --parse "$url" \
        --folderoutput "$run" --html --json simple --no-color --no-progressbar
    report_outcome "$run" $? Maigret
    finish_run "$run"
}

# ── Blackbird ───────────────────────────────────────────────────────────────

blackbird_run() {
    local target=$1 opts=${2-} py run args before after new_dir
    py=$(find_tool blackbird-python "$BLACKBIRD_DIR/.venv/bin/python") || return 1
    if [ -z "${2+set}" ]; then
        opts=$(ui_checklist "Blackbird — reports and options" \
            "csv|CSV report|on" "json|JSON report|on" "pdf|PDF report|on" \
            "nonsfw|Skip adult sites|off" "dump|Save the HTML of every account found|off" \
            "ai|AI profile (uses the Blackbird online service)|off") || return 0
    fi
    if has ai "$opts" && ! confirm_third_party "the Blackbird AI service" "the names of the sites where the target was found"; then
        opts=$(grep -vx ai <<< "$opts")
    fi
    run=$(new_run_dir blackbird "$target") || return 1
    if is_email "$target"; then args=(--email "$target"); else args=(--username "$target"); fi
    has csv "$opts" && args+=(--csv)
    has json "$opts" && args+=(--json)
    has pdf "$opts" && args+=(--pdf)
    has nonsfw "$opts" && args+=(--no-nsfw)
    has dump "$opts" && args+=(--dump)
    has ai "$opts" && args+=(--ai)
    mkdir -p "$BLACKBIRD_DIR/results"
    before=$(ls -1 "$BLACKBIRD_DIR/results")
    run_logged "$run" "Blackbird: $target" -- env -C "$BLACKBIRD_DIR" "$py" blackbird.py "${args[@]}"
    report_outcome "$run" $? Blackbird
    # Blackbird always writes inside its own results folder: move the new
    # report folders into the run folder.
    after=$(ls -1 "$BLACKBIRD_DIR/results")
    while IFS= read -r new_dir; do
        [ -n "$new_dir" ] && mv "$BLACKBIRD_DIR/results/$new_dir" "$run/"
    done < <(comm -13 <(sort <<< "$before") <(sort <<< "$after"))
    finish_run "$run"
}

# ── User Scanner ────────────────────────────────────────────────────────────

user_scanner_run() {
    local target=$1 opts=${2-} format=${3-} bin run args ext
    bin=$(find_tool user-scanner "$ARGOS_BIN_DIR/user-scanner") || return 1
    if [ -z "${2+set}" ]; then
        format=$(ui_choice "User Scanner — report format" "JSON" "CSV" "PDF") || return 0
        opts=$(ui_checklist "User Scanner — options" \
            "nonsfw|Skip adult sites|off" \
            "cross|Follow the accounts, links and emails found (cross-scan)|off" \
            "hudson|Infostealer lookup (Hudson Rock online service)|off" \
            "loud|Include checks that may notify the target (password reset flows)|off") || return 0
    fi
    if has hudson "$opts" && ! confirm_third_party "Hudson Rock" "the target username or email"; then
        opts=$(grep -vx hudson <<< "$opts")
    fi
    if has loud "$opts" && ! ui_question "Loud checks can trigger emails or notifications to the account owner.
The target may learn that someone is looking.

Enable loud checks for this run?"; then
        opts=$(grep -vx loud <<< "$opts")
    fi
    case "$format" in CSV) ext=csv ;; PDF) ext=pdf ;; *) ext=json ;; esac
    run=$(new_run_dir user-scanner "$target") || return 1
    if is_email "$target"; then args=(--email "$target"); else args=(--username "$target"); fi
    args+=(--format "$ext" --output "$run/user-scanner.$ext")
    has nonsfw "$opts" && args+=(--no-nsfw)
    has cross "$opts" && args+=(--cross-scan)
    has hudson "$opts" && args+=(--hudson)
    has loud "$opts" && args+=(--allow-loud)
    record_version "$run" user-scanner "$bin" --version
    run_logged "$run" "User Scanner: $target" -- env -C "$run" "$bin" "${args[@]}"
    report_outcome "$run" $? "User Scanner"
    finish_run "$run"
}

# ── Linkook ─────────────────────────────────────────────────────────────────

linkook_run() {
    local user=$1 opts=${2-} bin run args
    bin=$(find_tool linkook "$ARGOS_BIN_DIR/linkook") || return 1
    if [ -z "${2+set}" ]; then
        opts=$(ui_checklist "Linkook — options" \
            "all|Scan every known site, not only linked ones|off" \
            "neo4j|Export a JSON file for Neo4j|off" \
            "breach|Breach lookup (Hudson Rock online service)|off") || return 0
    fi
    if has breach "$opts" && ! confirm_third_party "Hudson Rock" "the target username"; then
        opts=$(grep -vx breach <<< "$opts")
    fi
    run=$(new_run_dir linkook "$user") || return 1
    args=("$user" --output "$run" --no-color --show-summary)
    has all "$opts" && args+=(--scan-all)
    has neo4j "$opts" && args+=(--neo4j)
    has breach "$opts" && args+=(--check-breach)
    record_version "$run" linkook "$bin" --version
    run_logged "$run" "Linkook: $user" -- env -C "$run" "$bin" "${args[@]}"
    report_outcome "$run" $? Linkook
    finish_run "$run"
}

# ── Socialscan ──────────────────────────────────────────────────────────────

socialscan_run() {
    local target=$1 bin run
    bin=$(find_tool socialscan "$ARGOS_BIN_DIR/socialscan") || return 1
    run=$(new_run_dir socialscan "$target") || return 1
    record_version "$run" socialscan "$bin" --version
    run_logged "$run" "Socialscan: $target" -- env -C "$run" "$bin" "$target" \
        --show-urls --json "$run/socialscan.json"
    report_outcome "$run" $? Socialscan
    finish_run "$run"
}

# ── Menu ────────────────────────────────────────────────────────────────────

choice=$(ui_choice "Case: $(case_name)
Which search?" \
    "Sherlock — username on 400+ sites" \
    "Maigret — username on 3000+ sites, detailed reports" \
    "Maigret — start from a profile URL" \
    "Blackbird — username or email" \
    "User Scanner — username or email" \
    "Linkook — accounts linked to a username" \
    "Socialscan — is a username or email in use?" \
    "All username tools, one after the other") || exit 0

# Cancelling a prompt ends quietly; an invalid value ends with an error code.
quit() { exit $(($1 == 2)); }

case "$choice" in
    "Sherlock"*) target=$(ask_username Sherlock) || quit $?; sherlock_run "$target" ;;
    "Maigret — start"*) maigret_from_url ;;
    "Maigret"*) target=$(ask_username Maigret) || quit $?; maigret_run "$target" ;;
    "Blackbird"*) target=$(ask_username_or_email Blackbird) || quit $?; blackbird_run "$target" ;;
    "User Scanner"*) target=$(ask_username_or_email "User Scanner") || quit $?; user_scanner_run "$target" ;;
    "Linkook"*) target=$(ask_username Linkook) || quit $?; linkook_run "$target" ;;
    "Socialscan"*) target=$(ask_username_or_email Socialscan) || quit $?; socialscan_run "$target" ;;
    "All"*)
        target=$(ask_username "All tools") || quit $?
        ARGOS_NO_OPEN=1
        sherlock_run "$target" $'csv\ntxt'
        maigret_run "$target" $'html\npdf\njson' "Top 500 sites (faster)"
        blackbird_run "$target" $'csv\njson'
        user_scanner_run "$target" "" JSON
        linkook_run "$target" ""
        socialscan_run "$target"
        ARGOS_NO_OPEN=0
        open_path "$(case_root)"
        ;;
esac
