import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import qs.Theme
import qs.Services

// Native session lock (ext-session-lock) with PAM password auth. The repo had no lock tool
// (wlogout's default lock button needs swaylock, which is not installed), so Lock lives here.
Scope {
    id: root

    property bool locked: false
    property string input: ""
    property string status: ""

    function lock() { locked = true; }

    PamContext {
        id: pam
        configDirectory: Quickshell.shellDir + "/pam"
        config: "password.conf"
        onPamMessage: { if (responseRequired) respond(root.input); }
        onCompleted: result => {
            if (result === PamResult.Success) {
                root.locked = false;
                root.status = "";
            } else {
                root.status = "Wrong password";
                shake.restart();
            }
            root.input = "";
        }
        onError: root.status = "Authentication unavailable"
    }

    WlSessionLock {
        locked: root.locked
        onLockedChanged: if (!locked) { root.input = ""; root.status = ""; }

        surface: Component {
            WlSessionLockSurface {
                color: Colors.bg0

                Image {
                    anchors.fill: parent
                    source: "file://" + Quickshell.env("HOME") + "/.config/hypr/wallpaper.jpg"
                    fillMode: Image.PreserveAspectCrop
                    sourceSize: Qt.size(parent.width, parent.height)
                    asynchronous: true
                    opacity: 0.35
                }

                Item {
                    id: card
                    anchors.centerIn: parent
                    width: 320; height: 190

                    SystemClock { id: clk; precision: SystemClock.Minutes }

                    SequentialAnimation {
                        id: shake
                        NumberAnimation { target: card; property: "anchors.horizontalCenterOffset"; to: -12; duration: 50 }
                        NumberAnimation { target: card; property: "anchors.horizontalCenterOffset"; to: 12; duration: 80 }
                        NumberAnimation { target: card; property: "anchors.horizontalCenterOffset"; to: 0; duration: 50 }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 14
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: Qt.formatDateTime(clk.date, "HH:mm")
                            color: Colors.text
                            font.family: Typography.sans
                            font.pixelSize: 64
                            font.weight: Font.Bold
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 44
                            radius: 22
                            color: Colors.surface
                            border.width: 1
                            border.color: root.status !== "" ? Colors.urgent : Colors.border

                            TextInput {
                                id: field
                                anchors.fill: parent
                                anchors.leftMargin: 18; anchors.rightMargin: 18
                                verticalAlignment: TextInput.AlignVCenter
                                horizontalAlignment: TextInput.AlignHCenter
                                echoMode: TextInput.Password
                                passwordCharacter: "•"
                                color: Colors.text
                                font.family: Typography.sans
                                font.pixelSize: Typography.title
                                focus: true
                                enabled: !pam.active
                                text: root.input
                                onTextChanged: root.input = text
                                onAccepted: { root.status = ""; pam.start(); text = ""; }
                                Component.onCompleted: forceActiveFocus()
                            }
                            Text {
                                anchors.centerIn: parent
                                visible: field.text === "" && !pam.active
                                text: "Password"
                                color: Colors.textMuted
                                font.family: Typography.sans
                                font.pixelSize: Typography.body
                            }
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: pam.active ? "Checking…" : root.status
                            color: root.status !== "" ? Colors.urgent : Colors.textMuted
                            font.family: Typography.sans
                            font.pixelSize: Typography.small
                        }
                    }
                }
            }
        }
    }
}
