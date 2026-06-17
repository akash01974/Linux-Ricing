#!/usr/bin/env bash

export PATH="$HOME/.cargo/bin:$PATH"

dir="$HOME/.config/rofi/themes"
theme="terminal.rasi"
apps_list="$HOME/.config/rofi/data/terminal-apps.list"

# ── Detect terminal emulator ──────────────────────────────────────
if command -v kitty &>/dev/null; then
    TERMINAL="kitty"
elif command -v alacritty &>/dev/null; then
    TERMINAL="alacritty"
else
    TERMINAL="kitty"
fi
HYPR_TERMINAL=$(grep -rh -oP 'terminal\s*=\s*"\K[^"]+' "$HOME/.config/hypr" 2>/dev/null | head -1)
TERMINAL="${HYPR_TERMINAL:-$TERMINAL}"

# ── Build menu from database ──────────────────────────────────────
declare -a entries
declare -a commands

while IFS=$'\t' read -r icon category name command; do
    [[ -z "$icon" || "$icon" =~ ^# ]] && continue
    binary="${command##* }"
    if command -v "$binary" &>/dev/null; then
        entries+=("$icon  $name")
        commands+=("$command")
    fi
done < "$apps_list"

if [[ ${#entries[@]} -eq 0 ]]; then
    notify-send "Terminal Apps" "No terminal applications found"
    exit 1
fi

# ── Show rofi menu ────────────────────────────────────────────────
selected=$(printf '%s\n' "${entries[@]}" | rofi -dmenu -p '  Terminal Apps' \
    -theme ${dir}/${theme} \
    -hover-select \
    -me-select-entry '' \
    -me-accept-entry MousePrimary)

[[ -z "$selected" ]] && exit 0

# ── Launch selected app ───────────────────────────────────────────
for i in "${!entries[@]}"; do
    if [[ "${entries[$i]}" == "$selected" ]]; then
        read -ra cmd_args <<< "${commands[$i]}"
        "$TERMINAL" "${cmd_args[@]}"
        break
    fi
done
