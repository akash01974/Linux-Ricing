#!/usr/bin/env bash
set -euo pipefail

CACHE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/yay-packages.txt"
CACHE_TTL=$((6 * 60 * 60))

refresh_cache() {
    mkdir -p "$(dirname "$CACHE_FILE")"
    yay -Slq 2>/dev/null | sort -u > "$CACHE_FILE"
}

mkdir -p "$(dirname "$CACHE_FILE")"
if [[ ! -f "$CACHE_FILE" ]] || [[ $(( $(date +%s) - $(stat -c %Y "$CACHE_FILE") )) -ge $CACHE_TTL ]]; then
    refresh_cache
fi

export CACHE_FILE
export -f refresh_cache

selected=$(fzf -m --cycle \
    --prompt='Yay Packages > ' \
    --header='Tab select | Enter install | Ctrl+R refresh' \
    --preview='
        pkg=$(echo {} | awk "{print \$1}");
        yay -Si "$pkg" 2>/dev/null | sed -n "1,25p";
        echo "";
        echo "---";
        echo "Status: $(pacman -Q "$pkg" 2>/dev/null && echo "INSTALLED" || echo "NOT INSTALLED")"
    ' \
    --preview-window='right:60%' \
    --bind="ctrl-r:execute(bash -c 'refresh_cache')+reload(cat \"$CACHE_FILE\")" < "$CACHE_FILE")

[[ -z "$selected" ]] && exit 0

mapfile -t selected_pkgs <<< "$selected"

echo ""
echo "Selected packages:"
printf '  • %s\n' "${selected_pkgs[@]}"
echo ""

read -r -p "Install selected packages? [y/N] " confirm
[[ "$confirm" != "y" ]] && exit 0

if yay -S --needed "${selected_pkgs[@]}"; then
    notify-send "Yay Install" "✓ Successfully installed ${#selected_pkgs[@]} packages"
else
    notify-send -u critical "Yay Install" "✗ Installation failed"
    exit 1
fi
