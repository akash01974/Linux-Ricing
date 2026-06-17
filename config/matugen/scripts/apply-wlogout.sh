#!/bin/bash
# Convert 8-digit hex colors (#rrggbbaa) to rgba(r,g,b,a) for GTK CSS compatibility.
# Writes to a temp file then atomically moves to avoid partial writes.

CSS="$HOME/.config/wlogout/style.css"
TMP="${CSS}.tmp"

python3 -c "
import re, sys

def hex_to_rgba(m):
    h = m.group(1)
    if len(h) == 8:
        r, g, b, a = int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), round(int(h[6:8], 16) / 255, 2)
        return f'rgba({r}, {g}, {b}, {a})'
    return m.group(0)

with open(sys.argv[1]) as f:
    content = f.read()

content = re.sub(r'#([0-9a-fA-F]{8})\b', hex_to_rgba, content)
with open(sys.argv[2], 'w') as f:
    f.write(content)
" "$CSS" "$TMP" && mv "$TMP" "$CSS"
