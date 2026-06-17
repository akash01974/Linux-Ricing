#!/usr/bin/env bash
set -euo pipefail

CACHE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/pkg-remove.txt"
CACHE_TTL=$((6 * 60 * 60))

refresh_cache() {
    local official orphans aur
    official=$(pacman -Slq 2>/dev/null | sort -u)
    orphans=$(pacman -Qdtq 2>/dev/null | sort -u)
    aur=$(pacman -Qmq 2>/dev/null | sort -u)

    pacman -Qq 2>/dev/null | sort | while read -r pkg; do
        local label=""
        if grep -qxF "$pkg" <<< "$aur" &>/dev/null; then
            label="[AUR]"
        fi
        if grep -qxF "$pkg" <<< "$orphans" &>/dev/null; then
            label="${label:+$label }[ORPHAN]"
        fi
        if [[ -n "$label" ]]; then
            echo "$pkg $label"
        else
            echo "$pkg"
        fi
    done > "$CACHE_FILE"
}

mkdir -p "$(dirname "$CACHE_FILE")"
if [[ ! -f "$CACHE_FILE" ]] || [[ $(( $(date +%s) - $(stat -c %Y "$CACHE_FILE") )) -ge $CACHE_TTL ]]; then
    refresh_cache
fi

export CACHE_FILE
export -f refresh_cache

selected=$(fzf -m --cycle \
    --prompt='Installed Packages > ' \
    --header='Tab select | Enter remove | Ctrl+R refresh' \
    --preview='
        pkg=$(echo {} | awk "{print \$1}");
        pacman -Qi "$pkg" 2>/dev/null | grep -E "^(Name|Description|Version|Installed Size|Install Reason|Required By)"
    ' \
    --preview-window='right:60%' \
    --bind="ctrl-r:execute(bash -c 'refresh_cache')+reload(cat \"$CACHE_FILE\")" < "$CACHE_FILE")

[[ -z "$selected" ]] && exit 0

mapfile -t pkgs < <(echo "$selected" | awk '{print $1}')

echo ""
echo "Selected packages:"
printf '  • %s\n' "${pkgs[@]}"
echo ""

read -r -p "Remove selected packages? [y/N] " confirm
[[ "$confirm" != "y" ]] && exit 0

if sudo pacman -Rns "${pkgs[@]}"; then
    notify-send "Package Remove" "✓ Successfully removed ${#pkgs[@]} packages"
else
    notify-send -u critical "Package Remove" "✗ Removal failed"
    exit 1
fi
