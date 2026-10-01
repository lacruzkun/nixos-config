import QtQuick
import QtQuick.Effects
import qs.Theme

// Popup card: shadow + rounded surface + click blocker (so clicks inside never reach the
// "click outside to close" area of OverlayPanel) + entrance animation driven by `t`.
Item {
    id: root

    property real t: 1                        // 0..1 from OverlayPanel
    property real radius: Metrics.radius
    property color color: Colors.surface
    property real slide: 10                   // px the panel travels while fading in
    default property alias content: inner.data

    opacity: t
    scale: 0.97 + 0.03 * t
    transform: Translate { y: (1 - root.t) * -root.slide }

    RectangularShadow {
        anchors.fill: body
        radius: body.radius
        blur: 28
        offset: Qt.vector2d(0, 8)
        color: Colors.shadow
    }

    Rectangle {
        id: body
        anchors.fill: parent
        radius: root.radius
        color: root.color
        border.width: 1
        border.color: Colors.border
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onWheel: wheel => wheel.accepted = true
    }

    Item {
        id: inner
        anchors.fill: parent
    }
}
