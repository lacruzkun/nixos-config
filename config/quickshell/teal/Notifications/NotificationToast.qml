import QtQuick
import QtQuick.Layouts
import qs.Theme
import qs.Components

// One notification card (used by the centre; the island renders the transient preview).
Rectangle {
    id: root

    property var notification: ({})
    readonly property bool critical: notification.urgency === "critical"

    implicitHeight: row.implicitHeight + 20
    radius: Metrics.radiusCard
    color: Colors.card
    border.width: 1
    border.color: critical ? Colors.urgent : Colors.borderSoft

    RowLayout {
        id: row
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        AppIcon {
            Layout.alignment: Qt.AlignTop
            size: 32
            name: root.notification.app_icon ? root.notification.app_icon : (root.notification.app_name || "")
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1
            Text {
                Layout.fillWidth: true
                text: root.notification.summary || root.notification.app_name || ""
                elide: Text.ElideRight
                color: root.critical ? Colors.urgent : Colors.text
                font.family: Typography.sans
                font.pixelSize: Typography.body
                font.weight: Font.Medium
            }
            Text {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.notification.body || ""
                wrapMode: Text.Wrap
                maximumLineCount: 3
                elide: Text.ElideRight
                color: Colors.textDim
                font.family: Typography.sans
                font.pixelSize: Typography.small
            }
            Text {
                text: root.notification.app_name || ""
                visible: text !== "" && text !== root.notification.summary
                color: Colors.textMuted
                font.family: Typography.sans
                font.pixelSize: Typography.tiny
            }
        }
    }
}
