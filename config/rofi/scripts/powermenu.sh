#!/usr/bin/env bash

dir="${HOME}/.config/rofi/generated"
theme='powermenu'

selection=$(printf "Shutdown\0icon\x1fsystem-shutdown\nReboot\0icon\x1fsystem-reboot\nLogout\0icon\x1fsystem-log-out\nLock\0icon\x1fsystem-lock-screen\nSuspend\0icon\x1fsystem-suspend\n" | rofi -dmenu -theme "${dir}/${theme}.rasi" -p "" -selected-row 3 -no-custom -show-icons)

case "$selection" in
    Shutdown) systemctl poweroff ;;
    Reboot)   systemctl reboot ;;
    Logout)   hyprctl dispatch exit ;;
    Lock)     hyprlock ;;
    Suspend)  hyprlock & disown && systemctl suspend ;;
esac
