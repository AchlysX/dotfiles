import QtQuick
import qs.common

Item {
    id: root
    signal clicked()
    visible: Sys.hasBattery
    width: visible ? row.width + 12 : 0
    height: Theme.pillHeight

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6
        Item {
            width: 25; height: 12
            anchors.verticalCenter: parent.verticalCenter
            Rectangle {
                width: 22; height: 12; radius: 3.5
                color: "transparent"
                border.width: 1.2
                border.color: Theme.fgDim
                Rectangle {
                    x: 2; y: 2
                    height: parent.height - 4
                    width: Math.max(2, (parent.width - 4) * Sys.batteryPct)
                    radius: 1.5
                    color: Sys.charging ? Theme.good : Sys.batteryLow ? Theme.urgent : Theme.fg
                    Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                }
            }
            Rectangle { x: 22.5; y: 4; width: 2; height: 4; radius: 1; color: Theme.fgDim }
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Math.round(Sys.batteryPct * 100) + "%"
            color: Sys.batteryLow ? Theme.urgent : Theme.fg
            font.family: Theme.font
            font.pixelSize: 12
        }
    }
    MouseArea { anchors.fill: parent; onClicked: root.clicked() }
}
