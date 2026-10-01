.pragma library

// Turns the JSON from `hyprctl binds -j` into rows for the shortcuts menu.
// hyprctl reports the *loaded* configuration (variables expanded, every source file
// merged), so the menu can never disagree with what Hyprland will actually do.

var CATEGORIES = ["General", "Applications", "Windows", "Workspaces", "Navigation", "Media", "Screenshots", "System"];

var MOD_BITS = [[64, "SUPER"], [4, "CTRL"], [8, "ALT"], [1, "SHIFT"]];

// Global shortcuts registered by this shell (Shortcuts are bound in keybinds.conf as
// `global, teal:<name>`). Used only as a fallback when a bind has no description.
var GLOBALS = {
    launcher: ["Application launcher", "General"],
    shortcuts: ["Keyboard shortcuts", "General"],
    controlcenter: ["Control center", "General"],
    notifications: ["Notification center", "General"],
    calendar: ["Calendar", "General"],
    clipboard: ["Clipboard history", "General"],
    windows: ["Window overview", "Windows"],
    screenshots: ["Screenshot menu", "Screenshots"],
    power: ["Power menu", "System"]
};

function modNames(mask) {
    var out = [];
    for (var i = 0; i < MOD_BITS.length; i++)
        if (mask & MOD_BITS[i][0]) out.push(MOD_BITS[i][1]);
    return out;
}

var KEY_NAMES = {
    "return": "ENTER", "enter": "ENTER", "escape": "ESC", "space": "SPACE", "tab": "TAB",
    "slash": "/", "backslash": "\\", "comma": ",", "period": ".", "minus": "-", "equal": "=",
    "semicolon": ";", "apostrophe": "'", "grave": "`", "bracketleft": "[", "bracketright": "]",
    "left": "←", "right": "→", "up": "↑", "down": "↓", "print": "PRINT",
    "mouse_down": "SCROLL ↓", "mouse_up": "SCROLL ↑", "mouse:272": "LMB", "mouse:273": "RMB",
    "mouse:274": "MMB", "xf86audiomicmute": "MIC MUTE", "xf86audioraisevolume": "VOL +",
    "xf86audiolowervolume": "VOL −", "xf86audiomute": "MUTE", "xf86audioplay": "PLAY",
    "xf86audionext": "NEXT", "xf86audioprev": "PREV", "xf86monbrightnessup": "BRIGHT +",
    "xf86monbrightnessdown": "BRIGHT −"
};

function keyLabel(b) {
    var k = b.key || "";
    if (!k && b.keycode) return "KEY " + b.keycode;
    var n = KEY_NAMES[k.toLowerCase()];
    return n !== undefined ? n : k.toUpperCase();
}

function shortArg(s, n) {
    s = (s || "").replace(/\s+/g, " ").trim();
    return s.length > n ? s.slice(0, n - 1) + "…" : s;
}

function categorize(b) {
    var d = b.dispatcher, a = b.arg || "";
    if (d === "global") {
        var g = GLOBALS[a.split(":")[1]];
        return g ? g[1] : "General";
    }
    if (d === "workspace" || d === "movetoworkspace" || d === "movetoworkspacesilent"
        || d === "togglespecialworkspace" || d === "focusworkspaceoncurrentmonitor"
        || d === "split-workspace" || d === "split-movetoworkspace")
        return "Workspaces";
    if (d === "movefocus" || d === "focuswindow" || d === "cyclenext" || d === "focusmonitor")
        return "Navigation";
    if (d === "killactive" || d === "forcekillactive" || d === "fullscreen" || d === "fullscreenstate"
        || d === "togglefloating" || d === "pseudo" || d === "layoutmsg" || d === "movewindow"
        || d === "resizewindow" || d === "swapwindow" || d === "resizeactive" || d === "moveactive"
        || d === "pin" || d === "togglegroup" || d === "centerwindow")
        return "Windows";
    if (d === "exit" || d === "dpms") return "System";
    if (d === "exec" || d === "execr") {
        if (/\b(grim|slurp|swappy|hyprshot|grimblast)\b/.test(a)) return "Screenshots";
        if (/\b(wpctl|playerctl|brightnessctl|pactl|amixer)\b/.test(a)) return "Media";
        if (/\b(wlogout|systemctl|loginctl|hyprlock|swaylock)\b/.test(a)) return "System";
        return "Applications";
    }
    return "General";
}

function describe(b) {
    if (b.has_description && b.description) return b.description;
    var d = b.dispatcher, a = b.arg || "";
    switch (d) {
    case "killactive": return "Close window";
    case "fullscreen": return a === "1" ? "Maximize window" : (a === "2" ? "Fullscreen (client state)" : "Fullscreen");
    case "togglefloating": return "Toggle floating";
    case "pseudo": return "Toggle pseudotile";
    case "layoutmsg": return a === "togglesplit" ? "Toggle split direction" : "Layout: " + a;
    case "movefocus": return "Focus " + ({ l: "left", r: "right", u: "up", d: "down" }[a] || a);
    case "workspace":
        if (a === "e+1") return "Next workspace";
        if (a === "e-1") return "Previous workspace";
        return "Go to workspace " + a;
    case "movetoworkspace": return "Move window to " + (a.indexOf("special:") === 0 ? "scratchpad" : "workspace " + a);
    case "togglespecialworkspace": return "Toggle scratchpad" + (a ? " (" + a + ")" : "");
    case "movewindow": return "Drag to move window";
    case "resizewindow": return "Drag to resize window";
    case "exit": return "Exit Hyprland";
    case "global":
        var g = GLOBALS[a.split(":")[1]];
        return g ? g[0] : a;
    case "exec": case "execr": return "Run: " + shortArg(a, 44);
    }
    return d + (a ? " " + shortArg(a, 40) : "");
}

// Only plain numbered workspaces and h/j/k/l-style focus moves are folded together;
// "e+1", "special:magic" and friends keep their own row.
function groupable(b) {
    var a = b.arg || "";
    if (b.dispatcher === "workspace" || b.dispatcher === "movetoworkspace") return /^\d+$/.test(a);
    if (b.dispatcher === "movefocus") return /^[lrud]$/.test(a);
    return false;
}

function sameGroup(x, y) {
    return x.modmask === y.modmask && x.dispatcher === y.dispatcher && x.locked === y.locked && groupable(y);
}

var GROUPED_TEXT = {
    workspace: "Go to workspace (1–10)",
    movetoworkspace: "Move window to workspace (1–10)",
    movefocus: "Move focus (left / down / up / right)"
};

// binds: array from `hyprctl binds -j`. Returns rows:
// { keys: ["SUPER","R"], description, category, dispatcher, arg, locked, conflict, search }
function build(binds) {
    var list = (binds || []).filter(function (b) { return !b.catch_all; });

    // collisions: two live binds on the same chord both fire in Hyprland
    var seen = {};
    list.forEach(function (b) {
        var id = [b.modmask & ~(2 | 16), b.key, b.keycode, b.release, b.longPress, b.submap].join("|");
        b._chord = id;
        seen[id] = (seen[id] || 0) + 1;
    });

    var rows = [], used = {};
    list.forEach(function (b, i) {
        if (used[i]) return;
        var mods = modNames(b.modmask);
        var cat = categorize(b);
        var row = {
            keys: mods.concat([keyLabel(b)]),
            description: describe(b),
            category: cat,
            dispatcher: b.dispatcher,
            arg: b.arg || "",
            locked: !!b.locked,
            conflict: seen[b._chord] > 1,
            mouse: !!b.mouse
        };

        // fold 1..0 and h/j/k/l style families into a single row
        if (GROUPED_TEXT[b.dispatcher] && groupable(b)) {
            var family = [i];
            for (var j = i + 1; j < list.length; j++)
                if (!used[j] && sameGroup(b, list[j])) family.push(j);
            if (family.length >= 3) {
                if (b.dispatcher === "movefocus") {
                    var order = { l: 0, d: 1, u: 2, r: 3 };
                    family.sort(function (p, q) { return (order[list[p].arg] || 0) - (order[list[q].arg] || 0); });
                }
                var labels = family.map(function (idx) { return keyLabel(list[idx]); });
                family.forEach(function (idx) { used[idx] = true; });
                var conflict = family.some(function (idx) { return seen[list[idx]._chord] > 1; });
                row.keys = mods.concat([b.dispatcher === "movefocus" ? labels.join(" ") : labels[0] + " … " + labels[labels.length - 1]]);
                row.description = GROUPED_TEXT[b.dispatcher];
                row.conflict = conflict;
            }
        }
        used[i] = true;
        row.search = (row.keys.join(" ") + " " + row.description + " " + row.category).toLowerCase();
        rows.push(row);
    });

    rows.sort(function (x, y) { return CATEGORIES.indexOf(x.category) - CATEGORIES.indexOf(y.category); });
    return rows;
}
