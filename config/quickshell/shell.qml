import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.common
import qs.bar
import qs.notifications
import qs.osd
import qs.control
import qs.dock
import qs.settings

ShellRoot {
    Variants { model: Quickshell.screens; Bar {} }
    Variants { model: Quickshell.screens; NotifPopups {} }
    Variants { model: Quickshell.screens; NotifCenter {} }
    Variants { model: Quickshell.screens; ControlCenter {} }
    Variants { model: Quickshell.screens; Dock {} }
    SettingsWindow {}
    Variants { model: Quickshell.screens; OsdWindow {} }

    // qs ipc call panel toggle <notifs|control|launcher> | control <main|wifi|bt> | close
    IpcHandler {
        target: "panel"
        function toggle(name: string): void { UI.toggle(name, Hyprland.focusedMonitor?.name ?? "") }
        function control(page: string): void { UI.openControl(Hyprland.focusedMonitor?.name ?? "", page) }
        function settings(page: string): void { UI.settingsPage = page !== "" ? page : UI.settingsPage; UI.settingsOpen = true }
        function closeSettings(): void { UI.settingsOpen = false }
        function close(): void { UI.close() }
    }

    // qs ipc call osd volume <up|down|mute> | brightness <up|down> | mic
    IpcHandler {
        target: "osd"
        function volume(action: string): void { Osd.volume(action) }
        function brightness(action: string): void { Osd.brightness(action) }
        function mic(): void { Osd.mic() }
    }

    // qs ipc call displays set <placement|align|layout> <value> | apply | keep | revert
    IpcHandler {
        target: "displays"
        function set(key: string, value: string): void {
            if (key === "placement") Displays.placement = value
            else if (key === "align") Displays.align = value
            else if (key === "layout") Displays.layout = value
        }
        function apply(): void { Displays.apply() }
        function keep(): void { Displays.keep() }
        function revert(): void { Displays.revert() }
    }
}
