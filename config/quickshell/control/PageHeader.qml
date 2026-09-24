import QtQuick
import QtQuick.Layouts
import qs.common

// Back arrow + title + optional switch, shared by the Wi-Fi and Bluetooth pages.
RowLayout {
    id: root
    property string title
    property bool hasSwitch: true
    property bool checked: false
    signal back()
    signal switched()

    spacing: 8
    Layout.fillWidth: true

    Item {
        Layout.preferredWidth: 30; Layout.preferredHeight: 30
        Icon { anchors.centerIn: parent; name: "go-previous"; size: 16; opacity: backArea.containsMouse ? 1 : 0.7 }
        MouseArea { id: backArea; anchors.fill: parent; hoverEnabled: true; onClicked: root.back() }
    }
    Text {
        Layout.fillWidth: true
        text: root.title
        color: Theme.fg
        font.family: Theme.font; font.pixelSize: 15; font.weight: Font.DemiBold
    }
    Toggle { visible: root.hasSwitch; checked: root.checked; onToggled: root.switched() }
}
