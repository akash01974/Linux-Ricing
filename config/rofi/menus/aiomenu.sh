#!/usr/bin/env bash

dir="$HOME/.config/rofi/themes"
theme="default"

entries=(
    "1.    Search Files"
    "2.  󰀻  App Launcher"
    "3.  󰆍  Terminal Apps"
    "4.  󰸉  Wallpaper Switcher"
    "5.    Clipboard"
    "6.  󰞅  Emoji"
    "7.  󰌌  Keybind Reference"
    "8.    Waybar Layouts"
)

selected=$(printf '%s\n' "${entries[@]}" | rofi -dmenu -p '  Menu' \
    -theme ${dir}/aiomenu.rasi \
    -hover-select \
    -me-select-entry '' \
    -me-accept-entry MousePrimary)

case "$selected" in
    "1.    Search Files")
        pkill rofi
        "$HOME/.config/rofi/menus/search-files.sh"
        ;;
    "2.  󰀻  App Launcher")
        pkill rofi
        rofi -show drun -theme ${dir}/${theme}.rasi -click-to-exit -hover-select -me-select-entry '' -me-accept-entry MousePrimary
        ;;
    "3.  󰆍  Terminal Apps")
        pkill rofi
        "$HOME/.config/rofi/menus/terminal-apps.sh"
        ;;
    "4.  󰸉  Wallpaper Switcher")
        pkill rofi
        "$HOME/.config/rofi/menus/wallpaper.sh"
        ;;
    "5.    Clipboard")
        pkill rofi
        "$HOME/.config/hypr/scripts/clipboard-picker.sh"
        ;;
    "6.  󰞅  Emoji")
        pkill rofi
        "$HOME/.config/rofi/menus/emoji.sh"
        ;;
    "7.  󰌌  Keybind Reference")
        pkill rofi
        "$HOME/.config/rofi/menus/keybinds.sh"
        ;;
    "8.    Waybar Layouts")
        pkill rofi
        "$HOME/.config/rofi/menus/waybar-layouts.sh"
        ;;
esac
