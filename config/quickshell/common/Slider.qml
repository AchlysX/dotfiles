import QtQuick

// Full-width pill slider (macOS-style): the fill is the value, the icon sits inside.
Item {
    id: root
    property real value: 0
    property string icon
    property string label
    signal moved(real v)
    signal iconClicked()

    implicitHeight: 40
    implicitWidth: 300

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: Theme.surfaceHi

        Rectangle {
            height: parent.height
            width: Math.max(height, parent.width * Math.max(0, Math.min(1, root.value)))
            radius: height / 2
            color: "#3c3c42"
            // Snappy while dragging, springy when the value changes underneath us (keys).
            Behavior on width {
                enabled: !drag.pressed
                NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
            }
        }

        MouseArea {
            id: drag
            anchors.fill: parent
            function setFrom(x) { root.moved(Math.max(0, Math.min(1, x / width))) }
            onPressed: m => setFrom(m.x)
            onPositionChanged: m => { if (pressed) setFrom(m.x) }
        }

        Icon {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            name: root.icon
            size: 18
            MouseArea {
                anchors.fill: parent
                anchors.margins: -8
                onClicked: root.iconClicked()
            }
        }
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: Theme.fgDim
            font.family: Theme.font
            font.pixelSize: 12
            font.features: { "tnum": 1 }
        }
    }
}
