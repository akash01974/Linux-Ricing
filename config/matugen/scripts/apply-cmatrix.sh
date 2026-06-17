#!/bin/bash
# Maps matugen primary color to nearest cmatrix named color.

COLOR_FILE="$HOME/.cache/matugen/cmatrix-hex.txt"
OUTPUT_FILE="$HOME/.cache/matugen/cmatrix-color"

[ ! -f "$COLOR_FILE" ] && exit 0

HEX=$(tr -d '#' < "$COLOR_FILE" | tr '[:lower:]' '[:upper:]')
[ -z "$HEX" ] && exit 0

R=$((16#${HEX:0:2}))
G=$((16#${HEX:2:2}))
B=$((16#${HEX:4:2}))

# Named cmatrix colors as RGB tuples
declare -A COLORS
COLORS[green]="0 255 0"
COLORS[red]="255 0 0"
COLORS[blue]="0 0 255"
COLORS[white]="255 255 255"
COLORS[yellow]="255 255 0"
COLORS[cyan]="0 255 255"
COLORS[magenta]="255 0 255"
COLORS[black]="0 0 0"

closest="green"
min_dist=999999

for name in "${!COLORS[@]}"; do
    read cr cg cb <<< "${COLORS[$name]}"
    dr=$((R - cr))
    dg=$((G - cg))
    db=$((B - cb))
    dist=$((dr*dr + dg*dg + db*db))
    if [ "$dist" -lt "$min_dist" ]; then
        min_dist=$dist
        closest=$name
    fi
done

echo "$closest" > "$OUTPUT_FILE"
