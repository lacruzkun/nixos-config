{ config, pkgs, lib, ... }:

{
  home.username = "lacruz";
  home.homeDirectory = "/home/lacruz";
  home.stateVersion = "25.11";
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
  home.file.".config/hypr".source = ./config/hypr;
  home.file.".vim".source = ./config/vim;
  home.file.".config/waybar".source = ./config/waybar;
  home.file.".config/wofi".source = ./config/wofi;
  home.file.".config/kitty".source = ./config/kitty;
  home.file.".config/rofi".source = ./config/rofi;
  home.file.".config/mako".source = ./config/mako;

  # Keep the screenshot destination available after every Home Manager switch.
  # The screenshot commands intentionally do not create directories at runtime.
  home.activation.ensureScreenshotDirectory = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p "$HOME/Pictures/Screenshots"
  '';
}
