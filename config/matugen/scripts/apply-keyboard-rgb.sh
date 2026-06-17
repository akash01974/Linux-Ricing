#!/bin/bash
# Applies exact matugen primary color to keyboard RGB.
# Fire-and-forget with PID tracking to prevent stale/racing processes.

COLOR_FILE="$HOME/.cache/matugen/openrgb-keyboard.txt"
[ ! -f "$COLOR_FILE" ] && exit 0

COLOR=$(tr -d '#' < "$COLOR_FILE")
ORGB_PID_FILE="/tmp/theme-openrgb-accurate.pid"

# Kill previous accurate OpenRGB (from older post_hook) to prevent
# concurrent device access.
if [ -f "$ORGB_PID_FILE" ]; then
    OLD_PID=$(cat "$ORGB_PID_FILE" 2>/dev/null)
    if [ -n "$OLD_PID" ]; then
        kill "$OLD_PID" 2>/dev/null || true
    fi
fi

openrgb --noautoconnect --device 1 --mode static \
    --color "$COLOR" --brightness 100 >/dev/null 2>&1 &

echo $! > "$ORGB_PID_FILE"
