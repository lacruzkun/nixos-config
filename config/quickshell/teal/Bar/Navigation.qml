import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Theme
import qs.Components
import qs.Services

// Top-left pill: launcher, Hyprland workspaces (1-10 + scratchpads), shortcuts, window title.
Pill {
    id: root

    required property var screen

    readonly property int cell: 24
    readonly property int cellGap: 3
    readonly property var monitor: Hyprland.monitorFor(screen)
    readonly property var workspaces: Hyprland.workspaces.values
    readonly property int activeId: monitor && monitor.activeWorkspace ? monitor.activeWorkspace.id : 1
    readonly property var specials: workspaces.filter(w => w.name.indexOf("special:") === 0)
    readonly property string title: Hyprland.activeToplevel && Hyprland.activeToplevel.workspace
        && monitor && Hyprland.activeToplevel.workspace.monitor
        && Hyprland.activeToplevel.workspace.monitor.name === monitor.name ? Hyprland.activeToplevel.title : ""

    function wsFor(i) {
        for (let k = 0; k < workspaces.length; k++)
            if (workspaces[k].id === i) return workspaces[k];
        return null;
    }
    function occupied(i) {
        const w = wsFor(i);
        return w !== null && w.toplevels.values.length > 0;
    }

    implicitWidth: row.implicitWidth + 16
    implicitHeight: Metrics.pillHeight

    RowLayout {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 6
        spacing: 4

        IconButton {
            id: launcherBtn
            icon: "\uf313"                      // nf-linux-nixos
            iconSize: 18
            size: 28
            active: UiState.isOpen("launcher")
            onClicked: UiState.toggle("launcher")
            Tooltip { target: launcherBtn; hovered: launcherBtn.hovered; text: "Applications" }
        }

        Rectangle { width: 1; height: 16; color: Colors.borderSoft }

        // ---- workspaces -------------------------------------------------
        Item {
            id: wsStrip
            implicitWidth: 10 * root.cell + 9 * root.cellGap
            implicitHeight: root.cell

            // sliding highlight under the active workspace
            Rectangle {
                width: root.cell
                height: root.cell
                radius: height / 2
                color: Colors.accent
                x: Math.max(0, Math.min(9, root.activeId - 1)) * (root.cell + root.cellGap)
                visible: root.activeId >= 1 && root.activeId <= 10
                Behavior on x { NumberAnimation { duration: Animations.normal; easing.type: Easing.BezierSpline; easing.bezierCurve: Animations.easeOutQuint } }
            }

            Repeater {
                model: 10
                delegate: Item {
                    id: cellItem
                    required property int index
                    readonly property int wsId: index + 1
                    readonly property bool isActive: root.activeId === wsId
                    readonly property bool isOccupied: root.occupied(wsId)
                    readonly property var ws: root.wsFor(wsId)

                    x: index * (root.cell + root.cellGap)
                    width: root.cell
                    height: root.cell

                    Rectangle {      // quiet dot for unused workspaces
                        anchors.centerIn: parent
                        width: cellItem.isOccupied || cellItem.isActive ? 0 : 4
                        height: width
                        radius: width / 2
                        color: cellHover.containsMouse ? Colors.textMuted : Colors.track
                        Behavior on width { NumberAnimation { duration: Animations.fast } }
                    }
                    Text {           // number for the active / occupied ones
                        anchors.centerIn: parent
                        visible: cellItem.isOccupied || cellItem.isActive
                        text: cellItem.wsId
                        font.family: Typography.mono
                        font.pixelSize: Typography.small
                        font.weight: cellItem.isActive ? Font.Bold : Font.Normal
                        color: cellItem.isActive ? Colors.text
                             : cellItem.ws && cellItem.ws.urgent ? Colors.urgent
                             : Colors.textMuted
                    }
                    Rectangle {      // hover wash
                        anchors.fill: parent
                        radius: height / 2
                        color: Colors.accentSoft
                        opacity: cellHover.containsMouse && !cellItem.isActive ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: Animations.fast } }
                    }
                    MouseArea {
                        id: cellHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Hyprland.dispatch("workspace " + cellItem.wsId)
                    }
                }
            }

            WheelHandler {
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                onWheel: event => Hyprland.dispatch("workspace " + (event.angleDelta.y > 0 ? "e-1" : "e+1"))
            }
        }

        // scratchpads / special workspaces that currently exist
        Repeater {
            model: root.specials
            delegate: IconButton {
                required property var modelData
                icon: "\uf0c5"
                size: 24
                iconSize: 13
                active: modelData.active
                onClicked: Hyprland.dispatch("togglespecialworkspace " + modelData.name.replace("special:", ""))
            }
        }

        Rectangle { width: 1; height: 16; color: Colors.borderSoft }

        IconButton {
            id: keysBtn
            icon: "\uf11c"                      // keyboard
            size: 28
            active: UiState.isOpen("shortcuts")
            onClicked: UiState.toggle("shortcuts")
            Tooltip { target: keysBtn; hovered: keysBtn.hovered; text: "Keyboard shortcuts" }
        }

        // Active window title - only when the screen is wide enough that it cannot collide
        // with the island in the middle.
        Text {
            id: titleText
            readonly property real room: root.screen.width / 2 - Metrics.islandWindowWidth / 2 * 0.62
                - (row.x + launcherBtn.width + wsStrip.implicitWidth + 140)
            visible: root.title !== "" && room > 120
            Layout.maximumWidth: Math.max(0, Math.min(260, room))
            Layout.leftMargin: 4
            Layout.rightMargin: 8
            text: root.title
            elide: Text.ElideRight
            color: Colors.textMuted
            font.family: Typography.sans
            font.pixelSize: Typography.small
        }
    }
}
