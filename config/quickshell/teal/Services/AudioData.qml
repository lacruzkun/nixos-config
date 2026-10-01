pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// PipeWire through Quickshell's native API (no wpctl/pactl polling). The existing
// wpctl Hyprland binds keep working; their changes arrive here as signals.
Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    PwObjectTracker { objects: [root.sink, root.source] }

    readonly property bool hasSink: sink !== null && sink.audio !== null
    readonly property bool hasSource: source !== null && source.audio !== null

    readonly property real volume: hasSink ? sink.audio.volume : 0
    readonly property bool muted: hasSink ? sink.audio.muted : false
    readonly property real micVolume: hasSource ? source.audio.volume : 0
    readonly property bool micMuted: hasSource ? source.audio.muted : false

    readonly property string sinkName: sink ? (sink.nickname || sink.description || sink.name) : "No output"
    readonly property string sourceName: source ? (source.nickname || source.description || source.name) : "No input"

    // Glyph for the current output state.
    readonly property string volumeIcon: !hasSink || muted || volume <= 0.001 ? "\uf026"
        : volume < 0.5 ? "\uf027" : "\uf028"

    property bool quiet: true
    Timer { id: settle; interval: 900; onTriggered: root.quiet = false }
    Timer { interval: 2500; running: true; onTriggered: root.quiet = false }
    onSinkChanged: { quiet = true; settle.restart(); }
    onSourceChanged: { quiet = true; settle.restart(); }

    Connections {
        target: root.hasSink ? root.sink.audio : null
        function onVolumesChanged() { if (!root.quiet) IslandState.push("volume"); }
        function onMutedChanged() { if (!root.quiet) IslandState.push("volume"); }
    }
    Connections {
        target: root.hasSource ? root.source.audio : null
        function onMutedChanged() { if (!root.quiet) IslandState.push("mic"); }
    }

    function setVolume(v) {
        if (!hasSink) return;
        sink.audio.muted = false;
        sink.audio.volume = Math.max(0, Math.min(1, v));
    }
    function setMicVolume(v) {
        if (hasSource) source.audio.volume = Math.max(0, Math.min(1, v));
    }
    function toggleMute() { if (hasSink) sink.audio.muted = !sink.audio.muted; }
    function toggleMicMute() { if (hasSource) source.audio.muted = !source.audio.muted; }

    function cycle(isSink) {
        const nodes = Pipewire.nodes.values.filter(n => n.audio && !n.isStream && n.isSink === isSink);
        if (nodes.length < 2) return;
        const cur = isSink ? sink : source;
        const next = nodes[(nodes.indexOf(cur) + 1) % nodes.length];
        if (isSink) Pipewire.preferredDefaultAudioSink = next;
        else Pipewire.preferredDefaultAudioSource = next;
    }
}
