#!/usr/bin/env bash
# EyeWitness Screenshot Tool
# Compatible with: Ubuntu 24.04 LTS, Ubuntu Budgie 24.04 LTS

[ "$XDG_SESSION_TYPE" = "wayland" ] && export GDK_BACKEND=x11

EYEWITNESS_DIR="$HOME/Downloads/Programs/EyeWitness/Python"
EYEWITNESS_BIN="$EYEWITNESS_DIR/EyeWitness.py"
OUTPUT_DIR="$HOME/Documents/EyeWitness"

if [ ! -f "$EYEWITNESS_BIN" ]; then
    zenity --error --text "EyeWitness not found in $EYEWITNESS_DIR\nRe-run setup.sh." 2> >(grep -v 'GtkDialog' >&2)
    exit 1
fi

# EyeWitness ships its own setup; use its virtualenv Python if present, otherwise
# fall back to the system python3. On Ubuntu 24.04 (PEP 668) the upstream setup may
# fail to install dependencies, so surface a clear error instead of a silent crash.
if [ -x "$EYEWITNESS_DIR/.venv/bin/python" ]; then
    PYTHON="$EYEWITNESS_DIR/.venv/bin/python"
else
    PYTHON="python3"
fi

# run_eyewitness: launch EyeWitness with the given args and report failure via zenity
run_eyewitness() {
    cd "$EYEWITNESS_DIR" || exit 1
    if ! "$PYTHON" EyeWitness.py "$@"; then
        zenity --error \
            --text "EyeWitness failed to run.\nIts dependencies may be missing (Ubuntu 24.04 / PEP 668).\nRe-run setup.sh or check the EyeWitness setup output." \
            2> >(grep -v 'GtkDialog' >&2)
        exit 1
    fi
}

mkdir -p "$OUTPUT_DIR"

opt1="Single URL"
opt2="URL list (file)"

eyewitness=$(zenity --list \
    --title "EyeWitness" \
    --text "Select input mode" \
    --width=400 --height=200 \
    --radiolist \
    --column "Select" --column "Option" \
    TRUE "$opt1" FALSE "$opt2" \
    2> >(grep -v 'GtkDialog' >&2))

case $eyewitness in

    "$opt1") # Single URL
        domain=$(zenity --entry --title "EyeWitness" --text "Enter URL (e.g. https://www.example.com)" --entry-text "" 2> >(grep -v 'GtkDialog' >&2))
        if [ -n "$domain" ]; then
            run_eyewitness --web --single "$domain" -d "$OUTPUT_DIR"
        else
            zenity --error --text "No URL entered, exiting" 2> >(grep -v 'GtkDialog' >&2)
            exit 1
        fi
        ;;

    "$opt2") # URL list
        eyewitness_file=$(zenity --file-selection --title "Select a file with a URL list" 2> >(grep -v 'GtkDialog' >&2))
        if [ -n "$eyewitness_file" ]; then
            run_eyewitness --web -f "$eyewitness_file" -d "$OUTPUT_DIR"
        else
            zenity --error --text "No file selected, exiting" 2> >(grep -v 'GtkDialog' >&2)
            exit 1
        fi
        ;;

esac
