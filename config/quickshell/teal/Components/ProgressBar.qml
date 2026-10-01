import QtQuick
import qs.Theme

// Thin animated progress bar (island volume/brightness/media progress).
Rectangle {
    id: root

    property real value: 0                 // 0..1
    property color fill: Colors.accentStrong
    property bool animated: true

    implicitHeight: 6
    radius: height / 2
    color: Colors.track

    Rectangle {
        width: Math.max(root.height, root.width * Math.max(0, Math.min(1, root.value)))
        height: parent.height
        radius: height / 2
        color: root.fill

        Behavior on width {
            enabled: root.animated
            NumberAnimation { duration: Animations.normal; easing.type: Easing.OutCubic }
        }
        Behavior on color { ColorAnimation { duration: Animations.normal } }
    }
}
