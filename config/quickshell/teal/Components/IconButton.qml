import QtQuick
import qs.Theme

// Round icon button with hover / pressed / active states.
Item {
    id: root

    property string icon: ""
    property bool active: false
    property bool danger: false
    property int size: 28
    property int iconSize: Metrics.iconSize
    property color iconColor: Colors.text
    property alias hovered: area.containsMouse
    property alias containsPress: area.pressed

    signal clicked(var mouse)
    signal wheel(var wheel)

    implicitWidth: size
    implicitHeight: size

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        scale: area.pressed ? 0.92 : 1
        color: root.danger && (area.containsMouse || root.active) ? Colors.danger
             : root.active ? Colors.accent
             : area.containsMouse ? Colors.accentSoft
             : "transparent"

        Behavior on color { ColorAnimation { duration: Animations.fast } }
        Behavior on scale { NumberAnimation { duration: Animations.fast; easing.type: Easing.OutCubic } }
    }

    NerdIcon {
        anchors.centerIn: parent
        size: root.iconSize
        text: root.icon
        color: root.iconColor
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => root.clicked(mouse)
        onWheel: wheel => root.wheel(wheel)
    }
}
