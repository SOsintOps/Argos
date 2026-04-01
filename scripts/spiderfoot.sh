#!/usr/bin/env bash
# SpiderFoot Launcher
# Compatibile con: Ubuntu 24.04 LTS, Ubuntu Budgie 24.04 LTS
# SpiderFoot installato via pipx

HOST="127.0.0.1"
PORT="5001"

# Path esplicito: pipx installa in ~/.local/bin, non nel PATH di app Terminal=false
SPIDERFOOT_BIN="$HOME/.local/bin/spiderfoot"

if [ ! -x "$SPIDERFOOT_BIN" ]; then
    zenity --error --text "SpiderFoot non trovato in $SPIDERFOOT_BIN\nRieseguire setup.sh." 2> >(grep -v 'GtkDialog' >&2)
    exit 1
fi

# Avvia SpiderFoot in background se non e' gia' in ascolto su quella porta
if ! pgrep -f "spiderfoot -l" >/dev/null; then
    "$SPIDERFOOT_BIN" -l "${HOST}:${PORT}" &
    sleep 5
fi

xdg-open "http://${HOST}:${PORT}" >/dev/null 2>&1
