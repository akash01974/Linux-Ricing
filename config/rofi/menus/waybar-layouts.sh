#!/usr/bin/env bash
set -euo pipefail

LAYOUTS_DIR="$HOME/.config/waybar/layouts"
CONFIG_LINK="$HOME/.config/waybar/config.jsonc"
STYLE_LINK="$HOME/.config/waybar/style.css"
RASI_DIR="$HOME/.config/rofi/themes"
NOTIFY_ID=1024

# Get current active layout
active="$(basename "$(dirname "$(readlink -f "$CONFIG_LINK")")")"

# Discover layouts and build rofi entries
entries=()
for dir in "$LAYOUTS_DIR"/*/; do
    name="$(basename "$dir")"
    [ -f "$dir/config.jsonc" ] || continue
    [ -f "$dir/style.css" ] || continue
    if [ "$name" = "$active" ]; then
        entries+=("  $name")  # checkmark for active
    else
        entries+=("   $name")
    fi
done

if [ ${#entries[@]} -eq 0 ]; then
    notify-send -r $NOTIFY_ID -t 2000 "Waybar Layout" "No layouts found"
    exit 1
fi

selected=$(printf '%s\n' "${entries[@]}" | rofi -dmenu -i \
    -p '  Waybar Layout' \
    -theme "$RASI_DIR/default.rasi" \
    -hover-select \
    -me-select-entry '' \
    -me-accept-entry MousePrimary)

[ -z "$selected" ] && exit 0

# Strip icon prefix to get layout name
layout="${selected##* }"

# Only switch if different
if [ "$layout" = "$active" ]; then
    notify-send -r $NOTIFY_ID -t 1500 "Waybar Layout" "Already on: $layout"
    exit 0
fi

ln -sf "layouts/$layout/config.jsonc" "$CONFIG_LINK"
ln -sf "layouts/$layout/style.css" "$STYLE_LINK"

notify-send -r $NOTIFY_ID -t 2000 "Waybar Layout" " $active  →  $layout"

exec "$HOME/.config/waybar/scripts/launch.sh" restart
