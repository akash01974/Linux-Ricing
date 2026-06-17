#!/usr/bin/env bash

dir="$HOME/.config/rofi/themes"
theme="search-files"
cache_dir="/tmp/rofi-search-files"
cache_file="$cache_dir/cache"
cache_ttl=30

mkdir -p "$cache_dir"

build_list() {
    if command -v fd &>/dev/null; then
        # fd: fast, recursive, respects .gitignore by default
        # --hidden includes .config, then we exclude other hidden dirs via grep
        fd --type f --type d --hidden . "$HOME" 2>/dev/null |
            grep -v -E '/\.(cache|git|npm|local|mozilla|cargo|rustup|nvm|bun|deno|pyenv|svelte-kit|next|local/share/Trash)(/|$)'
    else
        # find fallback: prune all hidden dirs except .config
        find "$HOME" \
            \( -type d \( -name '.*' -and ! -name '.config' \) -prune \) -o \
            \( -type f -o -type d \) -print 2>/dev/null
    fi
}

if [ -f "$cache_file" ] && [ $(( $(date +%s) - $(stat -c %Y "$cache_file") )) -lt $cache_ttl ]; then
    file_list=$(cat "$cache_file")
else
    file_list=$(build_list)
    echo "$file_list" > "$cache_file"
fi

selected=$(echo "$file_list" | rofi -dmenu -i -fuzzy \
    -p '  Search Files' \
    -theme ${dir}/${theme}.rasi \
    -click-to-exit)

[[ -z "$selected" ]] && exit 0

xdg-open "$selected"
