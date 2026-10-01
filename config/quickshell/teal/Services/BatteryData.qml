pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower

// Battery through UPower (native). Desktops without a battery report present = false and
// the UI simply omits every battery element.
Singleton {
    id: root

    readonly property var device: UPower.displayDevice
    readonly property bool present: device !== null && device.ready && device.isPresent
        && device.type === UPowerDeviceType.Battery
    readonly property real level: present ? device.percentage : 0           // 0..1
    readonly property int percent: Math.round(level * 100)
    readonly property bool charging: present && (device.state === UPowerDeviceState.Charging
        || device.state === UPowerDeviceState.PendingCharge)
    readonly property bool full: present && device.state === UPowerDeviceState.FullyCharged
    readonly property bool low: present && !charging && level <= 0.2
    readonly property real seconds: !present ? 0 : (charging ? device.timeToFull : device.timeToEmpty)

    readonly property string icon: charging ? "\uf0e7"
        : level > 0.85 ? "\uf240" : level > 0.6 ? "\uf241" : level > 0.35 ? "\uf242" : level > 0.12 ? "\uf243" : "\uf244"

    readonly property string eta: {
        if (!present || full || seconds <= 0) return "";
        const h = Math.floor(seconds / 3600), m = Math.round((seconds % 3600) / 60);
        return (h > 0 ? h + " h " : "") + m + " min " + (charging ? "to full" : "left");
    }
    readonly property string stateText: !present ? "" : full ? "Fully charged" : charging ? "Charging" : "Discharging"
}
