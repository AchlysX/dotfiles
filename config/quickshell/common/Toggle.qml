import QtQuick

Rectangle {
    id: root
    property bool checked: false
    signal toggled()
    implicitWidth: 42
    implicitHeight: 24
    radius: height / 2
    color: checked ? Theme.fg : Theme.surfaceHi
    border.width: 1
    border.color: Theme.border
    Behavior on color { ColorAnimation { duration: 160 } }

    Rectangle {
        width: 18; height: 18; radius: 9
        y: 3
        x: root.checked ? parent.width - width - 3 : 3
        color: root.checked ? Theme.bg : Theme.fgDim
        Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
    }
    MouseArea { anchors.fill: parent; onClicked: root.toggled() }
}
