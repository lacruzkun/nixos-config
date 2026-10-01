import QtQuick
import qs.Theme

// Nerd Font glyph. Every icon in the shell goes through this so size/colour stay consistent.
Text {
    property int size: Metrics.iconSize

    font.family: Typography.icon
    font.pixelSize: size
    color: Colors.text
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    renderType: Text.NativeRendering

    Behavior on color { ColorAnimation { duration: Animations.fast } }
}
