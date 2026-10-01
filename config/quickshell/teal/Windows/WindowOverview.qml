import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Theme
import qs.Components
import qs.Services

// Compact list of every open window (real Hyprland data). Click or Enter focuses it.
OverlayPanel {
    id: win

    open: UiState.isOpen("windows")
    onDismissed: UiState.close()
    onOpenChanged: if (open) { Hyprland.refreshToplevels(); list.currentIndex = 0; }

    readonly property var windows: Hyprland.toplevels.values
        .filter(t => t.workspace !== null)
        .sort((a, b) => (a.workspace.id - b.workspace.id) || a.title.localeCompare(b.title))

    function focusWindow(t) {
        if (!t) return;
        UiState.close();
        Hyprland.dispatch("focuswindow address:0x" + t.address);
    }

    function iconOf(t) {
        const cls = t.wayland ? t.wayland.appId : (t.lastIpcObject ? t.lastIpcObject.class : "");
        if (!cls) return "";
        const e = DesktopEntries.heuristicLookup(cls);
        return e ? e.icon : cls;
    }

    Item {
        anchors.fill: parent
        focus: true
        Keys.onPressed: event => {
            const n = list.count;
            if (event.key === Qt.Key_Down || event.key === Qt.Key_J || event.key === Qt.Key_Tab) { if (n) list.currentIndex = (list.currentIndex + 1) % n; event.accepted = true; }
            else if (event.key === Qt.Key_Up || event.key === Qt.Key_K || event.key === Qt.Key_Backtab) { if (n) list.currentIndex = (list.currentIndex - 1 + n) % n; event.accepted = true; }
            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) { win.focusWindow(win.windows[list.currentIndex]); event.accepted = true; }
        }
    }

    Panel {
        t: win.t
        width: 520
        height: Math.min(Math.max(list.count, 1) * 54 + 78, win.height - 140)
        anchors.horizontalCenter: parent.horizontalCenter
        y: Metrics.barHeight + 40

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Metrics.pad
            spacing: 8

            Text {
                text: "Windows"
                color: Colors.text
                font.family: Typography.sans
                font.pixelSize: Typography.title
                font.weight: Font.Medium
            }

            ListView {
                id: list
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: win.windows
                spacing: 3
                boundsBehavior: Flickable.StopAtBounds
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                delegate: Rectangle {
                    id: row
                    required property var modelData
                    required property int index
                    readonly property bool active: Hyprland.activeToplevel === modelData
                    readonly property bool selected: ListView.isCurrentItem
                    width: ListView.view.width
                    height: 51
                    radius: Metrics.radiusSmall
                    color: selected ? Colors.accentSoft : rowArea.containsMouse ? Qt.alpha(Colors.accentSoft, 0.4) : "transparent"
                    border.width: active ? 1 : 0
                    border.color: Colors.accent
                    Behavior on color { ColorAnimation { duration: Animations.fast } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12; anchors.rightMargin: 12
                        spacing: 12
                        AppIcon { size: 30; name: win.iconOf(row.modelData) }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Text {
                                Layout.fillWidth: true
                                text: row.modelData.title || "(untitled)"
                                elide: Text.ElideRight
                                color: Colors.text
                                font.family: Typography.sans
                                font.pixelSize: Typography.body
                                font.weight: row.active ? Font.Medium : Font.Normal
                            }
                            Text {
                                text: row.active ? "Focused" : ""
                                visible: text !== ""
                                color: Colors.accentStrong
                                font.family: Typography.sans
                                font.pixelSize: Typography.tiny
                            }
                        }
                        Rectangle {
                            Layout.preferredWidth: wsLabel.implicitWidth + 16
                            Layout.preferredHeight: 22
                            radius: 11
                            color: Colors.teal1
                            Text {
                                id: wsLabel
                                anchors.centerIn: parent
                                text: row.modelData.workspace ? (row.modelData.workspace.name.indexOf("special:") === 0 ? "scratchpad" : row.modelData.workspace.name) : ""
                                color: Colors.text
                                font.family: Typography.mono
                                font.pixelSize: Typography.small
                            }
                        }
                    }
                    MouseArea {
                        id: rowArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: list.currentIndex = row.index
                        onClicked: win.focusWindow(row.modelData)
                    }
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    visible: list.count === 0
                    spacing: 8
                    NerdIcon { Layout.alignment: Qt.AlignHCenter; text: "\uf2d2"; size: 28; color: Colors.track }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "No open windows"
                        color: Colors.textMuted
                        font.family: Typography.sans
                        font.pixelSize: Typography.body
                    }
                }
            }
        }
    }
}
