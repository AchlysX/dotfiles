import QtQuick
import QtQuick.Layouts
import Quickshell.Networking
import qs.common

// One network. Known/open: tap to connect. Unknown + secured: asks for the password inline.
Rectangle {
    id: row
    required property var modelData
    property bool asking: false
    property string error: ""

    readonly property bool secured: modelData.security !== WifiSecurityType.Open
        && modelData.security !== WifiSecurityType.Owe
    readonly property bool connecting: modelData.stateChanging

    implicitHeight: main.implicitHeight + 16 + (asking ? 46 : 0)
    radius: 14
    color: rowMouse.containsMouse ? Theme.surfaceHi : "transparent"
    clip: true
    Behavior on implicitHeight { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

    function activate() {
        if (modelData.connected || connecting) return
        error = ""
        if (modelData.known || !secured) { modelData.connect(); return }
        asking = true
        pw.forceActiveFocus()
    }
    function submit() {
        if (pw.text.length === 0) return
        error = ""
        modelData.connectWithPsk(pw.text)
        pw.text = ""
        asking = false
    }

    Connections {
        target: row.modelData
        function onConnectionFailed() {
            row.error = row.secured ? "Wrong password?" : "Couldn't connect"
            row.asking = row.secured
        }
    }

    MouseArea { id: rowMouse; anchors.fill: parent; hoverEnabled: true; onClicked: row.activate() }

    RowLayout {
        id: main
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 8; leftMargin: 10; rightMargin: 10 }
        spacing: 10

        Icon { name: Sys.signalIcon(row.modelData.signalStrength); size: 16 }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Text {
                Layout.fillWidth: true
                text: row.modelData.name
                elide: Text.ElideRight
                color: Theme.fg
                font.family: Theme.font; font.pixelSize: 13
                font.weight: row.modelData.connected ? Font.DemiBold : Font.Normal
            }
            Text {
                visible: text !== ""
                text: row.error !== "" ? row.error
                    : row.connecting ? "Connecting…"
                    : row.modelData.connected ? "Connected"
                    : row.modelData.known ? "Saved" : ""
                color: row.error !== "" ? Theme.urgent : Theme.fgDim
                font.family: Theme.font; font.pixelSize: 11
            }
        }
        Icon { visible: row.secured; name: "changes-prevent"; size: 13; opacity: 0.5 }
        Text {
            visible: row.modelData.connected && rowMouse.containsMouse
            text: "Disconnect"
            color: Theme.fgDim
            font.family: Theme.font; font.pixelSize: 11
            MouseArea { anchors.fill: parent; anchors.margins: -6; onClicked: row.modelData.disconnect() }
        }
    }

    // Inline password entry
    Rectangle {
        visible: row.asking
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 8; leftMargin: 10; rightMargin: 10 }
        height: 34
        radius: 10
        color: Theme.bg
        border.width: 1
        border.color: pw.activeFocus ? Theme.fgDim : Theme.border

        TextInput {
            id: pw
            anchors { fill: parent; leftMargin: 12; rightMargin: 74 }
            verticalAlignment: TextInput.AlignVCenter
            echoMode: TextInput.Password
            color: Theme.fg
            selectionColor: Theme.fgDim
            clip: true
            font.family: Theme.font; font.pixelSize: 13
            onAccepted: row.submit()
            Text {
                visible: pw.text === ""
                anchors.verticalCenter: parent.verticalCenter
                text: "Password"
                color: Theme.fgDim
                font: pw.font
            }
        }
        Rectangle {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 4 }
            width: 62; height: 26; radius: 8
            color: Theme.fg
            Text { anchors.centerIn: parent; text: "Connect"; color: Theme.bg
                font.family: Theme.font; font.pixelSize: 12; font.weight: Font.DemiBold }
            MouseArea { anchors.fill: parent; onClicked: row.submit() }
        }
    }
}
