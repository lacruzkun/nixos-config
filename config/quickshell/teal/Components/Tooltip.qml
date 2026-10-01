import QtQuick
import Quickshell
import qs.Theme

// Hover tooltip shown in its own popup surface (bar windows are too small to hold it).
// Usage: Tooltip { target: someItem; hovered: area.containsMouse; text: "..." }
Item {
    id: root

    property Item target: parent
    property bool hovered: false
    property string text: ""
    property bool shown: false

    onHoveredChanged: {
        if (hovered) delay.restart();
        else { delay.stop(); shown = false; }
    }

    Timer { id: delay; interval: 450; onTriggered: root.shown = root.hovered && root.text !== "" }

    PopupWindow {
        visible: root.shown
        anchor.item: root.target
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.margins.top: 8
        color: "transparent"
        implicitWidth: label.implicitWidth + 24
        implicitHeight: label.implicitHeight + 16

        Rectangle {
            anchors.fill: parent
            radius: Metrics.radiusSmall
            color: Colors.bg1
            border.width: 1
            border.color: Colors.border

            Text {
                id: label
                anchors.centerIn: parent
                text: root.text
                color: Colors.text
                font.family: Typography.sans
                font.pixelSize: Typography.small
            }
        }
    }
}
