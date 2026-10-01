.pragma library

// Monday-first month grid (locale is en_GB in configuration.nix).
// Returns 42 cells: { day, month, year, inMonth }.
function monthGrid(year, month) {
    var first = new Date(year, month, 1);
    var offset = (first.getDay() + 6) % 7;           // Monday = 0
    var cells = [];
    for (var i = 0; i < 42; i++) {
        var d = new Date(year, month, 1 - offset + i);
        cells.push({
            day: d.getDate(),
            month: d.getMonth(),
            year: d.getFullYear(),
            inMonth: d.getMonth() === month
        });
    }
    return cells;
}

var MONTHS = ["January", "February", "March", "April", "May", "June", "July",
              "August", "September", "October", "November", "December"];
var WEEKDAYS = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"];
