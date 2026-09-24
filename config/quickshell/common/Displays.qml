pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

// Display settings. The draft (b*/e*/layout/...) is what the UI edits; apply()
// writes it as ~/.config/hypr/modules/monitors_generated.lua and reloads Hyprland,
// then gives 10 s to confirm before reverting (so a bad mode can't strand you).
Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string genFile: home + "/.config/hypr/modules/monitors_generated.lua"

    // ---- live state ----
    readonly property var monitors: Hyprland.monitors.values
    readonly property var builtin: monitors.find(m => m.name.startsWith("eDP")) ?? null
    readonly property var external: monitors.find(m => !m.name.startsWith("eDP")) ?? null
    readonly property bool docked: builtin !== null && external !== null

    // ---- draft ----
    property string bMode: ""       // "2560x1600@165"
    property real   bScale: 1
    property string eMode: ""
    property real   eScale: 1
    property string layout: "extend"     // extend | mirror
    property string placement: "above"   // above | below | left | right   (external relative to built-in)
    property string align: "center"      // start | center | end

    // last *confirmed* arrangement (what is on disk / on screen)
    property var applied: ({ layout: "extend", placement: "above", align: "center" })

    // ---- confirm / revert ----
    property bool pending: false
    property int countdown: 0

    // ---------- helpers ----------
    function fmtHz(x) { return String(Math.round(parseFloat(x) * 100) / 100) }
    function currentMode(m) { return m ? (m.lastIpcObject.width + "x" + m.lastIpcObject.height + "@" + fmtHz(m.lastIpcObject.refreshRate)) : "" }
    function modeList(m) { return (m?.lastIpcObject.availableModes ?? []).map(s => s.replace("Hz", "")) }
    function resolutions(m) {
        const out = []
        for (const s of modeList(m)) { const r = s.split("@")[0]; if (!out.includes(r)) out.push(r) }
        return out
    }
    function refreshes(m, res) {
        const out = []
        for (const s of modeList(m)) {
            const p = s.split("@"); if (p[0] === res) { const hz = fmtHz(p[1]); if (!out.includes(hz)) out.push(hz) }
        }
        return out.sort((a, b) => parseFloat(b) - parseFloat(a))
    }
    function validScales(res) {
        const p = res.split("x"), w = +p[0], h = +p[1]
        return [1, 1.25, 1.5, 1.6, 1.75, 2, 2.5, 3].filter(s => {
            const lw = w / s, lh = h / s
            return Math.abs(lw - Math.round(lw)) < 0.005 && Math.abs(lh - Math.round(lh)) < 0.005
        })
    }
    function resOf(mode) { return mode.split("@")[0] }
    function hzOf(mode) { return mode.split("@")[1] }
    function logical(mode, scale) { const p = resOf(mode).split("x"); return { w: Math.round(+p[0] / scale), h: Math.round(+p[1] / scale) } }

    function setRes(which, res) {
        const m = which === "b" ? builtin : external
        const cur = which === "b" ? bMode : eMode
        const list = refreshes(m, res)
        const hz = list.includes(hzOf(cur)) ? hzOf(cur) : list[0]
        const mode = res + "@" + hz
        const sc = which === "b" ? bScale : eScale
        const scales = validScales(res)
        const scale = scales.includes(sc) ? sc : scales[0]
        if (which === "b") { bMode = mode; bScale = scale } else { eMode = mode; eScale = scale }
    }
    function setHz(which, hz) {
        const cur = which === "b" ? bMode : eMode
        const mode = resOf(cur) + "@" + hz
        if (which === "b") bMode = mode; else eMode = mode
    }

    // Position of the external display relative to the built-in one (built-in stays at 0,0).
    function externalPosition() {
        const b = logical(bMode, bScale), e = logical(eMode, eScale)
        const off = (big, small) => align === "start" ? 0 : align === "end" ? big - small : Math.round((big - small) / 2)
        if (placement === "above") return { x: off(b.w, e.w), y: -e.h }
        if (placement === "below") return { x: off(b.w, e.w), y: b.h }
        if (placement === "left")  return { x: -e.w, y: off(b.h, e.h) }
        return { x: b.w, y: off(b.h, e.h) }
    }

    function generate() {
        let t = "-- Written by the Quickshell settings app (Settings > Displays).\n"
              + "-- Delete this file to fall back to the defaults in monitors.lua.\n"
        if (builtin)
            t += `hl.monitor({ output = "${builtin.name}", mode = "${bMode}", position = "0x0", scale = "${bScale}" })\n`
        if (external) {
            if (layout === "mirror")
                t += `hl.monitor({ output = "${external.name}", mode = "${eMode}", position = "auto", scale = "${eScale}", mirror = "${builtin?.name}" })\n`
            else {
                const p = externalPosition()
                t += `hl.monitor({ output = "${external.name}", mode = "${eMode}", position = "${p.x}x${p.y}", scale = "${eScale}" })\n`
            }
        }
        return t
    }

    // ---------- lifecycle ----------
    function loadFromLive() {
        if (builtin) { bMode = currentMode(builtin); bScale = builtin.lastIpcObject.scale }
        if (external) { eMode = currentMode(external); eScale = external.lastIpcObject.scale }
    }
    function refresh() { Hyprland.refreshMonitors() }

    function shell(script, arg) {
        Quickshell.execDetached(["sh", "-c", script, "sh", arg ?? ""])
    }

    function apply() {
        const f = genFile
        shell(`cp -f "${f}" "${f}.bak" 2>/dev/null || rm -f "${f}.bak"; printf '%s' "$1" > "${f}"; hyprctl reload`, generate())
        pending = true
        countdown = 10
        confirmTimer.restart()
    }
    function keep() {
        pending = false; confirmTimer.stop()
        applied = { layout: layout, placement: placement, align: align }
        shell(`rm -f "${genFile}.bak"; mkdir -p "${home}/.local/state/quickshell"; printf '%s' "$1" > "${home}/.local/state/quickshell/displays.json"`,
              JSON.stringify(applied))
    }
    function revert() {
        pending = false; confirmTimer.stop()
        layout = applied.layout; placement = applied.placement; align = applied.align
        const f = genFile
        shell(`if [ -f "${f}.bak" ]; then mv -f "${f}.bak" "${f}"; else rm -f "${f}"; fi; hyprctl reload`)
        reloadTimer.restart()
    }

    Timer {
        id: confirmTimer
        interval: 1000; repeat: true
        onTriggered: { root.countdown--; if (root.countdown <= 0) root.revert() }
    }
    Timer { id: reloadTimer; interval: 1500; onTriggered: { root.refresh(); root.loadFromLive() } }
    Timer { id: settle; interval: 1500; onTriggered: { root.refresh(); root.loadFromLive() } }

    FileView {
        path: root.home + "/.local/state/quickshell/displays.json"
        onLoaded: {
            try {
                const j = JSON.parse(text())
                if (j.layout) root.layout = j.layout
                if (j.placement) root.placement = j.placement
                if (j.align) root.align = j.align
                root.applied = { layout: root.layout, placement: root.placement, align: root.align }
            } catch (e) {}
        }
    }

    Component.onCompleted: { refresh(); settle.start() }
}
