import QtQuick
import QtQuick.Layouts
import qs.Theme
import qs.Components
import qs.Services

Section {
    title: "Audio"
    icon: "\uf028"

    // output
    RowLayout {
        Layout.fillWidth: true
        spacing: 10
        IconButton {
            icon: AudioData.volumeIcon
            active: AudioData.muted
            danger: false
            iconColor: AudioData.muted ? Colors.urgent : Colors.text
            enabled: AudioData.hasSink
            onClicked: AudioData.toggleMute()
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Text {
                Layout.fillWidth: true
                text: AudioData.sinkName
                elide: Text.ElideRight
                color: Colors.text
                font.family: Typography.sans
                font.pixelSize: Typography.small
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: AudioData.cycle(true) }
            }
            Slider {
                Layout.fillWidth: true
                enabled: AudioData.hasSink
                value: AudioData.volume
                onMoved: v => AudioData.setVolume(v)
            }
        }
        Text {
            Layout.preferredWidth: 34
            horizontalAlignment: Text.AlignRight
            text: Math.round(AudioData.volume * 100) + "%"
            color: Colors.textDim
            font.family: Typography.mono
            font.pixelSize: Typography.small
        }
    }

    // input
    RowLayout {
        Layout.fillWidth: true
        spacing: 10
        IconButton {
            icon: AudioData.micMuted ? "\uf131" : "\uf130"
            iconColor: AudioData.micMuted ? Colors.urgent : Colors.text
            enabled: AudioData.hasSource
            onClicked: AudioData.toggleMicMute()
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Text {
                Layout.fillWidth: true
                text: AudioData.sourceName
                elide: Text.ElideRight
                color: Colors.text
                font.family: Typography.sans
                font.pixelSize: Typography.small
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: AudioData.cycle(false) }
            }
            Slider {
                Layout.fillWidth: true
                enabled: AudioData.hasSource
                value: AudioData.micVolume
                onMoved: v => AudioData.setMicVolume(v)
            }
        }
        Text {
            Layout.preferredWidth: 34
            horizontalAlignment: Text.AlignRight
            text: Math.round(AudioData.micVolume * 100) + "%"
            color: Colors.textDim
            font.family: Typography.mono
            font.pixelSize: Typography.small
        }
    }
}
