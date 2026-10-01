.pragma library

// Small fuzzy matcher used by the launcher, clipboard, windows and shortcut search.
// score() returns 0 for "no match", otherwise a positive number (bigger = better).

function score(query, text) {
    if (!query) return 1;
    if (!text) return 0;
    var q = query.toLowerCase();
    var t = String(text).toLowerCase();

    if (t === q) return 1000;
    if (t.indexOf(q) === 0) return 900 - Math.min(t.length, 100) * 0.1;

    // word-start match: "fire" -> "Mozilla Firefox"
    var wordIdx = t.search(new RegExp("[\\s\\-_.]" + escapeRegex(q)));
    if (wordIdx >= 0) return 700 - wordIdx * 0.5;

    var sub = t.indexOf(q);
    if (sub >= 0) return 500 - sub;

    // subsequence: every query character appears in order
    var ti = 0, gaps = 0, last = -1, bonus = 0;
    for (var qi = 0; qi < q.length; qi++) {
        var found = t.indexOf(q[qi], ti);
        if (found < 0) return 0;
        if (last >= 0 && found !== last + 1) gaps += found - last - 1;
        if (found === 0 || /[\s\-_.]/.test(t[found - 1])) bonus += 8;
        last = found;
        ti = found + 1;
    }
    return Math.max(1, 200 - gaps * 2 + bonus - t.length * 0.2);
}

function escapeRegex(s) {
    return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

// fields: [{ text: "...", weight: 1.0 }, ...]. Best weighted field wins.
function scoreFields(query, fields) {
    var best = 0;
    for (var i = 0; i < fields.length; i++) {
        var f = fields[i];
        if (!f.text) continue;
        var s = score(query, f.text) * f.weight;
        if (s > best) best = s;
    }
    return best;
}

function scoreApp(query, app) {
    return scoreFields(query, [
        { text: app.name, weight: 1.0 },
        { text: app.genericName, weight: 0.6 },
        { text: (app.keywords || []).join(" "), weight: 0.5 },
        { text: (app.categories || []).join(" "), weight: 0.3 },
        { text: app.comment, weight: 0.25 },
        { text: app.id, weight: 0.4 }
    ]);
}

// Generic ranking helper: items are returned sorted by score, non-matches dropped.
function rank(query, items, scorer) {
    if (!query) return items.slice();
    var scored = [];
    for (var i = 0; i < items.length; i++) {
        var s = scorer(query, items[i]);
        if (s > 0) scored.push({ s: s, i: i, item: items[i] });
    }
    scored.sort(function (a, b) { return b.s - a.s || a.i - b.i; });
    return scored.map(function (x) { return x.item; });
}
