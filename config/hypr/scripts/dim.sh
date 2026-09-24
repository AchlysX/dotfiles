#!/usr/bin/env bash
# Idle dim: drop the panel to a third of its current level (floor 1%).
# `brightnessctl -s` saves the old value; `brightnessctl -r` puts it back.
cur=$(brightnessctl -m | cut -d, -f4 | tr -d %)
target=$(( cur / 3 ))
[ "$target" -lt 1 ] && target=1
brightnessctl -s -q set "${target}%"
