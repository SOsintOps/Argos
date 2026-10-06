#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Ramingo (SOsintOps)
#
# Argos launcher: query Shodan for exposed hosts and services.

set -uo pipefail
# shellcheck source=lib/argos.sh
. "$(dirname "$(readlink -f "$0")")/lib/argos.sh"
argos_init "Shodan"

# The Shodan CLI imports a deprecated setuptools module: hide that warning.
export PYTHONWARNINGS="ignore::UserWarning"

bin=$(find_tool shodan "$ARGOS_BIN_DIR/shodan") || exit 1

if ! "$bin" info >/dev/null 2>&1; then
    key=$(ui_secret "Shodan API key (from https://account.shodan.io)") || exit 0
    if [ -z "$key" ] || ! "$bin" init "$key" >/dev/null 2>&1; then
        ui_error "Shodan did not accept the API key."
        exit 1
    fi
    ui_info "API key saved. Shodan is ready."
fi

choice=$(ui_choice "Case: $(case_name)
What do you want to do?" \
    "Search (results saved as compressed JSON and CSV)" \
    "Everything Shodan knows about an IP address" \
    "Subdomains and DNS records of a domain" \
    "Count the results of a search (uses no query credits)" \
    "My account: plan and remaining credits") || exit 0

case "$choice" in
    Search*)
        query=$(ui_entry "Shodan query (for example: org:\"Example\" port:443, or product:nginx country:IT)") || exit 0
        [ -n "$query" ] || exit 0
        limit=$(ui_entry "Maximum results (each 100 results use one query credit)" 100) || exit 0
        case "$limit" in ''|*[!0-9]*) limit=100 ;; esac
        run=$(new_run_dir shodan "$query") || exit 1
        run_logged "$run" "Shodan: $query" -- "$bin" download --limit "$limit" "$run/results" "$query"
        rc=$?
        if [ -f "$run/results.json.gz" ]; then
            "$bin" parse --fields ip_str,port,transport,org,isp,asn,hostnames,domains,location.country_code,location.city,product,version,timestamp \
                --separator , "$run/results.json.gz" > "$run/results.csv" 2>> "$run/output.log"
        fi
        ;;
    Everything*)
        ip=$(ui_entry "IPv4 address") || exit 0
        if ! is_ipv4 "$ip"; then ui_error "\"$ip\" is not an IPv4 address."; exit 1; fi
        run=$(new_run_dir shodan-host "$ip") || exit 1
        run_logged "$run" "Shodan host: $ip" -- "$bin" host --history "$ip"
        rc=$?
        ;;
    Subdomains*)
        domain=$(ui_entry "Domain") || exit 0
        if ! is_domain "$domain"; then ui_error "\"$domain\" is not a valid domain name."; exit 1; fi
        run=$(new_run_dir shodan-domain "$domain") || exit 1
        run_logged "$run" "Shodan domain: $domain" -- "$bin" domain "$domain"
        rc=$?
        ;;
    Count*)
        query=$(ui_entry "Shodan query") || exit 0
        [ -n "$query" ] || exit 0
        run=$(new_run_dir shodan-count "$query") || exit 1
        run_logged "$run" "Shodan count: $query" -- "$bin" count "$query"
        rc=$?
        ;;
    My*)
        out=$(mktemp)
        "$bin" info > "$out" 2>&1
        ui_text_file "$out"
        rm -f "$out"
        exit 0
        ;;
esac

report_outcome "$run" "$rc" Shodan
finish_run "$run"
[ "$ARGOS_UI" = zenity ] && [ "$rc" -eq 0 ] && ui_text_file "$run/output.log"
