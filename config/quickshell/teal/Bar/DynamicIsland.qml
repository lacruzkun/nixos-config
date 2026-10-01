import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.Theme
import qs.Components
import qs.Services

// The centre Dynamic Island. One rounded body whose width/height/radius animate between
// states; each state's content cross-fades inside it (nothing is swapped instantly).
// Which state is shown comes from IslandState (priorities live there).
Item {
    id: root

    readonly property string mode: IslandState.display
    readonly property var d: IslandState.data
    readonly property bool critical: mode === "notification" && d.urgency === "critical"

    SystemClock { id: clock; precision: SystemClock.Seconds }

    // [width, height] per state. Idle sizes itself from its content so any locale fits.
    readonly property var sizes: ({
        media: [390, 88],
        volume: [270, 46],
        mic: [210, 46],
        brightness: [270, 46],
        workspace: [132, 46],
        notification: [420, 76],
        screenshot: [250, 46],
        bluetooth: [310, 52]
    })
    readonly property real targetW: mode === "idle" ? idleRow.implicitWidth + 34 : sizes[mode][0]
    readonly property real targetH: mode === "idle" ? Metrics.pillHeight : sizes[mode][1]

    implicitWidth: body.width
    implicitHeight: body.height

    Rectangle {
        id: body
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.targetW
        height: root.targetH
        radius: Math.min(height / 2, 30)
        color: Colors.surface
        border.width: 1
        border.color: root.critical ? Colors.urgent : Colors.border
        clip: true

        Behavior on width { NumberAnimation { duration: Animations.morph; easing.type: Easing.BezierSpline; easing.bezierCurve: Animations.easeOutQuint } }
        Behavior on height { NumberAnimation { duration: Animations.morph; easing.type: Easing.BezierSpline; easing.bezierCurve: Animations.easeOutQuint } }
        Behavior on border.color { ColorAnimation { duration: Animations.normal } }

        // Subtle press feedback on the whole island.
        scale: hit.pressed ? 0.985 : 1
        Behavior on scale { NumberAnimation { duration: Animations.fast; easing.type: Easing.OutCubic } }

        // ================= IDLE =====================================
        Item {
            anchors.fill: parent
            opacity: root.mode === "idle" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: Animations.normal } }

            Row {
                id: idleRow
                anchors.centerIn: parent
                spacing: 8
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Qt.formatDateTime(clock.date, "HH:mm")
                    color: Colors.text
                    font.family: Typography.sans
                    font.pixelSize: Typography.title
                    font.weight: Font.Medium
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Qt.formatDateTime(clock.date, "ss")
                    color: Colors.textMuted
                    font.family: Typography.mono
                    font.pixelSize: Typography.small
                    width: 16
                }
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 3; height: 3; radius: 1.5
                    color: Colors.borderSoft
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Qt.formatDateTime(clock.date, "ddd d MMM")
                    color: Colors.textMuted
                    font.family: Typography.sans
                    font.pixelSize: Typography.small
                }
                NerdIcon {                 // small secondary indicator: something is playing
                    anchors.verticalCenter: parent.verticalCenter
                    visible: MediaData.playing
                    text: "\uf001"
                    size: 11
                    color: Colors.accentStrong
                }
            }
        }

        // ================= MEDIA ====================================
        Item {
            anchors.fill: parent
            anchors.margins: 14
            opacity: root.mode === "media" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: Animations.normal } }

            RowLayout {
                anchors.fill: parent
                spacing: 12

                ClippingRectangle {
                    Layout.preferredWidth: 58
                    Layout.preferredHeight: 58
                    radius: 14
                    color: Colors.bg1
                    Image {
                        anchors.fill: parent
                        source: MediaData.artUrl
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        sourceSize: Qt.size(116, 116)
                        visible: status === Image.Ready
                    }
                    NerdIcon {
                        anchors.centerIn: parent
                        visible: MediaData.artUrl === ""
                        text: "\uf001"
                        size: 22
                        color: Colors.textMuted
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 1
                    Text {
                        Layout.fillWidth: true
                        text: MediaData.title || MediaData.identity || "Nothing playing"
                        elide: Text.ElideRight
                        color: Colors.text
                        font.family: Typography.sans
                        font.pixelSize: Typography.body
                        font.weight: Font.Medium
                    }
                    Text {
                        Layout.fillWidth: true
                        text: MediaData.artist
                        visible: text !== ""
                        elide: Text.ElideRight
                        color: Colors.textMuted
                        font.family: Typography.sans
                        font.pixelSize: Typography.small
                    }
                    Item { Layout.fillHeight: true }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Text {
                            text: MediaData.format(MediaData.position)
                            color: Colors.textMuted
                            font.family: Typography.mono
                            font.pixelSize: Typography.tiny
                        }
                        ProgressBar {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            value: MediaData.progress
                            animated: false
                        }
                        Text {
                            text: MediaData.length > 0 ? "-" + MediaData.format(MediaData.length - MediaData.position) : "--:--"
                            color: Colors.textMuted
                            font.family: Typography.mono
                            font.pixelSize: Typography.tiny
                        }
                    }
                }

                NerdIcon {
                    text: MediaData.playing ? "\uf04b" : "\uf04c"
                    size: 16
                    color: MediaData.playing ? Colors.accentStrong : Colors.textMuted
                }
            }
        }

        // ================= VOLUME ===================================
        Item {
            anchors.fill: parent
            anchors.leftMargin: 16; anchors.rightMargin: 16
            opacity: root.mode === "volume" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: Animations.normal } }
            RowLayout {
                anchors.fill: parent
                spacing: 12
                NerdIcon { text: AudioData.volumeIcon; size: Metrics.iconLarge; Layout.preferredWidth: 26
                    color: AudioData.muted ? Colors.urgent : Colors.text }
                ProgressBar { Layout.fillWidth: true; value: AudioData.muted ? 0 : AudioData.volume
                    fill: AudioData.muted ? Colors.urgent : Colors.accentStrong }
                Text {
                    Layout.preferredWidth: 38
                    horizontalAlignment: Text.AlignRight
                    text: AudioData.muted ? "mute" : Math.round(AudioData.volume * 100) + "%"
                    color: Colors.text
                    font.family: Typography.mono
                    font.pixelSize: Typography.body
                }
            }
        }

        // ================= MICROPHONE ===============================
        Item {
            anchors.fill: parent
            anchors.leftMargin: 16; anchors.rightMargin: 16
            opacity: root.mode === "mic" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: Animations.normal } }
            RowLayout {
                anchors.centerIn: parent
                spacing: 12
                NerdIcon { text: AudioData.micMuted ? "\uf131" : "\uf130"; size: Metrics.iconLarge
                    color: AudioData.micMuted ? Colors.urgent : Colors.positive }
                Text {
                    text: AudioData.micMuted ? "Microphone muted" : "Microphone live"
                    color: Colors.text
                    font.family: Typography.sans
                    font.pixelSize: Typography.body
                }
            }
        }

        // ================= BRIGHTNESS ===============================
        Item {
            anchors.fill: parent
            anchors.leftMargin: 16; anchors.rightMargin: 16
            opacity: root.mode === "brightness" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: Animations.normal } }
            RowLayout {
                anchors.fill: parent
                spacing: 12
                NerdIcon { text: "\uf185"; size: Metrics.iconLarge; Layout.preferredWidth: 26 }
                ProgressBar { Layout.fillWidth: true; value: BrightnessData.value }
                Text {
                    Layout.preferredWidth: 38
                    horizontalAlignment: Text.AlignRight
                    text: Math.round(BrightnessData.value * 100) + "%"
                    color: Colors.text
                    font.family: Typography.mono
                    font.pixelSize: Typography.body
                }
            }
        }

        // ================= WORKSPACE ================================
        Item {
            anchors.fill: parent
            opacity: root.mode === "workspace" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: Animations.normal } }
            Row {
                anchors.centerIn: parent
                spacing: 10
                NerdIcon { anchors.verticalCenter: parent.verticalCenter; text: "\uf2d2"; size: 16; color: Colors.textMuted }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.d.name !== undefined ? root.d.name : ""
                    color: Colors.text
                    font.family: Typography.mono
                    font.pixelSize: Typography.large
                    font.weight: Font.Bold
                }
            }
        }

        // ================= NOTIFICATION =============================
        Item {
            anchors.fill: parent
            anchors.margins: 14
            opacity: root.mode === "notification" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: Animations.normal } }
            RowLayout {
                anchors.fill: parent
                spacing: 12
                AppIcon {
                    Layout.alignment: Qt.AlignVCenter
                    size: 40
                    name: root.d.icon !== undefined && root.d.icon ? root.d.icon : (root.d.app || "")
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1
                    Text {
                        Layout.fillWidth: true
                        text: root.d.title || root.d.app || ""
                        elide: Text.ElideRight
                        color: root.critical ? Colors.urgent : Colors.text
                        font.family: Typography.sans
                        font.pixelSize: Typography.body
                        font.weight: Font.Medium
                    }
                    Text {
                        Layout.fillWidth: true
                        text: root.d.body || ""
                        visible: text !== ""
                        maximumLineCount: 2
                        wrapMode: Text.Wrap
                        elide: Text.ElideRight
                        color: Colors.textDim
                        font.family: Typography.sans
                        font.pixelSize: Typography.small
                    }
                }
            }
        }

        // ================= SCREENSHOT ===============================
        Item {
            anchors.fill: parent
            opacity: root.mode === "screenshot" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: Animations.normal } }
            Row {
                anchors.centerIn: parent
                spacing: 10
                NerdIcon { anchors.verticalCenter: parent.verticalCenter; text: "\uf030"; size: 18; color: Colors.positive }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.d.title || "Screenshot taken"
                    color: Colors.text
                    font.family: Typography.sans
                    font.pixelSize: Typography.body
                }
            }
        }

        // ================= BLUETOOTH ================================
        Item {
            anchors.fill: parent
            anchors.leftMargin: 16; anchors.rightMargin: 16
            opacity: root.mode === "bluetooth" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: Animations.normal } }
            RowLayout {
                anchors.fill: parent
                spacing: 12
                NerdIcon { text: "\uf293"; size: Metrics.iconLarge; Layout.preferredWidth: 26
                    color: root.d.connected ? Colors.positive : Colors.textMuted }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    Text {
                        Layout.fillWidth: true
                        text: root.d.name || "Bluetooth device"
                        elide: Text.ElideRight
                        color: Colors.text
                        font.family: Typography.sans
                        font.pixelSize: Typography.body
                        font.weight: Font.Medium
                    }
                    Text {
                        text: root.d.connected ? "Connected" : "Disconnected"
                        color: root.d.connected ? Colors.positive : Colors.textMuted
                        font.family: Typography.sans
                        font.pixelSize: Typography.small
                    }
                }
            }
        }

        MouseArea {
            id: hit
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            onEntered: IslandState.hovered = true
            onExited: IslandState.hovered = false
            onClicked: mouse => {
                if (mouse.button === Qt.MiddleButton) { MediaData.toggle(); return; }
                if (mouse.button === Qt.RightButton) { UiState.toggle("controlCenter"); return; }
                const m = root.mode;
                if (m === "notification") { IslandState.clear(); UiState.toggle("notifications"); }
                else if (m === "media") UiState.toggle("media");
                else if (m === "idle" && IslandState.display === "media") UiState.toggle("media");
                else UiState.toggle("calendar");
            }
        }
    }
}
