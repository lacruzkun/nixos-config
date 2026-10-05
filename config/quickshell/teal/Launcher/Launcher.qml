import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.Theme
import qs.Components
import qs.Services

// Application launcher (replaces Rofi). The existing 90s-anime.png artwork is the banner on the
// left; search + results are on the right.
OverlayPanel {
    id: win

    open: UiState.isOpen("launcher")
    scrim: true
    onDismissed: UiState.close()

    AppModel { id: search; query: input.text }

    onOpenChanged: {
        if (open) {
            input.text = UiState.launcherMode === "run" ? ">" : "";
            list.currentIndex = 0;
            input.forceActiveFocus();
        }
    }

    function run(item) {
        if (!item) return;
        UiState.close();
        switch (item.kind) {
        case "app":
            if (item.entry.runInTerminal) Quickshell.execDetached(["kitty"].concat(item.entry.command));
            else item.entry.execute();
            break;
        case "run":
            Quickshell.execDetached(["sh", "-c", item.id]);
            break;
        case "window":
            Hyprland.dispatch("focuswindow address:0x" + item.address);
            break;
        case "action":
            runAction(item.id);
            break;
        }
    }

    function runAction(id) {
        if (id.indexOf("shot:") === 0) { Actions.screenshot(id.slice(5)); return; }
        if (id === "power:lock" || id === "power:suspend") { Actions.power(id.slice(6)); return; }
        if (id.indexOf("power:") === 0) { UiState.show("power"); return; }   // destructive: confirm there
        UiState.show(id);
    }

    Panel {
        id: panel
        t: win.t
        width: Math.min(660, win.width - 80)
        readonly property real bannerH: Math.round(width * 0.36)       // wide strip, like the old Rofi header
        height: Math.min(bannerH + 372, win.height - 120)
        anchors.horizontalCenter: parent.horizontalCenter
        y: Math.max(Metrics.barHeight + 20, (win.height - height) / 2 - 30)

        // everything is clipped to the panel's rounded corners so the artwork bleeds to the edge
        ClippingRectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: Metrics.radius - 1
            color: "transparent"

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // ---------------- artwork header with the search bar on it ----------------
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: panel.bannerH
                    clip: true

                    Rectangle { anchors.fill: parent; color: Colors.teal0 }

                    Image {
                        id: art
                        // scaled to the full width, then slid up so the glasses and face sit in the strip
                        width: parent.width
                        height: width * 1012 / 1352
                        y: -0.125 * height
                        source: Qt.resolvedUrl("../assets/90s-anime.png")
                        fillMode: Image.Stretch
                        asynchronous: true
                        cache: true
                        smooth: true
                        sourceSize: Qt.size(1352, 1012)
                        scale: 1.0 + 0.04 * (1 - win.t)         // tiny settle on open
                    }

                    // faint teal wash keeps the artwork in the shell's palette without hiding it
                    Rectangle { anchors.fill: parent; color: Qt.alpha(Colors.teal1, 0.12) }

                    Rectangle {                                  // mode / result count
                        x: 18; y: 16
                        width: modeText.implicitWidth + 24
                        height: 26
                        radius: 13
                        color: Qt.alpha(Colors.bg0, 0.62)
                        Text {
                            id: modeText
                            anchors.centerIn: parent
                            text: search.modeLabel + "  ·  " + list.count
                            color: Colors.text
                            font.family: Typography.mono
                            font.pixelSize: Typography.tiny + 1
                        }
                    }

                    // search: icon pill + entry pill, same two-pill look as the Rofi header
                    RowLayout {
                        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 22 }
                        height: 48
                        spacing: 10

                        Rectangle {
                            Layout.preferredWidth: 48
                            Layout.preferredHeight: 48
                            radius: 24
                            color: Qt.alpha(Colors.bg1, 0.95)
                            NerdIcon {
                                anchors.centerIn: parent
                                text: search.runMode ? "\uf120" : "\uf002"
                                size: 16
                                color: Colors.text
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            radius: 24
                            color: Qt.alpha(Colors.bg1, 0.95)
                            border.width: 1
                            border.color: input.activeFocus ? Colors.accentStrong : "transparent"
                            Behavior on border.color { ColorAnimation { duration: Animations.fast } }

                            TextInput {
                                id: input
                                anchors.fill: parent
                                anchors.leftMargin: 20; anchors.rightMargin: 20
                                verticalAlignment: TextInput.AlignVCenter
                                color: Colors.text
                                selectionColor: Colors.accent
                                font.family: Typography.sans
                                font.pixelSize: Typography.title
                                clip: true
                                focus: true

                                Text {
                                    anchors.fill: parent
                                    verticalAlignment: Text.AlignVCenter
                                    visible: input.text === ""
                                    text: search.placeholder
                                    elide: Text.ElideRight
                                    color: Colors.textDim
                                    opacity: 0.75
                                    font: input.font
                                }

                                onTextChanged: list.currentIndex = 0

                                Keys.onPressed: event => {
                                    const n = list.count;
                                    const ctrl = event.modifiers & Qt.ControlModifier;
                                    if (event.key === Qt.Key_Down || (ctrl && (event.key === Qt.Key_J || event.key === Qt.Key_N))) {
                                        if (n > 0) list.currentIndex = (list.currentIndex + 1) % n;
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Up || (ctrl && (event.key === Qt.Key_K || event.key === Qt.Key_P))) {
                                        if (n > 0) list.currentIndex = (list.currentIndex - 1 + n) % n;
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Tab) {
                                        if (n > 0) list.currentIndex = (list.currentIndex + 1) % n;
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_PageDown) {
                                        list.currentIndex = Math.min(n - 1, list.currentIndex + 5); event.accepted = true;
                                    } else if (event.key === Qt.Key_PageUp) {
                                        list.currentIndex = Math.max(0, list.currentIndex - 5); event.accepted = true;
                                    } else if (event.key === Qt.Key_Escape) {
                                        win.dismissed(); event.accepted = true;
                                    }
                                }
                                onAccepted: win.run(search.results[list.currentIndex])
                            }
                        }
                    }
                }

                // ---------------- results below the artwork ----------------
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 14
                    Layout.topMargin: 12
                    spacing: 8

                    ListView {
                        id: list
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: search.results
                        currentIndex: 0
                        spacing: 6
                        boundsBehavior: Flickable.StopAtBounds
                        highlightMoveDuration: 90
                        keyNavigationEnabled: false
                        cacheBuffer: 400

                        delegate: AppDelegate {
                            selected: ListView.isCurrentItem
                            onHovered: list.currentIndex = index
                            onActivated: win.run(modelData)
                        }

                        onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                        // empty state
                        ColumnLayout {
                            anchors.centerIn: parent
                            visible: list.count === 0
                            spacing: 8
                            NerdIcon { Layout.alignment: Qt.AlignHCenter; text: "\uf002"; size: 26; color: Colors.track }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: search.runMode ? "Type a command to run" : "No applications found"
                                color: Colors.textMuted
                                font.family: Typography.sans
                                font.pixelSize: Typography.body
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 6
                        spacing: 14
                        Repeater {
                            model: [["↑↓", "navigate"], ["⏎", "open"], ["esc", "close"]]
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
                    }
                }
            }
        }
    }
}
