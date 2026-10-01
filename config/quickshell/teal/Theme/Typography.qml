pragma Singleton
import QtQuick
import Quickshell

// Fonts come from configuration.nix (fonts.packages): rubik, nerd-fonts.jetbrains-mono,
// nerd-fonts.iosevka. CJK falls through to Noto Sans CJK via fontconfig.
Singleton {
    readonly property string sans: "Rubik"
    readonly property string mono: "JetBrainsMono Nerd Font"
    readonly property string monoAlt: "Iosevka Nerd Font"
    readonly property string icon: "JetBrainsMono Nerd Font"

    readonly property int tiny: 10
    readonly property int small: 11
    readonly property int body: 13
    readonly property int title: 15
    readonly property int large: 20
    readonly property int huge: 34
}
