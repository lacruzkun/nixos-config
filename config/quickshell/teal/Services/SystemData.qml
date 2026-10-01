pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// CPU / memory / uptime straight from /proc (no subprocesses) and disk via `df` once per
// refresh. Sampling only runs while the control center is open.
Singleton {
    id: root

    property real cpu: 0                 // 0..1
    property real memUsed: 0             // 0..1
    property real memTotalGb: 0
    property real memUsedGb: 0
    property string uptime: ""
    property real diskUsed: 0            // 0..1
    property string diskText: ""

    property var _prev: null

    function sample() {
        stat.reload();
        meminfo.reload();
        up.reload();
        if (!df.running) df.running = true;
    }

    FileView { id: stat; path: "/proc/stat"; blockLoading: true }
    FileView { id: meminfo; path: "/proc/meminfo"; blockLoading: true }
    FileView { id: up; path: "/proc/uptime"; blockLoading: true }

    Connections {
        target: stat
        function onLoaded() {
            const line = stat.text().split("\n")[0].trim().split(/\s+/).slice(1).map(Number);
            const idle = line[3] + (line[4] || 0);
            const total = line.reduce((a, b) => a + b, 0);
            if (root._prev) {
                const dt = total - root._prev.total, di = idle - root._prev.idle;
                if (dt > 0) root.cpu = Math.max(0, Math.min(1, 1 - di / dt));
            }
            root._prev = { total: total, idle: idle };
        }
    }
    Connections {
        target: meminfo
        function onLoaded() {
            const t = meminfo.text();
            const get = k => { const m = t.match(new RegExp(k + ":\\s+(\\d+)")); return m ? parseInt(m[1]) : 0; };
            const total = get("MemTotal"), avail = get("MemAvailable");
            if (total > 0) {
                root.memUsed = 1 - avail / total;
                root.memTotalGb = total / 1048576;
                root.memUsedGb = (total - avail) / 1048576;
            }
        }
    }
    Connections {
        target: up
        function onLoaded() {
            const s = Math.floor(parseFloat(up.text().split(" ")[0]));
            const d = Math.floor(s / 86400), h = Math.floor((s % 86400) / 3600), m = Math.floor((s % 3600) / 60);
            root.uptime = (d > 0 ? d + "d " : "") + (h > 0 || d > 0 ? h + "h " : "") + m + "m";
        }
    }

    Process {
        id: df
        command: ["df", "-B1", "--output=used,size", "/"]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = text.trim().split("\n")[1];
                if (!p) return;
                const [used, size] = p.trim().split(/\s+/).map(Number);
                if (size > 0) {
                    root.diskUsed = used / size;
                    root.diskText = (used / 1073741824).toFixed(0) + " / " + (size / 1073741824).toFixed(0) + " GB";
                }
            }
        }
    }

    Timer {
        interval: 2000
        repeat: true
        triggeredOnStart: true
        running: UiState.open === "controlCenter"
        onTriggered: root.sample()
    }
}
