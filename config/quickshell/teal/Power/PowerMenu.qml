import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Theme
import qs.Components
import qs.Services

// Power menu with a confirmation step for logout / reboot / shutdown.
OverlayPanel {
    id: win

    open: UiState.isOpen("power")
    scrim: true
    onDismissed: { pending = ""; UiState.close(); }
    onOpenChanged: if (!open) pending = ""

    property string pending: ""
    readonly property var actions: [
        { id: "lock",     label: "Lock",      icon: "\uf023", confirm: false, key: Qt.Key_L },
        { id: "logout",   label: "Log out",   icon: "\uf08b", confirm: true,  key: Qt.Key_O },
        { id: "suspend",  label: "Suspend",   icon: "\uf186", confirm: false, key: Qt.Key_S },
        { id: "reboot",   label: "Reboot",    icon: "\uf021", confirm: true,  key: Qt.Key_R },
        { id: "shutdown", label: "Shut down", icon: "\uf011", confirm: true,  key: Qt.Key_P }
    ]

    function choose(a) {
        if (a.confirm && pending !== a.id) { pending = a.id; return; }
        UiState.close();
        pending = "";
        Actions.power(a.id);
    }

    Item {
        anchors.fill: parent
        focus: true
        Keys.onPressed: event => {
            for (let i = 0; i < win.actions.length; i++)
                if (event.key === win.actions[i].key) { win.choose(win.actions[i]); event.accepted = true; return; }
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                const a = win.actions.find(x => x.id === win.pending);
                if (a) { win.choose(a); event.accepted = true; }
            }
        }
    }

    Panel {
        t: win.t
        width: row.implicitWidth + Metrics.pad * 2
        height: 168
        anchors.centerIn: parent

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Metrics.pad
            spacing: 12

            RowLayout {
                id: row
                Layout.alignment: Qt.AlignHCenter
                spacing: 10
                Repeater {
                    model: win.actions
                    delegate: Rectangle {
                        id: btn
                        required property var modelData
                        readonly property bool armed: win.pending === modelData.id
                        Layout.preferredWidth: 92
                        Layout.preferredHeight: 96
                        radius: Metrics.radiusCard
                        color: armed ? Colors.danger : area.containsMouse ? Colors.accentSoft : Colors.card
                        border.width: 1
                        border.color: armed ? Colors.urgent : Colors.borderSoft
                        scale: area.pressed ? 0.95 : 1
                        Behavior on color { ColorAnimation { duration: Animations.fast } }
                        Behavior on scale { NumberAnimation { duration: Animations.fast } }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            NerdIcon { Layout.alignment: Qt.AlignHCenter; text: btn.modelData.icon; size: 26
                                color: btn.armed ? Colors.fg1 : Colors.text }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: btn.armed ? "Confirm" : btn.modelData.label
                                color: Colors.text
                                font.family: Typography.sans
                                font.pixelSize: Typography.small
                                font.weight: btn.armed ? Font.Bold : Font.Normal
                            }
                        }
                        MouseArea {
                            id: area
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: win.choose(btn.modelData)
                        }
                    }
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: win.pending !== "" ? "Press again or Enter to confirm  ·  Esc to cancel"
                                         : "L lock  ·  O log out  ·  S suspend  ·  R reboot  ·  P shut down"
                color: Colors.textMuted
                font.family: Typography.sans
                font.pixelSize: Typography.small
            }
        }
    }
}
