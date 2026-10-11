#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Ramingo (SOsintOps)
#
# Argos launcher: Flowsint, graph-based investigation platform running in
# Docker containers on this computer. Its data lives in Docker volumes and
# survives a stop; the passwords are in ~/.config/argos/flowsint.env.

set -uo pipefail
# shellcheck source=lib/argos.sh
. "$(dirname "$(readlink -f "$0")")/lib/argos.sh"
argos_init "Flowsint"

FLOWSINT_DIR="$ARGOS_TOOLS_DIR/flowsint"
FLOWSINT_ENV="$ARGOS_CONFIG_DIR/flowsint.env"
URL="http://127.0.0.1:5173"

compose() {
    docker compose --env-file "$FLOWSINT_ENV" -f "$FLOWSINT_DIR/docker-compose.prod.yml" "$@"
}

# wait_for_http URL SECONDS: true once the address answers; shows progress.
wait_for_http() {
    local url=$1 seconds=$2 i
    if [ "$ARGOS_UI" = zenity ]; then
        (
            for ((i = 0; i < seconds; i++)); do
                curl -s -o /dev/null "$url" && break
                sleep 1
            done
            echo 100
        ) | zenity --progress --pulsate --auto-close --no-cancel --width=460 \
                --title "$ARGOS_TITLE" --text "Starting Flowsint (the databases take a while)..." 2>/dev/null
    else
        for ((i = 0; i < seconds; i++)); do
            curl -s -o /dev/null "$url" && break
            sleep 1
        done
    fi
    curl -s -o /dev/null "$url"
}

if [ ! -f "$FLOWSINT_DIR/docker-compose.prod.yml" ] || [ ! -f "$FLOWSINT_ENV" ]; then
    ui_error "Flowsint is not installed. Run: setup.sh flowsint"
    exit 1
fi
if ! command -v docker >/dev/null 2>&1; then
    ui_error "docker is not installed. Run: setup.sh flowsint"
    exit 1
fi
if ! docker info >/dev/null 2>&1; then
    ui_error "Docker cannot be reached by your user.
If Flowsint was just installed, log out and in again: your user joined the docker group."
    exit 1
fi

choice=$(ui_choice "Flowsint runs in Docker containers on this computer.
First visit: create your account at $URL/register" \
    "Open Flowsint (starts it when needed)" \
    "Stop Flowsint (the data is kept)") || exit 0

case "$choice" in
    Open*)
        if ! curl -s -o /dev/null "$URL"; then
            if [ -z "$(compose ps -q api 2>/dev/null)" ] && curl -s -o /dev/null http://127.0.0.1:5001; then
                ui_error "Port 5001 is used by another program (SpiderFoot?). Close it and try again."
                exit 1
            fi
            if ! compose up -d >/dev/null 2>&1; then
                ui_error "Flowsint could not start. Try in a terminal:
docker compose --env-file $FLOWSINT_ENV -f $FLOWSINT_DIR/docker-compose.prod.yml up"
                exit 1
            fi
            if ! wait_for_http "$URL" 180; then
                ui_error "Flowsint is not answering yet at $URL. Check: docker compose -f $FLOWSINT_DIR/docker-compose.prod.yml logs"
                exit 1
            fi
        fi
        open_path "$URL"
        ;;
    Stop*)
        if compose down >/dev/null 2>&1; then
            ui_info "Flowsint stopped. Its data stays in the Docker volumes."
        else
            ui_error "Flowsint could not be stopped. Check: docker compose -f $FLOWSINT_DIR/docker-compose.prod.yml ps"
            exit 1
        fi
        ;;
esac
