pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

// Every "do something" entry point shared by the launcher, power menu and screenshot popup.
// Commands are exactly the ones already used by config/hypr/modules/keybinds.conf.
Singleton {
    id: root

    signal lockRequested()

    readonly property string shotDir: Quickshell.env("HOME") + "/Pictures/Screenshots"

    function sh(script) { Quickshell.execDetached(["sh", "-c", script]); }

    // delay lets the popup fade out before slurp/grim take over the screen
    function later(script) { Quickshell.execDetached(["sh", "-c", "sleep 0.35; " + script]); }

    function power(name) {
        switch (name) {
        case "lock": lockRequested(); break;
        case "logout": Hyprland.dispatch("exit"); break;
        case "suspend": sh("systemctl suspend"); break;
        case "reboot": sh("systemctl reboot"); break;
        case "shutdown": sh("systemctl poweroff"); break;
        }
    }

    function screenshot(kind) {
        const f = "\"" + shotDir + "/$(date +%Y-%m-%d_%H-%M-%S).png\"";
        switch (kind) {
        case "region-copy": later("grim -g \"$(slurp)\" - | wl-copy && notify-send 'Screenshot copied'"); break;
        case "region-save": later("mkdir -p \"" + shotDir + "\"; file=" + f + "; grim -g \"$(slurp)\" \"$file\" && wl-copy < \"$file\" && notify-send 'Screenshot saved'"); break;
        case "region-edit": later("grim -g \"$(slurp)\" - | swappy -f -"); break;
        case "screen-copy": later("grim - | wl-copy && notify-send 'Full screen copied'"); break;
        case "screen-save": later("mkdir -p \"" + shotDir + "\"; file=" + f + "; grim \"$file\" && notify-send 'Full screen saved'"); break;
        case "window-copy": later("hyprshot -m window --clipboard-only"); break;
        case "window-edit": later("hyprshot -m window --raw | swappy -f -"); break;
        }
    }
}
