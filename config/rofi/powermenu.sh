#!/usr/bin/env bash
# Menú de energía (rofi). Basado en los menús de adi1090x/rofi.

dir="$HOME/.config/rofi"
theme='powermenu'

uptime="$(uptime -p | sed -e 's/up //g')"

# Opciones
shutdown='⏼'
reboot='󰜉'
lock=''
suspend=''
logout='󰿅'
yes=''
no=''

rofi_cmd() {
	rofi -dmenu \
		-p "Encendido: $uptime" \
		-mesg "Encendido: $uptime" \
		-theme "${dir}/${theme}.rasi"
}

confirm_cmd() {
	rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px;}' \
		-theme-str 'mainbox {children: [ "message", "listview" ];}' \
		-theme-str 'listview {columns: 2; lines: 1;}' \
		-theme-str 'element-text {horizontal-align: 0.5;}' \
		-theme-str 'textbox {horizontal-align: 0.5;}' \
		-dmenu \
		-p 'Confirmación' \
		-mesg '¿Estás seguro?' \
		-theme "${dir}/${theme}.rasi"
}

confirm_exit() {
	echo -e "$yes\n$no" | confirm_cmd
}

run_rofi() {
	echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

# Pide confirmación; si la respuesta no es "sí", termina el script
run_cmd() {
	selected="$(confirm_exit)"
	if [[ "$selected" != "$yes" ]]; then
		exit 0
	fi
	case $1 in
		--shutdown) systemctl poweroff ;;
		--reboot)   systemctl reboot ;;
		--suspend)
			playerctl pause 2>/dev/null
			amixer set Master mute >/dev/null 2>&1
			systemctl suspend
			;;
	esac
}

chosen="$(run_rofi)"
case ${chosen} in
	"$shutdown")
		run_cmd --shutdown
		;;
	"$reboot")
		run_cmd --reboot
		;;
	"$lock")
		run_cmd
		hyprlock
		;;
	"$suspend")
		run_cmd --suspend
		hyprlock
		;;
	"$logout")
		run_cmd
		# Con la configuración en Lua, hyprctl dispatch recibe código Lua
		hyprctl dispatch 'hl.dsp.exit()'
		;;
esac
