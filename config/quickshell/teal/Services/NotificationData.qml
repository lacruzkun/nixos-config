pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Mako stays the notification daemon (config/mako/config). Mako runs
//   on-notify=exec quickshell -c teal ipc call shell notify "$id"
// for every new notification; this singleton looks that id up with `makoctl list -j` and
// hands it to the island. History for the notification center comes from `makoctl history -j`.
Singleton {
    id: root

    property var history: []
    property var active: []

    function onNotify(id) {
        lookup.pendingId = parseInt(id);
        if (!lookup.running) lookup.running = true;
    }

    function loadHistory() {
        if (!hist.running) hist.running = true;
        if (!current.running) current.running = true;
    }

    function dismissAll() { Quickshell.execDetached(["makoctl", "dismiss", "--all"]); active = []; }
    function restoreLast() { Quickshell.execDetached(["makoctl", "restore"]); }
    function clearHistory() {
        // mako has no "clear history" command; dismissing without history keeps it from growing
        // further, the list below is simply hidden until the next notification.
        history = [];
    }

    function classify(n) {
        const text = ((n.summary || "") + " " + (n.app_name || "")).toLowerCase();
        return /screenshot|full screen (copied|saved)/.test(text) ? "screenshot" : "notification";
    }

    function parse(text) {
        try {
            const v = JSON.parse(text);
            return Array.isArray(v) ? v : (v ? [v] : []);
        } catch (e) { return []; }
    }

    Process {
        id: lookup
        property int pendingId: -1
        command: ["makoctl", "list", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                const n = root.parse(text).find(x => x.id === lookup.pendingId);
                if (!n) return;
                const kind = root.classify(n);
                if (kind === "screenshot") {
                    IslandState.push("screenshot", { title: n.summary }, 2400);
                } else {
                    IslandState.push(n.urgency === "critical" ? "critical" : "notification", {
                        app: n.app_name, icon: n.app_icon, title: n.summary, body: n.body, urgency: n.urgency
                    }, n.urgency === "critical" ? 8000 : 5000);
                }
            }
        }
    }

    Process {
        id: hist
        command: ["makoctl", "history", "-j"]
        stdout: StdioCollector { onStreamFinished: root.history = root.parse(text).reverse().slice(0, 60) }
    }
    Process {
        id: current
        command: ["makoctl", "list", "-j"]
        stdout: StdioCollector { onStreamFinished: root.active = root.parse(text) }
    }
}
