pragma Singleton
import QtQuick
import Quickshell

// Which popover panel is open, and on which screen. Only one at a time.
Singleton {
    property string panel: ""
    property string screenName: ""
    property string view: "main"      // control center page: main | wifi | bt
    property bool settingsOpen: false
    property string settingsPage: "displays"   // displays | wallpaper | power
    property double closedAt: 0

    function isOpen(name, screen) { return panel === name && screenName === screen }
    function toggle(name, screen) {
        // A click on the button that opened the panel also clears its focus grab
        // first; without this guard the panel would close and instantly reopen.
        if (!isOpen(name, screen) && Date.now() - closedAt < 250) return
        if (isOpen(name, screen)) close()
        else { panel = name; screenName = screen }
    }
    // Open (or switch) the control center on a given page; same page again closes it.
    function openControl(screen, v) {
        if (isOpen("control", screen) && view === v) { close(); return }
        if (!isOpen("control", screen) && Date.now() - closedAt < 250) return
        view = v; panel = "control"; screenName = screen
    }
    function close() { panel = ""; screenName = ""; closedAt = Date.now() }
}
