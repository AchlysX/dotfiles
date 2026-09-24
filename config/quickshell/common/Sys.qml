pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Networking
import Quickshell.Bluetooth

// One place for system state, so the bar, OSD and control center agree.
Singleton {
    id: root

    // ---- audio ----
    readonly property var sink: Pipewire.defaultAudioSink
    PwObjectTracker { objects: [root.sink] }
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    function setVolume(v) { if (sink?.audio) sink.audio.volume = Math.max(0, Math.min(1, v)) }
    function toggleMute() { if (sink?.audio) sink.audio.muted = !sink.audio.muted }
    readonly property string volumeIcon: muted || volume <= 0 ? "audio-volume-muted"
        : volume < 0.34 ? "audio-volume-low" : volume < 0.67 ? "audio-volume-medium" : "audio-volume-high"

    readonly property var source: Pipewire.defaultAudioSource
    PwObjectTracker { objects: [root.source] }
    readonly property bool micMuted: source?.audio?.muted ?? false
    function toggleMic() { if (source?.audio) source.audio.muted = !source.audio.muted }

    // ---- brightness (brightnessctl; the backlight is the source of truth) ----
    // Never below 1%: raw minimum is effectively a black screen on an OLED.
    property real brightness: 0
    function setBrightness(v) {
        const pct = Math.round(Math.max(0.01, Math.min(1, v)) * 100)
        root.brightness = pct / 100        // optimistic, so the OSD tracks held keys
        Quickshell.execDetached(["brightnessctl", "-q", "set", pct + "%"])
        readTimer.restart()
    }
    function stepBrightness(dir) {
        // Finer steps in the dim range, where OLED changes are most visible.
        const b = root.brightness
        setBrightness(b + dir * (b < 0.1 ? 0.01 : b < 0.25 ? 0.02 : 0.05))
    }
    Timer { id: readTimer; interval: 350; onTriggered: readBrightness.running = true }
    Process {
        id: readBrightness
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                const f = text.trim().split(",")
                if (f.length > 3) root.brightness = parseInt(f[3]) / 100
            }
        }
    }
    Component.onCompleted: readBrightness.running = true

    // ---- battery ----
    readonly property var bat: UPower.displayDevice
    readonly property bool hasBattery: bat?.ready ?? false
    readonly property real batteryPct: { const p = bat?.percentage ?? 0; return p > 1 ? p / 100 : p }
    readonly property bool charging: bat?.state === UPowerDeviceState.Charging
        || bat?.state === UPowerDeviceState.FullyCharged
    readonly property bool batteryLow: hasBattery && !charging && batteryPct <= 0.15

    // ---- network ----
    readonly property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var wiredDevice: Networking.devices.values.find(d => d.type === DeviceType.Wired) ?? null
    readonly property var activeWifi: wifiDevice?.networks.values.find(n => n.connected) ?? null
    readonly property string netIcon: {
        if (activeWifi) return signalIcon(activeWifi.signalStrength)
        if (wiredDevice?.connected) return "network-wired"
        return Networking.wifiEnabled ? "network-wireless-signal-none" : "network-wireless-disabled"
    }

    function signalIcon(s) {
        return s > 0.75 ? "network-wireless-signal-excellent" : s > 0.5 ? "network-wireless-signal-good"
             : s > 0.25 ? "network-wireless-signal-ok" : "network-wireless-signal-weak"
    }

    // ---- power profile (power-profiles-daemon) ----
    readonly property int profile: PowerProfiles.profile
    readonly property string profileName: profile === PowerProfile.PowerSaver ? "Power saver"
        : profile === PowerProfile.Performance ? "Performance" : "Balanced"
    readonly property string profileIcon: profile === PowerProfile.PowerSaver ? "power-profile-power-saver"
        : profile === PowerProfile.Performance ? "power-profile-performance" : "power-profile-balanced"
    function cycleProfile() {
        if (profile === PowerProfile.PowerSaver) PowerProfiles.profile = PowerProfile.Balanced
        else if (profile === PowerProfile.Balanced)
            PowerProfiles.profile = PowerProfiles.hasPerformanceProfile ? PowerProfile.Performance : PowerProfile.PowerSaver
        else PowerProfiles.profile = PowerProfile.PowerSaver
    }

    // ---- night light ----
    property bool nightLight: false
    Process { command: ["hyprsunset", "-t", "3500"]; running: root.nightLight }

    // ---- bluetooth ----
    readonly property var btAdapter: Bluetooth.defaultAdapter
    readonly property bool btOn: btAdapter?.enabled ?? false
    readonly property bool btConnected: btOn && (btAdapter?.devices.values.some(d => d.connected) ?? false)
}
