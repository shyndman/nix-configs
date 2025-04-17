# Zsh module for Home Manager
# This module configures Zsh with Oh My Zsh and other enhancements

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.zsh;
in {
  options.modules.zsh = {
    enable = mkEnableOption "Zsh configuration";
    
    defaultUser = mkOption {
      type = types.str;
      default = "user";
      description = "Default username for Zsh prompt";
    };
    
    ohMyZsh = {
      enable = mkEnableOption "Oh My Zsh";
      
      theme = mkOption {
        type = types.str;
        default = "robbyrussell";
        description = "Oh My Zsh theme";
      };
      
      plugins = mkOption {
        type = types.listOf types.str;
        default = [ "git" ];
        description = "Oh My Zsh plugins";
      };
    };
  };
  
  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      autocd = true;

      autosuggestion.enable = true;
    
      enableCompletion = true;
      
      oh-my-zsh = mkIf cfg.ohMyZsh.enable {
        enable = true;
        theme = cfg.ohMyZsh.theme;
        plugins = cfg.ohMyZsh.plugins;
      };
      
      initExtra = ''
        # Custom Zsh configuration
        setopt AUTO_PUSHD
        setopt PUSHD_IGNORE_DUPS
        setopt PUSHD_SILENT
        
        # History settings
        HISTSIZE=10000
        SAVEHIST=10000
        setopt HIST_IGNORE_ALL_DUPS
        setopt HIST_FIND_NO_DUPS
        setopt HIST_IGNORE_SPACE
        
        # Custom aliases
        alias ls='ls --color=auto'
        alias ll='ls -la'
        alias la='ls -A'
        alias l='ls -CF'
        
        # Git aliases
        alias gs='git status'
        alias ga='git add'
        alias gc='git commit'
        alias gp='git push'
        alias gl='git pull'
        
        # Navigation aliases
        alias ..='cd ..'
        alias ...='cd ../..'
        alias ....='cd ../../..'
        
        # Utility aliases
        alias grep='grep --color=auto'
        alias df='df -h'
        alias du='du -h'
        
        # Safety aliases
        alias rm='rm -i'
        alias cp='cp -i'
        alias mv='mv -i'
        
        # Welcome message
        echo "Welcome, ${cfg.defaultUser}! Your Zsh is ready."
      '';
      
      shellAliases = {
        # Add your shell aliases here
      };
    };
  };
}

