#!/usr/bin/env bash
#Script for ffmpeg interaction

zenity --info --text="The next window will prompt for a target media file" --title="Video Utilities"

sleep 1

#prompt for file selection
ffmpeg_file=$(zenity --file-selection --title "Video Utilities")
timestamp=$(date +%Y-%m-%d:%H:%M)

#define choices
opt1="Play a video"
opt2="Convert a video to mp4"
opt3="Extract video frames"
opt4="Shorten a video (Low Activity)"
opt5="Shorten a video (High Activity)"
opt6="Extract Audio"
opt7="Rotate Video"

#make sure file is selected
if [ -n "$ffmpeg_file" ]; then

        #prompt for user choice selection
        ffmpeg=$(zenity  --list  --title "Video Utilities" --text "What do you want to do?" --width=400 --height=400 --radiolist  --column "Choose" --column "Option" TRUE "$opt1" FALSE "$opt2" FALSE "$opt3" FALSE "$opt4" FALSE "$opt5" FALSE "$opt6" FALSE "$opt7")

        #perform actions based on selection
        case $ffmpeg in

        $opt1 )
          ffplay "$ffmpeg_file"
          ;;
        $opt2 )
          ffmpeg -i "$ffmpeg_file" -vcodec mpeg4 -strict -2 "/home/osint/Videos/$timestamp.mp4" | zenity --progress --pulsate --no-cancel --auto-close --title="ffmpeg" --text="Converting Video to mp4"
           nautilus "/home/osint/Videos/" >/dev/null 2>&1
          ;;
        $opt3 )
          mkdir "/home/osint/Videos/$timestamp-frames"
          ffmpeg -y -i "$ffmpeg_file" -an -r 10 "/home/osint/Videos/$timestamp-frames/img%03d.bmp" | zenity --progress --pulsate --no-cancel --auto-close --title="ffmpeg" --text="Extracting Frames"
          nautilus "/home/osint/Videos/" >/dev/null 2>&1
          ;;
        $opt4 )
          ffmpeg -i "$ffmpeg_file" -strict -2 -vf "select=gt(scene\,0.003),setpts=N/(25*TB)" "/home/osint/Videos/$timestamp-low.mp4" | zenity --progress --pulsate --no-cancel --auto-close --title="ffmpeg" --text="Shortening video (Low Activity)"
          nautilus "/home/osint/Videos/" >/dev/null 2>&1
          ;;
        $opt5 )
          ffmpeg -i "$ffmpeg_file" -strict -2 -vf "select=gt(scene\,0.005),setpts=N/(25*TB)" "/home/osint/Videos/$timestamp-high.mp4" | zenity --progress --pulsate --no-cancel --auto-close --title="ffmpeg" --text="Shortening video (High Activity)"
          nautilus "/home/osint/Videos/" >/dev/null 2>&1
          ;;
        $opt6 )
          ffmpeg -i "$ffmpeg_file" -vn -ac 2 -ar 44100 -ab 320k -f mp3 "/home/osint/Videos/$timestamp.mp3" | zenity --progress --pulsate --no-cancel --auto-close --title="ffmpeg" --text="Extracting Audio"
           nautilus "/home/osint/Videos/" >/dev/null 2>&1
	  ;;
        $opt7 )
          ffmpeg -i "$ffmpeg_file" -vf transpose=0 "/home/osint/Videos/$timestamp.mp4" | zenity --progress --pulsate --no-cancel --auto-close --title="ffmpeg" --text="Rotating Video"
           nautilus "/home/osint/Videos/" >/dev/null 2>&1
        esac

else
    zenity --error --text "No file selected, exiting"
    exit
fi
