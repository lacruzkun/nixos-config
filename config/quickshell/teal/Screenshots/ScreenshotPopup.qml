import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Theme
import qs.Components
import qs.Services

// Front end for the existing grim / slurp / swappy / hyprshot commands (see Actions.qml).
// The PRINT-key binds in keybinds.conf keep working unchanged.
OverlayPanel {
    id: win

    open: UiState.isOpen("screenshots")
    scrim: true
    onDismissed: UiState.close()

    readonly property var groups: [
        { title: "Region", items: [
            { id: "region-copy", label: "To clipboard", icon: "\uf0c5", key: Qt.Key_1 },
            { id: "region-save", label: "Save + copy", icon: "\uf0c7", key: Qt.Key_2 },
            { id: "region-edit", label: "Annotate", icon: "\uf044", key: Qt.Key_3 } ] },
        { title: "Screen", items: [
            { id: "screen-copy", label: "To clipboard", icon: "\uf0c5", key: Qt.Key_4 },
            { id: "screen-save", label: "Save", icon: "\uf0c7", key: Qt.Key_5 } ] },
        { title: "Window", items: [
            { id: "window-copy", label: "To clipboard", icon: "\uf0c5", key: Qt.Key_6 },
            { id: "window-edit", label: "Annotate", icon: "\uf044", key: Qt.Key_7 } ] }
    ]

    function take(id) { UiState.close(); Actions.screenshot(id); }

    Item {
        anchors.fill: parent
        focus: true
        Keys.onPressed: event => {
            for (const g of win.groups)
                for (const it of g.items)
                    if (event.key === it.key) { win.take(it.id); event.accepted = true; return; }
        }
    }

    Panel {
        t: win.t
        width: content.implicitWidth + Metrics.pad * 2
        height: content.implicitHeight + Metrics.pad * 2
        anchors.centerIn: parent

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: Metrics.pad
            spacing: 12

            Text {
                text: "Screenshot"
                color: Colors.text
                font.family: Typography.sans
                font.pixelSize: Typography.title
                font.weight: Font.Medium
            }

            RowLayout {
                spacing: 14
                Repeater {
                    model: win.groups
                    delegate: ColumnLayout {
                        id: group
                        required property var modelData
                        Layout.alignment: Qt.AlignTop
                        spacing: 8
                        Text {
                            text: group.modelData.title
                            color: Colors.textMuted
                            font.family: Typography.sans
                            font.pixelSize: Typography.small
                            font.capitalization: Font.AllUppercase
                            font.letterSpacing: 0.8
                        }
                        Repeater {
                            model: group.modelData.items
                            delegate: Rectangle {
                                id: btn
                                required property var modelData
                                Layout.preferredWidth: 140
                                Layout.preferredHeight: 46
                                radius: Metrics.radiusCard - 4
                                color: area.containsMouse ? Colors.accentSoft : Colors.card
                                border.width: 1
                                border.color: area.containsMouse ? Colors.accent : Colors.borderSoft
                                scale: area.pressed ? 0.96 : 1
                                Behavior on color { ColorAnimation { duration: Animations.fast } }
                                Behavior on scale { NumberAnimation { duration: Animations.fast } }
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12; anchors.rightMargin: 12
                                    spacing: 10
                                    NerdIcon { text: btn.modelData.icon; size: 14 }
                                    Text {
                                        Layout.fillWidth: true
                                        text: btn.modelData.label
                                        color: Colors.text
                                        font.family: Typography.sans
                                        font.pixelSize: Typography.small + 1
                                    }
                                    Text {
                                        text: String.fromCharCode(btn.modelData.key)
                                        color: Colors.textMuted
                                        font.family: Typography.mono
                                        font.pixelSize: Typography.tiny
                                    }
                                }
                                MouseArea {
                                    id: area
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: win.take(btn.modelData.id)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
