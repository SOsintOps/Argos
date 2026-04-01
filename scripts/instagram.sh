#!/usr/bin/env bash
# Instagram OSINT Menu Script
# Instalooter rimosso (abbandonato). Tool disponibili: Instaloader, Toutatis
# Compatibile con: Ubuntu 24.04 LTS, Ubuntu Budgie 24.04 LTS

opt1="Instaloader"
opt2="Toutatis"

# Path espliciti: pipx installa in ~/.local/bin, non nel PATH di app Terminal=false
INSTALOADER_BIN="$HOME/.local/bin/instaloader"
TOUTATIS_BIN="$HOME/.local/bin/toutatis"

timestamp=$(date +%Y-%m-%d_%H%M)

socialmenu=$(zenity --list \
    --title "Instagram: Scegli Tool" \
    --text "Cosa vuoi fare?" \
    --width=400 --height=200 \
    --radiolist \
    --column "Scegli" --column "Opzione" \
    TRUE "$opt1" FALSE "$opt2" \
    2> >(grep -v 'GtkDialog' >&2))

case $socialmenu in

    "$opt1") # Instaloader
        if [ ! -x "$INSTALOADER_BIN" ]; then
            zenity --error --text "Instaloader non trovato. Rieseguire setup.sh." 2> >(grep -v 'GtkDialog' >&2)
            exit 1
        fi
        handle=$(zenity --entry --title "Instaloader" --text "Inserisci username Instagram" 2> >(grep -v 'GtkDialog' >&2))
        if [ -n "$handle" ]; then
            mkdir -p "$HOME/Documents/instaloader/$timestamp-$handle"
            cd "$HOME/Documents/instaloader/$timestamp-$handle" || exit 1
            # 2>&1 necessario: instaloader scrive su stderr, non stdout
            "$INSTALOADER_BIN" "$handle" 2>&1 \
                | zenity --progress --pulsate --no-cancel --auto-close \
                    --title="Instaloader" \
                    --text="Download profilo: $handle" 2> >(grep -v 'GtkDialog' >&2)
            xdg-open "$HOME/Documents/instaloader/$timestamp-$handle/" >/dev/null 2>&1
        else
            zenity --error --text "Nessun handle inserito, uscita" 2> >(grep -v 'GtkDialog' >&2)
            exit 1
        fi
        ;;

    "$opt2") # Toutatis
        if [ ! -x "$TOUTATIS_BIN" ]; then
            zenity --error --text "Toutatis non trovato. Rieseguire setup.sh." 2> >(grep -v 'GtkDialog' >&2)
            exit 1
        fi
        handle=$(zenity --entry --title "Toutatis" --text "Inserisci username Instagram TARGET" 2> >(grep -v 'GtkDialog' >&2))
        session=$(zenity --entry --title "Toutatis" --text "Inserisci il tuo Session ID Instagram" 2> >(grep -v 'GtkDialog' >&2))
        if [ -n "$handle" ] && [ -n "$session" ]; then
            "$TOUTATIS_BIN" -u "$handle" -s "$session"
            read -rsp $'Premi INVIO per continuare...\n'
        else
            zenity --error --text "Parametri mancanti, uscita" 2> >(grep -v 'GtkDialog' >&2)
            exit 1
        fi
        ;;

esac
