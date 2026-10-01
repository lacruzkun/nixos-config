pragma Singleton
import QtQuick
import Quickshell

// The one place the palette lives. Base values are the existing palette from
// config/waybar/colors.css (also used by kitty and mako) - nothing new added.
Singleton {
    // ---- base palette -------------------------------------------------
    readonly property color bg0: "#1a272a"
    readonly property color bg1: "#33515d"
    readonly property color bg2: "#58606b"

    readonly property color fg1: "#f4ceaa"
    readonly property color fg0: "#d0baaa"

    readonly property color teal0: "#2b7b82"
    readonly property color teal1: "#345c64"

    readonly property color blue: "#86a2ae"

    readonly property color red: "#841a20"
    readonly property color green: "#92941d"

    readonly property color brown0: "#8e432c"
    readonly property color brown1: "#755137"

    readonly property color salmon: "#ffb0ab"

    // ---- semantic roles (derived only from the palette above) ---------
    readonly property color surface: Qt.alpha(bg0, 0.90)        // pills, popups
    readonly property color card: Qt.alpha(bg1, 0.38)           // sections inside popups
    readonly property color cardHover: Qt.alpha(bg1, 0.62)
    readonly property color border: Qt.alpha(teal1, 0.95)       // same as mako's border
    readonly property color borderSoft: Qt.alpha(teal1, 0.55)
    readonly property color scrim: Qt.alpha(bg0, 0.45)
    readonly property color shadow: Qt.alpha("#000000", 0.35)

    readonly property color accent: teal0                       // interactive / active
    readonly property color accentSoft: Qt.alpha(teal0, 0.35)   // hover wash
    readonly property color accentStrong: Qt.lighter(teal0, 1.25)

    readonly property color text: fg1
    readonly property color textDim: fg0
    readonly property color textMuted: blue                     // secondary information

    readonly property color positive: green                     // connected / charging
    readonly property color danger: red                         // destructive
    readonly property color urgent: salmon                      // urgent outline / text
    readonly property color warn: brown0                        // low battery
    readonly property color track: Qt.alpha(bg2, 0.45)          // slider / progress track
}
