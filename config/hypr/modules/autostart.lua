---- AUTOSTART ----
hl.on("hyprland.start", function ()
	hl.exec_cmd("quickshell") -- bar, notifications, OSD, dock... (~/.config/quickshell)
	hl.exec_cmd("vicinae server")
	hl.exec_cmd("~/.config/hypr/scripts/wallpaper.sh") -- awww wallpaper (restores the last one)
	hl.exec_cmd("hypridle")                            -- dim / lock / panel-off (OLED protection)
	hl.exec_cmd("systemctl --user start hyprpolkitagent")
end)
