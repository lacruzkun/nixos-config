pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Clipboard history via cliphist (fed by `wl-paste --watch cliphist store`, started in
// config/hypr/modules/autostart.conf). Entries are read when the popup opens.
Singleton {
    id: root

    property var entries: []             // [{ id, text, image }]
    property bool toolMissing: false
    property bool loading: false

    function reload() {
        if (!list.running) { loading = true; list.running = true; }
    }

    function copy(entry) {
        Quickshell.execDetached(["sh", "-c", "cliphist decode \"$1\" | wl-copy", "sh", entry.id]);
    }
    function remove(entry) {
        Quickshell.execDetached(["sh", "-c", "printf '%s\\t\\n' \"$1\" | cliphist delete", "sh", entry.id]);
        entries = entries.filter(e => e.id !== entry.id);
    }
    function wipe() {
        Quickshell.execDetached(["cliphist", "wipe"]);
        entries = [];
    }

    Process {
        id: list
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.toolMissing = false;
                root.entries = text.split("\n").filter(l => l.length > 0).slice(0, 200).map(l => {
                    const tab = l.indexOf("\t");
                    const body = tab >= 0 ? l.slice(tab + 1) : l;
                    return { id: tab >= 0 ? l.slice(0, tab) : "", text: body, image: body.indexOf("[[ binary data") === 0 };
                }).filter(e => e.id !== "");
                root.loading = false;
            }
        }
        onExited: (code, status) => {
            root.loading = false;
            if (code === 127) root.toolMissing = true;
        }
    }
}
