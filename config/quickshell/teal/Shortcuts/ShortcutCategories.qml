import QtQuick
import QtQuick.Layouts
import qs.Theme
import qs.Components

// Category sidebar. Only categories that actually contain bindings are listed.
ColumnLayout {
    id: root

    property var categories: []
    property string current: "All"
    signal picked(string name)

    spacing: 4

    Repeater {
        model: root.categories
        delegate: Item {
            id: item
            required property var modelData
            readonly property bool active: root.current === modelData.name
            Layout.fillWidth: true
            Layout.preferredHeight: 38

            Rectangle {
                anchors.fill: parent
                radius: Metrics.radiusSmall + 2
                color: item.active ? Colors.accent : area.containsMouse ? Colors.accentSoft : "transparent"
                Behavior on color { ColorAnimation { duration: Animations.fast } }
            }
            Rectangle {                                    // active indicator
                width: 3
                height: item.active ? 18 : 0
                radius: 1.5
                anchors.verticalCenter: parent.verticalCenter
                x: 0
                color: Colors.fg1
                Behavior on height { NumberAnimation { duration: Animations.normal; easing.type: Easing.OutCubic } }
            }
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14; anchors.rightMargin: 12
                spacing: 10
                NerdIcon { text: item.modelData.icon; size: 14; color: item.active ? Colors.text : Colors.textMuted; Layout.preferredWidth: 18 }
                Text {
                    Layout.fillWidth: true
                    text: item.modelData.name
                    color: item.active ? Colors.text : Colors.textDim
                    font.family: Typography.sans
                    font.pixelSize: Typography.body
                    font.weight: item.active ? Font.Medium : Font.Normal
                }
                Text {
                    text: item.modelData.count
                    color: item.active ? Colors.text : Colors.textMuted
                    font.family: Typography.mono
                    font.pixelSize: Typography.tiny
                }
            }
            MouseArea {
                id: area
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.picked(item.modelData.name)
            }
        }
    }
}
