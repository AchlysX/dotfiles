import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common

// A normal floating window (Settings). Opened with: qs ipc call panel settings <page>
FloatingWindow {
    id: win
    title: "Settings"
    visible: UI.settingsOpen
    implicitWidth: 940
    implicitHeight: 660
    color: Theme.bg
    onVisibleChanged: { if (!visible) UI.settingsOpen = false }   // closed from the compositor

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // sidebar
        Rectangle {
            Layout.preferredWidth: 210
            Layout.fillHeight: true
            color: "#070708"
            Rectangle { anchors.right: parent.right; width: 1; height: parent.height; color: Theme.border }

            Column {
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: 14; topMargin: 24 }
                spacing: 4
                Text {
                    text: "Settings"
                    color: Theme.fgDim
                    font.family: Theme.font; font.pixelSize: 12
                    leftPadding: 10; bottomPadding: 8
                }
                Repeater {
                    model: [ { id: "displays", label: "Displays" }, { id: "wallpaper", label: "Wallpaper" }, { id: "power", label: "Power" } ]
                    delegate: Rectangle {
                        required property var modelData
                        readonly property bool active: UI.settingsPage === modelData.id
                        width: parent.width; height: 38; radius: 12
                        color: active ? Theme.surfaceHi : (m.containsMouse ? "#111113" : "transparent")
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Text {
                            anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                            text: modelData.label
                            color: active ? Theme.fg : Theme.fgDim
                            font.family: Theme.font; font.pixelSize: 14
                            font.weight: active ? Font.DemiBold : Font.Normal
                        }
                        MouseArea { id: m; anchors.fill: parent; hoverEnabled: true; onClicked: UI.settingsPage = modelData.id }
                    }
                }
            }
        }

        // pages
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            DisplaysPage  { anchors.fill: parent; visible: UI.settingsPage === "displays" }
            WallpaperPage { anchors.fill: parent; visible: UI.settingsPage === "wallpaper" }
            PowerPage     { anchors.fill: parent; visible: UI.settingsPage === "power" }
        }
    }
}
