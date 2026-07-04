#!/usr/bin/env bash
# Username Search Menu Script
# Compatible with: Ubuntu 24.04 LTS, Ubuntu Budgie 24.04 LTS
# Tools: Sherlock (pipx), Maigret (pipx), Blackbird (venv),
#        User Scanner (pipx), Linkook (pipx), Socialscan (pipx)
# Moriarty-Project removed (abandoned)

[ "$XDG_SESSION_TYPE" = "wayland" ] && export GDK_BACKEND=x11

opt1="Sherlock"
opt2="Maigret"
opt3="Blackbird"
opt4="User Scanner"
opt5="Linkook"
opt6="Socialscan"

# Explicit paths: pipx installs to ~/.local/bin, which is not in PATH for Terminal launchers
SHERLOCK_BIN="$HOME/.local/bin/sherlock"
MAIGRET_BIN="$HOME/.local/bin/maigret"
USERSCANNER_BIN="$HOME/.local/bin/user-scanner"
LINKOOK_BIN="$HOME/.local/bin/linkook"
SOCIALSCAN_BIN="$HOME/.local/bin/socialscan"

timestamp=$(date +%Y-%m-%d_%H%M)

socialmenu=$(zenity --list \
    --title "Username Search: Select Tool" \
    --text "What do you want to do?" \
    --width=400 --height=320 \
    --radiolist \
    --column "Select" --column "Option" \
    TRUE "$opt1" FALSE "$opt2" FALSE "$opt3" FALSE "$opt4" FALSE "$opt5" FALSE "$opt6" \
    2> >(grep -v 'GtkDialog' >&2))

case $socialmenu in

    "$opt1") # Sherlock
        username=$(zenity --entry --title "Sherlock" --text "Enter target username" --entry-text "" 2> >(grep -v 'GtkDialog' >&2))
        if [ -n "$username" ]; then
            mkdir -p "$HOME/Documents/sherlock"
            "$SHERLOCK_BIN" "$username" --csv -o "$HOME/Documents/sherlock/${timestamp}_${username}.csv" \
                | zenity --progress --pulsate --no-cancel --auto-close \
                    --title="Sherlock" \
                    --text="Report saved in ~/Documents/sherlock/" 2> >(grep -v 'GtkDialog' >&2)
            sleep 2
            xdg-open "$HOME/Documents/sherlock/" >/dev/null 2>&1
        else
            zenity --error --text "Username missing, exiting" 2> >(grep -v 'GtkDialog' >&2)
            exit 1
        fi
        ;;

    "$opt2") # Maigret
        username=$(zenity --entry --title "Maigret" --text "Enter target username" --entry-text "" 2> >(grep -v 'GtkDialog' >&2))
        if [ -n "$username" ]; then
            mkdir -p "$HOME/Documents/maigret"
            "$MAIGRET_BIN" "$username" \
                --html --pdf \
                -o "$HOME/Documents/maigret/${timestamp}_${username}" \
                | zenity --progress --pulsate --no-cancel --auto-close \
                    --title="Maigret" \
                    --text="Report saved in ~/Documents/maigret/" 2> >(grep -v 'GtkDialog' >&2)
            sleep 2
            xdg-open "$HOME/Documents/maigret/" >/dev/null 2>&1
        else
            zenity --error --text "Username missing, exiting" 2> >(grep -v 'GtkDialog' >&2)
            exit 1
        fi
        ;;

    "$opt3") # Blackbird
        username=$(zenity --entry --title "Blackbird" --text "Enter target username" --entry-text "" 2> >(grep -v 'GtkDialog' >&2))
        if [ -n "$username" ]; then
            VENV="$HOME/Downloads/Programs/blackbird/.venv"
            BLACKBIRD_DIR="$HOME/Downloads/Programs/blackbird"
            if [ -f "$VENV/bin/python" ]; then
                cd "$BLACKBIRD_DIR" || exit 1
                # Blackbird writes its reports to ./results inside its own directory
                "$VENV/bin/python" blackbird.py -u "$username" \
                    | zenity --progress --pulsate --no-cancel --auto-close \
                        --title="Blackbird" \
                        --text="Searching username: $username" 2> >(grep -v 'GtkDialog' >&2)
                if [ -d "$BLACKBIRD_DIR/results" ]; then
                    xdg-open "$BLACKBIRD_DIR/results/" >/dev/null 2>&1
                else
                    xdg-open "$BLACKBIRD_DIR/" >/dev/null 2>&1
                fi
            else
                zenity --error --text "Blackbird not found. Re-run setup.sh." 2> >(grep -v 'GtkDialog' >&2)
                exit 1
            fi
        else
            zenity --error --text "Username missing, exiting" 2> >(grep -v 'GtkDialog' >&2)
            exit 1
        fi
        ;;

    "$opt4") # User Scanner (username or email)
        if [ ! -x "$USERSCANNER_BIN" ]; then
            zenity --error --text "User Scanner not found. Re-run setup.sh." 2> >(grep -v 'GtkDialog' >&2)
            exit 1
        fi
        target=$(zenity --entry --title "User Scanner" --text "Enter a username or an email address" --entry-text "" 2> >(grep -v 'GtkDialog' >&2))
        if [ -n "$target" ]; then
            mkdir -p "$HOME/Documents/user-scanner"
            OUTFILE="$HOME/Documents/user-scanner/${timestamp}_${target//[@\/]/_}.json"
            # Detect email vs username to pick the right flag
            if [[ "$target" == *@* ]]; then
                SCAN_FLAG="-e"
            else
                SCAN_FLAG="-u"
            fi
            # user-scanner exports with: -f {json,csv} -o <file> (there is no --json flag)
            "$USERSCANNER_BIN" "$SCAN_FLAG" "$target" -f json -o "$OUTFILE" 2>&1 \
                | zenity --progress --pulsate --no-cancel --auto-close \
                    --title="User Scanner" \
                    --text="Scanning: $target" 2> >(grep -v 'GtkDialog' >&2)
            xdg-open "$HOME/Documents/user-scanner/" >/dev/null 2>&1
        else
            zenity --error --text "Target missing, exiting" 2> >(grep -v 'GtkDialog' >&2)
            exit 1
        fi
        ;;

    "$opt5") # Linkook
        if [ ! -x "$LINKOOK_BIN" ]; then
            zenity --error --text "Linkook not found. Re-run setup.sh." 2> >(grep -v 'GtkDialog' >&2)
            exit 1
        fi
        username=$(zenity --entry --title "Linkook" --text "Enter target username" --entry-text "" 2> >(grep -v 'GtkDialog' >&2))
        if [ -n "$username" ]; then
            OUTDIR="$HOME/Documents/linkook/${timestamp}_${username}"
            mkdir -p "$OUTDIR"
            "$LINKOOK_BIN" "$username" --output "$OUTDIR" 2>&1 \
                | zenity --progress --pulsate --no-cancel --auto-close \
                    --title="Linkook" \
                    --text="Mapping linked accounts: $username" 2> >(grep -v 'GtkDialog' >&2)
            xdg-open "$OUTDIR/" >/dev/null 2>&1
        else
            zenity --error --text "Username missing, exiting" 2> >(grep -v 'GtkDialog' >&2)
            exit 1
        fi
        ;;

    "$opt6") # Socialscan (username or email availability)
        if [ ! -x "$SOCIALSCAN_BIN" ]; then
            zenity --error --text "Socialscan not found. Re-run setup.sh." 2> >(grep -v 'GtkDialog' >&2)
            exit 1
        fi
        target=$(zenity --entry --title "Socialscan" --text "Enter a username or an email address" --entry-text "" 2> >(grep -v 'GtkDialog' >&2))
        if [ -n "$target" ]; then
            mkdir -p "$HOME/Documents/socialscan"
            OUTFILE="$HOME/Documents/socialscan/${timestamp}_${target//[@\/]/_}.json"
            "$SOCIALSCAN_BIN" "$target" --show-urls --json "$OUTFILE" 2>&1 \
                | zenity --progress --pulsate --no-cancel --auto-close \
                    --title="Socialscan" \
                    --text="Checking availability: $target" 2> >(grep -v 'GtkDialog' >&2)
            xdg-open "$HOME/Documents/socialscan/" >/dev/null 2>&1
        else
            zenity --error --text "Target missing, exiting" 2> >(grep -v 'GtkDialog' >&2)
            exit 1
        fi
        ;;

esac
