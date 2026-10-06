#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Ramingo (SOsintOps)
#
# Argos launcher: SpiderFoot web interface or a scan saved in the case.

set -uo pipefail
# shellcheck source=lib/argos.sh
. "$(dirname "$(readlink -f "$0")")/lib/argos.sh"
argos_init "SpiderFoot"

SPIDERFOOT_DIR="$ARGOS_TOOLS_DIR/spiderfoot"
LISTEN="127.0.0.1:5001"

py=$(find_tool spiderfoot-python "$SPIDERFOOT_DIR/.venv/bin/python") || exit 1

# wait_for_http URL SECONDS: true once the address answers.
wait_for_http() {
    local i
    for ((i = 0; i < $2; i++)); do
        curl -s -o /dev/null "$1" && return 0
        sleep 1
    done
    return 1
}

choice=$(ui_choice "Case: $(case_name)
How do you want to use SpiderFoot?" \
    "Open the web interface" \
    "Scan a target now and save the results in the case") || exit 0

case "$choice" in
    Open*)
        if ! curl -s -o /dev/null "http://$LISTEN"; then
            (cd "$SPIDERFOOT_DIR" && setsid "$py" sf.py -l "$LISTEN" >/dev/null 2>&1 < /dev/null &)
            if ! wait_for_http "http://$LISTEN" 40; then
                ui_error "SpiderFoot did not start. Try running: $py $SPIDERFOOT_DIR/sf.py -l $LISTEN"
                exit 1
            fi
        fi
        open_path "http://$LISTEN"
        ;;
    Scan*)
        target=$(ui_entry "Target: domain, IP address, email, username, phone number or name") || exit 0
        [ -n "$target" ] || exit 0
        usecase=$(ui_choice "Which modules?" \
            "passive — public sources only, nothing touches the target" \
            "footprint — map the target's internet footprint" \
            "investigate — footprint plus reputation and maliciousness checks" \
            "all — every module (slow, noisy)") || exit 0
        usecase=${usecase%% *}
        run=$(new_run_dir spiderfoot "$target") || exit 1
        record_version "$run" spiderfoot "$py" "$SPIDERFOOT_DIR/sf.py" --help
        # The inner script redirects SpiderFoot's CSV to a file; its arguments
        # are positional parameters, so single quotes are intended.
        # shellcheck disable=SC2016
        run_logged "$run" "SpiderFoot ($usecase): $target" -- env -C "$SPIDERFOOT_DIR" sh -c \
            '"$1" sf.py -s "$2" -u "$3" -o csv > "$4/results.csv"' argos "$py" "$target" "$usecase" "$run"
        report_outcome "$run" $? SpiderFoot
        finish_run "$run"
        ;;
esac
