import QtQuick
import QtQuick.Layouts
import qs.Theme
import qs.Components
import qs.Services

Section {
    id: root
    title: "Network"
    icon: "\uf1eb"

    property bool expanded: false

    trailing: [
        IconButton {
            visible: NetworkData.hasWifi
            size: 24; iconSize: 12
            icon: "\uf021"
            onClicked: NetworkData.rescan()
        },
        Toggle {
            visible: NetworkData.hasWifi
            checked: NetworkData.wifiEnabled
            onToggled: NetworkData.setWifi(!NetworkData.wifiEnabled)
        }
    ]

    // current connection
    RowLayout {
        Layout.fillWidth: true
        spacing: 10
        NerdIcon {
            text: NetworkData.type === "ethernet" ? "\uf6ff" : "\uf1eb"
            size: Metrics.iconLarge
            color: NetworkData.connected ? Colors.positive : Colors.textMuted
            Layout.preferredWidth: 28
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Text {
                Layout.fillWidth: true
                text: NetworkData.summary
                elide: Text.ElideRight
                color: Colors.text
                font.family: Typography.sans
                font.pixelSize: Typography.body
                font.weight: Font.Medium
            }
            Text {
                Layout.fillWidth: true
                visible: NetworkData.iface !== ""
                text: NetworkData.iface + (NetworkData.connected && NetworkData.type === "wifi" ? "  ·  signal " + NetworkData.signal + "%" : "")
                elide: Text.ElideRight
                color: Colors.textMuted
                font.family: Typography.mono
                font.pixelSize: Typography.tiny
            }
        }
        IconButton {
            visible: NetworkData.hasWifi && NetworkData.wifiEnabled && NetworkData.networks.length > 0
            size: 24; iconSize: 12
            icon: root.expanded ? "\uf077" : "\uf078"
            onClicked: root.expanded = !root.expanded
        }
        IconButton {
            visible: NetworkData.connected
            size: 24; iconSize: 12
            icon: "\uf00d"
            onClicked: NetworkData.disconnect()
        }
    }

    // available networks
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: root.expanded ? Math.min(netCol.implicitHeight, 190) : 0
        clip: true
        visible: Layout.preferredHeight > 0
        Behavior on Layout.preferredHeight { NumberAnimation { duration: Animations.popup; easing.type: Easing.OutCubic } }

        Flickable {
            anchors.fill: parent
            contentHeight: netCol.implicitHeight
            boundsBehavior: Flickable.StopAtBounds
            ColumnLayout {
                id: netCol
                width: parent.width
                spacing: 2
                Repeater {
                    model: NetworkData.networks.slice(0, 15)
                    delegate: Rectangle {
                        id: net
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        radius: Metrics.radiusSmall
                        color: netArea.containsMouse ? Colors.accentSoft : "transparent"
                        Behavior on color { ColorAnimation { duration: Animations.fast } }
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8; anchors.rightMargin: 8
                            spacing: 8
                            NerdIcon { text: net.modelData.secure ? "\uf023" : "\uf09c"; size: 11; color: Colors.textMuted }
                            Text {
                                Layout.fillWidth: true
                                text: net.modelData.ssid
                                elide: Text.ElideRight
                                color: net.modelData.active ? Colors.positive : Colors.text
                                font.family: Typography.sans
                                font.pixelSize: Typography.small
                                font.weight: net.modelData.active ? Font.Medium : Font.Normal
                            }
                            Text {
                                text: net.modelData.signal + "%"
                                color: Colors.textMuted
                                font.family: Typography.mono
                                font.pixelSize: Typography.tiny
                            }
                        }
                        MouseArea {
                            id: netArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (!net.modelData.active) NetworkData.connectTo(net.modelData.ssid)
                        }
                    }
                }
            }
        }
    }
}
