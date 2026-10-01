import QtQuick
import QtQuick.Layouts
import qs.Theme

// Titled card used by the control center and popups.
Rectangle {
    id: root

    property string title: ""
    property string icon: ""
    property alias trailing: trailingSlot.data
    default property alias content: body.data

    Layout.fillWidth: true
    implicitHeight: col.implicitHeight + Metrics.pad * 1.5
    radius: Metrics.radiusCard
    color: Colors.card
    border.width: 1
    border.color: Colors.borderSoft

    ColumnLayout {
        id: col
        anchors.fill: parent
        anchors.margins: Metrics.pad * 0.75
        spacing: Metrics.spacing

        RowLayout {
            visible: root.title !== ""
            Layout.fillWidth: true
            spacing: 8

            NerdIcon { visible: root.icon !== ""; text: root.icon; color: Colors.textMuted; size: 14 }
            Text {
                text: root.title
                color: Colors.textMuted
                font.family: Typography.sans
                font.pixelSize: Typography.small
                font.weight: Font.Medium
                font.capitalization: Font.AllUppercase
                font.letterSpacing: 0.8
            }
            Item { Layout.fillWidth: true }
            RowLayout { id: trailingSlot; spacing: 6 }
        }

        ColumnLayout {
            id: body
            Layout.fillWidth: true
            spacing: Metrics.spacing
        }
    }
}
