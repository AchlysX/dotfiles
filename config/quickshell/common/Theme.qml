pragma Singleton
import QtQuick
import Quickshell

// OLED-first palette: true black surfaces (pixels off), never pure white,
// neutral accents (blue subpixels age fastest, so no blue UI chrome).
Singleton {
    readonly property color bg:        "#000000"
    readonly property color surface:   "#0d0d0e"
    readonly property color surfaceHi: "#1a1a1c"
    readonly property color border:    "#22ffffff"
    readonly property color fg:        "#dcdcde"
    readonly property color fgDim:     "#84848a"
    readonly property color accent:    "#dcdcde"
    readonly property color good:      "#7bd88f"
    readonly property color urgent:    "#e5484d"

    readonly property string font: "Inter"
    readonly property int barHeight: 38
    readonly property int pillHeight: 30
    readonly property int radius: 16

    // Slow pixel shift so static bar content never sits on the same pixels.
    property real shiftX: 0
    property real shiftY: 0
    Behavior on shiftX { NumberAnimation { duration: 20000; easing.type: Easing.InOutSine } }
    Behavior on shiftY { NumberAnimation { duration: 20000; easing.type: Easing.InOutSine } }
    Timer {
        interval: 180000; running: true; repeat: true
        onTriggered: {
            Theme.shiftX = Math.round(Math.random() * 4 - 2)
            Theme.shiftY = Math.round(Math.random() * 2 - 1)
        }
    }
}
