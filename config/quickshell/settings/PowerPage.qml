import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.UPower
import qs.common

Flickable {
    id: root
    contentHeight: col.implicitHeight + 48
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    // Battery health from sysfs (design capacity vs. what it holds now).
    property real health: 0
    FileView { id: full;   path: "/sys/class/power_supply/BAT0/energy_full";        onLoaded: root.calcHealth() }
    FileView { id: design; path: "/sys/class/power_supply/BAT0/energy_full_design"; onLoaded: root.calcHealth() }
    function calcHealth() {
        const a = parseFloat(full.text()), b = parseFloat(design.text())
        if (a > 0 && b > 0) health = a / b
    }

    ColumnLayout {
        id: col
        x: 24; y: 24
        width: root.width - 48
        spacing: 18

        Text {
            text: "Power"
            color: Theme.fg
            font.family: Theme.font; font.pixelSize: 24; font.weight: Font.DemiBold
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: prof.implicitHeight + 32
            radius: 18; color: Theme.surface; border.width: 1; border.color: Theme.border
            ColumnLayout {
                id: prof
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
                spacing: 12
                Text { text: "Power mode"; color: Theme.fg
                    font.family: Theme.font; font.pixelSize: 15; font.weight: Font.DemiBold }
                Text {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    text: "Changes fan behaviour and how much power the CPU and GPU may draw."
                    color: Theme.fgDim; font.family: Theme.font; font.pixelSize: 12
                }
                Row {
                    spacing: 6
                    Chip { text: "Power saver"; selected: Sys.profile === PowerProfile.PowerSaver
                        onClicked: PowerProfiles.profile = PowerProfile.PowerSaver }
                    Chip { text: "Balanced"; selected: Sys.profile === PowerProfile.Balanced
                        onClicked: PowerProfiles.profile = PowerProfile.Balanced }
                    Chip { text: "Performance"; selected: Sys.profile === PowerProfile.Performance
                        enabled: PowerProfiles.hasPerformanceProfile
                        onClicked: PowerProfiles.profile = PowerProfile.Performance }
                }
            }
        }

        Rectangle {
            visible: Sys.hasBattery
            Layout.fillWidth: true
            implicitHeight: bat.implicitHeight + 32
            radius: 18; color: Theme.surface; border.width: 1; border.color: Theme.border
            ColumnLayout {
                id: bat
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
                spacing: 8
                Text { text: "Battery"; color: Theme.fg
                    font.family: Theme.font; font.pixelSize: 15; font.weight: Font.DemiBold }
                Text {
                    text: Math.round(Sys.batteryPct * 100) + "%  ·  " + (Sys.charging ? "Charging" : "On battery")
                    color: Theme.fg; font.family: Theme.font; font.pixelSize: 13
                }
                Text {
                    visible: root.health > 0
                    text: "Health " + Math.round(root.health * 100) + "% of original capacity"
                    color: Theme.fgDim; font.family: Theme.font; font.pixelSize: 12
                }
            }
        }
    }
}
