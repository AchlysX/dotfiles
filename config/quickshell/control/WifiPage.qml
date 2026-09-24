import QtQuick
import QtQuick.Layouts
import Quickshell.Networking
import qs.common

ColumnLayout {
    id: root
    signal back()
    spacing: 10

    // Only scan while this page is on screen (scanning costs power).
    function syncScan() { if (Sys.wifiDevice) Sys.wifiDevice.scannerEnabled = root.visible && Networking.wifiEnabled }
    onVisibleChanged: syncScan()
    Connections { target: Sys; function onWifiDeviceChanged() { root.syncScan() } }
    Connections { target: Networking; function onWifiEnabledChanged() { root.syncScan() } }

    readonly property var networks: {
        const l = (Sys.wifiDevice?.networks.values ?? []).filter(n => n.name !== "")
        return l.sort((a, b) => (b.connected - a.connected) || (b.known - a.known) || (b.signalStrength - a.signalStrength))
    }

    PageHeader {
        title: "Wi-Fi"
        checked: Networking.wifiEnabled
        onBack: root.back()
        onSwitched: Networking.wifiEnabled = !Networking.wifiEnabled
    }

    ListView {
        id: list
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(contentHeight, 320)
        visible: Networking.wifiEnabled && count > 0
        clip: true
        spacing: 2
        model: root.networks
        boundsBehavior: Flickable.StopAtBounds
        delegate: WifiRow { width: list.width }
        displaced: Transition { NumberAnimation { properties: "y"; duration: 200; easing.type: Easing.OutCubic } }
    }

    Text {
        Layout.fillWidth: true
        Layout.preferredHeight: 80
        visible: !list.visible
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: !Networking.wifiEnabled ? "Wi-Fi is off" : Sys.wifiDevice ? "Looking for networks…" : "No Wi-Fi adapter"
        color: Theme.fgDim
        font.family: Theme.font; font.pixelSize: 13
    }
}
