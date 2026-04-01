#!/usr/bin/env bash
# Username Search Menu Script
# Compatibile con: Ubuntu 24.04 LTS, Ubuntu Budgie 24.04 LTS
# Tool: Sherlock (pipx), Maigret (pipx), Blackbird (venv)
# Moriarty-Project rimosso (abbandonato)

opt1="Sherlock"
opt2="Maigret"
opt3="Blackbird"

timestamp=$(date +%Y-%m-%d_%H%M)

socialmenu=$(zenity --list \
    --title "Username Search: Scegli Tool" \
    --text "Cosa vuoi fare?" \
    --width=400 --height=250 \
    --radiolist \
    --column "Scegli" --column "Opzione" \
    TRUE "$opt1" FALSE "$opt2" FALSE "$opt3" \
    2> >(grep -v 'GtkDialog' >&2))

case $socialmenu in

    "$opt1") # Sherlock
        username=$(zenity --entry --title "Sherlock" --text "Inserisci username target" --entry-text "" 2> >(grep -v 'GtkDialog' >&2))
        if [ -n "$username" ]; then
            mkdir -p "$HOME/Documents/sherlock"
            "$HOME/.local/bin/sherlock" "$username" --csv -o "$HOME/Documents/sherlock/${timestamp}_${username}.csv" \
                | zenity --progress --pulsate --no-cancel --auto-close \
                    --title="Sherlock" \
                    --text="Report salvato in ~/Documents/sherlock/" 2> >(grep -v 'GtkDialog' >&2)
            sleep 2
            xdg-open "$HOME/Documents/sherlock/" >/dev/null 2>&1
        else
            zenity --error --text "Username mancante, uscita" 2> >(grep -v 'GtkDialog' >&2)
            exit 1
        fi
        ;;

    "$opt2") # Maigret
        username=$(zenity --entry --title "Maigret" --text "Inserisci username target" --entry-text "" 2> >(grep -v 'GtkDialog' >&2))
        if [ -n "$username" ]; then
            mkdir -p "$HOME/Documents/maigret"
            "$HOME/.local/bin/maigret" "$username" \
                --html --pdf \
                -o "$HOME/Documents/maigret/${timestamp}_${username}" \
                | zenity --progress --pulsate --no-cancel --auto-close \
                    --title="Maigret" \
                    --text="Report salvato in ~/Documents/maigret/" 2> >(grep -v 'GtkDialog' >&2)
            sleep 2
            xdg-open "$HOME/Documents/maigret/" >/dev/null 2>&1
        else
            zenity --error --text "Username mancante, uscita" 2> >(grep -v 'GtkDialog' >&2)
            exit 1
        fi
        ;;

    "$opt3") # Blackbird
        username=$(zenity --entry --title "Blackbird" --text "Inserisci username target" --entry-text "" 2> >(grep -v 'GtkDialog' >&2))
        if [ -n "$username" ]; then
            mkdir -p "$HOME/Documents/blackbird"
            VENV="$HOME/Downloads/Programs/blackbird/.venv"
            if [ -f "$VENV/bin/python" ]; then
                cd "$HOME/Downloads/Programs/blackbird" || exit 1
                "$VENV/bin/python" blackbird.py -u "$username" \
                    | zenity --progress --pulsate --no-cancel --auto-close \
                        --title="Blackbird" \
                        --text="Ricerca username: $username" 2> >(grep -v 'GtkDialog' >&2)
                xdg-open "$HOME/Documents/blackbird/" >/dev/null 2>&1
            else
                zenity --error --text "Blackbird non trovato. Rieseguire setup.sh." 2> >(grep -v 'GtkDialog' >&2)
                exit 1
            fi
        else
            zenity --error --text "Username mancante, uscita" 2> >(grep -v 'GtkDialog' >&2)
            exit 1
        fi
        ;;

esac
