{ config, pkgs, lib, packages, nixos-unstable, nixpkgs-unstable, inputs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ]; 

  nixpkgs.config.permittedInsecurePackages = [
                "electron-25.9.0"
              ];              
  ################## HARDWARE CONFIG ##################
  hardware = {
    bluetooth.enable = true;
    opentabletdriver.enable = true;
    pulseaudio.enable = false;
  };

  # fix for laptop not waking from sleep
  powerManagement.powerUpCommands = "sudo rmmod atkbd; sudo modprobe atkbd reset=1";
 
  ################## NIX CONFIG ##################
  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    
    # Automatic Garbage Collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # home-manager = {
  #   backupFileExtension = "backup";
  #   sharedModules = [{
  #     stylix.targets.kde.enable = true;
  #   }];    
  # }; # end home-manager 
  
  ################## BOOT ##################
  time.hardwareClockInLocalTime = true;
  boot = {
    supportedFilesystems = [ "ntfs" "exfat" ];
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      grub = {
        devices = ["nodev"];
        efiSupport = true;
        enable = true;
        useOSProber = true;
      }; # end grub 
    }; # end loader

  #  kernelPackages = pkgs.linuxPackages_6_8;
  
    kernelParams = [ "amd_iommu=on"
                     "amd_pstate=active" ];
                    
    kernelModules = [ "kvm-amd" "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" "xpadneo"];
    
    kernel.sysctl = { "vm.swappiness" = 10;};
  };

 ################## NETWORKING ##################
  networking = {
    hostName = "pearlescent";
    networkmanager.enable = true;
  };
  
  ################## LOCALE ##################
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    }; # end extraLocaleSettings
  }; # end i18n

  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
    elisa
    oxygen
    khelpcenter
    plasma-browser-integration
    print-manager
    krunner
  ];
  
  environment.gnome.excludePackages = with pkgs; [
    gnome.seahorse
  ];

  # Enable sound with pipewire.
  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    users.mirad = {
      isNormalUser = true;
      description = "mirad";
      extraGroups = [ "networkmanager" "wheel" "mirad" ];
    };

    # Sets the default shell of the system to zsh
    defaultUserShell = pkgs.zsh;
  };

  ################## FONTS #####################
  fonts.packages = with pkgs; [
    nerdfonts
    meslo-lgs-nf
    corefonts
    vistafonts
  ];

  ################## THEMING ####################
  stylix = {
    enable = true;
    
    # image = pkgs.fetchurl {
      # url = "https://github.com/dracula/wallpaper/blob/master/first-collection/nixos.png";
      # sha256 = "1yhl17wnq2hrw0b4imqp3sgvn49vhnf4nwgjky859p7panaxay50";
    # };
    image = ./nixos.png;

    autoEnable = true;
    
    polarity = "dark";
    
    base16Scheme = {
      # dracula
      base00 = "282a36"; #background
      base01 = "3a3c4e";
      base02 = "44475a";
      base03 = "6272a4";
      base04 = "62d6e8";
      base05 = "f8f8f2"; #foreground
      base06 = "f1f2f8";
      base07 = "f7f7fb";
      base08 = "ff5555";
      base09 = "ffb86c";
      base0A = "f1fa8c";
      base0B = "50fa7b";
      base0C = "8be9fd";
      base0D = "bd93f9";
      base0E = "ff79c6";
      base0F = "00f769";
    }; # end base16

    fonts = {
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };

      sansSerif = {
        package = pkgs.nerdfonts;
        name = "DejaVu Sans";
      };

      monospace = {
        package = pkgs.nerdfonts;
        name = "JetBrainsMono NF Regular";
      };

      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      }; # end emoji

      sizes.terminal = 14;
    }; # end fonts

    targets = {
      grub.useImage = true;
    }; # end targets

    cursor = {
      package = pkgs.oreo-cursors-plus;
      name = "oreo_purple_cursors";
      size = 32;
    }; # end cursor
  };
  
  ################## SERVICES ##################
  services = {
    asusd.enable = true; # asus daemon

    supergfxd = {
      enable = true;
      settings = {
        mode = "Integrated";
        vfio_enable = true;
        vfio_save = true;
        always_reboot = false;
        no_logind = false;
        logout_timeout_s = 60;
        hotplug_type = "Std";
      };    
    };

    # Power Management (tlp) daemon
    power-profiles-daemon.enable = false;
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 80;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 30;     
      };  
    };

    xserver = {
      enable = true;
      desktopManager.plasma5.enable = true;
      desktopManager.gnome.enable = true;
      displayManager = {
        sddm.enable = true;
        
        autoLogin = {
          enable = true;
          user = "mirad";
        }; # end autologin
      }; # end displayManager

      layout = "us";
      xkbVariant = "";

      # Enable touchpad support (enabled default in most desktopManager).
      libinput.enable = true;
    };

    # Enable CUPS to print documents.
    printing.enable = true;

    udev.extraRules = '' 
        # Microsoft Xbox One S Controller; bluetooth; USB #EXPERIMENTAL
        KERNEL=="hidraw*", KERNELS=="*045e:02ea*", MODE="0660", TAG+="uaccess"
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02ea", MODE="0660", TAG+="uaccess"
      '';
  }; # end services

  ################## VIRTUALISATION ##################
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.ovmf.enable = true;
    };
  };
  
  ################## MISC CONFIG ##################

  environment.sessionVariables = {
    FLAKE = "/etc/nixos";
  };
  
  # Many programs look at /etc/shells to determine
  # if a user is a "normal" user and not a "system" user.
  # Therefore it is recommended to add the user shells to this list.
  environment.shells = with pkgs; [ zsh ];

  programs.zsh = # ZSH CONFIG
  {
    # Always enable the shell system-wide, even if 
    # it's already enabled in your home-manager. 
    # Otherwise it wont source the necessary files.
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    enableBashCompletion = true;

    shellInit = ''
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
    '';
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05";
  
  ################## PACKAGES ##################

  # Allow closed source packages
  nixpkgs.config.allowUnfree = true;

  programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = false; # for source dedicated server
  };

  programs.nix-ld = { # fix for running things like self written python that needs things like libstdc++.so.6
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
    ];
  };
  
  environment.systemPackages = with pkgs; [
    # Virtualization Packages
    qemu
    libvirt
    OVMFFull
    virt-manager
    # Power Management
    corectrl
    # Ricing
   # gtk2 #
   # gtk3 # Trying to fix stylix cursor changing
   # gtk4 #
    albert # kde krunner replacement    
    ## Terminal Rice 
    nh # nixos rebuild rice (among other things)   
    nix-output-monitor
    nodejs_22
    kitty
    kitty-themes
    zsh
    cava
    meslo-lgs-nf
    zsh-autosuggestions
    oh-my-zsh
    zoxide # fancy cd
    fzf # fuzzy finder used with zoxide
    fzf-zsh # wrap fzf to use in oh-my-zsh
    # Development
    gdb
    zulu # openjdk java
    gcc
    lldb # helix debugger
    nil # helix nix support
    clang-tools
    python3
    python311Packages.python-lsp-server
    pipenv
    gnumake
    jupyter
    pandoc
    texliveMedium
    # Other Packages
    libsForQt5.kio-admin
    filelight # disk space analyzer
    vlc
    peaclock
    pika-backup 
    tex-match # latex lookup
    xboxdrv # xbox controller driver
    #linuxKernel.packages.linux_6_8.xpadneo # kernel module for xbox driver
    gamemode
    btop
    globalprotect-openconnect # trying to get nmsu vpn to work
    openconnect  # trying to get nmsu vpn to work
    gp-saml-gui  # trying to get nmsu vpn to work
    libreswan # trying to get nmsu vpn to work
    wine
    libreoffice-qt
    wayland
    hunspellDicts.en_US-large # english dictionary for spellchecking
    qalculate-gtk
    xdotool # type from clipboard
    xclip # type from clipboard
    nerdfonts
    steam
    ksystemlog
    easyeffects
    pciutils
    r2modman
    usbutils
    haruna
    xdg-utils
    dracula-theme
    exfat
    exfatprogs
    thefuck
    obs-studio
    latte-dock
    nixpkgs-fmt
    discord
    prismlauncher
    jamesdsp
    neofetch
    gparted
    ntfs3g
    spectacle
    microsoft-edge
    obsidian
    vscode
    speedtest-cli
    git
  ];

  services.globalprotect = {
  enable = true;
  # if you need a Host Integrity Protection report
  csdWrapper = "${pkgs.openconnect}/libexec/openconnect/hipreport.sh";
  };
}
