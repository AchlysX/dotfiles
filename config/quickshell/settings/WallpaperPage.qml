import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import qs.common

Item {
    id: root
    readonly property string home: Quickshell.env("HOME")
    property string current: ""

    FileView {
        id: state
        path: root.home + "/.local/state/wallpaper"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.current = text().trim()
    }

    Text {
        id: title
        x: 24; y: 24
        text: "Wallpaper"
        color: Theme.fg
        font.family: Theme.font; font.pixelSize: 24; font.weight: Font.DemiBold
    }
    Text {
        anchors { left: title.left; top: title.bottom; topMargin: 6 }
        text: "Images in ~/Pictures/Wallpapers appear here. Drop new ones in and they show up."
        color: Theme.fgDim
        font.family: Theme.font; font.pixelSize: 12
    }

    GridView {
        id: grid
        anchors { fill: parent; topMargin: 90; leftMargin: 24; rightMargin: 16; bottomMargin: 16 }
        cellWidth: Math.floor(width / Math.max(1, Math.floor(width / 230)))
        cellHeight: cellWidth * 0.66
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        model: FolderListModel {
            folder: "file://" + root.home + "/Pictures/Wallpapers"
            nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp"]
            showDirs: false
            sortField: FolderListModel.Name
        }
        delegate: Item {
            id: cell
            required property string filePath
            required property string fileName
            readonly property bool active: root.current === filePath
            width: grid.cellWidth; height: grid.cellHeight

            Rectangle {
                anchors { fill: parent; margins: 6 }
                radius: 14
                color: Theme.surface
                border.width: cell.active ? 2 : 1
                border.color: cell.active ? Theme.fg : Theme.border

                Image {
                    anchors { fill: parent; margins: cell.active ? 4 : 2 }
                    source: "file://" + cell.filePath
                    sourceSize: Qt.size(460, 300)
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    layer.enabled: true
                }
                Text {
                    anchors { left: parent.left; bottom: parent.bottom; margins: 12 }
                    text: cell.fileName.replace(/\.[^.]+$/, "")
                    color: Theme.fg
                    font.family: Theme.font; font.pixelSize: 12; font.weight: Font.DemiBold
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.current = cell.filePath
                        Quickshell.execDetached([root.home + "/.config/hypr/scripts/wallpaper.sh", cell.filePath])
                    }
                }
            }
        }
    }
}
