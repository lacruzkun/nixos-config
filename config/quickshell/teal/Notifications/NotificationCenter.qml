import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Theme
import qs.Components
import qs.Services

// Notification centre. Mako remains the daemon; this reads its current + dismissed
// notifications through makoctl and shows them in the shell's style.
OverlayPanel {
    id: win

    open: UiState.isOpen("notifications")
    onDismissed: UiState.close()
    onOpenChanged: if (open) NotificationData.loadHistory()

    readonly property var items: NotificationData.active.concat(NotificationData.history)

    Panel {
        t: win.t
        width: 400
        height: Math.min(win.height - Metrics.barHeight - Metrics.gap * 3, 520)
        x: win.width - width - Metrics.gap
        y: Metrics.barHeight + 4

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Metrics.pad
            spacing: Metrics.spacing

            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: "Notifications"
                    color: Colors.text
                    font.family: Typography.sans
                    font.pixelSize: Typography.title
                    font.weight: Font.Medium
                }
                IconButton { icon: "\uf1f8"; size: 28; iconSize: 13; visible: NotificationData.active.length > 0; onClicked: NotificationData.dismissAll() }
            }

            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentHeight: list.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: list
                    width: parent.width
                    spacing: 6

                    Repeater {
                        model: win.items
                        delegate: NotificationToast {
                            required property var modelData
                            Layout.fillWidth: true
                            notification: modelData
                        }
                    }
                }

                // intentional empty state
                ColumnLayout {
                    anchors.centerIn: parent
                    visible: win.items.length === 0
                    spacing: 8
                    NerdIcon { Layout.alignment: Qt.AlignHCenter; text: "\uf0f3"; size: 28; color: Colors.track }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "No notifications"
                        color: Colors.textMuted
                        font.family: Typography.sans
                        font.pixelSize: Typography.body
                    }
                }
            }
        }
    }
}
