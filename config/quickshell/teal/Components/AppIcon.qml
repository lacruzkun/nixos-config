import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.Theme

// Native application icon from the icon theme, with a neutral glyph when none resolves.
Item {
    id: root

    property string name: ""               // icon name or absolute path
    property int size: 32
    readonly property string resolved: name === "" ? "" : (name.startsWith("/") ? name : Quickshell.iconPath(name, true))

    implicitWidth: size
    implicitHeight: size

    IconImage {
        anchors.fill: parent
        visible: root.resolved !== ""
        source: root.resolved
        asynchronous: true
    }

    NerdIcon {
        anchors.centerIn: parent
        visible: root.resolved === ""
        size: root.size * 0.6
        text: "\uf2d0"
        color: Colors.textMuted
    }
}
