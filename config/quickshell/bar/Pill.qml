import QtQuick
import qs.common

// The only thing the bar draws: a small black capsule around a group.
Rectangle {
    default property alias content: holder.data
    property int padding: 12
    implicitWidth: holder.childrenRect.width + padding * 2
    implicitHeight: Theme.pillHeight
    radius: height / 2
    color: Theme.bg
    border.width: 1
    border.color: Theme.border
    Item {
        id: holder
        anchors.centerIn: parent
        width: childrenRect.width
        height: parent.height
    }
}
