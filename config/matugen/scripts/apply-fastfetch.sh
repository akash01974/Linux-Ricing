#!/bin/bash
# Injects matugen colors into fastfetch config.jsonc.
# Maps ANSI keyColor codes to matugen hex colors:
#   31 (system) -> primary
#   32 (software) -> secondary
#   33 (hardware) -> tertiary
#   34 (time) -> primary_fixed_dim

COLOR_FILE="$HOME/.cache/matugen/fastfetch-colors.json"
CONFIG_FILE="$HOME/.config/fastfetch/config.jsonc"

[ ! -f "$COLOR_FILE" ] && exit 0
[ ! -f "$CONFIG_FILE" ] && exit 0

# Read colors using python for reliable JSON parsing
python3 << PYEOF
import json, re

with open("$COLOR_FILE") as f:
    c = json.load(f)

with open("$CONFIG_FILE") as f:
    config = f.read()

# Color map: ANSI code -> matugen color key
color_map = {
    "31": c["primary"],
    "32": c["secondary"],
    "33": c["tertiary"],
    "34": c["primary_fixed_dim"],
}

# Replace "keyColor": "XX" with hex colors
for ansi, hex_color in color_map.items():
    config = config.replace(f'"keyColor": "{ansi}"', f'"keyColor": "{hex_color}"')

# Also set/update display.color for global overrides
display_section = f"""
  "display": {{
    "separator": " ➜ ",
    "color": {{
      "keys": "{c["primary"]}",
      "title": "{c["tertiary"]}",
      "output": "{c["on_surface"]}",
      "separator": "{c["outline"]}"
    }}
  }},"""

# If display section exists, replace it; otherwise inject after logo
if '"display"' in config:
    config = re.sub(
        r'"display"\s*:\s*\{[^}]*\},',
        display_section,
        config,
        count=1
    )
else:
    config = config.replace(
        '"logo"',
        display_section + '\n  "logo"',
        1
    )

with open("$CONFIG_FILE", "w") as f:
    f.write(config)

print("fastfetch colors applied")
PYEOF
