#!/usr/bin/env bash
set -uo pipefail

readonly BINDS_FILE="$HOME/.config/hypr/modules/binds.lua"
readonly CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
readonly CACHE_FILE="$CACHE_DIR/hypr-keybinds.txt"
readonly KEY_CACHE="$CACHE_DIR/hypr-keybinds.meta"

dir="$HOME/.config/rofi/themes"
mkdir -p "$CACHE_DIR"

friendly_name() {
    local cmd="$1"
    local base
    base=$(basename "${cmd%% *}" 2>/dev/null || echo "$cmd")
    case "$base" in
        kitty|alacritty|wezterm|foot)   echo "Terminal" ;;
        firefox|google-chrome|chromium|brave|librewolf) echo "Browser" ;;
        code|codium|code-insiders)      echo "VS Code" ;;
        nautilus|dolphin|thunar|pcmanfm|nemo) echo "File Manager" ;;
        rofi)                           echo "Application Launcher" ;;
        hyprlock)                       echo "Lock Screen" ;;
        hyprshot)                       echo "Screenshot" ;;
        swaync-client)                  echo "Notifications" ;;
        wpctl)                          echo "Volume Control" ;;
        brightnessctl)                  echo "Brightness" ;;
        playerctl)                      echo "Media Control" ;;
        hyprctl)                        echo "Hyprland Command" ;;
        wtype)                          echo "Type Text" ;;
        matugen)                        echo "Theme Generator" ;;
        awww)                           echo "Wallpaper" ;;
        *)                              echo "$(echo "${base%.sh}" | sed 's/-/ /g; s/\b\(.\)/\u\1/g')"
    esac
}

readable_action() {
    local action="$1"
    # Resolve known variables inside exec_cmd(variable_name)
    local resolved="$action"
    resolved="${resolved//terminal/$terminal}"
    resolved="${resolved//fileManager/$fileManager}"
    resolved="${resolved//menu/$menu}"

    if [[ "$resolved" =~ hl\.dsp\.exec_cmd\(\"([^\"]+)\" ]]; then
        friendly_name "${BASH_REMATCH[1]}"
        return
    fi
    # Bare variable in exec_cmd (no quotes) — already resolved above
    if [[ "$resolved" =~ hl\.dsp\.exec_cmd\(([^\)]+)\) ]]; then
        friendly_name "${BASH_REMATCH[1]}"
        return
    fi
    if [[ "$action" =~ window\.close\(\) ]]; then echo "Close Window"; return; fi
    if [[ "$action" =~ window\.float ]]; then echo "Toggle Float"; return; fi
    if [[ "$action" =~ window\.pseudo ]]; then echo "Toggle Pseudo"; return; fi
    if [[ "$action" =~ window\.drag ]]; then echo "Drag Window"; return; fi
    if [[ "$action" =~ window\.resize ]]; then echo "Resize Window"; return; fi
    if [[ "$action" =~ window\.move ]]; then echo "Move to Workspace"; return; fi
    if [[ "$action" =~ focus\(\{\ *direction\ *=\ *\"([^\"]+)\" ]]; then
        local dir="${BASH_REMATCH[1]}"; echo "Focus ${dir^}"; return
    fi
    if [[ "$action" =~ focus\(\{\ *workspace\ *=\ *\"([^\"]+)\" ]]; then
        local dir="${BASH_REMATCH[1]}"
        case "$dir" in "e+1") echo "Next Workspace" ;; "e-1") echo "Previous Workspace" ;; *) echo "Focus Workspace" ;; esac
        return
    fi
    if [[ "$action" =~ layout\(\"([^\"]+)\"\) ]]; then
        local layout="${BASH_REMATCH[1]}"
        case "$layout" in togglesplit) echo "Toggle Split" ;; *) echo "Layout ${layout^}" ;; esac
        return
    fi
    if [[ "$action" =~ workspace\.toggle_special ]]; then echo "Toggle Special Workspace"; return; fi
    if [[ "$action" =~ dispatch ]]; then echo "Shutdown"; return; fi
    if [[ "$action" =~ kill-active ]]; then echo "Kill Active"; return; fi
    if [[ "$action" =~ \"([^\"]+\.sh)\" ]]; then
        local script="${BASH_REMATCH[1]}"
        local base; base=$(basename "$script" .sh)
        echo "$base" | sed 's/-/ /g; s/\b\(.\)/\u\1/g'
        return
    fi
    local truncated="${action:0:40}..."
    echo "$truncated"
}

resolve_key() {
    local raw="$1"
    if [[ "$raw" =~ ^\"([^\"]+)\" ]]; then echo "${BASH_REMATCH[1]}"; return; fi
    # Specific patterns must come before general ones
    if [[ "$raw" =~ mainMod\ \.\.\ \"\ \+\ SHIFT\ \+\ \"\ \.\.\ key ]]; then echo "SUPER + SHIFT + KEY"; return; fi
    if [[ "$raw" =~ mainMod\ \.\.\ \"\ \+\ SHIFT\ \+\ ([^\"]+)\" ]]; then echo "SUPER + SHIFT + ${BASH_REMATCH[1]}"; return; fi
    if [[ "$raw" =~ mainMod\ \.\.\ \"\ \+\ ALT\ \+\ ([^\"]+)\" ]]; then echo "SUPER + ALT + ${BASH_REMATCH[1]}"; return; fi
    if [[ "$raw" =~ mainMod\ \.\.\ \"\ \+\ \"\ \.\.\ key ]]; then echo "SUPER + KEY"; return; fi
    if [[ "$raw" =~ mainMod\ \.\.\ \"\ \+\ ([^\"]+)\" ]]; then echo "SUPER + ${BASH_REMATCH[1]}"; return; fi
    if [[ "$raw" =~ mainMod\ \.\.\ \"\ \+\ (mouse:[0-9]+)\" ]]; then echo "SUPER + ${BASH_REMATCH[1]}"; return; fi
    local cleaned
    cleaned=$(echo "$raw" | sed 's/mainMod/SUPER/g; s/\.\.//g; s/"//g; s/  */ /g; s/^ *//; s/ *$//')
    echo "$cleaned"
}

generate_cache() {
    local line in_for=0 for_start=0 for_end=0
    local terminal fileManager menu

    # Extract variable values from binds.lua
    terminal=$(grep -oP 'local\s+terminal\s*=\s*"\K[^"]*' "$BINDS_FILE")
    fileManager=$(grep -oP 'local\s+fileManager\s*=\s*"\K[^"]*' "$BINDS_FILE")
    menu=$(grep -oP 'local\s+menu\s*=\s*"\K[^"]*' "$BINDS_FILE")

    > "$CACHE_FILE"

    while IFS= read -r line; do
        if [[ "$line" =~ for[[:space:]]+[a-z]+[[:space:]]*=[[:space:]]*([0-9]+)[[:space:]]*,[[:space:]]*([0-9]+)[[:space:]]*do ]]; then
            in_for=1; for_start="${BASH_REMATCH[1]}"; for_end="${BASH_REMATCH[2]}"
            continue
        fi
        if [[ "$line" =~ ^[[:space:]]*end[[:space:]]*$ ]] && [[ $in_for -eq 1 ]]; then
            in_for=0; continue
        fi
        [[ "$line" != *"hl.bind("* ]] && continue

        line="${line#*hl.bind(}"
        key_raw=$(echo "$line" | sed 's/^[[:space:]]*//; s/,.*//')
        rest="${line#*,}"

        # Extract action by finding matching closing paren
        action_raw="" depth=0
        for ((idx = 0; idx < ${#rest}; idx++)); do
            char="${rest:idx:1}"
            if [[ "$char" == "(" ]]; then ((depth++))
            elif [[ "$char" == ")" ]]; then
                if [[ $depth -eq 0 ]]; then
                    action_raw="${rest:0:idx+1}"
                    break
                fi
                ((depth--))
            fi
        done
        [[ -z "$action_raw" ]] && continue

        key_display=$(resolve_key "$key_raw")
        desc=$(readable_action "$action_raw")

        if [[ $in_for -eq 1 ]]; then
            for ((n = for_start; n <= for_end; n++)); do
                k=$((n % 10))
                expanded_key="${key_display//KEY/$k}"
                if [[ "$action_raw" == *"window.move"* ]]; then
                    echo "$expanded_key → Move to Workspace $n" >> "$CACHE_FILE"
                elif [[ "$action_raw" == *"focus"* ]]; then
                    echo "$expanded_key → Workspace $n" >> "$CACHE_FILE"
                fi
            done
        else
            echo "$key_display → $desc" >> "$CACHE_FILE"
        fi
    done < "$BINDS_FILE"
}

# Cache check: regenerate if binds.lua changed or cache is stale
if [[ ! -f "$CACHE_FILE" ]] || [[ ! -f "$KEY_CACHE" ]] || \
   [[ "$(stat -c %Y "$BINDS_FILE")" -ne "$(cat "$KEY_CACHE" 2>/dev/null)" ]] || \
   [[ $(( $(date +%s) - $(stat -c %Y "$CACHE_FILE") )) -ge 3600 ]]; then
    generate_cache
    stat -c %Y "$BINDS_FILE" > "$KEY_CACHE"
fi

selected=$(cat "$CACHE_FILE" | rofi -dmenu -i -p '  Keybinds' \
    -theme ${dir}/keybinds.rasi \
    -click-to-exit)

[[ -z "$selected" ]] && exit 0

echo -n "$selected" | wl-copy 2>/dev/null || echo -n "$selected" | xclip -selection clipboard 2>/dev/null || true
notify-send "Copied keybind:" "$selected"
