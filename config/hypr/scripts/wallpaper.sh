#!/usr/bin/env bash
# Set the wallpaper: wallpaper.sh [image]. With no argument, restores the last one.
# The chosen image is also symlinked at ~/.config/hypr/current-wallpaper for hyprlock.
set -e
state="$HOME/.local/state/wallpaper"
link="$HOME/.config/hypr/current-wallpaper"
default="$HOME/Pictures/Wallpapers/ink.png"

img="${1:-$(cat "$state" 2>/dev/null || true)}"
[ -f "$img" ] || img="$default"

pgrep -x awww-daemon >/dev/null || { awww-daemon >/dev/null 2>&1 & sleep 0.8; }
awww img "$img" --transition-type fade --transition-duration 0.8 --transition-fps 120

mkdir -p "$(dirname "$state")"
echo "$img" > "$state"
ln -sf "$img" "$link"
