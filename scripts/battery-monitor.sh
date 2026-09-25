#!/usr/bin/env bash

BATTERY="BAT1"
THRESHOLDS=(5 10 15)
STATE_FILE="/tmp/battery-monitor-notified"
POLL_INTERVAL=60

touch "$STATE_FILE"

while true; do
    capacity=$(cat /sys/class/power_supply/$BATTERY/capacity)
    status=$(cat /sys/class/power_supply/$BATTERY/status)

    if [[ "$status" != "Discharging" ]]; then
        > "$STATE_FILE"
        sleep "$POLL_INTERVAL"
        continue
    fi

    for level in "${THRESHOLDS[@]}"; do
        if (( capacity <= level )); then
            if ! grep -q "^${level}$" "$STATE_FILE"; then
                notify-send -u critical -i battery-caution \
                    "Battery Low" \
                    "Battery at ${capacity}%. Plug in the charger."
                echo "$level" >> "$STATE_FILE"
            fi
        fi
    done

    sleep "$POLL_INTERVAL"
done
