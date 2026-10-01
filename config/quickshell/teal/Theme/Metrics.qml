pragma Singleton
import QtQuick
import Quickshell

Singleton {
    // Matches gaps_out = 10 in config/hypr/modules/decorations.conf.
    readonly property int gap: 10

    readonly property int pillHeight: 38
    readonly property int barMargin: 6                         // pill distance from the screen edge
    // Space reserved at the top. Hyprland adds gaps_out (10) on top of this, so windows end up
    // 10px below the pills.
    readonly property int barHeight: pillHeight + barMargin
    readonly property int radius: 22                           // large panels
    readonly property int radiusCard: 16
    readonly property int radiusSmall: 10
    readonly property int spacing: 8
    readonly property int pad: 14

    readonly property int iconSize: 16
    readonly property int iconLarge: 22

    readonly property int popupWidth: 392                      // control center
    readonly property int islandWindowWidth: 560               // fixed layer surface; content morphs inside
    readonly property int islandWindowHeight: 150
}
