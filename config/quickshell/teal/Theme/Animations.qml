pragma Singleton
import QtQuick
import Quickshell

// Durations and curves follow config/hypr/modules/animations.conf
// (easeOutQuint 0.23,1,0.32,1 and easeInOutCubic 0.65,0.05,0.36,1).
Singleton {
    readonly property int fast: 120
    readonly property int normal: 200
    readonly property int popup: 260
    readonly property int morph: 340

    readonly property var easeOutQuint: [0.23, 1, 0.32, 1, 1, 1]
    readonly property var easeInOutCubic: [0.65, 0.05, 0.36, 1, 1, 1]
}
