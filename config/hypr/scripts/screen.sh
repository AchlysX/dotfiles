#!/usr/bin/env bash
# screen.sh on|off — panel power (black pixels = no OLED wear)
case "$1" in
  off) hyprctl dispatch 'hl.dsp.dpms({ action = "off" })' ;;
  *)   hyprctl dispatch 'hl.dsp.dpms({ action = "on" })' ;;
esac
