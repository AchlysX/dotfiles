import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.common

// Auto-hiding dock. Rests off-screen (OLED-friendly), rises when the pointer
// touches the bottom edge, and magnifies icons under the pointer.
PanelWindow {
    id: win
    required property var modelData
    screen: modelData

    readonly property int base: 44
    property bool shown: false

    anchors { bottom: true }
    implicitWidth: Apps.items.length * 64 + 320
    implicitHeight: 160
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "qs-dock"
    // Only the dock (or a thin strip at the screen edge while hidden) takes input.
    mask: Region { item: hit }

    Timer { id: hideTimer; interval: 450; onTriggered: win.shown = false }

    Item {
        id: hit
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        width: win.shown ? body.width + 80 : 360
        height: win.shown ? 130 : 3

        HoverHandler {
            id: hover
            onHoveredChanged: {
                if (hovered) { hideTimer.stop(); win.shown = true }
                else hideTimer.restart()
            }
        }

        // Tracks the pointer for the zoom. No buttons accepted, so clicks reach the icons.
        MouseArea {
            id: pointer
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
        }

        Rectangle {
            id: body
            x: (hit.width - width) / 2
            width: row.width + 24
            height: win.base + 20
            radius: 24
            color: "#eb000000"
            border.width: 1
            border.color: Theme.border
            anchors.bottom: parent.bottom
            anchors.bottomMargin: win.shown ? 10 : -(height + 24)
            Behavior on anchors.bottomMargin { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

            Row {
                id: row
                x: 12
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                spacing: 0

                Repeater {
                    model: Apps.items
                    delegate: Item {
                        id: slot
                        required property var modelData
                        readonly property bool running: modelData.windows.length > 0
                        readonly property bool focused: modelData.windows.some(w => w.activated)

                        // Pointer distance (in dock coordinates) drives a smooth bell-curve zoom.
                        readonly property real cx: body.x + row.x + slot.x + slot.width / 2
                        readonly property real dist: hover.hovered ? Math.abs(pointer.mouseX - cx) : 9999
                        readonly property real zoom: 1 + 0.5 * Math.exp(-(dist * dist) / (2 * 50 * 50))
                        property real level: zoom
                        Behavior on level { NumberAnimation { duration: 70 } }

                        width: win.base * 1.3          // fixed pitch: only the icons grow, so the zoom can't feed back into itself
                        height: win.base

                        Image {
                            id: icon
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: win.base * slot.level
                            height: width
                            source: Apps.iconFor(slot.modelData.appId)
                            sourceSize: Qt.size(128, 128)
                            smooth: true
                            mipmap: true
                            fillMode: Image.PreserveAspectFit
                        }
                        // running indicator
                        Rectangle {
                            visible: slot.running
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.bottom
                            anchors.topMargin: 4
                            width: slot.focused ? 12 : 4; height: 4; radius: 2
                            color: slot.focused ? Theme.fg : Theme.fgDim
                            Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                        }
                        // name tooltip
                        Rectangle {
                            visible: slot.dist < slot.width / 2 && hover.hovered
                            z: 10
                            anchors.horizontalCenter: icon.horizontalCenter
                            anchors.bottom: icon.top
                            anchors.bottomMargin: 10
                            width: tip.implicitWidth + 20; height: 26; radius: 13
                            color: Theme.bg; border.width: 1; border.color: Theme.border
                            Text {
                                id: tip
                                anchors.centerIn: parent
                                text: Apps.nameFor(slot.modelData.appId)
                                color: Theme.fg
                                font.family: Theme.font; font.pixelSize: 12
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            anchors.topMargin: -30
                            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                            onClicked: m => {
                                if (m.button === Qt.RightButton) Apps.togglePin(slot.modelData.appId)
                                else if (m.button === Qt.MiddleButton) Apps.launch(slot.modelData.appId)
                                else Apps.activate(slot.modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}
