pragma Singleton
import QtQuick
import Quickshell

// Central controller for the Dynamic Island. Anything that wants the island's attention calls
// push(); priorities decide who wins, so the island never flickers between states:
//   critical notification > notification > media > screenshot > volume/mic/brightness
//   > bluetooth > workspace > clock
Singleton {
    id: root

    readonly property var priorities: ({
        critical: 100, notification: 90, media: 70, screenshot: 60,
        volume: 50, mic: 50, brightness: 50, bluetooth: 40, workspace: 30
    })

    property string mode: "idle"
    property var data: ({})
    property int priority: 0
    property bool hovered: false
    property bool armed: false                      // ignore the burst of events at startup

    // What the island actually shows. Hovering reveals media when a player exists.
    readonly property string display: mode !== "idle" ? mode
        : (hovered && MediaData.available ? "media" : "idle")

    function push(kind, payload, ms) {
        if (!armed) return;
        if ((kind === "volume" || kind === "brightness" || kind === "mic") && UiState.open === "controlCenter") return;
        const p = priorities[kind] !== undefined ? priorities[kind] : 10;
        if (mode !== "idle" && p < priority) return;    // lower priority never interrupts
        mode = kind === "critical" ? "notification" : kind;
        data = payload || {};
        priority = p;
        hold.interval = ms || 2200;
        if (!hovered) hold.restart();
    }

    function clear() {
        hold.stop();
        mode = "idle";
        priority = 0;
        data = ({});
    }

    onHoveredChanged: {
        if (hovered) hold.stop();
        else if (mode !== "idle") hold.restart();
    }

    Timer { id: hold; onTriggered: root.clear() }
    Timer { interval: 2500; running: true; onTriggered: root.armed = true }
}
