import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.Theme
import qs.Components
import qs.Services

// Top-right pill: tray, microphone, network, bluetooth, volume, battery. Clicking an icon does
// its quick action; clicking the pill itself opens the control center.
Pill {
    id: root

    required property var barWindow

    implicitWidth: row.implicitWidth + 20
    implicitHeight: Metrics.pillHeight

    // background click target = whole pill (icons sit above it)
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: UiState.toggle("controlCenter")
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 2

        // ---- system tray -----------------------------------------------
        Repeater {
            model: SystemTray.items
            delegate: Item {
                id: trayItem
                required property var modelData
                Layout.preferredWidth: 26
                Layout.preferredHeight: 26

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: trayArea.containsMouse ? Colors.accentSoft : "transparent"
                    Behavior on color { ColorAnimation { duration: Animations.fast } }
                }
                IconImage {
                    anchors.centerIn: parent
                    width: 16; height: 16
                    source: trayItem.modelData.icon
                    opacity: trayArea.containsMouse ? 1 : 0.72
                    Behavior on opacity { NumberAnimation { duration: Animations.fast } }
                }
                MouseArea {
                    id: trayArea
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mouse => {
                        const it = trayItem.modelData;
                        if (mouse.button === Qt.MiddleButton) it.secondaryActivate();
                        else if (mouse.button === Qt.RightButton || it.onlyMenu) {
                            if (it.hasMenu) {
                                const p = trayItem.mapToItem(null, 0, trayItem.height);
                                it.display(root.barWindow, p.x, p.y + 4);
                            }
                        } else it.activate();
                    }
                    onWheel: wheel => trayItem.modelData.scroll(wheel.angleDelta.y, false)
                }
            }
        }

        Rectangle {
            visible: SystemTray.items.values.length > 0
            Layout.preferredWidth: 1; Layout.preferredHeight: 16
            Layout.leftMargin: 4; Layout.rightMargin: 4
            color: Colors.borderSoft
        }

        // ---- microphone: shown only when there is an input -------------
        IconButton {
            visible: AudioData.hasSource
            icon: AudioData.micMuted ? "\uf131" : "\uf130"
            iconColor: AudioData.micMuted ? Colors.urgent : Colors.textMuted
            size: 26
            iconSize: 14
            onClicked: AudioData.toggleMicMute()
        }

        // ---- network ---------------------------------------------------
        IconButton {
            icon: NetworkData.type === "ethernet" && NetworkData.connected ? "\uf6ff" : (NetworkData.connected ? "\uf1eb" : "\uf1eb")
            iconColor: NetworkData.connected ? Colors.text : Colors.textMuted
            opacity: NetworkData.connected ? 1 : 0.6
            size: 26
            iconSize: 14
            onClicked: UiState.toggle("controlCenter")
        }

        // ---- bluetooth -------------------------------------------------
        IconButton {
            visible: BluetoothData.available
            icon: BluetoothData.enabled ? "\uf293" : "\uf294"
            iconColor: BluetoothData.connectedDevices.length > 0 ? Colors.positive
                     : BluetoothData.enabled ? Colors.text : Colors.textMuted
            size: 26
            iconSize: 14
            onClicked: mouse => {
                if (mouse.button === Qt.RightButton) BluetoothData.setEnabled(!BluetoothData.enabled);
                else UiState.toggle("controlCenter");
            }
        }

        // ---- volume (click = mute, wheel = level) ----------------------
        Item {
            Layout.preferredWidth: volRow.implicitWidth + 12
            Layout.preferredHeight: 26
            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: volArea.containsMouse ? Colors.accentSoft : "transparent"
                Behavior on color { ColorAnimation { duration: Animations.fast } }
            }
            Row {
                id: volRow
                anchors.centerIn: parent
                spacing: 6
                NerdIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    text: AudioData.volumeIcon
                    size: 14
                    color: AudioData.muted ? Colors.urgent : Colors.text
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: AudioData.hasSink
                    text: AudioData.muted ? "mute" : Math.round(AudioData.volume * 100) + "%"
                    color: AudioData.muted ? Colors.urgent : Colors.textDim
                    font.family: Typography.mono
                    font.pixelSize: Typography.small
                }
            }
            MouseArea {
                id: volArea
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton) UiState.toggle("controlCenter");
                    else AudioData.toggleMute();
                }
                onWheel: wheel => AudioData.setVolume(AudioData.volume + (wheel.angleDelta.y > 0 ? 0.05 : -0.05))
            }
        }

        // ---- battery: absent on machines without one -------------------
        Item {
            visible: BatteryData.present
            Layout.preferredWidth: batRow.implicitWidth + 12
            Layout.preferredHeight: 26
            Row {
                id: batRow
                anchors.centerIn: parent
                spacing: 6
                NerdIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    text: BatteryData.icon
                    size: 14
                    color: BatteryData.charging ? Colors.positive : BatteryData.low ? Colors.urgent : Colors.text
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: BatteryData.percent + "%"
                    color: BatteryData.low ? Colors.urgent : Colors.textDim
                    font.family: Typography.mono
                    font.pixelSize: Typography.small
                }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: UiState.toggle("controlCenter")
            }
        }
    }
}
