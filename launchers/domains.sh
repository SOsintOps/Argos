#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Ramingo (SOsintOps)
#
# Argos launcher: subdomains, hosts, IPs and emails of a domain.

set -uo pipefail
# shellcheck source=lib/argos.sh
. "$(dirname "$(readlink -f "$0")")/lib/argos.sh"
argos_init "Domains"

# Sources that answer without an API key (checked with theHarvester 5.0).
HARVESTER_FREE_SOURCES="crtsh,certspotter,hackertarget,rapiddns,duckduckgo,waybackarchive,subdomaincenter,thc,urlscan,otx,robtex,mojeek,baidu,yahoo,arquivo,shodanInternetDB"

# Returns 1 when the user cancels, 2 when the value is invalid.
ask_domain() {
    local value
    value=$(ui_entry "$1 — target domain (for example example.com)") || return 1
    value=${value,,}
    value=${value#http://}
    value=${value#https://}
    value=${value%%/*}
    if ! is_domain "$value"; then
        ui_error "\"$value\" is not a valid domain name."
        return 2
    fi
    printf '%s\n' "$value"
}

has() { grep -qx -- "$1" <<< "$2"; }

# ── Amass ───────────────────────────────────────────────────────────────────

amass_run() {
    local domain=$1 bin opts minutes run args engine_before rc
    bin=$(find_tool amass "$ARGOS_BIN_DIR/amass") || return 1
    opts=$(ui_checklist "Amass — enumeration mode
Without API keys, passive sources find little: brute force is recommended.
API keys go in ~/.config/amass/datasources.yaml" \
        "brute|DNS brute force with the built-in word list|on" \
        "alts|Try altered names (dev-, -test, numbers ...)|off" \
        "active|Active checks: zone transfers and certificate grabs (contacts the target)|off") || return 0
    if has active "$opts" && ! ui_question "Active checks connect directly to the target's servers and can be logged by them.

Enable active checks?"; then
        opts=$(grep -vx active <<< "$opts")
    fi
    minutes=$(ui_entry "Amass — stop after how many minutes without new results?" 10) || return 0
    case "$minutes" in ''|*[!0-9]*) minutes=10 ;; esac

    run=$(new_run_dir amass "$domain") || return 1
    args=(enum -d "$domain" -dir "$run/amass" -timeout "$minutes" -nocolor)
    has brute "$opts" && args+=(-brute)
    has alts "$opts" && args+=(-alts)
    has active "$opts" && args+=(-active)
    record_version "$run" amass "$bin" -version
    engine_before=$(pgrep -f "amass engine" || true)
    run_logged "$run" "Amass: $domain" -- "$bin" "${args[@]}"
    rc=$?
    # Amass v5 keeps its findings in a database under ~/.config/amass:
    # export what is known about this domain into the run folder.
    "$bin" subs -d "$domain" -names -nocolor -o "$run/subdomains.txt" >/dev/null 2>&1
    "$bin" subs -d "$domain" -ip -nocolor -o "$run/subdomains_with_ips.txt" >/dev/null 2>&1
    printf 'Note: subdomains*.txt list everything Amass knows about %s, earlier runs included.\n' \
        "$domain" >> "$run/command.txt"
    # Stop the collection engine only if this run started it.
    [ -z "$engine_before" ] && pkill -f "amass engine" 2>/dev/null
    report_outcome "$run" "$rc" Amass
    finish_run "$run"
}

# ── theHarvester ────────────────────────────────────────────────────────────

harvester_run() {
    local domain=$1 bin scope sources limit run rc
    bin=$(find_tool theHarvester "$ARGOS_BIN_DIR/theHarvester") || return 1
    scope=$(ui_choice "theHarvester — sources" \
        "Free sources (no API key needed)" \
        "Everything that can find subdomains" \
        "Everything that can find email addresses" \
        "All sources (those without a key are skipped)" \
        "Choose the sources myself") || return 0
    case "$scope" in
        Free*) sources=$HARVESTER_FREE_SOURCES ;;
        *subdomains) sources=subdomains ;;
        *email*) sources=emails ;;
        All*) sources=all ;;
        *)
            sources=$(ui_entry "Comma-separated source names (see theHarvester -h)" "crtsh,certspotter") || return 0
            if [[ ! $sources =~ ^[A-Za-z0-9,-]+$ ]]; then
                ui_error "Source names may contain only letters, digits, dashes and commas."
                return 1
            fi
            ;;
    esac
    limit=$(ui_entry "theHarvester — maximum results per source" 500) || return 0
    case "$limit" in ''|*[!0-9]*) limit=500 ;; esac

    run=$(new_run_dir theharvester "$domain") || return 1
    record_version "$run" theHarvester "$bin" -h
    run_logged "$run" "theHarvester: $domain" -- env -C "$run" "$bin" \
        -d "$domain" -b "$sources" -l "$limit" -f "$run/theharvester"
    rc=$?
    # Plain lists next to the JSON, for quick reading and for other tools.
    if [ -f "$run/theharvester.json" ] && command -v jq >/dev/null 2>&1; then
        jq -r '.hosts[]? // empty' "$run/theharvester.json" | sort -u > "$run/hosts.txt"
        jq -r '.emails[]? // empty' "$run/theharvester.json" | sort -u > "$run/emails.txt"
        jq -r '.ips[]? // empty' "$run/theharvester.json" | sort -u > "$run/ips.txt"
    fi
    report_outcome "$run" "$rc" theHarvester
    finish_run "$run"
}

# ── subfinder ───────────────────────────────────────────────────────────────

subfinder_run() {
    local domain=$1 bin scope run args rc
    bin=$(find_tool subfinder "$ARGOS_BIN_DIR/subfinder") || return 1
    scope=$(ui_choice "subfinder — sources" \
        "Default sources (fast)" "All sources (slower, more results)") || return 0
    run=$(new_run_dir subfinder "$domain") || return 1
    args=(-d "$domain" -o "$run/subdomains.jsonl" -oJ -cs)
    case "$scope" in All*) args+=(-all) ;; esac
    record_version "$run" subfinder "$bin" -version
    run_logged "$run" "subfinder: $domain" -- "$bin" "${args[@]}"
    rc=$?
    if [ -f "$run/subdomains.jsonl" ] && command -v jq >/dev/null 2>&1; then
        jq -r '.host // empty' "$run/subdomains.jsonl" | sort -u > "$run/subdomains.txt"
    fi
    report_outcome "$run" "$rc" subfinder
    finish_run "$run"
}

# ── gau ─────────────────────────────────────────────────────────────────────

gau_run() {
    local domain=$1 bin opts run args
    bin=$(find_tool gau "$ARGOS_BIN_DIR/gau") || return 1
    opts=$(ui_checklist "gau — known URLs of the domain" \
        "subs|Include subdomains|on" \
        "wayback|Wayback Machine|on" "commoncrawl|Common Crawl|on" \
        "otx|AlienVault OTX|on" "urlscan|urlscan.io|on") || return 0
    run=$(new_run_dir gau "$domain") || return 1
    args=("$domain" --o "$run/urls.txt" --threads 5)
    has subs "$opts" && args+=(--subs)
    local providers
    providers=$(grep -vx subs <<< "$opts" | paste -sd, -)
    [ -n "$providers" ] && args+=(--providers "$providers")
    record_version "$run" gau "$bin" --version
    run_logged "$run" "gau: $domain" -- "$bin" "${args[@]}"
    report_outcome "$run" $? gau
    [ -f "$run/urls.txt" ] && printf 'URLs found: %s\n' "$(wc -l < "$run/urls.txt")" >> "$run/command.txt"
    finish_run "$run"
}

# ── Menu ────────────────────────────────────────────────────────────────────

choice=$(ui_choice "Case: $(case_name)
Which tool?" \
    "theHarvester — subdomains, hosts, IPs and emails from public sources" \
    "Amass — subdomain enumeration (brute force and sources)" \
    "subfinder — passive subdomains, no API key needed" \
    "gau — known URLs (Wayback Machine, Common Crawl, OTX, urlscan)" \
    "All: theHarvester, subfinder and Amass, one after the other") || exit 0

domain=$(ask_domain "Domains") || exit $(($? == 2))
case "$choice" in
    theHarvester*) harvester_run "$domain" ;;
    Amass*) amass_run "$domain" ;;
    subfinder*) subfinder_run "$domain" ;;
    gau*) gau_run "$domain" ;;
    All*)
        harvester_run "$domain"
        subfinder_run "$domain"
        amass_run "$domain"
        ;;
esac
