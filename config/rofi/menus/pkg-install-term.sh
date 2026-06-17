#!/usr/bin/env bash
set -euo pipefail

CACHE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/pacman-packages.txt"
CACHE_TTL=$((6 * 60 * 60))

refresh_cache() {
    mkdir -p "$(dirname "$CACHE_FILE")"
    pacman -Slq 2>/dev/null | sort > "$CACHE_FILE"
}

mkdir -p "$(dirname "$CACHE_FILE")"
if [[ ! -f "$CACHE_FILE" ]] || [[ $(( $(date +%s) - $(stat -c %Y "$CACHE_FILE") )) -ge $CACHE_TTL ]]; then
    refresh_cache
fi

export CACHE_FILE
export -f refresh_cache

selected=$(fzf -m --cycle \
    --prompt='Packages > ' \
    --header='Tab select | Enter install | Ctrl+R refresh' \
    --preview='pacman -Si {} 2>/dev/null | sed -n "1,20p"' \
    --preview-window='right:60%' \
    --bind="ctrl-r:execute(bash -c 'refresh_cache')+reload(cat \"$CACHE_FILE\")" < "$CACHE_FILE")

[[ -z "$selected" ]] && exit 0

mapfile -t pkgs <<< "$selected"

echo ""
echo "Selected packages:"
printf '  • %s\n' "${pkgs[@]}"
echo ""

read -r -p "Install selected packages? [y/N] " confirm
[[ "$confirm" != "y" ]] && exit 0

if sudo pacman -S --needed "${pkgs[@]}"; then
    notify-send "Package Install" "✓ Successfully installed ${#pkgs[@]} packages"
else
    notify-send -u critical "Package Install" "✗ Installation failed"
    exit 1
fi
