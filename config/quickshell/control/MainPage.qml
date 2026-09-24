import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking
import qs.common

ColumnLayout {
    id: root
    signal openPage(string page)
    spacing: 12

    function fmt(sec) {
        const h = Math.floor(sec / 3600), m = Math.floor((sec % 3600) / 60)
        return h > 0 ? h + "h " + m + "m" : m + "m"
    }
    readonly property string batteryText: {
        if (!Sys.hasBattery) return ""
        let t = Math.round(Sys.batteryPct * 100) + "%"
        if (Sys.charging) t += Sys.batteryPct >= 0.99 ? " · Full" : " · Charging" + (Sys.bat.timeToFull > 0 ? " · " + fmt(Sys.bat.timeToFull) + " to full" : "")
        else t += " · " + (Sys.bat.timeToEmpty > 0 ? fmt(Sys.bat.timeToEmpty) + " left" : "On battery")
        return t
    }

    RowLayout {
        Layout.fillWidth: true
        Text {
            Layout.fillWidth: true
            Layout.leftMargin: 4
            text: root.batteryText
            color: Theme.fgDim
            font.family: Theme.font; font.pixelSize: 12
        }
        Chip {
            text: "Settings"
            implicitHeight: 28
            onClicked: { UI.close(); UI.settingsOpen = true }
        }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 2
        rowSpacing: 8
        columnSpacing: 8
        uniformCellWidths: true

        Tile {
            Layout.fillWidth: true
            icon: Sys.netIcon
            title: "Wi-Fi"
            subtitle: !Networking.wifiEnabled ? "Off" : Sys.activeWifi ? Sys.activeWifi.name : "Not connected"
            active: Networking.wifiEnabled
            hasMore: true
            onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
            onMoreClicked: root.openPage("wifi")
        }
        Tile {
            Layout.fillWidth: true
            icon: Sys.btOn ? "bluetooth-active" : "bluetooth-disabled"
            title: "Bluetooth"
            subtitle: !Sys.btAdapter ? "Unavailable" : !Sys.btOn ? "Off" : Sys.btConnected ? "Connected" : "On"
            active: Sys.btOn
            hasMore: Sys.btAdapter !== null
            onClicked: { if (Sys.btAdapter) Sys.btAdapter.enabled = !Sys.btAdapter.enabled }
            onMoreClicked: root.openPage("bt")
        }
        Tile {
            Layout.fillWidth: true
            icon: Sys.profileIcon
            title: Sys.profileName
            subtitle: "Power mode"
            active: true
            onClicked: Sys.cycleProfile()
        }
        Tile {
            Layout.fillWidth: true
            icon: "night-light"
            title: "Night light"
            subtitle: Sys.nightLight ? "On" : "Off"
            active: Sys.nightLight
            onClicked: Sys.nightLight = !Sys.nightLight
        }
        Tile {
            Layout.fillWidth: true
            icon: Notifs.dnd ? "notifications-disabled" : "preferences-system-notifications"
            title: "Do not disturb"
            subtitle: Notifs.dnd ? "On" : "Off"
            active: Notifs.dnd
            onClicked: Notifs.dnd = !Notifs.dnd
        }
        Tile {
            Layout.fillWidth: true
            icon: Sys.micMuted ? "microphone-sensitivity-muted" : "microphone-sensitivity-high"
            title: "Microphone"
            subtitle: Sys.micMuted ? "Muted" : "On"
            active: !Sys.micMuted
            onClicked: Sys.toggleMic()
        }
    }

    Slider {
        Layout.fillWidth: true
        icon: Sys.volumeIcon
        value: Sys.muted ? 0 : Sys.volume
        label: Sys.muted ? "muted" : Math.round(Sys.volume * 100)
        onMoved: v => { if (Sys.muted) Sys.toggleMute(); Sys.setVolume(v) }
        onIconClicked: Sys.toggleMute()
    }
    Slider {
        Layout.fillWidth: true
        icon: "display-brightness"
        value: Sys.brightness
        label: Math.round(Sys.brightness * 100)
        onMoved: v => Sys.setBrightness(v)
    }

    // Session buttons. Restart / power off need a second tap.
    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: 2
        spacing: 8

        component SessionButton: Rectangle {
            id: btn
            property string text
            property bool confirm: false
            property bool armed: false
            signal fire()
            Layout.fillWidth: true
            implicitHeight: 34
            radius: 17
            color: armed ? Theme.urgent : (m.containsMouse ? Theme.surfaceHi : "transparent")
            border.width: 1
            border.color: armed ? Theme.urgent : Theme.border
            Timer { id: disarm; interval: 2500; onTriggered: btn.armed = false }
            Text {
                anchors.centerIn: parent
                text: btn.armed ? "Confirm?" : btn.text
                color: btn.armed ? Theme.bg : Theme.fgDim
                font.family: Theme.font; font.pixelSize: 12
            }
            MouseArea {
                id: m
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    if (btn.confirm && !btn.armed) { btn.armed = true; disarm.restart(); return }
                    btn.armed = false
                    btn.fire()
                }
            }
        }

        SessionButton { text: "Lock";      onFire: { UI.close(); Quickshell.execDetached(["hyprlock"]) } }
        SessionButton { text: "Sleep";     onFire: { UI.close(); Quickshell.execDetached(["systemctl", "suspend"]) } }
        SessionButton { text: "Restart";   confirm: true; onFire: Quickshell.execDetached(["systemctl", "reboot"]) }
        SessionButton { text: "Power off"; confirm: true; onFire: Quickshell.execDetached(["systemctl", "poweroff"]) }
    }
}
