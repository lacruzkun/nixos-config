//@ pragma UseQApplication
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=6000

import QtQuick
import Quickshell
import Quickshell.Io        // <- add this line
import Quickshell.Hyprland
import qs.Components
import qs.Services
import qs.Bar
import qs.Wallpaper
import qs.Launcher
import qs.ControlCenter
import qs.Media
import qs.Calendar
import qs.Notifications
import qs.Clipboard
import qs.Screenshots
import qs.Power
import qs.Windows
import qs.Shortcuts
import qs.Lock

// Entry point: `quickshell -c teal`. Everything else lives in the folders next to this file.
ShellRoot {
    id: root

    // ---------------- per-monitor surfaces ----------------
    Variants {
        model: Quickshell.screens
        WallpaperWindow {}
    }
    Variants {
        model: Quickshell.screens
        TopBar {}
    }

    // ---------------- popups (created on first use) ----------------
    PopupSlot { name: "launcher";      sourceComponent: Component { Launcher {} } }
    PopupSlot { name: "controlCenter"; sourceComponent: Component { ControlCenter {} } }
    PopupSlot { name: "media";         sourceComponent: Component { MediaPopup {} } }
    PopupSlot { name: "calendar";      sourceComponent: Component { CalendarPopup {} } }
    PopupSlot { name: "notifications"; sourceComponent: Component { NotificationCenter {} } }
    PopupSlot { name: "clipboard";     sourceComponent: Component { ClipboardPopup {} } }
    PopupSlot { name: "screenshots";   sourceComponent: Component { ScreenshotPopup {} } }
    PopupSlot { name: "power";         sourceComponent: Component { PowerMenu {} } }
    PopupSlot { name: "windows";       sourceComponent: Component { WindowOverview {} } }
    PopupSlot { name: "shortcuts";     sourceComponent: Component { ShortcutsMenu {} } }

    LockScreen { id: lock }
    Connections {
        target: Actions
        function onLockRequested() { UiState.close(); lock.lock(); }
    }

    // ---------------- Hyprland global shortcuts ----------------
    // Bound in config/hypr/modules/keybinds.conf as `global, teal:<name>`.
    GlobalShortcut { appid: "teal"; name: "launcher";      onPressed: UiState.toggle("launcher") }
    GlobalShortcut { appid: "teal"; name: "shortcuts";     onPressed: UiState.toggle("shortcuts") }
    GlobalShortcut { appid: "teal"; name: "controlcenter"; onPressed: UiState.toggle("controlCenter") }
    GlobalShortcut { appid: "teal"; name: "notifications"; onPressed: UiState.toggle("notifications") }
    GlobalShortcut { appid: "teal"; name: "clipboard";     onPressed: UiState.toggle("clipboard") }
    GlobalShortcut { appid: "teal"; name: "windows";       onPressed: UiState.toggle("windows") }
    GlobalShortcut { appid: "teal"; name: "screenshots";   onPressed: UiState.toggle("screenshots") }
    GlobalShortcut { appid: "teal"; name: "power";         onPressed: UiState.toggle("power") }
    GlobalShortcut { appid: "teal"; name: "calendar";      onPressed: UiState.toggle("calendar") }

    // ---------------- command line: `quickshell -c teal ipc call shell <fn>` ----------------
    IpcHandler {
        target: "shell"
        function toggle(name: string): void { UiState.toggle(name); }
        function open(name: string): void { UiState.show(name); }
        function close(): void { UiState.close(); }
        function run(): void { UiState.toggle("launcher", "run"); }
        // called by mako's on-notify hook (config/mako/config)
        function notify(id: string): void { NotificationData.onNotify(id); }
    }

    // ---------------- island: workspace switches ----------------
    property int lastWorkspace: -1
    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() {
            const ws = Hyprland.focusedWorkspace;
            if (!ws) return;
            if (root.lastWorkspace !== -1 && ws.id !== root.lastWorkspace)
                IslandState.push("workspace", { name: ws.name.indexOf("special:") === 0 ? "scratchpad" : ws.name }, 1100);
            root.lastWorkspace = ws.id;
        }
    }
}
