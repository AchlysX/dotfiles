import QtQuick
import Quickshell.Hyprland
import qs.common

// GNOME-style workspace dots: the active one stretches into a pill.
Row {
    id: root
    required property string screenName
    spacing: 0

    Repeater {
        model: Hyprland.workspaces.values.filter(w => w.id > 0 && w.monitor?.name === root.screenName)

        delegate: Item {
            id: ws
            required property var modelData
            readonly property bool active: modelData.active

            width: pill.width + 10
            height: Theme.pillHeight

            Rectangle {
                id: pill
                anchors.centerIn: parent
                height: 6
                width: ws.active ? 20 : 6
                radius: 3
                color: ws.active ? Theme.fg : ws.modelData.urgent ? Theme.urgent : Theme.fgDim
                opacity: ws.active || hover.containsMouse ? 1 : 0.6
                Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }
            MouseArea {
                id: hover
                anchors.fill: parent
                hoverEnabled: true
                onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + ws.modelData.id + " })")
            }
        }
    }
}
