# Hyprland: bounce + slide, no fade

## File changed
- `config/hypr/modules/animations.conf`

This replaces the prior fade-heavy transitions with springy slide animations for windows, layer-shell surfaces, and workspaces. `animation = fade, 0` disables Hyprland's fade animation branch. The existing square-corner settings are not changed by this patch.

## Apply
From the root of your `~/nixos-config` repository, back up the existing file and copy this patch's `config/hypr/modules/animations.conf` into the matching path. Then run:

```bash
sudo nixos-rebuild switch --flake .#nixos
hyprctl reload
```

The configuration uses the traditional `animation = ...` syntax from Hyprland's 0.54-era config format, matching the existing project file. I couldn't run Hyprland's own config parser in this environment, so if your installed Hyprland reports an unsupported style, share the exact error and version from `hyprctl version`.
