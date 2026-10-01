import QtQuick
import QtQuick.Layouts
import qs.Theme
import qs.Components

// One launcher row.
Item {
    id: root

    required property var modelData
    required property int index
    property bool selected: false

    signal activated()
    signal hovered()

    height: 54
    width: ListView.view ? ListView.view.width : 400

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: 2; anchors.rightMargin: 2
        radius: Metrics.radiusCard - 4
        color: root.selected ? Colors.accentSoft : area.containsMouse ? Qt.alpha(Colors.accentSoft, 0.4) : "transparent"
        border.width: root.selected ? 1 : 0
        border.color: Colors.accent
        Behavior on color { ColorAnimation { duration: Animations.fast } }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12; anchors.rightMargin: 14
        spacing: 12

        Item {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            AppIcon {
                anchors.fill: parent
                visible: root.modelData.glyph === undefined
                size: 36
                name: root.modelData.icon || ""
            }
            Rectangle {
                anchors.fill: parent
                visible: root.modelData.glyph !== undefined
                radius: 11
                color: Colors.teal1
                NerdIcon { anchors.centerIn: parent; text: root.modelData.glyph || ""; size: 17; color: Colors.text }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Text {
                Layout.fillWidth: true
                text: root.modelData.title
                elide: Text.ElideRight
                color: Colors.text
                font.family: Typography.sans
                font.pixelSize: Typography.body + 1
                font.weight: root.selected ? Font.Medium : Font.Normal
            }
            Text {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.modelData.subtitle || ""
                elide: Text.ElideRight
                color: Colors.textMuted
                font.family: Typography.sans
                font.pixelSize: Typography.small
            }
        }

        Text {
            text: root.modelData.tag || ""
            color: Colors.textMuted
            font.family: Typography.mono
            font.pixelSize: Typography.tiny
            opacity: 0.8
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered()
        onClicked: root.activated()
    }
}
