import QtQuick

// Selectable pill used all over the settings app.
Rectangle {
    id: chip
    property string text
    property bool selected: false
    property bool enabled: true
    signal clicked()

    implicitWidth: label.implicitWidth + 26
    implicitHeight: 32
    radius: height / 2
    color: selected ? Theme.fg : (area.containsMouse && enabled ? Theme.surfaceHi : "transparent")
    border.width: 1
    border.color: selected ? Theme.fg : Theme.border
    opacity: enabled ? 1 : 0.4
    Behavior on color { ColorAnimation { duration: 120 } }

    Text {
        id: label
        anchors.centerIn: parent
        text: chip.text
        color: chip.selected ? Theme.bg : Theme.fg
        font.family: Theme.font
        font.pixelSize: 13
        font.weight: chip.selected ? Font.DemiBold : Font.Normal
    }
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        enabled: chip.enabled
        onClicked: chip.clicked()
    }
}
