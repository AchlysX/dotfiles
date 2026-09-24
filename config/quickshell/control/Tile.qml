import QtQuick
import qs.common

// Quick-setting tile. `active` = feature is on. Optional chevron opens a detail page.
Rectangle {
    id: tile
    property string icon
    property string title
    property string subtitle
    property bool active: false
    property bool hasMore: false
    signal clicked()
    signal moreClicked()

    implicitHeight: 60
    radius: 18
    color: mouse.containsMouse ? "#1f1f22" : (active ? "#19191c" : "#0f0f11")
    border.width: 1
    border.color: active ? "#3affffff" : Theme.border
    Behavior on color { ColorAnimation { duration: 120 } }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: tile.clicked()
    }

    Rectangle {
        id: badge
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        width: 36; height: 36; radius: 18
        color: tile.active ? "#34343a" : "#1a1a1d"
        Icon {
            anchors.centerIn: parent
            name: tile.icon
            size: 18
            opacity: tile.active ? 1 : 0.5
        }
    }

    Column {
        anchors.left: badge.right
        anchors.leftMargin: 10
        anchors.right: tile.hasMore ? chevron.left : parent.right
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        spacing: 1
        Text {
            width: parent.width
            text: tile.title
            elide: Text.ElideRight
            color: Theme.fg
            font.family: Theme.font; font.pixelSize: 13; font.weight: Font.DemiBold
        }
        Text {
            width: parent.width
            text: tile.subtitle
            visible: text !== ""
            elide: Text.ElideRight
            color: Theme.fgDim
            font.family: Theme.font; font.pixelSize: 11
        }
    }

    Item {
        id: chevron
        visible: tile.hasMore
        anchors.right: parent.right
        width: 34; height: parent.height
        Icon { anchors.centerIn: parent; name: "go-next"; size: 14; opacity: chevMouse.containsMouse ? 1 : 0.55 }
        MouseArea {
            id: chevMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: tile.moreClicked()
        }
    }
}
