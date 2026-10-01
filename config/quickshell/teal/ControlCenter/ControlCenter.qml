import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Theme
import qs.Components
import qs.Media
import qs.Services

// Compact control center, anchored below the top-right utilities.
OverlayPanel {
    id: win

    open: UiState.isOpen("controlCenter")
    onDismissed: UiState.close()
    onOpenChanged: if (open) { NetworkData.refresh(); }

    Panel {
        id: panel
        t: win.t
        width: Metrics.popupWidth
        height: Math.min(col.implicitHeight + Metrics.pad * 2, win.height - Metrics.barHeight - Metrics.gap * 3)
        x: win.width - width - Metrics.gap
        y: Metrics.barHeight + 4

        Flickable {
            id: flick
            anchors.fill: parent
            anchors.margins: Metrics.pad
            contentHeight: col.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: col
                width: flick.width
                spacing: Metrics.spacing

                NetworkPanel {}
                AudioPanel {}
                BluetoothPanel {}

                Section {                       // brightness (hidden when there is no backlight)
                    visible: BrightnessData.available
                    title: "Brightness"
                    icon: "\uf185"
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        NerdIcon { text: "\uf186"; size: 14; color: Colors.textMuted }
                        Slider {
                            Layout.fillWidth: true
                            value: BrightnessData.value
                            onMoved: v => BrightnessData.set(v)
                        }
                        NerdIcon { text: "\uf185"; size: 16; color: Colors.text }
                        Text {
                            Layout.preferredWidth: 34
                            horizontalAlignment: Text.AlignRight
                            text: Math.round(BrightnessData.value * 100) + "%"
                            color: Colors.textDim
                            font.family: Typography.mono
                            font.pixelSize: Typography.small
                        }
                    }
                }

                Loader {                        // no battery -> nothing is created at all
                    Layout.fillWidth: true
                    active: BatteryData.present
                    visible: active
                    sourceComponent: BatteryPanel {}
                }

                MediaMini {
                    Layout.fillWidth: true
                    visible: MediaData.available
                }

                SystemPanel {}
            }
        }
    }
}
