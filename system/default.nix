
# System-wide configuration for NixOS
# This file defines system-level settings that apply to all users

{ config, lib, pkgs, ... }:

{
  config = {
    # Default platform is x86_64-linux, will be overridden in specific configs
    nixpkgs.hostPlatform = "x86_64-linux";

    # Common environment settings
    environment = {
      etc = {
        "foo.conf".text = ''
          launch_the_rockets = true
        '';
      };
      systemPackages = with pkgs; [
        # Core utilities
        ripgrep
        fd
        bat
        eza
        fzf
        zoxide
        
        # System tools
         btop
        ncdu
        
        # Make Zsh available system-wide
        zsh
      ];
      
      # System-wide environment variables
      variables = {
        EDITOR = "micro";
        VISUAL = "micro";
        TERM = "xterm-256color";
      };
    };

    # Common system services
    systemd.services = {
      foo = {
        enable = true;
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        wantedBy = [ "system-manager.target" ];
        script = ''
          ${lib.getBin pkgs.hello}/bin/hello
          echo "We launched the rockets!"
        '';
      };
    };
    
    # Common user settings
    users.mutableUsers = false;
    
    # Common security settings
    security = {
      sudo.enable = true;
      sudo.wheelNeedsPassword = true;
    };
    
    # Common network settings
    networking = {
      firewall = {
        enable = true;
        allowPing = true;
      };
    };
    
    # Common time settings
    time.timeZone = "UTC"; # Default, can be overridden in specific configs
    
    # Common locale settings
    i18n.defaultLocale = "en_US.UTF-8";
    
    # Common Nix settings
    nix = {
      settings = {
        auto-optimise-store = true;
        experimental-features = [ "nix-command" "flakes" ];
      };
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
    };
  };
}


