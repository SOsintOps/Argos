#!/usr/bin/env bash
# recon-ng Launcher
# Compatibile con: Ubuntu 24.04 LTS, Ubuntu Budgie 24.04 LTS

VENV="$HOME/Downloads/Programs/recon-ng/.venv"
RECONNG="$HOME/Downloads/Programs/recon-ng/recon-ng"

if [ ! -f "$VENV/bin/python" ]; then
    zenity --error --text "recon-ng non trovato. Rieseguire setup.sh." 2> >(grep -v 'GtkDialog' >&2)
    exit 1
fi

cd "$HOME/Downloads/Programs/recon-ng" || exit 1
"$VENV/bin/python" recon-ng
