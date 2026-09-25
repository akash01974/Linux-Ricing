#!/bin/bash
set -u
WP="${1:-$WP}"
WP_NAME="${2:-$(basename "$WP")}"
CACHE_COLORS="$HOME/.cache/wallpaper-colors.json"
HYPRLOCK_DIR="$HOME/.cache/hyprlock"
PID_FILE="/tmp/theme-update.pid"
COLORS_CSS="$HOME/.config/waybar/colors.css"
ORGB_ACCURATE_PID="/tmp/theme-openrgb-accurate.pid"

log() {
    echo "[$(date '+%H:%M:%S.%3N')] $*"
}

# Nanosecond mtime for colors.css
get_mtime_ns() {
    python3 -c "import os; print(os.stat('$COLORS_CSS').st_mtime_ns)" 2>/dev/null || echo "0"
}

# ─── Handler PID management (kill-and-replace) ──────────────────────────

HANDLER_PID=$$

handle_kill_previous() {
    if [ -f "$PID_FILE" ]; then
        OLD_PID=$(cat "$PID_FILE" 2>/dev/null)
        if [ -n "$OLD_PID" ] && [ "$OLD_PID" != "$HANDLER_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
            log "Killing previous theme update (PID $OLD_PID)"
            kill "$OLD_PID" 2>/dev/null
            sleep 0.2
        fi
    fi
    if [ -f "$ORGB_ACCURATE_PID" ]; then
        opid=$(cat "$ORGB_ACCURATE_PID" 2>/dev/null)
        [ -n "$opid" ] && kill "$opid" 2>/dev/null || true
        rm -f "$ORGB_ACCURATE_PID"
    fi
    echo "$HANDLER_PID" > "$PID_FILE"
}

handle_cleanup() {
    if [ -f "$PID_FILE" ]; then
        CURRENT=$(cat "$PID_FILE" 2>/dev/null)
        if [ "$CURRENT" = "$HANDLER_PID" ]; then
            rm -f "$PID_FILE"
        fi
    fi
}

trap handle_cleanup EXIT
handle_kill_previous

log "=== Theme update started: $WP_NAME ==="
OVERALL_START=$(date +%s%N)

# ─── Phase 1: Fire everything in parallel ──────────────────────────

# 1a. Set wallpaper directly (no transition)
cp -f -- "$WP" "$HOME/.cache/hyprlock/current.jpg" 2>/dev/null || true
awww kill 2>/dev/null || true
sleep 0.3
awww-daemon &>/dev/null &
sleep 0.5
log "Wallpaper set, daemon restarted"

# 1b. Hyprlock wallpaper cache
mkdir -p "$HYPRLOCK_DIR"
cp -f -- "$WP" "$HYPRLOCK_DIR/current.jpg" 2>/dev/null || true
log "Hyprlock cache updated"

# ─── Phase 2: Matugen + single Waybar reload ──────────────────────

log "Starting matugen…"
MATUGEN_START=$(date +%s%N)

CSS_NS_BEFORE=$(get_mtime_ns)

# Monitor colors.css — reload Waybar exactly once when colors.css is written
(
    MON_PARENT="$HANDLER_PID"
    while true; do
        if ! kill -0 "$MON_PARENT" 2>/dev/null; then
            exit 0
        fi
        CSS_NS_NOW=$(get_mtime_ns)
        if [ "$CSS_NS_NOW" -gt "$CSS_NS_BEFORE" ] 2>/dev/null; then
            killall -SIGUSR2 waybar 2>/dev/null || true
            log "colors.css written → Waybar reloaded early"
            break
        fi
        sleep 0.05
    done
) &
MONITOR_PID=$!

if matugen image "$WP" --source-color-index 0 -q 2>/tmp/matugen-err.log; then
    MATUGEN_ELAPSED=$(( ($(date +%s%N) - MATUGEN_START) / 1000000 ))
    log "Matugen finished in ${MATUGEN_ELAPSED}ms"

    # Wait for monitor: it may have already fired and exited,
    # or it may still be polling (if colors.css was written in the
    # last 50ms window). Give it up to 3s to detect the write.
    if kill -0 "$MONITOR_PID" 2>/dev/null; then
        log "Waiting for Waybar reload monitor…"
        for _ in $(seq 1 60); do
            if ! kill -0 "$MONITOR_PID" 2>/dev/null; then
                break
            fi
            sleep 0.05
        done
        kill "$MONITOR_PID" 2>/dev/null; wait "$MONITOR_PID" 2>/dev/null
    fi

    # ─── Phase 3: Notification ─────────────────────────────────────

    TOTAL_ELAPSED=$(( ($(date +%s%N) - OVERALL_START) / 1000000 ))
    notify-send -t 5000 "Theme Updated" \
        "󰸉  $WP_NAME\n󱇯  ${TOTAL_ELAPSED}ms total (matugen: ${MATUGEN_ELAPSED}ms)"
    log "DONE — ${TOTAL_ELAPSED}ms total"
else
    log "MATUGEN FAILED (see /tmp/matugen-err.log)"
    notify-send -u critical -t 5000 "Theme Update Failed" \
        "Matugen error for $WP_NAME\nSee /tmp/matugen-err.log"
    exit 1
fi

# ─── Phase 4: Background housekeeping ──────────────────────────────

# Rebuild color cache if stale (>1 hour)
if [ -f "$CACHE_COLORS" ]; then
    CACHE_AGE=$(( $(date +%s) - $(stat -c %Y "$CACHE_COLORS") ))
else
    CACHE_AGE=999999
fi
if [ "$CACHE_AGE" -gt 3600 ]; then
    log "Rebuilding color cache (age: ${CACHE_AGE}s)…"
    "$HOME/.config/matugen/scripts/build-color-cache.py" \
        >/tmp/color-cache-rebuild.log 2>&1 &
fi
