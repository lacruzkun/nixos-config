import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Theme
import qs.Components
import qs.Services

// Keyboard shortcuts overlay (SUPER + /). Data comes from KeybindModel -> hyprctl binds -j.
OverlayPanel {
    id: win

    open: UiState.isOpen("shortcuts")
    scrim: true
    onDismissed: UiState.close()

    KeybindModel { id: binds; active: win.open; query: search.text }

    onOpenChanged: if (open) { search.text = ""; binds.category = "All"; list.currentIndex = 0; search.forceActiveFocus(); }

    Panel {
        id: panel
        t: win.t
        width: Math.min(980, win.width - 80)
        height: Math.min(620, win.height - 100)
        anchors.centerIn: parent

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Metrics.pad + 4
            spacing: 14

            // ---------------- header ----------------
            RowLayout {
                Layout.fillWidth: true
                spacing: 14
                ColumnLayout {
                    spacing: 0
                    Text {
                        text: "Keyboard Shortcuts"
                        color: Colors.text
                        font.family: Typography.sans
                        font.pixelSize: Typography.large
                        font.weight: Font.Medium
                    }
                    Text {
                        text: binds.rows.length + " bindings from your Hyprland config"
                        color: Colors.textMuted
                        font.family: Typography.sans
                        font.pixelSize: Typography.small
                    }
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    Layout.preferredWidth: Math.min(340, panel.width * 0.4)
                    Layout.preferredHeight: 42
                    radius: 21
                    color: Colors.card
                    border.width: 1
                    border.color: search.activeFocus ? Colors.accent : Colors.borderSoft
                    Behavior on border.color { ColorAnimation { duration: Animations.fast } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16; anchors.rightMargin: 16
                        spacing: 10
                        NerdIcon { text: "\uf002"; size: 14; color: Colors.textMuted }
                        TextInput {
                            id: search
                            Layout.fillWidth: true
                            color: Colors.text
                            selectionColor: Colors.accent
                            font.family: Typography.sans
                            font.pixelSize: Typography.body + 1
                            clip: true
                            focus: true
                            Text {
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                visible: search.text === ""
                                text: "Search shortcuts…"
                                color: Colors.textMuted
                                font: search.font
                            }
                            onTextChanged: list.currentIndex = 0
                            Keys.onPressed: event => {
                                const n = list.count;
                                if (event.key === Qt.Key_Down) { if (n) list.currentIndex = Math.min(n - 1, list.currentIndex + 1); event.accepted = true; }
                                else if (event.key === Qt.Key_Up) { if (n) list.currentIndex = Math.max(0, list.currentIndex - 1); event.accepted = true; }
                                else if (event.key === Qt.Key_PageDown) { list.currentIndex = Math.min(n - 1, list.currentIndex + 8); event.accepted = true; }
                                else if (event.key === Qt.Key_PageUp) { list.currentIndex = Math.max(0, list.currentIndex - 8); event.accepted = true; }
                                else if (event.key === Qt.Key_Tab) { binds.cycleCategory(1); event.accepted = true; }
                                else if (event.key === Qt.Key_Backtab) { binds.cycleCategory(-1); event.accepted = true; }
                                else if (event.key === Qt.Key_Escape) {
                                    if (search.text !== "") search.text = ""; else win.dismissed();
                                    event.accepted = true;
                                }
                            }
                        }
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Colors.borderSoft }

            // ---------------- body ----------------
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 16

                ShortcutCategories {
                    Layout.preferredWidth: 190
                    Layout.alignment: Qt.AlignTop
                    categories: binds.categories
                    current: binds.category
                    onPicked: name => { binds.category = name; list.currentIndex = 0; }
                }

                Rectangle { Layout.fillHeight: true; width: 1; color: Colors.borderSoft }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 10
                        Text {
                            Layout.preferredWidth: 360
                            text: "Shortcut"
                            color: Colors.textMuted
                            font.family: Typography.sans
                            font.pixelSize: Typography.small
                            font.capitalization: Font.AllUppercase
                            font.letterSpacing: 0.8
                        }
                        Text {
                            text: "Action"
                            color: Colors.textMuted
                            font.family: Typography.sans
                            font.pixelSize: Typography.small
                            font.capitalization: Font.AllUppercase
                            font.letterSpacing: 0.8
                        }
                    }

                    ListView {
                        id: list
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: binds.visibleRows
                        spacing: 2
                        boundsBehavior: Flickable.StopAtBounds
                        onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                        delegate: Rectangle {
                            id: row
                            required property var modelData
                            required property int index
                            readonly property bool selected: ListView.isCurrentItem
                            width: ListView.view.width
                            height: 44
                            radius: Metrics.radiusSmall
                            color: selected || rowArea.containsMouse ? Qt.alpha(Colors.accentSoft, selected ? 1 : 0.6) : "transparent"
                            Behavior on color { ColorAnimation { duration: Animations.fast } }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10; anchors.rightMargin: 12
                                spacing: 0

                                Row {
                                    Layout.preferredWidth: 360
                                    spacing: 5
                                    Repeater {
                                        model: row.modelData.keys
                                        delegate: Row {
                                            id: keyItem
                                            required property string modelData
                                            required property int index
                                            spacing: 5
                                            Text {
                                                visible: keyItem.index > 0
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: "+"
                                                color: Colors.track
                                                font.family: Typography.mono
                                                font.pixelSize: Typography.small
                                            }
                                            Keycap {
                                                label: keyItem.modelData
                                                highlighted: row.selected || rowArea.containsMouse
                                            }
                                        }
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: row.modelData.description
                                    elide: Text.ElideRight
                                    color: Colors.text
                                    font.family: Typography.sans
                                    font.pixelSize: Typography.body
                                }

                                Row {
                                    visible: row.modelData.conflict
                                    spacing: 6
                                    NerdIcon { anchors.verticalCenter: parent.verticalCenter; text: "\uf071"; size: 12; color: Colors.urgent }
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "also bound elsewhere"
                                        color: Colors.urgent
                                        font.family: Typography.sans
                                        font.pixelSize: Typography.tiny
                                    }
                                }
                            }
                            MouseArea {
                                id: rowArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: list.currentIndex = row.index
                            }
                        }

                        // empty / error states
                        ColumnLayout {
                            anchors.centerIn: parent
                            visible: list.count === 0
                            spacing: 8
                            NerdIcon { Layout.alignment: Qt.AlignHCenter; text: "\uf11c"; size: 28; color: Colors.track }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: binds.failed ? "Could not read bindings from Hyprland (hyprctl binds)"
                                    : !binds.loaded ? "Loading…"
                                    : "No shortcuts match your search"
                                color: Colors.textMuted
                                font.family: Typography.sans
                                font.pixelSize: Typography.body
                            }
                        }
                    }
                }
            }

            // ---------------- footer ----------------
            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                Repeater {
                    model: [["↑↓", "navigate"], ["tab", "category"], ["esc", "close"]]
                    delegate: Row {
                        required property var modelData
                        spacing: 6
                        Keycap { label: parent.modelData[0] }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: parent.modelData[1]
                            color: Colors.textMuted
                            font.family: Typography.sans
                            font.pixelSize: Typography.tiny
                        }
                    }
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: "Edit config/hypr/modules/keybinds.conf to change these"
                    color: Colors.textMuted
                    font.family: Typography.sans
                    font.pixelSize: Typography.tiny
                }
            }
        }
    }
}
