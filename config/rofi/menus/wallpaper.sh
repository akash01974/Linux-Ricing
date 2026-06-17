#!/bin/bash

WALL_DIR="$HOME/Pictures/Wallpapers"

if ! pidof awww-daemon >/dev/null; then
    awww-daemon &
    sleep 0.5
fi

RASI_DIR="$HOME/.config/rofi/themes"

SELECTED=$(
for img in "$WALL_DIR"/*; do
    [[ "$img" =~ \.(jpg|jpeg|png|webp|PNG|JPG)$ ]] || continue
    printf "%s\0icon\x1f%s\n" "$(basename "$img")" "$img"
done | rofi \
-dmenu \
-i \
-show-icons \
-hover-select \
-me-select-entry '' \
-me-accept-entry MousePrimary \
-theme "$RASI_DIR/default.rasi" \
-theme-str 'window { width: 760px; } element-icon { size: 160px; } listview { lines: 1; }' \
-p "" \
-name "wallpaper-picker"
)

[ -z "$SELECTED" ] && exit 1

export WP="$WALL_DIR/$SELECTED"
export WP_NAME="$SELECTED"
nohup "$HOME/.config/rofi/helpers/handler-theme-update.sh" \
    >/tmp/theme-update.log 2>&1 &
disown
