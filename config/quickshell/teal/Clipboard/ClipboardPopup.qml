import QtQuick
import QtQuick.Layouts
import Quickshell
import "../lib/Fuzzy.js" as Fuzzy
import qs.Theme
import qs.Components
import qs.Services

// Clipboard history (cliphist). Enter copies the selected entry, Delete removes it.
OverlayPanel {
    id: win

    open: UiState.isOpen("clipboard")
    onDismissed: UiState.close()
    onOpenChanged: if (open) { search.text = ""; ClipboardData.reload(); list.currentIndex = 0; search.forceActiveFocus(); }

    readonly property var shown: Fuzzy.rank(search.text.trim(), ClipboardData.entries, (q, e) => Fuzzy.score(q, e.text))

    function choose(entry) {
        if (!entry) return;
        UiState.close();
        ClipboardData.copy(entry);
    }

    Panel {
        t: win.t
        width: Math.min(560, win.width - 80)
        height: Math.min(520, win.height - 140)
        anchors.horizontalCenter: parent.horizontalCenter
        y: Metrics.barHeight + 40

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Metrics.pad
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: "Clipboard"
                    color: Colors.text
                    font.family: Typography.sans
                    font.pixelSize: Typography.title
                    font.weight: Font.Medium
                }
                IconButton { icon: "\uf1f8"; size: 28; iconSize: 13; visible: ClipboardData.entries.length > 0; onClicked: ClipboardData.wipe() }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 42
                radius: 21
                color: Colors.card
                border.width: 1
                border.color: search.activeFocus ? Colors.accent : Colors.borderSoft

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
                            text: "Search clipboard…"
                            color: Colors.textMuted
                            font: search.font
                        }
                        onTextChanged: list.currentIndex = 0
                        Keys.onPressed: event => {
                            const n = list.count;
                            if (event.key === Qt.Key_Down) { if (n) list.currentIndex = (list.currentIndex + 1) % n; event.accepted = true; }
                            else if (event.key === Qt.Key_Up) { if (n) list.currentIndex = (list.currentIndex - 1 + n) % n; event.accepted = true; }
                            else if (event.key === Qt.Key_Delete) { if (n) ClipboardData.remove(win.shown[list.currentIndex]); event.accepted = true; }
                            else if (event.key === Qt.Key_Escape) { win.dismissed(); event.accepted = true; }
                        }
                        onAccepted: win.choose(win.shown[list.currentIndex])
                    }
                }
            }

            ListView {
                id: list
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: win.shown
                spacing: 3
                boundsBehavior: Flickable.StopAtBounds
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                delegate: Rectangle {
                    id: row
                    required property var modelData
                    required property int index
                    readonly property bool selected: ListView.isCurrentItem
                    width: ListView.view.width
                    height: 46
                    radius: Metrics.radiusSmall
                    color: selected ? Colors.accentSoft : rowArea.containsMouse ? Qt.alpha(Colors.accentSoft, 0.4) : "transparent"
                    border.width: selected ? 1 : 0
                    border.color: Colors.accent
                    Behavior on color { ColorAnimation { duration: Animations.fast } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12; anchors.rightMargin: 12
                        spacing: 10
                        NerdIcon { text: row.modelData.image ? "\uf03e" : "\uf0c5"; size: 14; color: Colors.textMuted }
                        Text {
                            Layout.fillWidth: true
                            text: row.modelData.text.replace(/\s+/g, " ")
                            elide: Text.ElideRight
                            color: row.modelData.image ? Colors.textMuted : Colors.text
                            font.family: row.modelData.image ? Typography.sans : Typography.mono
                            font.pixelSize: Typography.small + 1
                        }
                    }
                    MouseArea {
                        id: rowArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: list.currentIndex = row.index
                        onClicked: win.choose(row.modelData)
                    }
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    visible: list.count === 0
                    spacing: 8
                    NerdIcon { Layout.alignment: Qt.AlignHCenter; text: "\uf0ea"; size: 28; color: Colors.track }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: ClipboardData.toolMissing ? "cliphist is not installed"
                            : search.text !== "" ? "No matching entries"
                            : ClipboardData.loading ? "Loading…" : "Clipboard history is empty"
                        color: Colors.textMuted
                        font.family: Typography.sans
                        font.pixelSize: Typography.body
                    }
                }
            }
        }
    }
}
