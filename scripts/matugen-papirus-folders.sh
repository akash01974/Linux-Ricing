#!/bin/bash
# Maps matugen primary color to closest Papirus folder color

COLOR_FILE="$HOME/.config/gtk-3.0/colors.css"
if [ ! -f "$COLOR_FILE" ]; then exit 0; fi

PRIMARY=$(grep -oP '(?<=@define-color accent_color )[^;]+' "$COLOR_FILE" | tr -d ' ')
[ -z "$PRIMARY" ] && exit 0

# Convert hex to RGB for comparison
R=$((16#${PRIMARY:1:2}))
G=$((16#${PRIMARY:3:2}))
B=$((16#${PRIMARY:5:2}))

# Find closest Papirus color based on hue
# Papirus colors with their approximate hue ranges
if [ "$R" -gt 200 ] && [ "$G" -gt 150 ] && [ "$B" -lt 100 ]; then
    COLOR="orange"
elif [ "$R" -gt 200 ] && [ "$G" -gt 180 ] && [ "$G" -lt 230 ]; then
    COLOR="yellow"
elif [ "$R" -gt 200 ] && [ "$G" -lt 100 ] && [ "$B" -lt 100 ]; then
    COLOR="red"
elif [ "$R" -gt 150 ] && [ "$G" -lt 100 ] && [ "$B" -lt 100 ]; then
    COLOR="carmine"
elif [ "$R" -lt 100 ] && [ "$G" -gt 100 ] && [ "$B" -lt 100 ]; then
    COLOR="green"
elif [ "$R" -lt 100 ] && [ "$G" -lt 100 ] && [ "$B" -gt 150 ]; then
    COLOR="blue"
elif [ "$R" -lt 100 ] && [ "$G" -gt 100 ] && [ "$B" -gt 100 ]; then
    COLOR="teal"
elif [ "$R" -gt 150 ] && [ "$G" -gt 150 ] && [ "$B" -gt 200 ]; then
    COLOR="indigo"
elif [ "$R" -gt 150 ] && [ "$G" -lt 80 ] && [ "$B" -gt 150 ]; then
    COLOR="violet"
elif [ "$R" -gt 200 ] && [ "$G" -gt 100 ] && [ "$G" -lt 180 ]; then
    COLOR="deeporange"
elif [ "$R" -gt 180 ] && [ "$G" -gt 180 ] && [ "$B" -gt 200 ]; then
    COLOR="adwaita"
elif [ "$R" -gt 180 ] && [ "$G" -gt 120 ] && [ "$G" -lt 200 ] && [ "$B" -lt 100 ]; then
    COLOR="brown"
elif [ "$R" -lt 80 ] && [ "$G" -lt 80 ] && [ "$B" -lt 80 ]; then
    COLOR="black"
elif [ "$R" -gt 200 ] && [ "$G" -gt 200 ] && [ "$B" -gt 200 ]; then
    COLOR="white"
else
    # Fall back to hue-based matching
    MAX=$R
    if [ "$G" -gt "$MAX" ]; then MAX=$G; fi
    if [ "$B" -gt "$MAX" ]; then MAX=$B; fi
    MIN=$R
    if [ "$G" -lt "$MIN" ]; then MIN=$G; fi
    if [ "$B" -lt "$MIN" ]; then MIN=$B; fi

    if [ "$MAX" -eq "$MIN" ]; then
        COLOR="grey"
    elif [ "$MAX" -eq "$R" ]; then
        if [ "$G" -ge "$B" ]; then
            COLOR="orange"
        else
            COLOR="pink"
        fi
    elif [ "$MAX" -eq "$G" ]; then
        COLOR="green"
    else
        COLOR="blue"
    fi
fi

sudo -n /usr/bin/papirus-folders -C "$COLOR" --theme Papirus-Dark 2>/dev/null || true
sudo -n /usr/bin/papirus-folders -C "$COLOR" --theme Papirus 2>/dev/null || true
