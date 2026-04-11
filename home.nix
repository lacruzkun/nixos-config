{ config, nix, ...}:

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
  home.file.".config/hypr".source = ./config/hypr;
  home.file.".vim".source = ./config/vim;
  home.file.".config/waybar".source = ./config/waybar;
  home.file.".config/wofi".source = ./config/wofi;
  home.file.".config/kitty".source = ./config/kitty;
}
