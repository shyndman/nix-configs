# System-wide configuration for NixOS on Raspberry Pi 5
# This file defines system-level settings that apply to all users

{ config, pkgs, lib, ... }:

{
  # By the divine wisdom of Shellus, the Command Interpreter:
  
  # Make Zsh available system-wide
  environment.shells = [ pkgs.zsh ];

  # Set the default shell for the vantron user
  users.users.vantron = {
    shell = pkgs.zsh;
    # Note: Other user settings like home directory, groups, etc.
    # should be defined in your NixOS configuration
  };

  # Install system-wide packages that complement Zsh
  environment.systemPackages = with pkgs; [
    # Core utilities that enhance the shell experience
    bat       # Better cat
    eza       # Better ls
    fd        # Better find
    ripgrep   # Better grep
    fzf       # Fuzzy finder
    zoxide    # Better cd
    
    # Additional useful tools
    htop      # Process viewer
    ncdu      # Disk usage analyzer
    trash-cli # Safer alternative to rm
  ];

  # System-wide Zsh configuration (minimal, as most customization happens in Home Manager)
  programs.zsh = {
    enable = true;
    
    # Basic system-wide settings
    enableCompletion = true;
    
    # System-wide shell aliases (minimal, as most are in Home Manager)
    shellAliases = {
      # Safety first
      rm = "trash-put";
    };
  };
}
