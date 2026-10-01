.pragma library

// nmcli -t escapes ':' as '\:' and '\' as '\\'. Split on unescaped colons.
function splitT(line) {
    var out = [], cur = "";
    for (var i = 0; i < line.length; i++) {
        var c = line[i];
        if (c === "\\" && i + 1 < line.length) { cur += line[i + 1]; i++; }
        else if (c === ":") { out.push(cur); cur = ""; }
        else cur += c;
    }
    out.push(cur);
    return out;
}

// nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device status
function parseDevices(text) {
    var devs = [];
    text.split("\n").forEach(function (l) {
        if (!l) return;
        var p = splitT(l);
        if (p.length < 4) return;
        devs.push({ device: p[0], type: p[1], state: p[2], connection: p[3] });
    });
    return devs;
}

// nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list
function parseWifi(text) {
    var seen = {}, nets = [];
    text.split("\n").forEach(function (l) {
        if (!l) return;
        var p = splitT(l);
        if (p.length < 4 || !p[1]) return;              // hidden SSIDs are skipped
        var n = { active: p[0] === "*", ssid: p[1], signal: parseInt(p[2]) || 0, secure: p[3] !== "" && p[3] !== "--" };
        var prev = seen[n.ssid];
        if (prev === undefined) { seen[n.ssid] = nets.length; nets.push(n); }
        else {
            var e = nets[prev];
            if (n.active) e.active = true;
            if (n.signal > e.signal) e.signal = n.signal;
        }
    });
    nets.sort(function (a, b) { return (b.active - a.active) || (b.signal - a.signal); });
    return nets;
}
