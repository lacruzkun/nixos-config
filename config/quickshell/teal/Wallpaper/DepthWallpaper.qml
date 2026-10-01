import QtQuick
import QtQuick.Effects
import qs.Theme

// Real three-layer depth composition, stacked in one surface so ordering is guaranteed:
//
//   1. wallpaper.jpg                (the original, untouched, same file hyprpaper used)
//   2. big clock                    (drawn ABOVE the wallpaper)
//   3. wallpaper-foreground.png     (opaque pixels cut out of the same wallpaper, drawn ABOVE the clock)
//
// Where the foreground PNG is opaque (the character, hair, railing, house, plants, pole)
// it covers the clock; everywhere else the clock shows through. All three layers live in one
// "stage" that is scaled with the same cover-fit maths, so they stay pixel-aligned at any
// monitor size, aspect ratio or scale factor.
Item {
    id: root

    property date now: new Date()
    property url wallpaperSource
    property url foregroundSource: Qt.resolvedUrl("wallpaper-foreground.png")
    property bool shadow: true
    property alias stageItem: stage

    // intrinsic size of both images (the foreground was cut from the 3840x2160 wallpaper)
    readonly property real imgW: 3840
    readonly property real imgH: 2160
    readonly property real fit: Math.max(width / imgW, height / imgH)     // "cover"

    // Clock layout, as fractions of the image so it follows the artwork.
    // Hours sit in the open sky above the character, minutes in the clouds beside her, so the
    // character's head, arm and hair overlap the digits instead of the other way round.
    // The face is always in front of the clock because it is part of the foreground layer.
    readonly property real fontFraction: 0.38                     // font height / image height
    readonly property real hoursX: 0.600
    readonly property real hoursY: 0.333
    readonly property real minutesX: 0.667
    readonly property real minutesY: 0.704

    // Very wide screens crop the top and bottom of the artwork. Shrink the digits and pull
    // them toward the visible band so the stacked clock is never cut off by the screen edge.
    readonly property real stageH: imgH * fit
    readonly property real visibleFrac: stageH > 0 ? Math.min(1, height / stageH) : 1           // 1 on 16:9 and taller
    readonly property real fontPx: Math.max(1, fontFraction * stageH * Math.min(1, visibleFrac / 0.78))
    readonly property real cropFrac: (1 - visibleFrac) / 2
    function clampY(y) {
        const half = stageH > 0 ? 0.6 * fontPx / stageH + 0.01 : 0;
        return Math.max(cropFrac + half, Math.min(1 - cropFrac - half, y));
    }

    clip: true

    Item {
        id: stage
        width: Math.ceil(root.imgW * root.fit)
        height: Math.ceil(root.imgH * root.fit)
        anchors.centerIn: parent

        // ---- layer 1: original wallpaper -------------------------------
        Image {
            id: back
            anchors.fill: parent
            source: root.wallpaperSource
            fillMode: Image.Stretch                 // stage already has the image's aspect ratio
            sourceSize: Qt.size(stage.width, stage.height)   // decode at screen size, not 4K, to save VRAM
            asynchronous: true
            cache: true
            smooth: true
            mipmap: true
        }

        // ---- layer 2: clock --------------------------------------------
        Item {
            id: clockLayer
            anchors.fill: parent
            opacity: back.status === Image.Ready ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 400 } }

            // Rendered once into a texture; only changes when the minute changes.
            layer.enabled: root.shadow
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Colors.bg0
                shadowOpacity: 0.28
                shadowBlur: 0.35
                shadowVerticalOffset: 6
                shadowHorizontalOffset: 0
            }

            Text {
                id: hours
                text: Qt.formatDateTime(root.now, "HH")
                x: root.hoursX * stage.width - width / 2
                y: root.clampY(root.hoursY) * stage.height - height / 2
                color: Qt.alpha(Colors.bg1, 0.94)
                font.family: Typography.sans
                font.weight: Font.Bold
                font.pixelSize: Math.round(root.fontPx)
                renderType: Text.QtRendering
            }
            Text {
                id: minutes
                text: Qt.formatDateTime(root.now, "mm")
                x: root.minutesX * stage.width - width / 2
                y: root.clampY(root.minutesY) * stage.height - height / 2
                color: Qt.alpha(Colors.bg1, 0.94)
                font.family: Typography.sans
                font.weight: Font.Bold
                font.pixelSize: Math.round(root.fontPx)
                renderType: Text.QtRendering
            }
        }

        // ---- layer 3: foreground cut-out (real wallpaper pixels) --------
        Image {
            id: front
            anchors.fill: parent
            source: root.foregroundSource
            fillMode: Image.Stretch
            sourceSize: Qt.size(stage.width, stage.height)
            asynchronous: true
            cache: true
            smooth: true
            mipmap: true
        }
    }
}
