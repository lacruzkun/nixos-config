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
        width: Math.min(900, win.width - 80)
        height: Math.min(560, win.height - 120)
        anchors.horizontalCenter: parent.horizontalCenter
        y: Math.max(Metrics.barHeight + 20, (win.height - height) / 2 - 30)

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 12

            // ---------------- artwork banner ----------------
            ClippingRectangle {
                Layout.preferredWidth: Math.min(300, panel.width * 0.36)
                Layout.fillHeight: true
                radius: Metrics.radius - 8
                color: Colors.teal0

                Image {
                    id: art
                    anchors.fill: parent
                    source: Qt.resolvedUrl("../assets/90s-anime.png")
                    fillMode: Image.PreserveAspectCrop
                    horizontalAlignment: Image.AlignHCenter
                    asynchronous: true
                    cache: true
                    smooth: true
                    sourceSize: Qt.size(720, 720)          // decoded once at a banner-sized resolution
                    scale: 1.0 + 0.04 * (1 - win.t)         // tiny settle on open
                }

                // light teal wash keeps the artwork in the shell's palette without hiding it
                Rectangle { anchors.fill: parent; color: Qt.alpha(Colors.teal1, 0.14) }

                Rectangle {                                  // caption fade
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                    height: 96
                    gradient: Gradient {
                        GradientStop { position: 0; color: "transparent" }
                        GradientStop { position: 1; color: Qt.alpha(Colors.bg0, 0.88) }
                    }
                }
                ColumnLayout {
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 16 }
                    spacing: 2
                    Text {
                        text: search.modeLabel
                        color: Colors.text
                        font.family: Typography.sans
                        font.pixelSize: Typography.title
                        font.weight: Font.Medium
                    }
                    Text {
                        text: list.count + (list.count === 1 ? " result" : " results")
                        color: Colors.textMuted
                        font.family: Typography.mono
                        font.pixelSize: Typography.tiny
                    }
                }
            }

            // ---------------- search + results ----------------
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    radius: 25
                    color: Colors.card
                    border.width: 1
                    border.color: input.activeFocus ? Colors.accent : Colors.borderSoft
                    Behavior on border.color { ColorAnimation { duration: Animations.fast } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 18; anchors.rightMargin: 18
                        spacing: 12
                        NerdIcon {
                            text: search.runMode ? "\uf120" : "\uf002"
                            size: 16
                            color: Colors.textMuted
                        }
                        TextInput {
                            id: input
                            Layout.fillWidth: true
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
                                color: Colors.textMuted
                                font: input.font
                            }

                            onTextChanged: list.currentIndex = 0

                            Keys.onPressed: event => {
                                const n = list.count;
                                if (event.key === Qt.Key_Down || (event.key === Qt.Key_J && (event.modifiers & Qt.ControlModifier))
                                    || (event.key === Qt.Key_N && (event.modifiers & Qt.ControlModifier))) {
                                    if (n > 0) list.currentIndex = (list.currentIndex + 1) % n;
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Up || (event.key === Qt.Key_K && (event.modifiers & Qt.ControlModifier))
                                    || (event.key === Qt.Key_P && (event.modifiers & Qt.ControlModifier))) {
                                    if (n > 0) list.currentIndex = (list.currentIndex - 1 + n) % n;
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Tab) {
                                    if (n > 0) list.currentIndex = (list.currentIndex + 1) % n;
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_PageDown) {
                                    list.currentIndex = Math.min(n - 1, list.currentIndex + 6); event.accepted = true;
                                } else if (event.key === Qt.Key_PageUp) {
                                    list.currentIndex = Math.max(0, list.currentIndex - 6); event.accepted = true;
                                } else if (event.key === Qt.Key_Escape) {
                                    win.dismissed(); event.accepted = true;
                                }
                            }
                            onAccepted: win.run(search.results[list.currentIndex])
                        }
                    }
                }

                ListView {
                    id: list
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: search.results
                    currentIndex: 0
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
