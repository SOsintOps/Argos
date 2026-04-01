#!/usr/bin/env bash
# EyeWitness Screenshot Tool
# Compatibile con: Ubuntu 24.04 LTS, Ubuntu Budgie 24.04 LTS

EYEWITNESS_DIR="$HOME/Downloads/Programs/EyeWitness/Python"
EYEWITNESS_BIN="$EYEWITNESS_DIR/EyeWitness.py"
OUTPUT_DIR="$HOME/Documents/EyeWitness"

if [ ! -f "$EYEWITNESS_BIN" ]; then
    zenity --error --text "EyeWitness non trovato in $EYEWITNESS_DIR\nRieseguire setup.sh." 2> >(grep -v 'GtkDialog' >&2)
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

opt1="URL singolo"
opt2="Lista URL (file)"

eyewitness=$(zenity --list \
    --title "EyeWitness" \
    --text "Modalita' di input?" \
    --width=400 --height=200 \
    --radiolist \
    --column "Scegli" --column "Opzione" \
    TRUE "$opt1" FALSE "$opt2" \
    2> >(grep -v 'GtkDialog' >&2))

case $eyewitness in

    "$opt1") # URL singolo
        domain=$(zenity --entry --title "EyeWitness" --text "Inserisci URL (es: https://www.example.com)" --entry-text "" 2> >(grep -v 'GtkDialog' >&2))
        if [ -n "$domain" ]; then
            cd "$EYEWITNESS_DIR" || exit 1
            python3 EyeWitness.py --web --single "$domain" -d "$OUTPUT_DIR"
        else
            zenity --error --text "Nessun URL inserito, uscita" 2> >(grep -v 'GtkDialog' >&2)
            exit 1
        fi
        ;;

    "$opt2") # Lista URL
        eyewitness_file=$(zenity --file-selection --title "Seleziona file con lista URL" 2> >(grep -v 'GtkDialog' >&2))
        if [ -n "$eyewitness_file" ]; then
            cd "$EYEWITNESS_DIR" || exit 1
            python3 EyeWitness.py --web -f "$eyewitness_file" -d "$OUTPUT_DIR"
        else
            zenity --error --text "Nessun file selezionato, uscita" 2> >(grep -v 'GtkDialog' >&2)
            exit 1
        fi
        ;;

esac
