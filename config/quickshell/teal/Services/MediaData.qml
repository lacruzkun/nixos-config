pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// MPRIS. Picks the most relevant player (manual choice > playing > last played > first) and
// tells the island when something changes.
Singleton {
    id: root

    property string manualId: ""
    property string lastPlayingId: ""

    readonly property var player: {
        const list = Mpris.players.values;
        if (list.length === 0) return null;
        const byId = id => list.find(p => p.dbusName === id);
        return byId(manualId) || list.find(p => p.isPlaying) || byId(lastPlayingId) || list[0];
    }

    readonly property bool available: player !== null && (player.trackTitle !== "" || player.isPlaying)
    readonly property bool playing: player !== null && player.isPlaying
    readonly property string title: player ? player.trackTitle : ""
    readonly property string artist: player ? player.trackArtist : ""
    readonly property string album: player ? player.trackAlbum : ""
    readonly property string artUrl: player ? player.trackArtUrl : ""
    readonly property string identity: player ? player.identity : ""
    readonly property real length: player && player.lengthSupported ? player.length : 0
    readonly property real position: player && player.positionSupported ? player.position : 0
    readonly property real progress: length > 0 ? Math.max(0, Math.min(1, position / length)) : 0
    readonly property int playerCount: Mpris.players.values.length

    function toggle() { if (player && player.canTogglePlaying) player.togglePlaying(); }
    function next() { if (player && player.canGoNext) player.next(); }
    function previous() { if (player && player.canGoPrevious) player.previous(); }
    function seekTo(fraction) {
        if (player && player.canSeek && length > 0) player.position = fraction * length;
    }
    function cyclePlayer() {
        const list = Mpris.players.values;
        if (list.length < 2) return;
        const i = list.findIndex(p => player && p.dbusName === player.dbusName);
        manualId = list[(i + 1) % list.length].dbusName;
    }

    function format(seconds) {
        const s = Math.max(0, Math.floor(seconds));
        const m = Math.floor(s / 60);
        return m + ":" + (s % 60 < 10 ? "0" : "") + (s % 60);
    }

    // MPRIS positions are not pushed; nudge the binding once a second, and only while
    // something on screen is actually showing the progress.
    Timer {
        interval: 1000
        repeat: true
        running: root.playing && (IslandState.display === "media" || UiState.open === "controlCenter" || UiState.open === "media")
        onTriggered: root.player.positionChanged()
    }

    Instantiator {
        model: Mpris.players
        delegate: Scope {
            id: watcher
            required property var modelData
            readonly property bool isPlaying: modelData.isPlaying
            onIsPlayingChanged: if (isPlaying) root.lastPlayingId = modelData.dbusName

            Connections {
                target: watcher.modelData
                function onTrackTitleChanged() {
                    if (watcher.modelData.dbusName === (root.player ? root.player.dbusName : "") && watcher.modelData.isPlaying)
                        IslandState.push("media", ({}), 4500);
                }
                function onPlaybackStateChanged() {
                    if (watcher.modelData.dbusName === (root.player ? root.player.dbusName : ""))
                        IslandState.push("media", ({}), 3000);
                }
            }
        }
    }
}
