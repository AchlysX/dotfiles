import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import qs.common

ColumnLayout {
    id: root
    signal back()
    spacing: 10

    function syncScan() { if (Sys.btAdapter) Sys.btAdapter.discovering = root.visible && Sys.btOn }
    onVisibleChanged: syncScan()

    readonly property var devices: {
        const l = (Sys.btAdapter?.devices.values ?? []).filter(d => d.name !== "")
        return l.sort((a, b) => (b.connected - a.connected) || ((b.paired || b.bonded) - (a.paired || a.bonded))
            || a.name.localeCompare(b.name))
    }

    PageHeader {
        title: "Bluetooth"
        hasSwitch: Sys.btAdapter !== null
        checked: Sys.btOn
        onBack: root.back()
        onSwitched: { if (Sys.btAdapter) Sys.btAdapter.enabled = !Sys.btAdapter.enabled }
    }

    ListView {
        id: list
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(contentHeight, 320)
        visible: Sys.btOn && count > 0
        clip: true
        spacing: 2
        model: root.devices
        boundsBehavior: Flickable.StopAtBounds
        delegate: Rectangle {
            id: dev
            required property var modelData
            width: list.width
            height: 52
            radius: 14
            color: devMouse.containsMouse ? Theme.surfaceHi : "transparent"

            MouseArea {
                id: devMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    if (dev.modelData.connected) dev.modelData.disconnect()
                    else if (dev.modelData.paired || dev.modelData.bonded) dev.modelData.connect()
                    else dev.modelData.pair()
                }
            }
            RowLayout {
                anchors { fill: parent; leftMargin: 10; rightMargin: 12 }
                spacing: 10
                Icon { name: "bluetooth-active"; size: 16; opacity: dev.modelData.connected ? 1 : 0.5 }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    Text {
                        Layout.fillWidth: true
                        text: dev.modelData.name
                        elide: Text.ElideRight
                        color: Theme.fg
                        font.family: Theme.font; font.pixelSize: 13
                        font.weight: dev.modelData.connected ? Font.DemiBold : Font.Normal
                    }
                    Text {
                        text: {
                            const st = dev.modelData.state
                            if (dev.modelData.pairing) return "Pairing…"
                            if (st === BluetoothDeviceState.Connecting) return "Connecting…"
                            if (dev.modelData.connected)
                                return "Connected" + (dev.modelData.batteryAvailable ? " · " + Math.round(dev.modelData.battery * 100) + "%" : "")
                            return dev.modelData.paired || dev.modelData.bonded ? "Paired" : "Tap to pair"
                        }
                        color: Theme.fgDim
                        font.family: Theme.font; font.pixelSize: 11
                    }
                }
            }
        }
        displaced: Transition { NumberAnimation { properties: "y"; duration: 200; easing.type: Easing.OutCubic } }
    }

    Text {
        Layout.fillWidth: true
        Layout.preferredHeight: 80
        visible: !list.visible
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: !Sys.btAdapter ? "No Bluetooth adapter" : !Sys.btOn ? "Bluetooth is off" : "Searching for devices…"
        color: Theme.fgDim
        font.family: Theme.font; font.pixelSize: 13
    }
}
