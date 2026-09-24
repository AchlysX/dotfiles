import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.common

// Transparent strip; only three black capsules are actually drawn.
PanelWindow {
    id: bar
    required property var modelData
    screen: modelData

    anchors { top: true; left: true; right: true }
    implicitHeight: Theme.barHeight
    color: "transparent"
    WlrLayershell.namespace: "qs-bar"
    // Clicks between the capsules fall through to whatever is underneath.
    mask: Region {
        regions: [ Region { item: leftPill }, Region { item: centerPill }, Region { item: rightPill } ]
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        transform: Translate { x: Math.round(Theme.shiftX); y: Math.round(Theme.shiftY) }

        Pill {
            id: leftPill
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            padding: 8
            Workspaces { screenName: bar.screen.name }
        }

        // Clock: opens the notification center (GNOME-style).
        Pill {
            id: centerPill
            anchors.centerIn: parent
            padding: 16
            Row {
                spacing: 8
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Time.day
                    color: Theme.fgDim
                    font.family: Theme.font; font.pixelSize: 13
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Time.time
                    color: Theme.fg
                    font.family: Theme.font; font.pixelSize: 13; font.weight: Font.DemiBold
                }
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 5; height: 5; radius: 2.5
                    color: Notifs.dnd ? Theme.fgDim : Theme.fg
                    visible: Notifs.count > 0
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: UI.toggle("notifs", bar.screen.name)
            }
        }

        // Status icons: each one opens the control center on its own page.
        Pill {
            id: rightPill
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            padding: 6
            Row {
                spacing: 0
                BarIcon { name: "bluetooth-active"; visible: Sys.btConnected
                    onClicked: UI.openControl(bar.screen.name, "bt") }
                BarIcon { name: Sys.netIcon
                    onClicked: UI.openControl(bar.screen.name, "wifi") }
                BarIcon { name: Sys.volumeIcon
                    onClicked: UI.openControl(bar.screen.name, "main")
                    onScrolled: dy => Osd.volume(dy > 0 ? "up" : "down") }
                Battery { onClicked: UI.openControl(bar.screen.name, "main") }
            }
        }
    }
}
