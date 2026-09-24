import QtQuick
import qs.common

// Clickable status icon with a soft hover.
Item {
    property alias name: icon.name
    property int size: 15
    signal clicked()
    signal scrolled(int dy)
    width: size + 12
    height: Theme.pillHeight

    Icon { id: icon; anchors.centerIn: parent; size: parent.size; opacity: area.containsMouse ? 1 : 0.85
        Behavior on opacity { NumberAnimation { duration: 120 } } }
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        onClicked: parent.clicked()
        onWheel: w => parent.scrolled(w.angleDelta.y)
    }
}
