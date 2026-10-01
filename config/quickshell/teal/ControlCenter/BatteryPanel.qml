import QtQuick
import QtQuick.Layouts
import qs.Theme
import qs.Components
import qs.Services

// Only instantiated on machines that have a battery (see ControlCenter.qml).
Section {
    title: "Battery"
    icon: BatteryData.icon

    RowLayout {
        Layout.fillWidth: true
        spacing: 12
        Text {
            text: BatteryData.percent + "%"
            color: BatteryData.low ? Colors.urgent : Colors.text
            font.family: Typography.sans
            font.pixelSize: Typography.large
            font.weight: Font.Medium
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4
            ProgressBar {
                Layout.fillWidth: true
                value: BatteryData.level
                fill: BatteryData.charging ? Colors.positive : BatteryData.low ? Colors.urgent : Colors.accentStrong
            }
            Text {
                text: BatteryData.stateText + (BatteryData.eta !== "" ? "  ·  " + BatteryData.eta : "")
                color: BatteryData.charging ? Colors.positive : Colors.textMuted
                font.family: Typography.sans
                font.pixelSize: Typography.small
            }
        }
    }
}
