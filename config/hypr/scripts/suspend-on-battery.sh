#!/usr/bin/env bash
# Long-idle suspend, but only when unplugged (docked desk setups stay awake).
[ "$(cat /sys/class/power_supply/ADP0/online)" = "0" ] && systemctl suspend
