#!/usr/bin/env bash
# Domain Recon Menu Script
# Sublist3r e Photon rimossi (abbandonati). Tool disponibili: Amass, theHarvester
# Compatibile con: Ubuntu 24.04 LTS, Ubuntu Budgie 24.04 LTS

opt1="Amass"
opt2="TheHarvester"

timestamp=$(date +%Y-%m-%d_%H%M)
fqdnregex="\b((xn--)?[a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}\b"

domainmenu=$(zenity --list \
    --title "Domain Tool" \
    --text "Cosa vuoi fare?" \
    --width=400 --height=250 \
    --radiolist \
    --column "Scegli" --column "Opzione" \
    TRUE "$opt1" FALSE "$opt2" \
    2> >(grep -v 'GtkDialog' >&2))

case $domainmenu in

    "$opt1") # Amass
        domain=$(zenity --entry --title "Amass" --text "Inserisci il dominio target" --entry-text "" 2> >(grep -v 'GtkDialog' >&2))
        if [ -n "$domain" ]; then
            if [[ $domain =~ $fqdnregex ]]; then
                mkdir -p "$HOME/Documents/Amass"
                amass enum -src -brute -d "$domain" \
                    -o "$HOME/Documents/Amass/${timestamp}-${domain}.txt" \
                    | zenity --progress --pulsate --no-cancel --auto-close \
                        --title="Amass" \
                        --text="Enumerazione sottodomini: $domain" 2> >(grep -v 'GtkDialog' >&2)
                sleep 3
                xdg-open "$HOME/Documents/Amass/" >/dev/null 2>&1
            else
                zenity --error --text "Dominio non valido, uscita" 2> >(grep -v 'GtkDialog' >&2)
                exit 1
            fi
        fi
        ;;

    "$opt2") # TheHarvester
        domain=$(zenity --entry --title "TheHarvester" --text "Inserisci il dominio target" --entry-text "" 2> >(grep -v 'GtkDialog' >&2))
        if [ -n "$domain" ]; then
            if [[ $domain =~ $fqdnregex ]]; then
                VENV="$HOME/Downloads/Programs/theHarvester/.venv"
                if [ ! -f "$VENV/bin/python" ]; then
                    zenity --error --text "theHarvester non trovato. Rieseguire setup.sh." 2> >(grep -v 'GtkDialog' >&2)
                    exit 1
                fi
                mkdir -p "$HOME/Documents/theHarvester"
                OUTFILE="$HOME/Documents/theHarvester/${timestamp}-${domain}.html"
                "$VENV/bin/python" "$HOME/Downloads/Programs/theHarvester/theHarvester.py" \
                    -d "$domain" \
                    -b bing,yahoo,virustotal \
                    -f "$OUTFILE" \
                    2>&1 | zenity --progress --pulsate --no-cancel --auto-close \
                        --title="TheHarvester" \
                        --text="Raccolta dati: $domain" 2> >(grep -v 'GtkDialog' >&2)
                if [ -f "$OUTFILE" ]; then
                    xdg-open "$OUTFILE" >/dev/null 2>&1
                fi
            else
                zenity --error --text "Dominio non valido, uscita" 2> >(grep -v 'GtkDialog' >&2)
                exit 1
            fi
        fi
        ;;

esac
