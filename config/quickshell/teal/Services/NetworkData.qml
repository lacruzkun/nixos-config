pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../lib/Nmcli.js" as Nmcli

// NetworkManager state. Quickshell 0.2 has no native NetworkManager module, so this uses
// nmcli (NetworkManager is enabled in configuration.nix). `nmcli monitor` is event driven:
// state is re-read only when NetworkManager reports a change, never on a fast timer.
Singleton {
    id: root

    property bool hasWifi: false
    property bool wifiEnabled: true
    property string state: "disconnected"       // connected | connecting | disconnected
    property string type: ""                    // wifi | ethernet | ""
    property string iface: ""
    property string ssid: ""
    property int signal: 0                      // 0..100
    property var networks: []
    property string lastError: ""

    readonly property bool connected: state === "connected"
    readonly property string icon: type === "ethernet" && connected ? "\uf0ac"
        : !hasWifi || !wifiEnabled ? "\uf1eb"
        : "\uf1eb"
    readonly property string summary: !hasWifi && type !== "ethernet" ? "No network adapter"
        : connected ? (type === "wifi" ? ssid : "Wired") : state === "connecting" ? "Connecting…"
        : !wifiEnabled ? "Wi-Fi off" : "Disconnected"

    function refresh() {
        if (!devices.running) devices.running = true;
        if (!radio.running) radio.running = true;
    }
    function rescan() {
        Quickshell.execDetached(["nmcli", "device", "wifi", "rescan"]);
        scanDelay.restart();
    }
    function setWifi(on) {
        Quickshell.execDetached(["nmcli", "radio", "wifi", on ? "on" : "off"]);
    }
    function connectTo(name) {
        Quickshell.execDetached(["sh", "-c",
            "nmcli device wifi connect \"$1\" || notify-send 'Wi-Fi' \"Could not connect to $1. New secured networks need a saved password (nmcli device wifi connect ... --ask).\"",
            "sh", name]);
    }
    function disconnect() {
        if (iface !== "") Quickshell.execDetached(["nmcli", "device", "disconnect", iface]);
    }

    Component.onCompleted: refresh()

    Process {
        id: devices
        command: ["nmcli", "-t", "-f", "DEVICE,TYPE,STATE,CONNECTION", "device", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                const devs = Nmcli.parseDevices(text).filter(d => d.type === "wifi" || d.type === "ethernet");
                root.hasWifi = devs.some(d => d.type === "wifi");
                const active = devs.find(d => d.state === "connected")
                    || devs.find(d => d.state.indexOf("connecting") === 0)
                    || devs.find(d => d.type === "wifi")
                    || devs[0];
                if (!active) { root.state = "disconnected"; root.type = ""; root.iface = ""; root.ssid = ""; return; }
                root.iface = active.device;
                root.type = active.type;
                root.state = active.state === "connected" ? "connected"
                           : active.state.indexOf("connecting") === 0 ? "connecting" : "disconnected";
                root.ssid = active.type === "wifi" && root.state === "connected" ? active.connection : "";
                if (root.hasWifi) root.loadNetworks();
            }
        }
    }

    Process {
        id: radio
        command: ["nmcli", "radio", "wifi"]
        stdout: StdioCollector { onStreamFinished: root.wifiEnabled = text.trim() === "enabled" }
    }

    function loadNetworks() { if (!wifi.running && wifiEnabled) wifi.running = true; }

    Process {
        id: wifi
        command: ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "device", "wifi", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                const nets = Nmcli.parseWifi(text);
                root.networks = nets;
                const a = nets.find(n => n.active);
                root.signal = a ? a.signal : 0;
                if (a && root.type === "wifi") root.ssid = a.ssid;
            }
        }
    }

    // Event source: one line per NetworkManager change.
    Process {
        id: monitor
        command: ["nmcli", "monitor"]
        running: true
        stdout: SplitParser { onRead: debounce.restart() }
        onRunningChanged: if (!running) retry.start()
    }
    Timer { id: retry; interval: 15000; onTriggered: monitor.running = true }
    Timer { id: debounce; interval: 500; onTriggered: root.refresh() }
    Timer { id: scanDelay; interval: 2500; onTriggered: root.loadNetworks() }

    // Signal strength drifts without events; refresh gently, and only while the panel is open.
    Timer {
        interval: 20000
        repeat: true
        running: UiState.open === "controlCenter"
        onTriggered: root.refresh()
    }
}
