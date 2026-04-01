#!/usr/bin/env bash
# Video Utilities — ffmpeg
# Compatibile con: Ubuntu 24.04 LTS, Ubuntu Budgie 24.04 LTS

FFMPEG_BIN="/usr/bin/ffmpeg"
FFPLAY_BIN="/usr/bin/ffplay"

zenity --info --text="La prossima finestra chiede di selezionare un file video" --title="Video Utilities" 2> >(grep -v 'GtkDialog' >&2)
sleep 1

ffmpeg_file=$(zenity --file-selection --title "Video Utilities" 2> >(grep -v 'GtkDialog' >&2))
timestamp=$(date +%Y-%m-%d_%H%M)

opt1="Riproduci video"
opt2="Converti in mp4"
opt3="Estrai frame"
opt4="Comprimi video (bassa attivita')"
opt5="Comprimi video (alta attivita')"
opt6="Estrai audio (mp3)"
opt7="Ruota video"

if [ -n "$ffmpeg_file" ]; then

    mkdir -p "$HOME/Videos"

    ffmpeg=$(zenity --list \
        --title "Video Utilities" \
        --text "Cosa vuoi fare?" \
        --width=400 --height=400 \
        --radiolist \
        --column "Scegli" --column "Opzione" \
        TRUE "$opt1" FALSE "$opt2" FALSE "$opt3" FALSE "$opt4" FALSE "$opt5" FALSE "$opt6" FALSE "$opt7" \
        2> >(grep -v 'GtkDialog' >&2))

    case $ffmpeg in

        "$opt1")
            "$FFPLAY_BIN" "$ffmpeg_file"
            ;;
        "$opt2")
            "$FFMPEG_BIN" -i "$ffmpeg_file" -vcodec mpeg4 "$HOME/Videos/${timestamp}.mp4" \
                | zenity --progress --pulsate --no-cancel --auto-close --title="ffmpeg" --text="Conversione in mp4..." 2> >(grep -v 'GtkDialog' >&2)
            xdg-open "$HOME/Videos/" >/dev/null 2>&1
            ;;
        "$opt3")
            mkdir -p "$HOME/Videos/${timestamp}-frames"
            "$FFMPEG_BIN" -y -i "$ffmpeg_file" -an -r 10 "$HOME/Videos/${timestamp}-frames/img%03d.bmp" \
                | zenity --progress --pulsate --no-cancel --auto-close --title="ffmpeg" --text="Estrazione frame..." 2> >(grep -v 'GtkDialog' >&2)
            xdg-open "$HOME/Videos/${timestamp}-frames/" >/dev/null 2>&1
            ;;
        "$opt4")
            "$FFMPEG_BIN" -i "$ffmpeg_file" -vf "select=gt(scene\,0.003),setpts=N/(25*TB)" "$HOME/Videos/${timestamp}-low.mp4" \
                | zenity --progress --pulsate --no-cancel --auto-close --title="ffmpeg" --text="Compressione (bassa attivita')..." 2> >(grep -v 'GtkDialog' >&2)
            xdg-open "$HOME/Videos/" >/dev/null 2>&1
            ;;
        "$opt5")
            "$FFMPEG_BIN" -i "$ffmpeg_file" -vf "select=gt(scene\,0.005),setpts=N/(25*TB)" "$HOME/Videos/${timestamp}-high.mp4" \
                | zenity --progress --pulsate --no-cancel --auto-close --title="ffmpeg" --text="Compressione (alta attivita')..." 2> >(grep -v 'GtkDialog' >&2)
            xdg-open "$HOME/Videos/" >/dev/null 2>&1
            ;;
        "$opt6")
            "$FFMPEG_BIN" -i "$ffmpeg_file" -vn -ac 2 -ar 44100 -ab 320k -f mp3 "$HOME/Videos/${timestamp}.mp3" \
                | zenity --progress --pulsate --no-cancel --auto-close --title="ffmpeg" --text="Estrazione audio..." 2> >(grep -v 'GtkDialog' >&2)
            xdg-open "$HOME/Videos/" >/dev/null 2>&1
            ;;
        "$opt7")
            "$FFMPEG_BIN" -i "$ffmpeg_file" -vf transpose=0 "$HOME/Videos/${timestamp}-rotated.mp4" \
                | zenity --progress --pulsate --no-cancel --auto-close --title="ffmpeg" --text="Rotazione video..." 2> >(grep -v 'GtkDialog' >&2)
            xdg-open "$HOME/Videos/" >/dev/null 2>&1
            ;;
    esac

else
    zenity --error --text "Nessun file selezionato, uscita" 2> >(grep -v 'GtkDialog' >&2)
    exit 1
fi
