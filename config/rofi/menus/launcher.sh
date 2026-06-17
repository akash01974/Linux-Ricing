#!/usr/bin/env bash


dir="$HOME/.config/rofi/themes"
theme='default'

## Run
pkill rofi || rofi \
    -show drun \
    -theme ${dir}/${theme}.rasi \
    -click-to-exit \
    -hover-select \
    -me-select-entry '' \
    -me-accept-entry MousePrimary
