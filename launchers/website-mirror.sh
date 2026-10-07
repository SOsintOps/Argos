#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Ramingo (SOsintOps)
#
# Argos launcher: offline copy of a website (HTTrack) or a map of its pages
# and links (katana).

set -uo pipefail
# shellcheck source=lib/argos.sh
. "$(dirname "$(readlink -f "$0")")/lib/argos.sh"
argos_init "Website Mirror"

mode=$(ui_choice "Case: $(case_name)
What do you want to do?" \
    "Save a browsable offline copy (HTTrack)" \
    "Crawl and list pages, links and files (katana)") || exit 0

url=$(ui_entry "Address of the website") || exit 0
if ! is_url "$url"; then
    ui_error "\"$url\" is not an http(s) address."
    exit 1
fi
depth=$(ui_entry "How many links deep? (1 = only this page, 3 is usually enough)" 3) || exit 0
case "$depth" in ''|*[!0-9]*) depth=3 ;; esac
host=$(sed -E 's#^https?://##; s#[/?].*##' <<< "$url")

case "$mode" in
    Save*)
        bin=$(find_tool httrack) || exit 1
        robots=""
        if ui_question "Ignore the site's robots.txt rules?
Normally they are respected."; then
            robots="-s0"
        fi
        run=$(new_run_dir httrack "$host") || exit 1
        printf 'Source URL: %s\n' "$url" >> "$run/command.txt"
        record_version "$run" httrack "$bin" --version
        # -q: never ask questions; -r: depth; output in the run folder.
        run_logged "$run" "HTTrack: $url" -- "$bin" "$url" -O "$run/mirror" -q "-r$depth" ${robots:+"$robots"}
        rc=$?
        report_outcome "$run" "$rc" HTTrack
        finish_run "$run"
        [ -f "$run/mirror/index.html" ] && open_path "$run/mirror/index.html"
        ;;
    Crawl*)
        bin=$(find_tool katana "$ARGOS_BIN_DIR/katana") || exit 1
        minutes=$(ui_entry "Stop after how many minutes?" 10) || exit 0
        case "$minutes" in ''|*[!0-9]*) minutes=10 ;; esac
        run=$(new_run_dir katana "$host") || exit 1
        printf 'Source URL: %s\n' "$url" >> "$run/command.txt"
        record_version "$run" katana "$bin" -version
        # -jc: links found inside JavaScript; -kf: robots.txt and sitemap.xml;
        # -fs rdn: stay on the site's registered domain.
        run_logged "$run" "katana: $url" -- "$bin" -u "$url" -d "$depth" -jc -kf all -fs rdn \
            -ct "${minutes}m" -j -o "$run/crawl.jsonl" -silent
        rc=$?
        if [ -f "$run/crawl.jsonl" ] && command -v jq >/dev/null 2>&1; then
            jq -r '.request.endpoint // empty' "$run/crawl.jsonl" | sort -u > "$run/urls.txt"
        fi
        report_outcome "$run" "$rc" katana
        finish_run "$run"
        ;;
esac
