pragma Singleton
import QtQuick
import Quickshell

// What the on-screen display is currently showing.
Singleton {
    property string kind: "volume"      // volume | brightness | mic
    property bool active: false

    readonly property real value: kind === "brightness" ? Sys.brightness
        : kind === "mic" ? (Sys.micMuted ? 0 : 1) : Sys.muted ? 0 : Sys.volume
    readonly property bool off: kind === "volume" ? Sys.muted : kind === "mic" ? Sys.micMuted : false
    readonly property string icon: kind === "brightness" ? "display-brightness"
        : kind === "mic" ? (Sys.micMuted ? "microphone-sensitivity-muted" : "microphone-sensitivity-high")
        : Sys.volumeIcon
    readonly property bool hasBar: kind !== "mic"

    function show(k) { kind = k; active = true; hideTimer.restart() }

    function volume(action) {
        if (action === "mute") Sys.toggleMute()
        else {
            if (Sys.muted) Sys.toggleMute()
            Sys.setVolume(Sys.volume + (action === "up" ? 0.05 : -0.05))
        }
        show("volume")
    }
    function brightness(action) { Sys.stepBrightness(action === "up" ? 1 : -1); show("brightness") }
    function mic() { Sys.toggleMic(); show("mic") }

    Timer { id: hideTimer; interval: 1500; onTriggered: Osd.active = false }
}
