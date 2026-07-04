#!/usr/bin/env bash
# Domain Recon Menu Script
# Sublist3r and Photon removed (abandoned). Available tools: Amass, theHarvester
# Compatible with: Ubuntu 24.04 LTS, Ubuntu Budgie 24.04 LTS

[ "$XDG_SESSION_TYPE" = "wayland" ] && export GDK_BACKEND=x11

opt1="Amass"
opt2="TheHarvester"

timestamp=$(date +%Y-%m-%d_%H%M)
fqdnregex="\b((xn--)?[a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}\b"

domainmenu=$(zenity --list \
    --title "Domain Tool" \
    --text "What do you want to do?" \
    --width=400 --height=250 \
    --radiolist \
    --column "Select" --column "Option" \
    TRUE "$opt1" FALSE "$opt2" \
    2> >(grep -v 'GtkDialog' >&2))

case $domainmenu in

    "$opt1") # Amass
        domain=$(zenity --entry --title "Amass" --text "Enter target domain" --entry-text "" 2> >(grep -v 'GtkDialog' >&2))
        if [ -n "$domain" ]; then
            if [[ $domain =~ $fqdnregex ]]; then
                mkdir -p "$HOME/Documents/Amass"
                amass enum -brute -d "$domain" \
                    -o "$HOME/Documents/Amass/${timestamp}-${domain}.txt" \
                    | zenity --progress --pulsate --no-cancel --auto-close \
                        --title="Amass" \
                        --text="Subdomain enumeration: $domain" 2> >(grep -v 'GtkDialog' >&2)
                sleep 3
                xdg-open "$HOME/Documents/Amass/" >/dev/null 2>&1
            else
                zenity --error --text "Invalid domain, exiting" 2> >(grep -v 'GtkDialog' >&2)
                exit 1
            fi
        fi
        ;;

    "$opt2") # TheHarvester
        domain=$(zenity --entry --title "TheHarvester" --text "Enter target domain" --entry-text "" 2> >(grep -v 'GtkDialog' >&2))
        if [ -n "$domain" ]; then
            if [[ $domain =~ $fqdnregex ]]; then
                VENV="$HOME/Downloads/Programs/theHarvester/.venv"
                if [ ! -f "$VENV/bin/python" ]; then
                    zenity --error --text "theHarvester not found. Re-run setup.sh." 2> >(grep -v 'GtkDialog' >&2)
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
                        --text="Harvesting data: $domain" 2> >(grep -v 'GtkDialog' >&2)
                if [ -f "$OUTFILE" ]; then
                    xdg-open "$OUTFILE" >/dev/null 2>&1
                fi
            else
                zenity --error --text "Invalid domain, exiting" 2> >(grep -v 'GtkDialog' >&2)
                exit 1
            fi
        fi
        ;;

esac
