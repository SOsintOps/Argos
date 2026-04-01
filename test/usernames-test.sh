#!/usr/bin/env bash
# Test script per usernames.sh
# Verifica che i tool siano raggiungibili prima di aprire il menu

echo "=== Test tool username OSINT ==="

check_tool() {
    local name=$1
    local cmd=$2
    if command -v "$cmd" &>/dev/null; then
        echo "[OK]   $name ($cmd)"
    else
        echo "[FAIL] $name ($cmd) — non trovato, verificare setup.sh"
    fi
}

check_tool "Sherlock"  "sherlock"
check_tool "Maigret"   "maigret"

BLACKBIRD_VENV="$HOME/Downloads/Programs/blackbird/.venv/bin/python"
if [ -f "$BLACKBIRD_VENV" ]; then
    echo "[OK]   Blackbird (venv: $BLACKBIRD_VENV)"
else
    echo "[FAIL] Blackbird — venv non trovato in $HOME/Downloads/Programs/blackbird/.venv"
fi

echo ""
echo "Se tutti i tool mostrano [OK], avvia usernames.sh"
