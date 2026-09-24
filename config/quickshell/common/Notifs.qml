pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// Owns org.freedesktop.Notifications. Everything stays tracked (= in the
// notification center) until dismissed; popups are just a transient view of it.
Singleton {
    id: root

    property bool dnd: false
    property var popups: []      // Notification objects currently shown as popups
    property var arrived: ({})   // notification id -> arrival time (ms)
    readonly property var list: server.trackedNotifications
    readonly property int count: server.trackedNotifications.values.length

    function hidePopup(n) { root.popups = root.popups.filter(p => p !== n) }
    function dismiss(n) { hidePopup(n); n.dismiss() }
    function clearAll() {
        const all = server.trackedNotifications.values.slice()
        root.popups = []
        all.forEach(n => n.dismiss())
    }
    function ago(id) {
        const s = Math.max(0, (Time.now.getTime() - (arrived[id] ?? Time.now.getTime())) / 1000)
        return s < 60 ? "now" : s < 3600 ? Math.floor(s / 60) + "m" : s < 86400 ? Math.floor(s / 3600) + "h" : Math.floor(s / 86400) + "d"
    }

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true
        actionsSupported: true
        persistenceSupported: true
        onNotification: n => {
            n.tracked = true
            root.arrived[n.id] = Date.now()
            if (!root.dnd || n.urgency === NotificationUrgency.Critical)
                root.popups = [n, ...root.popups.filter(p => p !== n)].slice(0, 4)
        }
    }
}
