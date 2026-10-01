import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Theme
import qs.Services

// One transparent layer-shell window per monitor holding the three floating pieces.
// Only the pills are input-reactive (mask); the rest of the strip is click-through.
// exclusiveZone reserves just the pill row, so windows tile below the bar.
PanelWindow {
    id: bar

    required property var modelData
    screen: modelData

    anchors { top: true; left: true; right: true }
    implicitHeight: Metrics.islandWindowHeight
    exclusiveZone: Metrics.barHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "teal-bar"

    mask: Region {
        regions: [
            Region { item: nav },
            Region { item: island },
            Region { item: utils }
        ]
    }

    Navigation {
        id: nav
        screen: bar.modelData
        anchors.left: parent.left
        anchors.leftMargin: Metrics.gap
        y: Metrics.barMargin
    }

    DynamicIsland {
        id: island
        anchors.horizontalCenter: parent.horizontalCenter
        y: Metrics.barMargin
    }

    Utilities {
        id: utils
        barWindow: bar
        anchors.right: parent.right
        anchors.rightMargin: Metrics.gap
        y: Metrics.barMargin
    }
}
