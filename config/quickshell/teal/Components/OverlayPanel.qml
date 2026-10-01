import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Theme
import qs.Services

// Full-screen transparent overlay surface that hosts one popup.
//  - clicking outside the content dismisses it
//  - `t` (0..1) animates in/out; the surface is unmapped once fully faded out
//  - keyboard focus is grabbed only while open
// Children are placed in `stage`, a full-size Item; position your panel inside it.
PanelWindow {
    id: win

    property bool open: false
    property bool exclusiveKeyboard: true    // modal popups take the keyboard (Esc, typing, arrows) while open
    property bool scrim: false
    property real t: open ? 1 : 0
    default property alias content: stage.data
    readonly property alias stageItem: stage

    signal dismissed()

    screen: UiState.focusedScreen
    visible: open || t > 0.001
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "teal-popup"
    WlrLayershell.keyboardFocus: !open ? WlrKeyboardFocus.None
                               : exclusiveKeyboard ? WlrKeyboardFocus.Exclusive
                               : WlrKeyboardFocus.OnDemand

    Behavior on t { NumberAnimation { duration: Animations.popup; easing.type: Easing.BezierSpline; easing.bezierCurve: Animations.easeOutQuint } }

    Rectangle {
        anchors.fill: parent
        color: Colors.scrim
        opacity: win.scrim ? win.t : 0
    }

    MouseArea {
        anchors.fill: parent
        onClicked: win.dismissed()
    }

    FocusScope {
        id: stage
        anchors.fill: parent
        focus: win.open
        Keys.onEscapePressed: win.dismissed()
    }

    onOpenChanged: if (open) stage.forceActiveFocus()
}
