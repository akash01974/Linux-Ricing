#!/usr/bin/env bash

dir="$HOME/.config/rofi/themes"
data_file="$HOME/.config/rofi/data/emoji-list.txt"

selected=$(awk -F'\t' '!/^#/ && NF>=4 {print $1 "  " $4}' "$data_file" | \
    rofi -dmenu -p '  Emoji' \
    -theme ${dir}/clipboard.rasi \
    -hover-select \
    -me-select-entry '' \
    -me-accept-entry MousePrimary)

[[ -z "$selected" ]] && exit 1

selected_emoji="${selected%%  *}"
wtype "$selected_emoji"
