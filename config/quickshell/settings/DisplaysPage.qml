import QtQuick
import QtQuick.Layouts
import qs.common

Flickable {
    id: root
    contentHeight: col.implicitHeight + 48
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    Component.onCompleted: { Displays.refresh(); Displays.loadFromLive() }

    // One display's mode / refresh / scale controls.
    component MonitorCard: Rectangle {
        id: card
        required property string which          // "b" | "e"
        required property var monitor
        readonly property string mode: which === "b" ? Displays.bMode : Displays.eMode
        readonly property real scale: which === "b" ? Displays.bScale : Displays.eScale

        visible: monitor !== null
        Layout.fillWidth: true
        implicitHeight: inner.implicitHeight + 32
        radius: 18
        color: Theme.surface
        border.width: 1
        border.color: Theme.border

        ColumnLayout {
            id: inner
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
            spacing: 12

            RowLayout {
                Text {
                    text: card.which === "b" ? "Built-in display" : "External display"
                    color: Theme.fg
                    font.family: Theme.font; font.pixelSize: 15; font.weight: Font.DemiBold
                }
                Text {
                    text: card.monitor ? card.monitor.name : ""
                    color: Theme.fgDim
                    font.family: Theme.font; font.pixelSize: 12
                }
            }

            Text { text: "Resolution"; color: Theme.fgDim; font.family: Theme.font; font.pixelSize: 12 }
            Flow {
                Layout.fillWidth: true; spacing: 6
                Repeater {
                    model: Displays.resolutions(card.monitor)
                    delegate: Chip {
                        required property string modelData
                        text: modelData.replace("x", " × ")
                        selected: Displays.resOf(card.mode) === modelData
                        onClicked: Displays.setRes(card.which, modelData)
                    }
                }
            }

            Text { text: "Refresh rate"; color: Theme.fgDim; font.family: Theme.font; font.pixelSize: 12 }
            Flow {
                Layout.fillWidth: true; spacing: 6
                Repeater {
                    model: Displays.refreshes(card.monitor, Displays.resOf(card.mode))
                    delegate: Chip {
                        required property string modelData
                        text: modelData + " Hz"
                        selected: Displays.hzOf(card.mode) === modelData
                        onClicked: Displays.setHz(card.which, modelData)
                    }
                }
            }

            Text { text: "Scale"; color: Theme.fgDim; font.family: Theme.font; font.pixelSize: 12 }
            Flow {
                Layout.fillWidth: true; spacing: 6
                Repeater {
                    model: Displays.validScales(Displays.resOf(card.mode))
                    delegate: Chip {
                        required property real modelData
                        text: Math.round(modelData * 100) + "%"
                        selected: Math.abs(card.scale - modelData) < 0.001
                        onClicked: { if (card.which === "b") Displays.bScale = modelData; else Displays.eScale = modelData }
                    }
                }
            }
        }
    }

    ColumnLayout {
        id: col
        x: 24; y: 24
        width: root.width - 48
        spacing: 18

        Text {
            text: "Displays"
            color: Theme.fg
            font.family: Theme.font; font.pixelSize: 24; font.weight: Font.DemiBold
        }

        // ---- arrangement preview ----
        Rectangle {
            id: preview
            visible: Displays.builtin !== null
            Layout.fillWidth: true
            implicitHeight: 220
            radius: 18
            color: Theme.surface
            border.width: 1
            border.color: Theme.border

            readonly property var bl: Displays.logical(Displays.bMode || "1920x1080@60", Displays.bScale)
            readonly property var el: Displays.logical(Displays.eMode || "1920x1080@60", Displays.eScale)
            readonly property bool two: Displays.docked
            readonly property bool mirrored: two && Displays.layout === "mirror"
            readonly property var ep: mirrored ? { x: 0, y: 0 } : Displays.externalPosition()
            readonly property real minX: two && !mirrored ? Math.min(0, ep.x) : 0
            readonly property real minY: two && !mirrored ? Math.min(0, ep.y) : 0
            readonly property real maxX: two && !mirrored ? Math.max(bl.w, ep.x + el.w) : bl.w
            readonly property real maxY: two && !mirrored ? Math.max(bl.h, ep.y + el.h) : bl.h
            readonly property real k: Math.min((width - 60) / (maxX - minX), (height - 50) / (maxY - minY))

            Item {
                anchors.centerIn: parent
                width: (preview.maxX - preview.minX) * preview.k
                height: (preview.maxY - preview.minY) * preview.k

                Rectangle {
                    visible: preview.two
                    x: (preview.ep.x - preview.minX) * preview.k
                    y: (preview.ep.y - preview.minY) * preview.k
                    width: preview.el.w * preview.k; height: preview.el.h * preview.k
                    radius: 6; color: "#141416"
                    border.width: 1; border.color: Theme.fgDim
                    Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                    Behavior on y { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                    Text { anchors.centerIn: parent; text: Displays.external ? Displays.external.name : ""
                        color: Theme.fgDim; font.family: Theme.font; font.pixelSize: 12 }
                }
                Rectangle {
                    x: (0 - preview.minX) * preview.k
                    y: (0 - preview.minY) * preview.k
                    width: preview.bl.w * preview.k; height: preview.bl.h * preview.k
                    radius: 6; color: "#1c1c20"
                    border.width: 1; border.color: Theme.fg
                    Text { anchors.centerIn: parent; text: Displays.builtin ? Displays.builtin.name : ""
                        color: Theme.fg; font.family: Theme.font; font.pixelSize: 12 }
                }
            }
        }

        // ---- when docked ----
        Rectangle {
            visible: Displays.docked
            Layout.fillWidth: true
            implicitHeight: dock.implicitHeight + 32
            radius: 18
            color: Theme.surface
            border.width: 1
            border.color: Theme.border

            ColumnLayout {
                id: dock
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
                spacing: 12

                Text { text: "When an external display is connected"; color: Theme.fg
                    font.family: Theme.font; font.pixelSize: 15; font.weight: Font.DemiBold }

                Text { text: "Mode"; color: Theme.fgDim; font.family: Theme.font; font.pixelSize: 12 }
                Row {
                    spacing: 6
                    Chip { text: "Extend"; selected: Displays.layout === "extend"; onClicked: Displays.layout = "extend" }
                    Chip { text: "Mirror"; selected: Displays.layout === "mirror"; onClicked: Displays.layout = "mirror" }
                }

                Text { text: "External display is"; color: Theme.fgDim; font.family: Theme.font; font.pixelSize: 12
                    visible: Displays.layout === "extend" }
                Row {
                    visible: Displays.layout === "extend"
                    spacing: 6
                    Chip { text: "Above";  selected: Displays.placement === "above"; onClicked: Displays.placement = "above" }
                    Chip { text: "Below";  selected: Displays.placement === "below"; onClicked: Displays.placement = "below" }
                    Chip { text: "Left of";  selected: Displays.placement === "left";  onClicked: Displays.placement = "left" }
                    Chip { text: "Right of"; selected: Displays.placement === "right"; onClicked: Displays.placement = "right" }
                }

                Text { text: "Alignment"; color: Theme.fgDim; font.family: Theme.font; font.pixelSize: 12
                    visible: Displays.layout === "extend" }
                Row {
                    visible: Displays.layout === "extend"
                    spacing: 6
                    Chip { text: Displays.placement === "above" || Displays.placement === "below" ? "Left edge" : "Top edge"
                        selected: Displays.align === "start"; onClicked: Displays.align = "start" }
                    Chip { text: "Centered"; selected: Displays.align === "center"; onClicked: Displays.align = "center" }
                    Chip { text: Displays.placement === "above" || Displays.placement === "below" ? "Right edge" : "Bottom edge"
                        selected: Displays.align === "end"; onClicked: Displays.align = "end" }
                }
            }
        }

        MonitorCard { which: "b"; monitor: Displays.builtin }
        MonitorCard { which: "e"; monitor: Displays.external }

        // ---- apply / confirm ----
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            visible: !Displays.pending
            Chip { text: "Apply"; selected: true; onClicked: Displays.apply() }
            Chip { text: "Reset"; onClicked: Displays.loadFromLive() }
            Item { Layout.fillWidth: true }
        }
        Rectangle {
            visible: Displays.pending
            Layout.fillWidth: true
            implicitHeight: 64
            radius: 18
            color: Theme.surface
            border.width: 1
            border.color: Theme.fgDim
            RowLayout {
                anchors { fill: parent; leftMargin: 18; rightMargin: 14 }
                spacing: 10
                Text {
                    Layout.fillWidth: true
                    text: "Keep these display settings?  Reverting in " + Displays.countdown + " s"
                    color: Theme.fg
                    font.family: Theme.font; font.pixelSize: 14
                }
                Chip { text: "Keep";   selected: true; onClicked: Displays.keep() }
                Chip { text: "Revert"; onClicked: Displays.revert() }
            }
        }
    }
}
