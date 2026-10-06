#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Ramingo (SOsintOps)
#
# Argos launcher: find public documents of a domain and read their metadata.

set -uo pipefail
# shellcheck source=lib/argos.sh
. "$(dirname "$(readlink -f "$0")")/lib/argos.sh"
argos_init "Documents & Metadata"

METAGOOFIL_DIR="$ARGOS_TOOLS_DIR/metagoofil"

# metadata_report FOLDER RUN: write metadata.csv and people.txt into RUN.
metadata_report() {
    local folder=$1 run=$2 exiftool
    exiftool=$(find_tool exiftool) || return 1
    "$exiftool" -r -csv -q "$folder" > "$run/metadata.csv" 2>> "$run/output.log"
    # Names and software that documents reveal, with how many files show each.
    "$exiftool" -r -q -s3 -Author -Creator -LastModifiedBy -Company -Manager -Producer -CreatorTool "$folder" 2>/dev/null \
        | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | grep -v '^$' | sort | uniq -c | sort -rn > "$run/people_and_software.txt"
}

download_documents() {
    local domain py types limit run rc
    py=$(find_tool metagoofil-python "$METAGOOFIL_DIR/.venv/bin/python") || return 1
    domain=$(ui_entry "Target domain (for example example.com)") || return 0
    domain=${domain,,}
    if ! is_domain "$domain"; then
        ui_error "\"$domain\" is not a valid domain name."
        return 1
    fi
    types=$(ui_checklist "Document types to look for" \
        "pdf|PDF|on" "doc|Word (doc)|on" "docx|Word (docx)|on" "xls|Excel (xls)|on" \
        "xlsx|Excel (xlsx)|on" "ppt|PowerPoint (ppt)|on" "pptx|PowerPoint (pptx)|on" \
        "odp|OpenDocument presentation|off" "ods|OpenDocument spreadsheet|off") || return 0
    if [ -z "$types" ]; then
        ui_error "Select at least one document type."
        return 1
    fi
    limit=$(ui_entry "Maximum files to download for each type" 50) || return 0
    case "$limit" in ''|*[!0-9]*) limit=50 ;; esac

    run=$(new_run_dir metagoofil "$domain") || return 1
    mkdir -p "$run/documents"
    record_version "$run" metagoofil "$py" "$METAGOOFIL_DIR/metagoofil.py" -h
    run_logged "$run" "metagoofil: $domain (slow on purpose, to avoid search engine blocks)" -- \
        env -C "$METAGOOFIL_DIR" "$py" metagoofil.py -d "$domain" -t "$(paste -sd, <<< "$types")" \
        -n "$limit" -w -o "$run/documents" -f "$run/links.txt"
    rc=$?
    report_outcome "$run" "$rc" metagoofil
    if find "$run/documents" -type f -print -quit | grep -q .; then
        metadata_report "$run/documents" "$run"
    else
        ui_warn "No documents were downloaded, so there is no metadata to read."
    fi
    finish_run "$run"
}

folder_metadata() {
    local folder run
    folder=$(ui_dir "Folder with the documents to examine") || return 0
    run=$(new_run_dir exiftool "$(basename "$folder")") || return 1
    printf 'Source folder: %s\n' "$folder" >> "$run/command.txt"
    record_version "$run" exiftool exiftool -ver
    metadata_report "$folder" "$run"
    finish_run "$run"
}

choice=$(ui_choice "Case: $(case_name)
What do you want to do?" \
    "Find and download the public documents of a domain, then read their metadata" \
    "Read the metadata of documents already in a folder") || exit 0

case "$choice" in
    Find*) download_documents ;;
    Read*) folder_metadata ;;
esac
