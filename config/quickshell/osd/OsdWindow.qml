import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.common

// Volume / brightness / mic pill. Springs in, fill glides, fades out.
PanelWindow {
    id: win
    required property var modelData
    screen: modelData

    readonly property bool onFocusedMonitor: (Hyprland.focusedMonitor?.name ?? modelData.name) === modelData.name
    visible: onFocusedMonitor && (Osd.active || pill.opacity > 0.01)

    anchors { bottom: true }
    margins.bottom: 84
    implicitWidth: 320
    implicitHeight: 76
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-osd"
    mask: Region {}      // never steals clicks

    Rectangle {
        id: pill
        anchors.centerIn: parent
        width: Osd.hasBar ? 280 : 76
        height: 52
        radius: 26
        color: Theme.bg
        border.width: 1
        border.color: Theme.border

        opacity: Osd.active ? 1 : 0
        scale: Osd.active ? 1 : 0.9
        transform: Translate { y: Osd.active ? 0 : 10
            Behavior on y { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } } }
        Behavior on opacity { NumberAnimation { duration: Osd.active ? 90 : 240; easing.type: Easing.OutCubic } }
        Behavior on scale { SpringAnimation { spring: 6; damping: 0.5; mass: 0.5 } }
        Behavior on width { SpringAnimation { spring: 6; damping: 0.55; mass: 0.5 } }

        Icon {
            id: glyph
            anchors.verticalCenter: parent.verticalCenter
            x: Osd.hasBar ? 20 : (parent.width - width) / 2
            name: Osd.icon
            size: 20
            opacity: Osd.off ? 0.55 : 1
        }

        Rectangle {
            id: track
            visible: Osd.hasBar
            anchors.verticalCenter: parent.verticalCenter
            x: 56
            width: parent.width - 56 - 62
            height: 6
            radius: 3
            color: Theme.surfaceHi

            Rectangle {
                height: parent.height
                radius: 3
                width: parent.width * Math.max(0, Math.min(1, Osd.value))
                color: Osd.off ? Theme.fgDim : Theme.fg
                // Springy fill so held keys feel liquid instead of steppy.
                Behavior on width { SpringAnimation { spring: 9; damping: 0.7; mass: 0.4 } }
            }
        }

        Text {
            visible: Osd.hasBar
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 20
            width: 30
            horizontalAlignment: Text.AlignRight
            text: Osd.off ? "off" : Math.round(Osd.value * 100)
            color: Osd.off ? Theme.fgDim : Theme.fg
            font.family: Theme.font; font.pixelSize: 13; font.weight: Font.Medium
            font.features: { "tnum": 1 }
        }
    }
}
