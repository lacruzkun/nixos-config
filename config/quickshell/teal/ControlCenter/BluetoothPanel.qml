import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import qs.Theme
import qs.Components
import qs.Services

Section {
    id: root
    title: "Bluetooth"
    icon: "\uf293"

    trailing: [
        Toggle {
            visible: BluetoothData.available
            checked: BluetoothData.enabled
            onToggled: BluetoothData.setEnabled(!BluetoothData.enabled)
        }
    ]

    Text {
        visible: !BluetoothData.available || !BluetoothData.enabled || BluetoothData.knownDevices.length === 0
        Layout.fillWidth: true
        text: !BluetoothData.available ? "No Bluetooth adapter"
            : !BluetoothData.enabled ? "Bluetooth is off"
            : "No paired devices"
        color: Colors.textMuted
        font.family: Typography.sans
        font.pixelSize: Typography.small
    }

    Repeater {
        model: BluetoothData.enabled ? BluetoothData.knownDevices : []
        delegate: Rectangle {
            id: dev
            required property var modelData
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            radius: Metrics.radiusSmall
            color: devArea.containsMouse ? Colors.accentSoft : "transparent"
            Behavior on color { ColorAnimation { duration: Animations.fast } }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8; anchors.rightMargin: 8
                spacing: 10
                NerdIcon {
                    text: "\uf293"
                    size: 14
                    color: dev.modelData.connected ? Colors.positive : Colors.textMuted
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    Text {
                        Layout.fillWidth: true
                        text: dev.modelData.name || dev.modelData.deviceName || dev.modelData.address
                        elide: Text.ElideRight
                        color: Colors.text
                        font.family: Typography.sans
                        font.pixelSize: Typography.small
                    }
                    Text {
                        text: dev.modelData.state === BluetoothDeviceState.Connecting ? "Connecting…"
                            : dev.modelData.connected ? "Connected" : "Paired"
                        color: dev.modelData.connected ? Colors.positive : Colors.textMuted
                        font.family: Typography.sans
                        font.pixelSize: Typography.tiny
                    }
                }
                Text {
                    visible: dev.modelData.connected && dev.modelData.batteryAvailable
                    text: Math.round(dev.modelData.battery * 100) + "%"
                    color: Colors.textDim
                    font.family: Typography.mono
                    font.pixelSize: Typography.small
                }
            }
            MouseArea {
                id: devArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: BluetoothData.toggleDevice(dev.modelData)
            }
        }
    }
}
