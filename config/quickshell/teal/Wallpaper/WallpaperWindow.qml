import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Theme

// One Background-layer surface per monitor. Normal windows, the bar and every popup sit above it.
// Replaces hyprpaper (see config/hypr/modules/autostart.conf).
PanelWindow {
    id: win

    required property var modelData
    screen: modelData

    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: Colors.bg0                      // shown for the instant before the image decodes

    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "teal-wallpaper"

    // Same file hyprpaper.conf pointed at; Home Manager links config/hypr to ~/.config/hypr.
    readonly property string wallpaperPath: Quickshell.env("HOME") + "/.config/hypr/wallpaper.jpg"

    SystemClock { id: clock; precision: SystemClock.Minutes }

    DepthWallpaper {
        anchors.fill: parent
        now: clock.date
        wallpaperSource: "file://" + win.wallpaperPath
    }
}
