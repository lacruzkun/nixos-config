import QtQuick
import Quickshell.Io
import "../lib/Hyprbinds.js" as Hyprbinds
import "../lib/Fuzzy.js" as Fuzzy

// Live keybinding data. Asks Hyprland for its *loaded* binds (`hyprctl binds -j`) every time
// the menu opens, so the list always matches keybinds.conf - there is no second copy to keep
// in sync. Descriptions come from the `bindd` lines in that file.
QtObject {
    id: root

    property bool active: false              // set by the menu when it is open
    property string category: "All"
    property string query: ""
    property var rows: []
    property bool failed: false
    property bool loaded: false

    readonly property var categories: {
        const counts = {};
        rows.forEach(r => counts[r.category] = (counts[r.category] || 0) + 1);
        const list = [{ name: "All", count: rows.length, icon: "\uf11c" }];
        Hyprbinds.CATEGORIES.forEach(c => { if (counts[c]) list.push({ name: c, count: counts[c], icon: iconFor(c) }); });
        return list;
    }

    readonly property var visibleRows: {
        let r = category === "All" ? rows : rows.filter(x => x.category === category);
        const q = query.trim().toLowerCase();
        if (q === "") return r;
        return Fuzzy.rank(q, r, (needle, row) => Fuzzy.score(needle, row.search));
    }

    function iconFor(c) {
        return ({ General: "\uf013", Applications: "\uf2d0", Windows: "\uf2d2", Workspaces: "\uf24d",
                  Navigation: "\uf0b2", Media: "\uf001", Screenshots: "\uf030", System: "\uf011" })[c] || "\uf11c";
    }

    function cycleCategory(step) {
        const names = categories.map(c => c.name);
        const i = Math.max(0, names.indexOf(category));
        category = names[(i + step + names.length) % names.length];
    }

    onActiveChanged: if (active) { failed = false; if (!proc.running) proc.running = true; }

    property Process proc: Process {
        command: ["hyprctl", "binds", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.rows = Hyprbinds.build(JSON.parse(text));
                    root.failed = root.rows.length === 0;
                } catch (e) {
                    root.rows = [];
                    root.failed = true;
                }
                root.loaded = true;
                if (root.category !== "All" && !root.rows.some(r => r.category === root.category)) root.category = "All";
            }
        }
        onExited: (code, status) => { if (code !== 0) { root.failed = true; root.loaded = true; } }
    }
}
