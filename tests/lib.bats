#!/usr/bin/env bats
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Ramingo (SOsintOps)
#
# Tests for launchers/lib/argos.sh.

load helpers
bats_require_minimum_version 1.5.0

setup() {
    setup_argos
    # shellcheck source=../launchers/lib/argos.sh
    . "$LAUNCHERS/lib/argos.sh"
    argos_init "Test"
}

@test "validators accept good values and reject bad ones" {
    is_username "john.doe_99"
    ! is_username "john doe"
    ! is_username "a/b"
    is_email "a.b@example.co.uk"
    ! is_email "not-an-email"
    is_domain "Example.COM"
    is_domain "sub.xn--80ak6aa92e.com"
    is_domain "example.xn--p1ai"
    ! is_domain "example"
    ! is_domain "-bad-.com"
    is_url "https://example.com/a?b=c"
    ! is_url "ftp://example.com"
    is_ipv4 "192.168.1.255"
    ! is_ipv4 "192.168.1.256"
    ! is_ipv4 "1.2.3"
    is_phone "+39 06 1234567"
    ! is_phone "12345"
    ! is_phone "+39 abc"
}

@test "safe_name keeps file names harmless" {
    [ "$(safe_name 'john doe/../etc')" = "john_doe_.._etc" ]
    [ "$(safe_name '..hidden')" = "hidden" ]
    [ "$(safe_name '')" = "target" ]
    [ "$(safe_name 'a@b.com')" = "a@b.com" ]
}

@test "a run folder belongs to the active case and starts its command.txt" {
    ARGOS_CASE=op-alpha
    dir=$(new_run_dir sherlock 'john doe')
    [[ $dir == "$ARGOS_CASES_ROOT/op-alpha/sherlock/"*"_john_doe" ]]
    grep -qx 'Case: op-alpha' "$dir/command.txt"
    grep -qx 'Target: john doe' "$dir/command.txt"
}

@test "two runs in the same second get different folders" {
    a=$(new_run_dir t x)
    b=$(new_run_dir t x)
    [ "$a" != "$b" ]
}

@test "run_logged records command, output and exit code" {
    dir=$(new_run_dir t x)
    run run_logged "$dir" "label" -- sh -c 'echo hello; exit 3'
    [ "$status" -eq 3 ]
    grep -q hello "$dir/output.log"
    grep -qx 'Exit code: 3' "$dir/command.txt"
    grep -q '^Command: sh -c' "$dir/command.txt"
}

@test "secrets never reach command.txt" {
    dir=$(new_run_dir t x)
    ARGOS_SECRETS=(s3cr3t)
    run_logged "$dir" "label" -- echo -s s3cr3t
    ! grep -q s3cr3t "$dir/command.txt"
    grep -q '<redacted>' "$dir/command.txt"
}

@test "finish_run writes hashes that verify" {
    dir=$(new_run_dir t x)
    echo data > "$dir/result.txt"
    mkdir "$dir/sub" && echo more > "$dir/sub/deep.txt"
    finish_run "$dir"
    (cd "$dir" && sha256sum -c --quiet SHA256SUMS)
    grep -q './sub/deep.txt' "$dir/SHA256SUMS"
    ! grep -q 'SHA256SUMS' <(cut -d' ' -f3 "$dir/SHA256SUMS")
}

@test "settings are stored without executing the file" {
    argos_set_config ARGOS_CASE 'x; touch /tmp/argos-pwned'
    argos_set_config ARGOS_CASE case-2
    [ "$(grep -c '^ARGOS_CASE=' "$ARGOS_CONFIG")" -eq 1 ]
    ARGOS_CASE=""
    argos_load_config
    [ "$ARGOS_CASE" = case-2 ]
    [ ! -e /tmp/argos-pwned ]
}

@test "terminal checklist returns the default keys on Enter" {
    run --separate-stderr ui_checklist "pick" "a|A|on" "b|B|off" "c|C|on" <<< ""
    [ "$status" -eq 0 ]
    [ "$output" = $'a\nc' ]
}

@test "terminal choice rejects out-of-range answers" {
    run --separate-stderr ui_choice "pick" one two <<< "5"
    [ "$status" -eq 1 ]
    run --separate-stderr ui_choice "pick" one two <<< "2"
    [ "$output" = two ]
}

@test "find_tool explains how to fix a missing tool" {
    run find_tool definitely-not-installed-tool
    [ "$status" -eq 1 ]
    [[ $output == *"Run setup.sh again"* ]]
}

@test "cancel in the progress window stops the tool and its children" {
    # zenity double: the progress dialog reads two updates, then "Cancel".
    double zenity 'case " $* " in *" --progress "*) head -n 2 >/dev/null; exit 1;; esac'
    ARGOS_UI=zenity
    dir=$(new_run_dir t x)
    start=$SECONDS
    run run_logged "$dir" "label" -- sh -c 'sleep 300 & echo $! > "$0/child.pid"; wait' "$dir"
    [ "$status" -eq 130 ]
    [ $((SECONDS - start)) -lt 20 ]
    ! kill -0 "$(cat "$dir/child.pid")" 2>/dev/null
    grep -q 'Cancelled by the user' "$dir/output.log"
    grep -qx 'Exit code: 130' "$dir/command.txt"
}

@test "list dialogs are tall enough to show every option" {
    double zenity 'for a in "$@"; do case $a in --height=*) echo "${a#--height=}" > "$BATS_TEST_TMPDIR/h";; esac; done; echo One'
    ARGOS_UI=zenity
    ui_choice "pick" 1 2 3 4 5 6 7 8 > /dev/null
    # Measured with zenity 4.2: about 220 px of title, text and buttons, 30 px per row.
    [ "$(cat "$BATS_TEST_TMPDIR/h")" -ge $((220 + 30 * 8)) ]
}

@test "cancel also works when job control is on (setsid forks)" {
    double zenity 'case " $* " in *" --progress "*) head -n 2 >/dev/null; exit 1;; esac'
    ARGOS_UI=zenity
    set -m
    dir=$(new_run_dir t x)
    start=$SECONDS
    run run_logged "$dir" "label" -- sh -c 'sleep 300 & echo $! > "$0/child.pid"; wait' "$dir"
    set +m
    [ "$status" -eq 130 ]
    [ $((SECONDS - start)) -lt 20 ]
    ! kill -0 "$(cat "$dir/child.pid")" 2>/dev/null
}

@test "the tool's exit code survives the progress window" {
    double zenity 'case " $* " in *" --progress "*) cat >/dev/null; exit 0;; esac'
    ARGOS_UI=zenity
    dir=$(new_run_dir t x)
    run run_logged "$dir" "label" -- sh -c 'echo working; sleep 1; exit 7'
    [ "$status" -eq 7 ]
    grep -q working "$dir/output.log"
}

@test "cancel works where SIGPIPE is ignored (as on CI runners)" {
    double zenity 'case " $* " in *" --progress "*) head -n 2 >/dev/null; exit 1;; esac'
    ARGOS_UI=zenity
    dir=$(new_run_dir t x)
    start=$SECONDS
    # An ignored signal stays ignored in every child process.
    run bash -c 'trap "" PIPE; . "$1/lib/argos.sh"; argos_init T; run_logged "$2" L -- sh -c "sleep 300 & echo \$! > \"\$0/child.pid\"; wait" "$2"' _ "$LAUNCHERS" "$dir"
    [ "$status" -eq 130 ]
    [ $((SECONDS - start)) -lt 20 ]
    ! kill -0 "$(cat "$dir/child.pid")" 2>/dev/null
}
