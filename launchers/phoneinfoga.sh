#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Ramingo (SOsintOps)
#
# Argos launcher: phone numbers — offline analysis, PhoneInfoga, Telegram.
# Internal use: phoneinfoga.sh --telegram NUMBER runs the Telegram check in
# the terminal it was started from.

set -uo pipefail
# shellcheck source=lib/argos.sh
. "$(dirname "$(readlink -f "$0")")/lib/argos.sh"
argos_init "Phone Numbers"

PORT=5000
# The Telegram login session is a credential: it lives here, never in a case.
TELEGRAM_HOME="$ARGOS_CONFIG_DIR/telegram"

ask_number() {
    local number
    number=$(ui_entry "Phone number in international format (for example +39 06 1234567)") || return 1
    if ! is_phone "$number"; then
        ui_error "\"$number\" is not a valid phone number."
        return 2
    fi
    printf '%s\n' "${number//[ ().-]/}"
}

offline_run() {
    local number=$1 py run
    py=$(find_tool phonenumbers-python "$ARGOS_TOOLS_DIR/phonenumbers/.venv/bin/python") || return 1
    run=$(new_run_dir phone-offline "$number") || return 1
    run_logged "$run" "Offline analysis: $number" -- "$py" "$ARGOS_LIB_DIR/phone_info.py" "$number" "$run/phone.json"
    report_outcome "$run" $? "Offline analysis"
    finish_run "$run"
    [ "$ARGOS_UI" = zenity ] && ui_text_file "$run/output.log"
}

phoneinfoga_run() {
    local number=$1 bin run rc
    bin=$(find_tool phoneinfoga "$ARGOS_BIN_DIR/phoneinfoga") || return 1
    run=$(new_run_dir phoneinfoga "$number") || return 1
    record_version "$run" phoneinfoga "$bin" version
    run_logged "$run" "PhoneInfoga: $number" -- "$bin" scan -n "$number"
    rc=$?
    report_outcome "$run" "$rc" PhoneInfoga
    finish_run "$run"
    [ "$ARGOS_UI" = zenity ] && ui_text_file "$run/output.log"
}

# telegram_run NUMBER: interactive (login code), so it needs a terminal.
telegram_run() {
    local number=$1 bin run
    bin=$(find_tool telegram-phone-number-checker "$ARGOS_BIN_DIR/telegram-phone-number-checker") || return 1
    mkdir -p "$TELEGRAM_HOME" && chmod 700 "$TELEGRAM_HOME"
    printf '%s\n' "Telegram check of $number" \
        "It logs in with YOUR Telegram account: use a research account." \
        "The first time it asks for an API ID and hash (https://my.telegram.org/apps)," \
        "your account's phone number and the login code Telegram sends you." \
        "The session is kept in $TELEGRAM_HOME, outside the case folders." ""
    run=$(new_run_dir telegram "$number") || return 1
    run_logged "$run" "Telegram: $number" -- env -C "$TELEGRAM_HOME" "$bin" \
        --phone-numbers "$number" --output "$run/telegram.json"
    report_outcome "$run" $? "Telegram check"
    finish_run "$run"
}

if [ "${1:-}" = "--telegram" ] && [ -n "${2:-}" ]; then
    ARGOS_UI="tty"
    telegram_run "$2"
    read -rp "Press ENTER to close this window. " _
    exit 0
fi

choice=$(ui_choice "Case: $(case_name)
What do you want to do?" \
    "Offline analysis: country, carrier, line type (no network)" \
    "PhoneInfoga scan (public sources)" \
    "Telegram: is an account linked to the number?" \
    "Open the PhoneInfoga web interface") || exit 0

if [[ $choice == Open* ]]; then
    bin=$(find_tool phoneinfoga "$ARGOS_BIN_DIR/phoneinfoga") || exit 1
    if ! curl -s -o /dev/null "http://127.0.0.1:$PORT"; then
        setsid "$bin" serve -p "$PORT" >/dev/null 2>&1 < /dev/null &
        for _ in $(seq 1 20); do
            curl -s -o /dev/null "http://127.0.0.1:$PORT" && break
            sleep 1
        done
    fi
    open_path "http://127.0.0.1:$PORT"
    exit 0
fi

number=$(ask_number) || exit $(($? == 2))
case "$choice" in
    Offline*) offline_run "$number" ;;
    PhoneInfoga*) phoneinfoga_run "$number" ;;
    Telegram*)
        confirm_third_party "Telegram" "the phone number, through your own Telegram account" || exit 0
        if [ "$ARGOS_UI" = zenity ]; then
            # The check needs a terminal for the login code.
            x-terminal-emulator -e "$0" --telegram "$number" >/dev/null 2>&1 &
        else
            telegram_run "$number"
        fi
        ;;
esac
