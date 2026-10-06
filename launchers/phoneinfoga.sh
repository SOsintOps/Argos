#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Ramingo (SOsintOps)
#
# Argos launcher: phone number intelligence (PhoneInfoga).

set -uo pipefail
# shellcheck source=lib/argos.sh
. "$(dirname "$(readlink -f "$0")")/lib/argos.sh"
argos_init "PhoneInfoga"

PORT=5000
bin=$(find_tool phoneinfoga "$ARGOS_BIN_DIR/phoneinfoga") || exit 1

choice=$(ui_choice "Case: $(case_name)
How do you want to use PhoneInfoga?" \
    "Scan one number and save the result in the case" \
    "Open the web interface") || exit 0

case "$choice" in
    Scan*)
        number=$(ui_entry "Phone number in international format (for example +39 06 1234567)") || exit 0
        if ! is_phone "$number"; then
            ui_error "\"$number\" is not a valid phone number."
            exit 1
        fi
        number=${number//[ ().-]/}
        run=$(new_run_dir phoneinfoga "$number") || exit 1
        record_version "$run" phoneinfoga "$bin" version
        run_logged "$run" "PhoneInfoga: $number" -- "$bin" scan -n "$number"
        rc=$?
        report_outcome "$run" "$rc" PhoneInfoga
        finish_run "$run"
        [ "$ARGOS_UI" = zenity ] && ui_text_file "$run/output.log"
        ;;
    Open*)
        if ! curl -s -o /dev/null "http://127.0.0.1:$PORT"; then
            setsid "$bin" serve -p "$PORT" >/dev/null 2>&1 < /dev/null &
            for _ in $(seq 1 20); do
                curl -s -o /dev/null "http://127.0.0.1:$PORT" && break
                sleep 1
            done
        fi
        open_path "http://127.0.0.1:$PORT"
        ;;
esac
