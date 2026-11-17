{ config, pkgs, lib, ... }:

let
    # https://codeberg.org/JuxGD/septabee-nix/archive/<thingy>.tar.gz, where <thingy> can be a commit hash or a branch name
    # 
    # if <thingy> is a branch name, this will allow one to use the latest package and module in the specified branch. this should autoupdate
    # remember branches are named after the Septabee version they package. `main` being the exception, it always has the latest one (unless i forget to update lol)
    #
    # if <thingy> is a commit hash, this will pin it so the package and module will be the same as long as the commit hash isn't changed
    #
    # 
    # in this example, <thingy> is "main", a branch name.
    septabee = import (builtins.fetchTarball "https://codeberg.org/JuxGD/septabee-nix/archive/main.tar.gz"); # this also works with github.com it's the exact same
in

{
  imports = [ # Include the results of the hardware scan.  # Absolute path on purpose: this file is gitignored, and flakes only
      # see git-tracked files inside the repo, so a relative ./ path here
      # would fail with "path does not exist" even though it's on disk.
      /etc/nixos/hardware-configuration.nix

      septabee.module
        # if using a specified commit, note that some old commits don't provide the module. the module is necessary to run at full capacity
        # these old commits also have no support for the `offline` option
    ];
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10; # keep only the last 10 generations bootable, so /boot doesn't fill up
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;

  time.timeZone = "Africa/Lagos";

  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
  };

  services.xserver.desktopManager.runXdgAutostartIfNone = true;

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
  programs.dconf.enable = true;

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
    wireplumber.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true; # lets JACK-API apps (Ardour) talk to PipeWire directly

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
      ];

      config.common.default = ["hyprland" "gtk"];
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true; # turn the adapter on at boot instead of leaving it off
  services.blueman.enable = true; # provides blueman-manager, used by the waybar bluetooth module

  # SSH server - key-based auth only, no root login, no passwords over the network
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lacruz = {
    isNormalUser = true;
    description = "lacruz";
    extraGroups = [ "networkmanager" "wheel" "adbusers" "kvm" "audio"];
    openssh.authorizedKeys.keys = [
      # paste your public key(s) here, one string per line - see chat for how to generate one
    ];
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

  programs.septabee = {
      enable = true;
      waylandSupport = true;
      offline = true;
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


  # Make headers from environment.systemPackages visible to GCC/Clang.
  # NixOS does not link /include into the system profile by default.
  environment.pathsToLink = [ "/include" ];

  environment.variables = {
      ANDROID_HOME = "$HOME/Android/Sdk";
      ANDROID_SDK_ROOT = "$HOME/Android/Sdk";
      JAVA_HOME = "${pkgs.jdk17}";
      RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}"; # lets rust-analyzer jump into std without `rustup component add rust-src`
  };
  environment.sessionVariables = {
    GNOME_KEYRING_CONTROL = "$XDG_RUNTIME_DIR/keyring";
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
    INPUT_METHOD = "fcitx";      # helps some Wayland-native / GTK4 apps
    GLFW_IM_MODULE = "ibus";     # some GLFW apps (e.g. some games) expect this even with fcitx

    # System-wide C/C++ and Vulkan development paths. These make the headers,
    # libraries and CMake/pkg-config metadata from systemPackages discoverable
    # without entering a nix-shell or nix develop environment.
    CPATH = "/run/current-system/sw/include";
    LIBRARY_PATH = "/run/current-system/sw/lib";
    PKG_CONFIG_PATH = "/run/current-system/sw/lib/pkgconfig:/run/current-system/sw/share/pkgconfig";
    CMAKE_PREFIX_PATH = "/run/current-system/sw";
    VULKAN_SDK = "/run/current-system/sw";
    VK_LAYER_PATH = "${pkgs.vulkan-validation-layers}/share/vulkan/explicit_layer.d";
    LD_LIBRARY_PATH = lib.makeLibraryPath [
      pkgs.vulkan-loader
      pkgs.glfw
      pkgs.sdl3
      pkgs.vulkan-volk
      pkgs.shaderc
      pkgs.glslang
      pkgs.spirv-tools
      pkgs.spirv-cross
    ];

    XDG_DATA_DIRS = let
                        schema = pkgs.gsettings-desktop-schemas;
                    in
                    [
                        "${schema}/share/gsettings-schemas/${schema.name}"
                    ];
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    alsa-lib
    freetype
    libglvnd
    stdenv.cc.cc.lib

    libice
    libsm
    libx11
    libxext
  ];
  services.gnome.gnome-keyring.enable = true;

  services.upower.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;   # <-- this is almost certainly your missing piece
  };
  programs.gamemode.enable = true;

  # Link Proton-GE into the compatibility tools directory for Heroic.
  # This uses the correct 'steamcompattool' output, which is a directory.
  systemd.user.tmpfiles = {
    enable = true;
    rules = let
      # Heroic looks for compatibility tools in this directory by default.
      compatdir = "%h/.steam/root/compatibilitytools.d";
      link = "${compatdir}/Proton-GE";
      target = pkgs.proton-ge-bin.steamcompattool.outPath;
    in [
      "d ${compatdir} - - - - -"
      "L+ ${link} - - - - ${target}"
    ];
  };

  services.flatpak.enable = true;

    systemd.services.flatpak-repo = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig.Type = "oneshot";

      script = ''
        ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
      '';
    };




  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    kitty
    wget
    mpv
    strawberry
    qimgv
    hypridle
    thunar
    brightnessctl
    wlogout
    cliphist
    fastfetch
    playerctl
    pavucontrol
    gnome-keyring
    libsecret
    obsidian
    calibre
    grim
    slurp
    swappy
    wl-clipboard
    hyprshot
    libnotify
    remmina
    samba
    cifs-utils

    blender
    godot
    unzip
    unrar
    p7zip
    cabextract
    heroic
    fish
    zsh
    ffmpeg-full
    obs-studio
    wine-staging
    winetricks
    vinegar   # bootstrapper for running Roblox Studio on Linux (via Wine)
    ruff
    leveldb
    sslh
    google-chrome
    anki

    # web dev
    nodejs_24
    ghidra-bin
    openjdk21
    procps


    # general programming stuff
    (python3.withPackages (ps: with ps; [
      numpy
      onnxruntime
      pillow
    ]))
    python313Packages.python-lsp-server
    python313Packages.pylsp-mypy
    python313Packages.python-lsp-ruff
    python313Packages.python-lsp-black
    uv # Required by Noctalia's local wallpaper-depth model setup
    prettier
    basedpyright
    lua
    luau-lsp
    tesseract

    # c development
    gcc
    gnumake
    cmake
    ninja
    gdb
    gf
    pkg-config
    clang
    clang-tools
    linuxHeaders
    renderdoc
    openal
    wtype

    # Vulkan / graphics programming
    vulkan-headers                 # Vulkan C and C++ headers, including Vulkan-Hpp
    vulkan-loader                  # Vulkan runtime loader (libvulkan.so)
    vulkan-tools                   # vulkaninfo, vkcube
    vulkan-tools-lunarg
    vulkan-validation-layers       # VK_LAYER_KHRONOS_validation
    vulkan-utility-libraries       # Khronos Vulkan utility libraries
    vulkan-volk                    # Vulkan function-pointer/meta loader (not GNU Radio's `volk`)
    vulkan-memory-allocator        # AMD Vulkan Memory Allocator (VMA)
    glfw                           # GLFW window/input library
    sdl3                           # SDL3 window/input library
    glm                            # Header-only maths library
    shaderc                        # GLSL/HLSL to SPIR-V compiler library and tools
    glslang                        # Khronos GLSL reference compiler
    spirv-headers                  # SPIR-V registry headers
    spirv-tools                    # SPIR-V assembler, disassembler, validator and optimizer
    spirv-cross                    # SPIR-V reflection and cross-compilation

    # rust development
    rustup
    btop
    (solana-cli.overrideAttrs (oldAttrs: {
        env = (oldAttrs.env or {}) // {
          RUSTFLAGS = (oldAttrs.env.RUSTFLAGS or "") + " --cap-lints allow";
        };
    }))


    #research
    qbittorrent
    glib
    gsettings-desktop-schemas
    dconf
    adw-gtk3
    nwg-look
    qt6Packages.qt6ct
    qt6Packages.qtwayland
    opencode

    reaper
    yabridge
    yabridgectl
    sfizz-ui
    (callPackage ./pkgs/vital.nix {})
    protobuf
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Compressed RAM swap - cheap insurance against OOM kills during heavy builds/compiles
  zramSwap.enable = true;

  # Keep the nix store from growing unbounded
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.optimise.automatic = true;

  # Periodically trim SSDs; a no-op on drives that don't support TRIM
  services.fstrim.enable = true;

  system.stateVersion = "25.11"; # Did you read the comment?

}
