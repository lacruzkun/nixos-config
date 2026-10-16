{ config, pkgs, lib, inputs, ... }:

{
  home.username = "lacruz";
  home.homeDirectory = "/home/lacruz";
  home.stateVersion = "25.11";

  imports = [ inputs.noctalia.homeModules.default ];

  home.packages = with pkgs; [
      adw-gtk3
      glib
      gsettings-desktop-schemas
      dconf
      nwg-look
  ];

  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo i use nixos btw";
    };
    profileExtra = ''
      if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
        exec hyprland
      fi
    '';
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.noctalia = {
    enable = true;
    settings = ./config/noctalia/config.toml;
  };

  # Recursive links leave the directories writable for Noctalia's generated
  # wallpaper-specific theme files while keeping this repo declarative.
  home.file.".config/hypr" = {
    source = ./config/hypr;
    recursive = true;
  };
  home.file.".config/kitty" = {
    source = ./config/kitty;
    recursive = true;
  };
  home.file.".vim".source = ./config/vim;

  # Keep screenshot and wallpaper directories present. Wallpaper images from
  # this repo are symlinked only when a destination doesn't already exist, so
  # users can add their own images without Home Manager overwriting them.
  home.activation.ensureScreenshotDirectory = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p "$HOME/Pictures/Screenshots"
  '';

  home.activation.installBundledWallpapers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    source_dir="${./config/wallpapers}"
    target_dir="$HOME/Pictures/Wallpapers"
    $DRY_RUN_CMD mkdir -p "$target_dir"
    for source in "$source_dir"/*; do
      [ -f "$source" ] || continue
      target="$target_dir/$(basename "$source")"
      if [ ! -e "$target" ] && [ ! -L "$target" ]; then
        $DRY_RUN_CMD ln -s "$source" "$target"
      fi
    done
  '';
}
