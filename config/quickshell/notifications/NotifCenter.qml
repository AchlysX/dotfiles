import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.common

// Drops down from the clock: every notification that hasn't been dismissed.
PanelWindow {
    id: win
    required property var modelData
    screen: modelData

    readonly property bool open: UI.isOpen("notifs", modelData.name)
    visible: open || panel.opacity > 0.01

    anchors { top: true }
    margins.top: Theme.barHeight + 6
    implicitWidth: 400
    implicitHeight: Math.min(panel.implicitHeight, modelData.height - Theme.barHeight - 40)
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-notif-center"
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    HyprlandFocusGrab {
        windows: [win]
        active: win.open
        onCleared: UI.close()
    }

    Rectangle {
        id: panel
        width: parent.width
        height: parent.height
        implicitHeight: header.implicitHeight + (list.count > 0 ? list.contentHeight : 90) + 44
        radius: Theme.radius + 2
        color: Theme.bg
        border.width: 1
        border.color: Theme.border
        opacity: win.open ? 1 : 0
        transform: Translate { y: win.open ? 0 : -14
            Behavior on y { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } } }
        Behavior on opacity { NumberAnimation { duration: 180 } }
        focus: win.open
        Keys.onEscapePressed: UI.close()

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            RowLayout {
                id: header
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: "Notifications"
                    color: Theme.fg
                    font.family: Theme.font; font.pixelSize: 15; font.weight: Font.DemiBold
                }
                // Do-not-disturb
                Rectangle {
                    width: dndLabel.implicitWidth + 22; height: 28; radius: 14
                    color: Notifs.dnd ? Theme.fg : "transparent"
                    border.width: 1; border.color: Theme.border
                    Text {
                        id: dndLabel
                        anchors.centerIn: parent
                        text: "Do not disturb"
                        color: Notifs.dnd ? Theme.bg : Theme.fgDim
                        font.family: Theme.font; font.pixelSize: 12
                    }
                    MouseArea { anchors.fill: parent; onClicked: Notifs.dnd = !Notifs.dnd }
                }
                Rectangle {
                    visible: Notifs.count > 0
                    width: clearLabel.implicitWidth + 22; height: 28; radius: 14
                    color: "transparent"
                    border.width: 1; border.color: Theme.border
                    Text {
                        id: clearLabel
                        anchors.centerIn: parent
                        text: "Clear"
                        color: Theme.fgDim
                        font.family: Theme.font; font.pixelSize: 12
                    }
                    MouseArea { anchors.fill: parent; onClicked: Notifs.clearAll() }
                }
            }

            ListView {
                id: list
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: count > 0
                clip: true
                spacing: 8
                model: Notifs.list.values.slice().reverse()
                boundsBehavior: Flickable.StopAtBounds
                delegate: NotifCard {
                    required property var modelData
                    width: list.width
                    notif: modelData
                    inCenter: true
                    onCloseRequested: Notifs.dismiss(modelData)
                }
                add: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 } }
                remove: Transition { NumberAnimation { property: "opacity"; to: 0; duration: 150 } }
                displaced: Transition { NumberAnimation { properties: "y"; duration: 220; easing.type: Easing.OutCubic } }
            }

            Text {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: Notifs.count === 0
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: Notifs.dnd ? "Do not disturb is on" : "No notifications"
                color: Theme.fgDim
                font.family: Theme.font; font.pixelSize: 13
            }
        }
    }
}
