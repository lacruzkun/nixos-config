import QtQuick
import qs.Theme

// Small pill switch.
Item {
    id: root

    property bool checked: false
    signal toggled()

    implicitWidth: 40
    implicitHeight: 22
    opacity: enabled ? 1 : 0.45

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? Colors.accent : Colors.track
        border.width: 1
        border.color: root.checked ? Colors.accentStrong : Colors.borderSoft
        Behavior on color { ColorAnimation { duration: Animations.normal } }
    }
    Rectangle {
        y: 3
        x: root.checked ? parent.width - width - 3 : 3
        width: 16; height: 16; radius: 8
        color: Colors.text
        Behavior on x { NumberAnimation { duration: Animations.normal; easing.type: Easing.OutCubic } }
    }
    MouseArea {
        anchors.fill: parent
        enabled: root.enabled
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
