import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../lib/Fuzzy.js" as Fuzzy
import qs.Services

// Search model for the launcher. Applications come straight from Quickshell's desktop-entry
// integration (no hand-written list); windows from Hyprland; the rest are shell actions.
QtObject {
    id: root

    property string query: ""

    // ---- sources ------------------------------------------------------
    readonly property var apps: DesktopEntries.applications.values.map(e => ({
        kind: "app",
        id: e.id,
        name: e.name,
        title: e.name,
        genericName: e.genericName,
        comment: e.comment,
        subtitle: e.genericName || e.comment || "",
        icon: e.icon,
        keywords: e.keywords,
        categories: e.categories,
        entry: e,
        tag: "App"
    })).sort((a, b) => a.title.localeCompare(b.title))

    readonly property var actions: [
        act("controlCenter", "Control center", "Network, audio, Bluetooth, battery", "\uf1de", "settings quick toggles wifi volume"),
        act("shortcuts", "Keyboard shortcuts", "Show every keybinding", "\uf11c", "keybindings hotkeys help keys"),
        act("clipboard", "Clipboard history", "Recent copied items", "\uf0ea", "paste copy history cliphist"),
        act("windows", "Window overview", "Switch between open windows", "\uf2d2", "alt tab switch windows"),
        act("notifications", "Notification center", "Recent notifications", "\uf0f3", "history mako"),
        act("calendar", "Calendar", "Month view", "\uf073", "date month"),
        act("power:lock", "Lock screen", "Lock the session", "\uf023", "lock screen secure"),
        act("power:suspend", "Suspend", "Sleep until woken", "\uf186", "sleep power"),
        act("power:logout", "Log out", "Exit Hyprland", "\uf08b", "logout exit power"),
        act("power:reboot", "Reboot", "Restart the computer", "\uf021", "restart power"),
        act("power:shutdown", "Shut down", "Power off", "\uf011", "poweroff power off"),
        act("shot:region-copy", "Screenshot: region", "Select an area, copy to clipboard", "\uf030", "screenshot grim slurp"),
        act("shot:region-edit", "Screenshot: region + annotate", "Open the area in swappy", "\uf044", "screenshot swappy edit"),
        act("shot:screen-copy", "Screenshot: full screen", "Copy the whole screen", "\uf108", "screenshot grim"),
        act("shot:window-copy", "Screenshot: window", "Copy the active window", "\uf2d0", "screenshot hyprshot"),
        act("screenshots", "Screenshot menu", "All capture options", "\uf030", "screenshot capture")
    ]

    readonly property var windows: Hyprland.toplevels.values.map(t => ({
        kind: "window",
        id: t.address,
        name: t.title || "(untitled)",
        title: t.title || "(untitled)",
        subtitle: "Workspace " + (t.workspace ? t.workspace.name : "?"),
        icon: iconFor(t),
        keywords: [],
        categories: [],
        address: t.address,
        tag: "Window"
    }))

    function act(id, title, subtitle, glyph, keywords) {
        return { kind: "action", id: id, name: title, title: title, subtitle: subtitle, glyph: glyph,
                 keywords: keywords.split(" "), categories: [], tag: id.indexOf("power:") === 0 ? "Power" : "Action" };
    }

    function iconFor(t) {
        const cls = t.wayland ? t.wayland.appId : (t.lastIpcObject ? t.lastIpcObject.class : "");
        if (!cls) return "";
        const e = DesktopEntries.heuristicLookup(cls);
        return e ? e.icon : cls;
    }

    // ---- result list --------------------------------------------------
    readonly property bool runMode: query.charAt(0) === ">"
    readonly property bool windowMode: /^w\s/.test(query)
    readonly property string needle: runMode ? query.slice(1).trim()
                                   : windowMode ? query.slice(2).trim() : query.trim()

    readonly property string modeLabel: runMode ? "Run command" : windowMode ? "Windows" : needle === "" ? "Applications" : "Search"
    readonly property string placeholder: "Search apps, windows, actions…   (> run command, w windows)"

    readonly property var results: {
        if (runMode) {
            return needle === "" ? [] : [{
                kind: "run", id: needle, name: needle, title: needle, subtitle: "Run in shell", glyph: "\uf120", tag: "Run"
            }];
        }
        if (windowMode) return Fuzzy.rank(needle, windows, (q, w) => Fuzzy.scoreFields(q, [
            { text: w.title, weight: 1 }, { text: w.subtitle, weight: 0.4 }]));
        if (needle === "") return apps.slice(0, 80);

        const pool = apps.concat(actions).concat(needle.length >= 2 ? windows : []);
        const scored = [];
        for (let i = 0; i < pool.length; i++) {
            const it = pool[i];
            const s = Fuzzy.scoreApp(needle, it) * (it.kind === "app" ? 1 : 0.92);
            if (s > 0) scored.push({ it: it, s: s, i: i });
        }
        // apps and actions interleave by score, so "lock" finds the lock action first
        scored.sort((a, b) => b.s - a.s || a.i - b.i);
        return scored.slice(0, 60).map(x => x.it);
    }
}
