#!/usr/bin/env bats
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Ramingo (SOsintOps)
#
# Tests for the launchers, run in terminal mode against test doubles.

load helpers

setup() { setup_argos; }

# ── Usernames & Emails ──────────────────────────────────────────────────────

@test "sherlock: default reports, results hashed in the run folder" {
    double sherlock 'while [ $# -gt 0 ]; do [ "$1" = --folderoutput ] && echo found > "$2/johndoe.csv"; shift; done'
    run bash "$LAUNCHERS/usernames.sh" < <(answers 1 johndoe "")
    [ "$status" -eq 0 ]
    call=$(grep '^sherlock johndoe' "$CALLS")
    [[ $call == *"--csv"* && $call == *"--txt"* && $call != *"--xlsx"* && $call != *"--nsfw"* ]]
    dir=$(only_run_dir sherlock)
    [ "$(arg_after --folderoutput "$call")" = "$dir" ]
    grep -q './johndoe.csv' "$dir/SHA256SUMS"
    grep -qx 'Exit code: 0' "$dir/command.txt"
}

@test "usernames: an invalid username creates nothing" {
    double sherlock
    run bash "$LAUNCHERS/usernames.sh" < <(answers 1 "john doe")
    [ "$status" -eq 1 ]
    [[ $output == *"not a valid username"* ]]
    [ ! -s "$CALLS" ]
    [ ! -d "$ARGOS_CASES_ROOT" ]
}

@test "usernames: cancelling the prompt runs nothing" {
    double sherlock
    run bash "$LAUNCHERS/usernames.sh" < <(answers 1)
    [ "$status" -eq 0 ]
    [ ! -s "$CALLS" ]
}

@test "maigret: HTML, PDF and JSON reports on the top sites by default" {
    double maigret
    run bash "$LAUNCHERS/usernames.sh" < <(answers 2 johndoe "" "")
    call=$(grep '^maigret johndoe' "$CALLS")
    [[ $call == *"--html"* && $call == *"--pdf"* && $call == *"--json simple"* ]]
    [[ $call != *"--all-sites"* ]]
}

@test "maigret: all sites when chosen" {
    double maigret
    run bash "$LAUNCHERS/usernames.sh" < <(answers 2 johndoe "" 2)
    grep -q -- '--all-sites' "$CALLS"
}

@test "blackbird: email search and its reports moved into the case" {
    double "$ARGOS_TOOLS_DIR/blackbird/.venv/bin/python" \
        'mkdir -p results/jd_report && echo r > results/jd_report/report.csv'
    run bash "$LAUNCHERS/usernames.sh" < <(answers 4 jd@example.com "")
    grep -q -- '--email jd@example.com' "$CALLS"
    ! grep -q -- '--ai' "$CALLS"
    dir=$(only_run_dir blackbird)
    [ -f "$dir/jd_report/report.csv" ]
    [ ! -e "$ARGOS_TOOLS_DIR/blackbird/results/jd_report" ]
    grep -q './jd_report/report.csv' "$dir/SHA256SUMS"
}

@test "user scanner: loud checks stay off when the warning is declined" {
    double user-scanner
    run bash "$LAUNCHERS/usernames.sh" < <(answers 5 johndoe 1 4 n)
    call=$(grep '^user-scanner' "$CALLS")
    [[ $call == *"--username johndoe"* && $call == *"--format json"* ]]
    [[ $call != *"--allow-loud"* ]]
}

@test "user scanner: third-party lookup only after consent" {
    double user-scanner
    run bash "$LAUNCHERS/usernames.sh" < <(answers 5 johndoe 1 3 y)
    grep -q -- '--hudson' "$CALLS"
}

@test "socialscan: JSON report in the run folder" {
    double socialscan
    run bash "$LAUNCHERS/usernames.sh" < <(answers 7 jd@example.com)
    dir=$(only_run_dir socialscan)
    [ "$(arg_after --json "$(cat "$CALLS")")" = "$dir/socialscan.json" ]
}

# ── Domains ─────────────────────────────────────────────────────────────────

@test "theHarvester: free sources, normalised domain, plain lists" {
    double theHarvester 'while [ $# -gt 0 ]; do [ "$1" = -f ] && echo "{\"hosts\":[\"b.example.com\",\"a.example.com\"],\"emails\":[]}" > "$2.json"; shift; done'
    run bash "$LAUNCHERS/domains.sh" < <(answers 1 "https://Example.COM/path" "" "")
    call=$(grep -v '^theHarvester -h' "$CALLS" | grep '^theHarvester')
    [[ $call == *"-d example.com"* && $call == *"-b crtsh,certspotter"* && $call == *"-l 500"* ]]
    dir=$(only_run_dir theharvester)
    if command -v jq >/dev/null; then
        [ "$(cat "$dir/hosts.txt")" = $'a.example.com\nb.example.com' ]
    fi
}

@test "amass: brute force by default, results exported, engine stopped" {
    double amass
    run bash "$LAUNCHERS/domains.sh" < <(answers 2 example.com "" "")
    grep -q '^amass enum -d example.com .*-brute' "$CALLS"
    grep -q '^amass subs -d example.com -names' "$CALLS"
    grep -q '^amass subs -d example.com -ip' "$CALLS"
    ! grep -q -- '-active' "$CALLS"
}

@test "domains: an invalid domain is refused" {
    double theHarvester
    run bash "$LAUNCHERS/domains.sh" < <(answers 1 "not a domain")
    [[ $output == *"not a valid domain"* ]]
    [ ! -s "$CALLS" ]
}

# ── Instagram ───────────────────────────────────────────────────────────────

@test "instaloader: profile without @, no browser session unless chosen" {
    double instaloader
    run bash "$LAUNCHERS/instagram.sh" < <(answers 1 "@some.one" "")
    call=$(grep '^instaloader some.one' "$CALLS")
    [[ $call == *"--dirname-pattern"* && $call != *"--load-cookies"* ]]
}

@test "instaloader: the Firefox session uses the newest cookie database" {
    double instaloader
    mkdir -p "$HOME/.mozilla/firefox/old.default" "$HOME/snap/firefox/common/.mozilla/firefox/new.default"
    touch -d '2026-01-01' "$HOME/.mozilla/firefox/old.default/cookies.sqlite"
    touch "$HOME/snap/firefox/common/.mozilla/firefox/new.default/cookies.sqlite"
    run bash "$LAUNCHERS/instagram.sh" < <(answers 1 someone "1 5 6")
    call=$(grep '^instaloader someone' "$CALLS")
    [ "$(arg_after --cookiefile "$call")" = "$HOME/snap/firefox/common/.mozilla/firefox/new.default/cookies.sqlite" ]
    [[ $call == *"--load-cookies firefox"* && $call == *"--stories"* ]]
}

@test "instaloader: a clear error when Firefox has no profile" {
    double instaloader
    run bash "$LAUNCHERS/instagram.sh" < <(answers 1 someone "1 5")
    [[ $output == *"No Firefox profile found"* ]]
    [ ! -s "$CALLS" ]
}

@test "toutatis: the session ID never reaches the evidence files" {
    double toutatis 'echo "user info for $2"'
    run bash "$LAUNCHERS/instagram.sh" < <(answers 2 someone SESSIONXYZ123)
    dir=$(only_run_dir toutatis)
    ! grep -rq SESSIONXYZ123 "$dir"
    grep -q '<redacted>' "$dir/command.txt"
}

# ── Cases ───────────────────────────────────────────────────────────────────

@test "case: create, then results go into it" {
    run bash "$LAUNCHERS/case.sh" < <(answers 1 op-alpha "fraud check")
    [ "$status" -eq 0 ]
    grep -qx 'ARGOS_CASE=op-alpha' "$ARGOS_CONFIG_DIR/argos.conf"
    grep -qx 'Description: fraud check' "$ARGOS_CASES_ROOT/op-alpha/case.txt"
    double socialscan
    run bash "$LAUNCHERS/usernames.sh" < <(answers 7 johndoe)
    [ -d "$ARGOS_CASES_ROOT/op-alpha/socialscan" ]
}

@test "case: a new case starts from the installed skeleton" {
    export ARGOS_HOME="$BATS_TEST_TMPDIR/argos-home"
    mkdir -p "$ARGOS_HOME/case-skeleton/notes"
    cp "$REPO/templates/Argos_Research_Log.csv" "$ARGOS_HOME/case-skeleton/notes/"
    run bash "$LAUNCHERS/case.sh" < <(answers 1 op-bravo "")
    [ -f "$ARGOS_CASES_ROOT/op-bravo/notes/Argos_Research_Log.csv" ]
    [ -f "$ARGOS_CASES_ROOT/op-bravo/case.txt" ]
}

@test "case: names with spaces or slashes are refused" {
    run bash "$LAUNCHERS/case.sh" < <(answers 1 "../evil")
    [[ $output == *"not a valid case name"* ]]
    [ ! -e "$ARGOS_CONFIG_DIR/argos.conf" ]
}

@test "case: switch between existing cases" {
    mkdir -p "$ARGOS_CASES_ROOT/alpha" "$ARGOS_CASES_ROOT/bravo"
    run bash "$LAUNCHERS/case.sh" < <(answers 2 2)
    grep -qx 'ARGOS_CASE=bravo' "$ARGOS_CONFIG_DIR/argos.conf"
}

# ── Video tools ─────────────────────────────────────────────────────────────

@test "video tools: conversion records the source hash" {
    double ffmpeg
    printf 'fake video' > "$BATS_TEST_TMPDIR/clip.avi"
    run bash "$LAUNCHERS/video-tools.sh" < <(answers "$BATS_TEST_TMPDIR/clip.avi" 3)
    grep -q 'libx264' "$CALLS"
    dir=$(only_run_dir video-tools)
    grep -qx "Source SHA-256: $(sha256sum "$BATS_TEST_TMPDIR/clip.avi" | cut -d' ' -f1)" "$dir/command.txt"
}

@test "video tools: a cut with a bad time is refused" {
    double ffmpeg
    printf 'fake video' > "$BATS_TEST_TMPDIR/clip.avi"
    run bash "$LAUNCHERS/video-tools.sh" < <(answers "$BATS_TEST_TMPDIR/clip.avi" 8 "1; rm -rf ~" 10)
    [[ $output == *"Times must be"* ]]
    [ ! -s "$CALLS" ]
}

@test "yt-dlp: Firefox session passed as a profile folder" {
    double yt-dlp
    mkdir -p "$HOME/snap/firefox/common/.mozilla/firefox/p.default"
    touch "$HOME/snap/firefox/common/.mozilla/firefox/p.default/cookies.sqlite"
    run bash "$LAUNCHERS/video-download.sh" < <(answers "https://www.youtube.com/watch?v=x" 1 "1 7")
    call=$(grep -v -- '--version' "$CALLS" | grep '^yt-dlp')
    [ "$(arg_after --cookies-from-browser "$call")" = "firefox:$HOME/snap/firefox/common/.mozilla/firefox/p.default" ]
    [[ $call == *"--no-playlist"* ]]
}

# ── Others ──────────────────────────────────────────────────────────────────

@test "shodan: search downloads results and builds a CSV" {
    double shodan 'case "$1" in download) echo x > "$4.json.gz";; parse) echo "ip_str,port";; esac'
    run bash "$LAUNCHERS/shodan.sh" < <(answers 1 "product:nginx" 100)
    grep -q '^shodan download --limit 100 .*/results product:nginx' "$CALLS"
    dir=$(only_run_dir shodan)
    grep -q ip_str "$dir/results.csv"
}

@test "phoneinfoga: number normalised before the scan" {
    double phoneinfoga
    run bash "$LAUNCHERS/phoneinfoga.sh" < <(answers 2 "+39 (06) 123-4567")
    grep -q '^phoneinfoga scan -n +39061234567' "$CALLS"
}

@test "website mirror: robots.txt respected unless the user says otherwise" {
    double httrack
    run bash "$LAUNCHERS/website-mirror.sh" < <(answers 1 https://example.com/ 2 n)
    grep -q '^httrack https://example.com/ -O .*/mirror -q -r2$' "$CALLS"
}

@test "subfinder: JSON output with sources, plain list extracted" {
    double subfinder 'while [ $# -gt 0 ]; do [ "$1" = -o ] && echo "{\"host\":\"a.example.com\",\"sources\":[\"crtsh\"]}" > "$2"; shift; done'
    run bash "$LAUNCHERS/domains.sh" < <(answers 3 example.com 1)
    grep -q '^subfinder -d example.com -o .*/subdomains.jsonl -oJ -cs$' "$CALLS"
    dir=$(only_run_dir subfinder)
    if command -v jq >/dev/null; then [ "$(cat "$dir/subdomains.txt")" = a.example.com ]; fi
}

@test "gau: chosen providers and subdomains" {
    double gau
    run bash "$LAUNCHERS/domains.sh" < <(answers 4 example.com "1 2 4")
    grep -q '^gau example.com --o .*/urls.txt --threads 5 --timeout 120 --retries 2 --verbose --subs --providers wayback,otx$' "$CALLS"
    [[ $output == *"gau found no URLs"* ]]
}

@test "katana: crawl limited to the site, JSONL in the run folder" {
    double katana
    run bash "$LAUNCHERS/website-mirror.sh" < <(answers 2 https://example.com/ 2 5)
    call=$(grep -v -- '-version' "$CALLS" | grep '^katana')
    [[ $call == *"-u https://example.com/ -d 2"* && $call == *"-fs rdn"* && $call == *"-ct 5m"* ]]
    dir=$(only_run_dir katana)
    [ "$(arg_after -o "$call")" = "$dir/crawl.jsonl" ]
}

@test "phone: offline analysis runs the helper with the normalised number" {
    double "$ARGOS_TOOLS_DIR/phonenumbers/.venv/bin/python"
    run bash "$LAUNCHERS/phoneinfoga.sh" < <(answers 1 "+39 06 1234567")
    grep -q 'phone_info.py +39061234567 .*/phone.json$' "$CALLS"
}

@test "phone: Telegram check asks consent, session kept outside the case" {
    double telegram-phone-number-checker 'echo "cwd=$PWD"'
    run bash "$LAUNCHERS/phoneinfoga.sh" < <(answers 3 "+39 06 1234567" n)
    [ ! -s "$CALLS" ]
    run bash "$LAUNCHERS/phoneinfoga.sh" < <(answers 3 "+39 06 1234567" y)
    grep -q '^telegram-phone-number-checker --phone-numbers +39061234567 --output .*/telegram.json$' "$CALLS"
    dir=$(only_run_dir telegram)
    grep -q "cwd=$ARGOS_CONFIG_DIR/telegram" "$dir/output.log"
}

@test "check: missing tools are reported and the exit code says so" {
    run bash "$LAUNCHERS/check.sh"
    [ "$status" -ne 0 ]
    [[ $output == *"sherlock"*"MISSING"* ]]
}

@test "setup.sh lists its steps without installing anything" {
    run bash "$REPO/setup.sh" --list
    [ "$status" -eq 0 ]
    [[ $output == *"launchers"* && $output == *"amass"* ]]
}

@test "domains: the All choice runs theHarvester, subfinder and Amass" {
    double theHarvester; double subfinder; double amass
    run bash "$LAUNCHERS/domains.sh" < <(answers 5 example.com "" "" 1 "" "")
    grep -q '^theHarvester -d example.com' "$CALLS"
    grep -q '^subfinder -d example.com' "$CALLS"
    grep -q '^amass enum -d example.com' "$CALLS"
}
