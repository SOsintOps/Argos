#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Ramingo (SOsintOps)
#
# Argos launcher: screenshots and an HTML report of web pages (EyeWitness).

set -uo pipefail
# shellcheck source=lib/argos.sh
. "$(dirname "$(readlink -f "$0")")/lib/argos.sh"
argos_init "Web Screenshots"

EYEWITNESS_DIR="$ARGOS_TOOLS_DIR/EyeWitness"

py=$(find_tool eyewitness-python "$EYEWITNESS_DIR/eyewitness-venv/bin/python") || exit 1
if [ ! -f "$EYEWITNESS_DIR/Python/EyeWitness.py" ]; then
    ui_error "EyeWitness is not installed in $EYEWITNESS_DIR. Run setup.sh again."
    exit 1
fi

mode=$(ui_choice "Case: $(case_name)
What do you want to capture?" \
    "One web page" \
    "A list of URLs (text file, one per line)" \
    "The web services of an Nmap or Nessus XML report") || exit 0

case "$mode" in
    One*)
        target=$(ui_entry "URL or host name (for example https://www.example.com)") || exit 0
        if ! is_url "$target" && ! is_domain "$target" && ! is_ipv4 "$target"; then
            ui_error "\"$target\" is not a URL, a host name or an IPv4 address."
            exit 1
        fi
        input=(--single "$target")
        label=$target
        ;;
    "A list"*)
        file=$(ui_file "Text file with one URL per line") || exit 0
        target=$(basename "$file")
        label="$(grep -c . "$file") URLs from $target"
        ;;
    *)
        file=$(ui_file "Nmap (-oX) or Nessus XML report") || exit 0
        target=$(basename "$file")
        label="services from $target"
        ;;
esac

timeout=$(ui_entry "Seconds to wait for each page" 15) || exit 0
case "$timeout" in ''|*[!0-9]*) timeout=15 ;; esac

run=$(new_run_dir eyewitness "$target") || exit 1
# Keep a copy of the input list with the evidence.
case "$mode" in
    "A list"*) cp "$file" "$run/input_urls.txt"; input=(-f "$run/input_urls.txt") ;;
    One*) ;;
    *) cp "$file" "$run/input_report.xml"; input=(-x "$run/input_report.xml") ;;
esac

run_logged "$run" "EyeWitness: $label" -- env -C "$EYEWITNESS_DIR/Python" "$py" EyeWitness.py \
    --web "${input[@]}" -d "$run/report" --no-prompt --timeout "$timeout"
rc=$?
report_outcome "$run" "$rc" EyeWitness
finish_run "$run"
[ -f "$run/report/report.html" ] && open_path "$run/report/report.html"
