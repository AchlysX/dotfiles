import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import qs.common

Rectangle {
    id: card
    required property var notif
    property bool inCenter: false
    signal closeRequested()

    readonly property bool critical: notif.urgency === NotificationUrgency.Critical
    readonly property string imgSource: {
        if (notif.image) return notif.image
        const ic = notif.appIcon
        if (!ic) return ""
        return ic.startsWith("/") ? "file://" + ic : Quickshell.iconPath(ic, true)
    }
    readonly property var extraActions: notif.actions.filter(a => a.identifier !== "default")
    readonly property var defaultAction: notif.actions.find(a => a.identifier === "default") ?? null

    implicitWidth: 360
    implicitHeight: body.implicitHeight + 26
    radius: 14
    color: inCenter ? Theme.surfaceHi : Theme.surface
    border.width: 1
    border.color: critical ? Theme.urgent : Theme.border

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if (card.defaultAction) card.defaultAction.invoke()
            card.closeRequested()
        }
    }

    RowLayout {
        id: body
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 13 }
        spacing: 12

        ClippingRectangle {
            Layout.alignment: Qt.AlignTop
            Layout.preferredWidth: 38
            Layout.preferredHeight: 38
            radius: 10
            color: Theme.surfaceHi
            Image {
                anchors.fill: parent
                source: card.imgSource
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: status === Image.Ready
            }
            Text {
                anchors.centerIn: parent
                visible: card.imgSource === ""
                text: (card.notif.appName || "?").charAt(0).toUpperCase()
                color: Theme.fgDim
                font.family: Theme.font; font.pixelSize: 16; font.weight: Font.DemiBold
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: card.notif.appName
                    elide: Text.ElideRight
                    color: Theme.fgDim
                    font.family: Theme.font; font.pixelSize: 11
                }
                Text {
                    text: area.containsMouse ? "✕" : Notifs.ago(card.notif.id)
                    color: Theme.fgDim
                    font.family: Theme.font; font.pixelSize: 11
                    MouseArea {
                        anchors.fill: parent; anchors.margins: -6
                        enabled: area.containsMouse
                        onClicked: card.closeRequested()
                    }
                }
            }
            Text {
                Layout.fillWidth: true
                visible: text !== ""
                text: card.notif.summary
                elide: Text.ElideRight
                color: Theme.fg
                font.family: Theme.font; font.pixelSize: 13; font.weight: Font.DemiBold
            }
            Text {
                Layout.fillWidth: true
                visible: text !== ""
                text: card.notif.body
                textFormat: Text.StyledText
                wrapMode: Text.WordWrap
                maximumLineCount: 4
                elide: Text.ElideRight
                color: Theme.fgDim
                font.family: Theme.font; font.pixelSize: 12
            }
            Flow {
                Layout.fillWidth: true
                Layout.topMargin: 4
                visible: card.extraActions.length > 0
                spacing: 6
                Repeater {
                    model: card.extraActions
                    delegate: Rectangle {
                        required property var modelData
                        width: label.implicitWidth + 20; height: 26; radius: 8
                        color: btn.containsMouse ? Theme.border : "transparent"
                        border.width: 1; border.color: Theme.border
                        Text {
                            id: label
                            anchors.centerIn: parent
                            text: parent.modelData.text
                            color: Theme.fg
                            font.family: Theme.font; font.pixelSize: 12
                        }
                        MouseArea {
                            id: btn
                            anchors.fill: parent; hoverEnabled: true
                            onClicked: { parent.modelData.invoke(); card.closeRequested() }
                        }
                    }
                }
            }
        }
    }
}
