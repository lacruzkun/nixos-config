import QtQuick
import Quickshell
import qs.Services

// Lazy popup host: the popup is not created until it is first opened, then stays loaded
// (hidden, no surface mapped) so re-opening is instant and the close animation can finish.
Scope {
    id: slot

    required property string name
    property Component sourceComponent
    property bool latched: false

    readonly property bool wanted: UiState.open === name
    onWantedChanged: if (wanted) latched = true

    LazyLoader {
        active: slot.latched
        component: slot.sourceComponent
    }
}
