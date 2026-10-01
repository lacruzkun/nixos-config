import QtQuick
import QtQuick.Layouts
import qs.Theme
import qs.Components
import qs.Services

Section {
    title: "System"
    icon: "\uf2db"

    component Stat: RowLayout {
        property string label
        property string valueText
        property real fraction: -1
        Layout.fillWidth: true
        spacing: 10
        Text {
            Layout.preferredWidth: 46
            text: parent.label
            color: Colors.textMuted
            font.family: Typography.sans
            font.pixelSize: Typography.small
        }
        ProgressBar {
            Layout.fillWidth: true
            visible: parent.fraction >= 0
            value: parent.fraction
        }
        Text {
            Layout.preferredWidth: parent.fraction >= 0 ? 92 : -1
            Layout.fillWidth: parent.fraction < 0
            horizontalAlignment: Text.AlignRight
            text: parent.valueText
            color: Colors.text
            font.family: Typography.mono
            font.pixelSize: Typography.small
        }
    }

    Stat { label: "CPU"; fraction: SystemData.cpu; valueText: Math.round(SystemData.cpu * 100) + "%" }
    Stat {
        label: "Memory"
        fraction: SystemData.memUsed
        valueText: SystemData.memUsedGb.toFixed(1) + " / " + SystemData.memTotalGb.toFixed(1) + " GB"
    }
    Stat { label: "Disk"; fraction: SystemData.diskText !== "" ? SystemData.diskUsed : -1; valueText: SystemData.diskText; visible: SystemData.diskText !== "" }
    Stat { label: "Uptime"; valueText: SystemData.uptime }
}
