import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Theme
import qs.Components
import qs.Services
import "../lib/Calendar.js" as Cal

// Month calendar opened from the island. Monday first.
OverlayPanel {
    id: win

    open: UiState.isOpen("calendar")
    onDismissed: UiState.close()

    SystemClock { id: clock; precision: SystemClock.Minutes }

    property int year: clock.date.getFullYear()
    property int month: clock.date.getMonth()

    onOpenChanged: if (open) { year = clock.date.getFullYear(); month = clock.date.getMonth(); }

    function shift(delta) {
        const d = new Date(year, month + delta, 1);
        year = d.getFullYear();
        month = d.getMonth();
    }

    readonly property var cells: Cal.monthGrid(year, month)

    Item {
        focus: true
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Left) { win.shift(-1); event.accepted = true; }
            else if (event.key === Qt.Key_Right) { win.shift(1); event.accepted = true; }
        }
    }

    Panel {
        t: win.t
        width: 320
        height: content.implicitHeight + Metrics.pad * 2
        x: (win.width - width) / 2
        y: Metrics.barHeight + 4

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: Metrics.pad
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                IconButton { icon: "\uf053"; size: 28; iconSize: 12; onClicked: win.shift(-1) }
                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: Cal.MONTHS[win.month] + " " + win.year
                    color: Colors.text
                    font.family: Typography.sans
                    font.pixelSize: Typography.title
                    font.weight: Font.Medium
                    MouseArea {      // click the title to jump back to today
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { win.year = clock.date.getFullYear(); win.month = clock.date.getMonth(); }
                    }
                }
                IconButton { icon: "\uf054"; size: 28; iconSize: 12; onClicked: win.shift(1) }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 7
                rowSpacing: 2
                columnSpacing: 2

                Repeater {
                    model: Cal.WEEKDAYS
                    delegate: Text {
                        required property string modelData
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData
                        color: Colors.textMuted
                        font.family: Typography.sans
                        font.pixelSize: Typography.tiny
                        font.weight: Font.Medium
                    }
                }

                Repeater {
                    model: win.cells
                    delegate: Item {
                        id: cell
                        required property var modelData
                        readonly property bool isToday: modelData.inMonth
                            && modelData.day === clock.date.getDate()
                            && modelData.month === clock.date.getMonth()
                            && modelData.year === clock.date.getFullYear()
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34

                        Rectangle {
                            anchors.centerIn: parent
                            width: 30; height: 30; radius: 15
                            color: cell.isToday ? Colors.accent : "transparent"
                        }
                        Text {
                            anchors.centerIn: parent
                            text: cell.modelData.day
                            color: cell.isToday ? Colors.text : cell.modelData.inMonth ? Colors.textDim : Colors.track
                            font.family: Typography.sans
                            font.pixelSize: Typography.body
                            font.weight: cell.isToday ? Font.Bold : Font.Normal
                        }
                    }
                }
            }
        }
    }
}
