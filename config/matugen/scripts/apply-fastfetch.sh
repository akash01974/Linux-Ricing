#!/bin/bash
# Injects matugen colors into fastfetch config.jsonc.
# Config uses placeholder tags: __PRIMARY__, __SECONDARY__, __TERTIARY__, __PRIMARY_DIM__
# which this script replaces with actual hex colors from matugen.

COLOR_FILE="$HOME/.cache/matugen/fastfetch-colors.json"
CONFIG_FILE="$HOME/.config/fastfetch/config.jsonc"

[ ! -f "$COLOR_FILE" ] && exit 0
[ ! -f "$CONFIG_FILE" ] && exit 0

python3 << 'PYEOF'
import json

with open("/home/akash/.cache/matugen/fastfetch-colors.json") as f:
    c = json.load(f)

with open("/home/akash/.config/fastfetch/config.jsonc") as f:
    config = f.read()

replacements = {
    "__PRIMARY__": c["primary"],
    "__SECONDARY__": c["secondary"],
    "__TERTIARY__": c["tertiary"],
    "__PRIMARY_DIM__": c["primary_fixed_dim"],
    "__ON_SURFACE__": c["on_surface"],
    "__OUTLINE__": c["outline"],
}

for tag, color in replacements.items():
    config = config.replace(tag, color)

with open("/home/akash/.config/fastfetch/config.jsonc", "w") as f:
    f.write(config)

print("fastfetch colors applied")
PYEOF
