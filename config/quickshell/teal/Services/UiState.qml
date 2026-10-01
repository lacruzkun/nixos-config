pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

// Which popup is open (only one at a time) and which screen popups appear on.
Singleton {
    id: root

    // "", launcher, controlCenter, calendar, media, shortcuts, power, clipboard,
    // screenshots, windows, notifications
    property string open: ""
    property string launcherMode: "apps"

    readonly property var focusedScreen: {
        const mon = Hyprland.focusedMonitor;
        const screens = Quickshell.screens;
        if (mon) {
            for (let i = 0; i < screens.length; i++)
                if (screens[i].name === mon.name) return screens[i];
        }
        return screens.length > 0 ? screens[0] : null;
    }

    function isOpen(name) { return open === name; }

    function show(name, mode) {
        if (name === "launcher") launcherMode = mode || "apps";
        open = name;
    }

    function toggle(name, mode) {
        if (open === name) open = "";
        else show(name, mode);
    }

    function close() { open = ""; }
}
