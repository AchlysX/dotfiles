pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property date now: clock.date
    readonly property string time: Qt.formatDateTime(clock.date, "HH:mm")
    readonly property string day: Qt.formatDateTime(clock.date, "ddd d MMM")

    SystemClock { id: clock; precision: SystemClock.Minutes }
}
