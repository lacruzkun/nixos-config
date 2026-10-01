import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.Theme
import qs.Components
import qs.Services

// Player card used by the control center and the media popup.
Section {
    id: root
    title: MediaData.identity || "Media"
    icon: "\uf001"
    property bool big: false

    trailing: [
        IconButton {
            visible: MediaData.playerCount > 1
            size: 24; iconSize: 12
            icon: "\uf074"
            onClicked: MediaData.cyclePlayer()
        }
    ]

    RowLayout {
        Layout.fillWidth: true
        spacing: 12

        ClippingRectangle {
            Layout.preferredWidth: root.big ? 96 : 56
            Layout.preferredHeight: Layout.preferredWidth
            radius: root.big ? 18 : 12
            color: Colors.bg1
            Image {
                anchors.fill: parent
                source: MediaData.artUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize: Qt.size(192, 192)
                visible: status === Image.Ready
            }
            NerdIcon { anchors.centerIn: parent; visible: MediaData.artUrl === ""; text: "\uf001"; size: 22; color: Colors.textMuted }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            Text {
                Layout.fillWidth: true
                text: MediaData.title || "Nothing playing"
                elide: Text.ElideRight
                color: Colors.text
                font.family: Typography.sans
                font.pixelSize: root.big ? Typography.title : Typography.body
                font.weight: Font.Medium
            }
            Text {
                Layout.fillWidth: true
                visible: text !== ""
                text: MediaData.artist
                elide: Text.ElideRight
                color: Colors.textMuted
                font.family: Typography.sans
                font.pixelSize: Typography.small
            }
            Text {
                Layout.fillWidth: true
                visible: root.big && text !== ""
                text: MediaData.album
                elide: Text.ElideRight
                color: Colors.textMuted
                font.family: Typography.sans
                font.pixelSize: Typography.tiny
            }
        }
    }

    Slider {
        Layout.fillWidth: true
        enabled: MediaData.player !== null && MediaData.player.canSeek && MediaData.length > 0
        value: MediaData.progress
        onMoved: v => MediaData.seekTo(v)
    }
    RowLayout {
        Layout.fillWidth: true
        Text {
            text: MediaData.format(MediaData.position)
            color: Colors.textMuted
            font.family: Typography.mono
            font.pixelSize: Typography.tiny
        }
        Item { Layout.fillWidth: true }
        IconButton { icon: "\uf048"; size: 30; enabled: MediaData.player !== null && MediaData.player.canGoPrevious; onClicked: MediaData.previous() }
        IconButton {
            icon: MediaData.playing ? "\uf04c" : "\uf04b"
            size: 34; iconSize: 15
            active: true
            onClicked: MediaData.toggle()
        }
        IconButton { icon: "\uf051"; size: 30; enabled: MediaData.player !== null && MediaData.player.canGoNext; onClicked: MediaData.next() }
        Item { Layout.fillWidth: true }
        Text {
            text: MediaData.length > 0 ? MediaData.format(MediaData.length) : "--:--"
            color: Colors.textMuted
            font.family: Typography.mono
            font.pixelSize: Typography.tiny
        }
    }
}
