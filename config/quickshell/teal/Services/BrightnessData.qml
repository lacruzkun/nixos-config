pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Backlight level. Reading is event driven: the kernel notifies sysfs when actual_brightness
// changes, so the F1/F2 brightnessctl binds show up in the island without any polling.
// Writing goes through brightnessctl, which the repo already uses.
Singleton {
    id: root

    property bool available: false
    property string device: ""
    property int max: 1
    property real value: 0                       // 0..1
    property bool loadedOnce: false
    property bool quiet: true

    Timer { interval: 2500; running: true; onTriggered: root.quiet = false }

    Process {
        command: ["brightnessctl", "-c", "backlight", "-m", "info"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                // name,class,current,percent,max
                const p = text.trim().split(",");
                if (p.length >= 5 && parseInt(p[4]) > 0) {
                    root.max = parseInt(p[4]);
                    root.value = parseInt(p[2]) / root.max;
                    root.device = p[0];
                    root.available = true;
                }
            }
        }
    }

    FileView {
        path: root.device !== "" ? "/sys/class/backlight/" + root.device + "/actual_brightness" : ""
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            const raw = parseInt(text());
            if (isNaN(raw) || root.max <= 0) return;
            const v = raw / root.max;
            const changed = Math.abs(v - root.value) > 0.002;
            root.value = v;
            if (root.loadedOnce && changed && !root.quiet) IslandState.push("brightness");
            root.loadedOnce = true;
        }
    }

    property real pending: -1
    Timer {
        id: apply
        interval: 60
        onTriggered: {
            if (root.pending >= 0)
                Quickshell.execDetached(["brightnessctl", "-c", "backlight", "set", Math.round(root.pending * 100) + "%"]);
            root.pending = -1;
        }
    }

    function set(v) {
        if (!available) return;
        pending = Math.max(0.01, Math.min(1, v));
        value = pending;
        apply.restart();
    }
}
