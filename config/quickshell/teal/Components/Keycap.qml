import QtQuick
import qs.Theme

// A physical-looking key: darker rim, lighter face, thicker bottom edge.
Item {
    id: root

    property string label: ""
    property bool highlighted: false

    implicitWidth: Math.max(28, text.implicitWidth + 18)
    implicitHeight: 28

    Rectangle {          // key body / side
        anchors.fill: parent
        radius: 7
        color: root.highlighted ? Colors.teal1 : Colors.bg2
        opacity: 0.85
    }
    Rectangle {          // key face
        x: 1; y: 1
        width: parent.width - 2
        height: parent.height - 4
        radius: 6
        color: root.highlighted ? Colors.accent : Colors.bg1
        border.width: 1
        border.color: Qt.alpha(Colors.fg0, 0.18)

        Behavior on color { ColorAnimation { duration: Animations.fast } }
    }
    Text {
        id: text
        x: (parent.width - width) / 2
        y: (parent.height - 3 - height) / 2
        text: root.label
        color: Colors.text
        font.family: Typography.mono
        font.pixelSize: Typography.small
        font.weight: Font.Medium
    }
}
