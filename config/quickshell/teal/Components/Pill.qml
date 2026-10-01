import QtQuick
import QtQuick.Effects
import qs.Theme

// Floating rounded surface used by the bar pills and (with a bigger radius) popups.
Item {
    id: root

    property real radius: height / 2
    property color color: Colors.surface
    property color borderColor: Colors.border
    property bool shadow: true
    property real shadowBlur: 18
    default property alias content: inner.data

    implicitHeight: Metrics.pillHeight

    RectangularShadow {
        visible: root.shadow
        anchors.fill: body
        radius: body.radius
        blur: root.shadowBlur
        offset: Qt.vector2d(0, 3)
        color: Colors.shadow
    }

    Rectangle {
        id: body
        anchors.fill: parent
        radius: root.radius
        color: root.color
        border.width: 1
        border.color: root.borderColor
    }

    Item {
        id: inner
        anchors.fill: parent
    }
}
