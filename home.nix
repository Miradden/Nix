{ config, inputs, pkgs, ... }:

{

  imports = [
    inputs.nvchad4nix.homeManagerModule
  ];

  # stylix.targets.kde.enable = true;

  programs = {
    zsh = {
      enable = true;

      shellAliases = { 
        update = "sudo nixos-rebuild switch --cores 12";
      };

      oh-my-zsh = {
        enable = true;
        plugins = with pkgs; [ "git" "thefuck" "fzf" ];
      }; # end omz
    }; # end zsh

    oh-my-posh = {
      enable = true;
      enableZshIntegration = true;
      useTheme = "atomic";
    }; # end omp

    ################## HELIX CONFIG ##################
    helix = {
      enable = true;
      #defaultEditor = true;
      settings = {
        editor = {
          indent-guides = {
            render = true; 
          };
          cursor-shape = {
            normal = "block";
            insert = "bar";
            select = "bar";
          };
          auto-save = true; 
        }; # end editor
      }; # end settings
    }; # end helix
    ################## KITTY CONFIG #################
    kitty = {
      enable = true;
    }; # end kitty
    ################## ZOXIDE CONFIG ################
    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [ "--cmd cd" ];
    }; # end zoxide

    nvchad = {
      enable = true;
      extraPackages = with pkgs; [
        nodePackages.bash-language-server
        emmet-language-server
        nixd
        (python3.withPackages(ps: with ps; [
          python-lsp-server
          flake8
        ]))
      ];
      hm-activation = true;
      backup = true;
    }; # end nvchad
    
    home-manager = { # let home-maanger install and manage itself
      enable = true;
    };
  }; # end programs
    
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "mirad";
  home.homeDirectory = "/home/mirad";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    zsh-fzf-tab
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/mirad/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };
}
