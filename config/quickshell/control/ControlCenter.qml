import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.common

// Drops from the status icons. Pages: main (quick settings), wifi, bt.
PanelWindow {
    id: win
    required property var modelData
    screen: modelData

    readonly property bool open: UI.isOpen("control", modelData.name)
    visible: open || panel.opacity > 0.01

    anchors { top: true; right: true }
    margins { top: Theme.barHeight + 2; right: 10 }
    implicitWidth: 392
    implicitHeight: 660
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-control"
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    mask: Region { item: panel }      // the empty part of this surface stays click-through

    HyprlandFocusGrab {
        windows: [win]
        active: win.open
        onCleared: UI.close()
    }

    readonly property Item current: UI.view === "wifi" ? wifi : UI.view === "bt" ? bt : main

    Rectangle {
        id: panel
        width: parent.width
        height: win.current.implicitHeight + 32
        radius: 22
        color: Theme.bg
        border.width: 1
        border.color: Theme.border
        opacity: win.open ? 1 : 0
        transform: Translate { y: win.open ? 0 : -14
            Behavior on y { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } } }
        Behavior on opacity { NumberAnimation { duration: 180 } }
        Behavior on height { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
        focus: win.open
        Keys.onEscapePressed: { if (UI.view !== "main") UI.view = "main"; else UI.close() }

        MainPage {
            id: main
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
            opacity: UI.view === "main" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: 150 } }
            onOpenPage: page => UI.view = page
        }
        WifiPage {
            id: wifi
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
            opacity: UI.view === "wifi" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: 150 } }
            onBack: UI.view = "main"
        }
        BluetoothPage {
            id: bt
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
            opacity: UI.view === "bt" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: 150 } }
            onBack: UI.view = "main"
        }
    }
}
