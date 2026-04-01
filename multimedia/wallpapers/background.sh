WALLPAPER="$HOME/Pictures/Be-quiet-Priest-sculpture-in-Venlo.jpg"

case $DESKTOP_SESSION in
"xfce")
	xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVirtual1/workspace0/last-image -s "$WALLPAPER"
	;;
"ubuntu-wayland")
	gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER"
	gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER"
	;;
"gnome" | "ubuntu")
	gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER"
	;;
"i3")
	feh --bg-scale "$WALLPAPER"
	mkdir -p ~/.config/i3
	echo "exec feh --bg-scale $WALLPAPER" >> ~/.config/i3/config
	;;
"budgie-desktop")
	gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER"
	;;
*)
	echo "Desktop non riconosciuto: $DESKTOP_SESSION"
	;;
esac

