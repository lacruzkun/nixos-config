# Migration change log

## Modified

- `flake.nix`
- `home.nix`
- `configuration.nix`
- `config/hypr/modules/autostart.conf`
- `config/hypr/modules/keybinds.conf`
- `config/hypr/hyprland.conf`
- `config/kitty/kitty.conf`

## Added

- `config/noctalia/config.toml` — Noctalia shell, wallpaper-based theme, app templates, wallpaper picker and depth-clock widget layout.
- `config/noctalia/README.md` — setup, plugin installation, keybinds and operating notes.
- `config/depth-wallpaper/original-foreground.png` — preserved legacy foreground cutout from the QML wallpaper.
- `config/wallpapers/` — 56 wallpaper images copied from the supplied `wallpaper-main` archive:
  - `0001.jpg`
  - `0002.jpg`
  - `0003.jpg`
  - `0004.jpg`
  - `0005.jpg`
  - `0006.jpg`
  - `0007.jpg`
  - `0008.jpg`
  - `0009.jpg`
  - `0010.png`
  - `0011.jpg`
  - `0012.jpg`
  - `0013.jpg`
  - `0014.jpg`
  - `0015.jpg`
  - `0016.jpg`
  - `0017.jpg`
  - `0018.jpg`
  - `0019.jpg`
  - `0020.jpg`
  - `0021.jpg`
  - `0022.png`
  - `0023.jpg`
  - `0024.jpg`
  - `0025.jpg`
  - `0026.jpg`
  - `0027.jpg`
  - `0028.jpg`
  - `0029.jpg`
  - `0030.jpg`
  - `0031.jpg`
  - `0032.jpg`
  - `0033.jpg`
  - `0034.jpg`
  - `0035.jpg`
  - `0036.jpg`
  - `0037.jpg`
  - `0038.jpg`
  - `0039.jpg`
  - `0040.jpg`
  - `0041.jpg`
  - `0042.png`
  - `0043.png`
  - `0044.jpg`
  - `0045.jpg`
  - `0046.png`
  - `0047.jpg`
  - `0048.jpg`
  - `0049.jpg`
  - `0050.jpg`
  - `0051.jpg`
  - `0052.jpg`
  - `0053.jpg`
  - `0054.png`
  - `0055.jpg`
  - `0056.png`

## Removed

- `config/quickshell/teal/` — the old Quickshell/QML shell, panels, services, theme, and wallpaper renderer (all files removed; no `.qml` files remain).
- `config/mako/config` — Mako styling and its Quickshell notification hook; Noctalia now manages notifications.
- `config/hypr/hyprpaper.conf` and `config/hypr/wallpaper.jpg` — old fixed wallpaper path; wallpapers are now managed by Noctalia.

## Important validation note

- `flake.nix` now includes the Noctalia input, but `flake.lock` was not regenerated because the preparation environment has no `nix` executable. Run `nix flake lock` before rebuilding.
- The Noctalia TOML was syntax-checked with Python. A Nix evaluation/build could not be run in this environment.
