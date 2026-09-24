import QtQuick

// Bundled symbolic icon (assets/icons/<name>.svg), pre-tinted for the dark theme.
Image {
    property string name
    property int size: 16
    width: size
    height: size
    source: name ? Qt.resolvedUrl("../assets/icons/" + name + ".svg") : ""
    sourceSize: Qt.size(size * 3, size * 3)
    smooth: true
    mipmap: true
}
