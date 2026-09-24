pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// What the dock shows: pinned apps first, then any other running app.
Singleton {
    id: root

    property var pinned: ["brave-browser", "com.mitchellh.ghostty", "dev.zed.Zed"]

    readonly property var items: {
        const byApp = {}
        for (const t of ToplevelManager.toplevels.values) {
            if (!byApp[t.appId]) byApp[t.appId] = []
            byApp[t.appId].push(t)
        }
        const out = []
        for (const id of root.pinned) out.push({ appId: id, windows: byApp[id] ?? [], pinned: true })
        for (const id in byApp)
            if (id !== "" && !root.pinned.includes(id)) out.push({ appId: id, windows: byApp[id], pinned: false })
        return out
    }

    function entryFor(appId) { return DesktopEntries.heuristicLookup(appId) ?? DesktopEntries.byId(appId) }
    function iconFor(appId) {
        const e = entryFor(appId)
        return Quickshell.iconPath(e?.icon ?? appId, true) || Quickshell.iconPath("application-x-executable", true)
    }
    function nameFor(appId) { return entryFor(appId)?.name ?? appId }

    function launch(appId) {
        const e = entryFor(appId)
        if (e) e.execute(); else Quickshell.execDetached([appId])
    }
    // Focus the app; with several windows, cycle to the next one.
    function activate(item) {
        if (item.windows.length === 0) { launch(item.appId); return }
        const i = item.windows.findIndex(w => w.activated)
        item.windows[(i + 1) % item.windows.length].activate()
    }
    function togglePin(appId) {
        pinned = pinned.includes(appId) ? pinned.filter(p => p !== appId) : [...pinned, appId]
        store.setText(JSON.stringify({ pinned: pinned }))
    }

    FileView {
        id: store
        path: Quickshell.env("HOME") + "/.local/state/quickshell/dock.json"
        onLoaded: {
            try { const j = JSON.parse(text()); if (Array.isArray(j.pinned)) root.pinned = j.pinned } catch (e) {}
        }
    }
    Component.onCompleted: Quickshell.execDetached(["mkdir", "-p", Quickshell.env("HOME") + "/.local/state/quickshell"])
}
