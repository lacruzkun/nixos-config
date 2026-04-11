# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Africa/Lagos";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.inputMethod.type = "fcitx5";

  # i18n.inputMethod.fcitx5.engines = with pkgs.fcitx-engines; [ moz ];

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_NG";
    LC_IDENTIFICATION = "en_NG";
    LC_MEASUREMENT = "en_NG";
    LC_MONETARY = "en_NG";
    LC_NAME = "en_NG";
    LC_NUMERIC = "en_NG";
    LC_PAPER = "en_NG";
    LC_TELEPHONE = "en_NG";
    LC_TIME = "en_NG";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;
  
  services.getty.autologinUser = "lacruz";

  programs.hyprland.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.gvfs.enable = true;
  services.udev.packages = with pkgs; [
    libmtp
  ];

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lacruz = {
    isNormalUser = true;
    description = "lacruz";
    extraGroups = [ "networkmanager" "wheel" "adbusers" "kvm"];
    packages = with pkgs; [
       tree
    #  thunderbird
    ];
  };


  # Install firefox.
  programs.firefox.enable = true;
  programs.git = {
	enable = true;
	config = {
		user.name = "lacruzkun";
		user.email = "crabraham0@gmail.com";
		init.defaultBranch = "main";
	};
  };

  fonts.packages = with pkgs; [
    nerd-fonts.tinos
    nerd-fonts.iosevka
    nerd-fonts.profont
    nerd-fonts.jetbrains-mono
    rubik
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    ipafont
    kochi-substitute
    texlivePackages.lobster2
    excalifont
    dancing-script
  ];

  fonts.fontconfig.defaultFonts = {
      monospace = [
        "Iosevka Nerd Font Mono"
        "IPAGothic"
      ];
      sansSerif = [
        "Noto Sans CJK JP"
        "IPAPGothic"
      ];
      serif = [
        "Noto Serif CJK JP"
        "IPAPMincho"
      ];
  };
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.android_sdk.accept_license = true;


  environment.variables = {
      ANDROID_HOME = "$HOME/Android/Sdk";
      ANDROID_SDK_ROOT = "$HOME/Android/Sdk";
      JAVA_HOME = "$(pkgs.jdk17)";
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    kitty
    wget
    mpv
    strawberry
    qimgv
    hyprpaper
    wofi
    rofi
    thunar
    brightnessctl
    wlogout
    fastfetch
    playerctl
    waybar
    pavucontrol

    blender
    unzip
    p7zip
    heroic
    fish

    # storage mounting
    libmtp
    mtpfs
    jmtpfs
    python3

    # c development
    gcc
    gnumake
    cmake
    gdb
    pkg-config
    clang
    clang-tools

    # rust development
    rustup
    # rustc
    # cargo
    # rust-analyzer
    # rustfmt

    android-studio
    jdk17
    vscodium
    android-tools
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  system.stateVersion = "25.11"; # Did you read the comment?

}
