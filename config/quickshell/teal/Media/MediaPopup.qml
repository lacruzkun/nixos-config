import QtQuick
import QtQuick.Layouts
import qs.Theme
import qs.Components
import qs.Services

// Opened by clicking the island while media is shown.
OverlayPanel {
    id: win

    open: UiState.isOpen("media")
    onDismissed: UiState.close()

    Panel {
        t: win.t
        width: 420
        height: card.implicitHeight + Metrics.pad * 2
        x: (win.width - width) / 2
        y: Metrics.barHeight + 4

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Metrics.pad
            MediaMini { id: card; Layout.fillWidth: true; big: true }
        }
    }
}
