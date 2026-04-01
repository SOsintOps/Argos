#!/usr/bin/env bash
# Metagoofil Menu Script
# Compatibile con: Ubuntu 24.04 LTS, Ubuntu Budgie 24.04 LTS

[ "$XDG_SESSION_TYPE" = "wayland" ] && export GDK_BACKEND=x11

VENV="$HOME/Downloads/Programs/metagoofil/.venv"
METAGOOFIL="$HOME/Downloads/Programs/metagoofil/metagoofil.py"

if [ ! -f "$VENV/bin/python" ]; then
    zenity --error --text "Metagoofil non trovato. Rieseguire setup.sh." 2> >(grep -v 'GtkDialog' >&2)
    exit 1
fi

opt1="Metagoofil"
opt2="Metagoofil + ExifTool"

timestamp=$(date +%Y-%m-%d_%H%M)
fqdnregex="\b((xn--)?[a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}\b"

domainmenu=$(zenity --list \
    --title "Metagoofil: Scegli modalita'" \
    --text "Cosa vuoi fare?" \
    --width=400 --height=300 \
    --radiolist \
    --column "Scegli" --column "Opzione" \
    TRUE "$opt1" FALSE "$opt2" \
    2> >(grep -v 'GtkDialog' >&2))

# Variabile globale per evitare il bug di cattura stdout con $()
DOCS_DIR=""

run_metagoofil() {
    local domain=$1
    DOCS_DIR="$HOME/Documents/Metagoofil/${timestamp}_docs_${domain}"
    mkdir -p "$DOCS_DIR"
    "$VENV/bin/python" "$METAGOOFIL" \
        -d "$domain" -w \
        -t pdf,doc,xls,ppt,docx,xlsx,pptx \
        -o "$DOCS_DIR"
}

case $domainmenu in

    "$opt1") # Metagoofil solo
        domain=$(zenity --entry --title "Metagoofil" --text "Inserisci dominio target" --entry-text "" 2> >(grep -v 'GtkDialog' >&2))
        if [ -n "$domain" ] && [[ $domain =~ $fqdnregex ]]; then
            run_metagoofil "$domain"
            sleep 1
            xdg-open "$HOME/Documents/Metagoofil/" >/dev/null 2>&1
        else
            zenity --error --text "Dominio non valido, uscita" 2> >(grep -v 'GtkDialog' >&2)
            exit 1
        fi
        ;;

    "$opt2") # Metagoofil + ExifTool
        domain=$(zenity --entry --title "Metagoofil + ExifTool" --text "Inserisci dominio target" --entry-text "" 2> >(grep -v 'GtkDialog' >&2))
        if [ -n "$domain" ] && [[ $domain =~ $fqdnregex ]]; then
            run_metagoofil "$domain"
            results_dir="$HOME/Documents/Metagoofil/${timestamp}_results_${domain}"
            mkdir -p "$results_dir"
            sleep 1
            if find "$DOCS_DIR" -maxdepth 1 -type f | grep -q .; then
                exiftool -r "$DOCS_DIR" -csv > "$results_dir/Report.csv" 2>/dev/null
                xdg-open "$HOME/Documents/Metagoofil/" >/dev/null 2>&1
            else
                zenity --warning --text "Nessun file trovato per ExifTool." 2> >(grep -v 'GtkDialog' >&2)
            fi
        else
            zenity --error --text "Dominio non valido, uscita" 2> >(grep -v 'GtkDialog' >&2)
            exit 1
        fi
        ;;

esac
