---- MONITORS ----

-- Originally set for a Lenovo Legion 5 AKP10 (15.1 OLED)
hl.monitor({
    output   = "eDP-1",
    mode     = "2560x1600@165",
    position = "0x0",
    scale    = "1.6",
})

-- Home desk: the external monitor sits directly above the laptop, centred over it.
-- (laptop is 2560/1.6 = 1600 wide, HDMI is 1920 wide -> x offset = (1600-1920)/2 = -160)
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@60",
    position = "-160x-1080",
    scale    = "1",
})

-- Overrides written by the Quickshell settings app (Settings > Displays), if present.
pcall(require, "modules.monitors_generated")
