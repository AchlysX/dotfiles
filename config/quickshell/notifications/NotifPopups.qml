import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.common

// Transient toasts, top-right, on whichever monitor has focus.
PanelWindow {
    id: win
    required property var modelData
    screen: modelData

    readonly property bool onFocusedMonitor: (Hyprland.focusedMonitor?.name ?? modelData.name) === modelData.name
    visible: onFocusedMonitor && Notifs.popups.length > 0

    anchors { top: true; right: true }
    margins { top: Theme.barHeight + 8; right: 12 }
    implicitWidth: 360
    implicitHeight: Math.max(1, stack.implicitHeight)
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-notifications"

    Column {
        id: stack
        width: parent.width
        spacing: 8

        Repeater {
            model: Notifs.popups

            delegate: Item {
                id: slot
                required property var modelData
                property bool shown: false
                property bool leaving: false

                width: stack.width
                height: card.implicitHeight
                opacity: shown && !leaving ? 1 : 0
                transform: Translate { x: slot.shown && !slot.leaving ? 0 : 40
                    Behavior on x { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } } }
                Behavior on opacity { NumberAnimation { duration: 200 } }
                Component.onCompleted: shown = true

                function dismissSoon() { leaving = true; leaveTimer.start() }

                NotifCard {
                    id: card
                    width: parent.width
                    notif: slot.modelData
                    onCloseRequested: Notifs.dismiss(slot.modelData)
                }
                HoverHandler { id: hovered }
                Timer {
                    interval: slot.modelData.expireTimeout > 0 ? slot.modelData.expireTimeout * 1000 : 6000
                    running: !hovered.hovered && !slot.leaving && !card.critical
                    onTriggered: slot.dismissSoon()
                }
                Timer { id: leaveTimer; interval: 220; onTriggered: Notifs.hidePopup(slot.modelData) }
                Connections {
                    target: slot.modelData
                    function onClosed() { Notifs.hidePopup(slot.modelData) }
                }
            }
        }
    }
}
