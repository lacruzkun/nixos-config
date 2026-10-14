# Noctalia desktop setup

This configuration replaces the former Quickshell/QML desktop shell with Noctalia. Noctalia now provides the top bar, app launcher, control center, notifications, clipboard history, session/power menu, wallpaper picker, window switcher, and screenshot-region action.

## First rebuild

From this repository on the NixOS machine, run:

```sh
nix flake lock
sudo nixos-rebuild switch --flake .#nixos
```

The Noctalia input is new, so `flake.lock` must be refreshed before rebuilding. The migration archive was prepared in an environment without the Nix executable, so that refresh/build could not be run here.

## Wallpapers and automatic colors

- The 56 images from the supplied `wallpaper-main` archive are in `config/wallpapers/`.
- Home Manager symlinks bundled images into `~/Pictures/Wallpapers` without overwriting existing files. You can add your own images to that directory.
- Open the wallpaper picker with **Super+Shift+W**, or select the wallpaper icon on the Noctalia bar.
- The theme palette source is set to `wallpaper` (`m3-content`). Noctalia recolors enabled templates for Hyprland, Kitty, GTK 3/4 and Qt when the wallpaper changes.
- If Qt applications still use an old palette, open `qt6ct` and choose the generated `noctalia` color scheme.

## Depth wallpaper setup

The old wallpaper used a manually prepared transparent foreground PNG to cover parts of the oversized clock. The original cutout has been preserved at `config/depth-wallpaper/original-foreground.png`. Noctalia's native `noctalia/wallpaper_depth` plugin instead estimates foreground depth locally and places desktop widgets behind the detected foreground; it is configured and enabled in `config/noctalia/config.toml`.

After the first launch, open the plugin's manager panel:

```sh
noctalia msg panel-toggle noctalia/wallpaper_depth:manager
```

Choose **Install model**. The official plugin creates a private Python environment and downloads its approximately 99 MB depth model. Setup requires network access, `python3`, and `uv`; `uv` is included in the system packages. Wallpaper analysis stays local after installation.

The large hour/minute clock widgets are pre-positioned to resemble the original 1920×1080 composition. Monitor sizes and scaling differ, so use **Super+Alt+W** (or Settings → Desktop → Toggle Editor) to resize and position them for your display. The new depth map is estimated by the plugin; it will not necessarily match the old hand-cut alpha mask pixel-for-pixel.

## Replaced shell keybinds

| Shortcut | Action |
| --- | --- |
| Super+R | Launcher |
| Super+/ | Noctalia settings |
| Super+N | Control center |
| Super+Shift+N | Notifications in control center |
| Super+X | Clipboard history |
| Super+W | Window switcher |
| Super+Shift+W | Wallpaper picker |
| Super+Alt+W | Edit desktop widgets |
| Super+M | Session / power menu |
| Super+Ctrl+Print | Screenshot region |

Existing Hyprland window/workspace bindings and the separate screenshot shortcuts are retained.

## Useful upstream references

- [Noctalia NixOS installation](https://docs.noctalia.dev/noctalia/getting-started/nixos/)
- [Wallpaper-derived themes](https://docs.noctalia.dev/noctalia/theming/)
- [Desktop widgets and editor](https://docs.noctalia.dev/noctalia/desktop/widgets/)
- [Official plugins — Wallpaper Depth](https://docs.noctalia.dev/noctalia/plugins/official-plugins/)
- [Noctalia IPC surfaces](https://docs.noctalia.dev/noctalia/ipc/surfaces/)
