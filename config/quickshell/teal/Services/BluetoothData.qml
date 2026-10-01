pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth

// BlueZ through Quickshell's native Bluetooth module.
Singleton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: adapter ? adapter.enabled : false
    readonly property var devices: Bluetooth.devices.values
    readonly property var connectedDevices: devices.filter(d => d.connected)
    readonly property var knownDevices: devices.filter(d => d.paired || d.connected)
    readonly property string icon: !available || !enabled ? "\uf294" : "\uf293"

    property bool quiet: true
    Timer { interval: 3000; running: true; onTriggered: root.quiet = false }

    function setEnabled(on) { if (adapter) adapter.enabled = on; }
    function toggleDevice(d) { if (d.connected) d.disconnect(); else d.connect(); }

    function noteDevice(d) {
        if (quiet) return;
        IslandState.push("bluetooth", { name: d.name || d.deviceName || d.address, connected: d.connected }, 2600);
    }

    Instantiator {
        model: Bluetooth.devices
        delegate: Scope {
            required property var modelData
            Connections {
                target: modelData
                function onConnectedChanged() { root.noteDevice(modelData); }
            }
        }
    }
}
