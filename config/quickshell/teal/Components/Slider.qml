import QtQuick
import qs.Theme

// Horizontal slider. `value` is 0..1; `moved` fires only for user input.
Item {
    id: root

    property real value: 0
    property color fill: Colors.accent

    signal moved(real value)

    implicitHeight: 22
    implicitWidth: 160
    opacity: enabled ? 1 : 0.45

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 6
        radius: 3
        color: Colors.track

        Rectangle {
            id: bar
            width: Math.max(track.height, handle.x + handle.width / 2)
            height: parent.height
            radius: parent.radius
            color: root.fill
        }
    }

    Rectangle {
        id: handle
        width: area.pressed ? 16 : 14
        height: width
        radius: width / 2
        anchors.verticalCenter: parent.verticalCenter
        x: (root.width - width) * Math.max(0, Math.min(1, root.value))
        color: Colors.text
        border.width: 2
        border.color: root.fill

        Behavior on width { NumberAnimation { duration: Animations.fast } }
        Behavior on x {
            enabled: !area.pressed
            NumberAnimation { duration: Animations.fast; easing.type: Easing.OutCubic }
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        function update(mx) {
            const v = Math.max(0, Math.min(1, (mx - handle.width / 2) / (root.width - handle.width)));
            root.moved(v);
        }
        onPressed: mouse => update(mouse.x)
        onPositionChanged: mouse => { if (pressed) update(mouse.x); }
        onWheel: wheel => root.moved(Math.max(0, Math.min(1, root.value + (wheel.angleDelta.y > 0 ? 0.05 : -0.05))))
    }
}
