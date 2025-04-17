# Zsh editing module for Home Manager
# This module configures Zsh key bindings for better word movement

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.zsh-edit;
in {
  options.modules.zsh-edit = {
    enable = mkEnableOption "Zsh editing enhancements";
    
    wordChars = mkOption {
      type = types.str;
      default = "*?_-.[]~=/&;!#$%^(){}<>";
      description = "Characters considered part of a word for Ctrl+Left/Right";
    };
    
    subwordChars = mkOption {
      type = types.str;
      default = "_";
      description = "Characters considered part of a subword for Alt+Left/Right";
    };
  };
  
  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      
      initExtra = ''
        # Word movement configuration
        export WORDCHARS="${cfg.wordChars}"
        
        # Key bindings for word movement
        bindkey '^[[1;5D' backward-word    # Ctrl+Left
        bindkey '^[[1;5C' forward-word     # Ctrl+Right
        
        # Define subword movement functions
        backward-subword() {
          local WORDCHARS="${cfg.subwordChars}"
          zle backward-word
        }
        zle -N backward-subword
        
        forward-subword() {
          local WORDCHARS="${cfg.subwordChars}"
          zle forward-word
        }
        zle -N forward-subword
        
        # Key bindings for subword movement
        bindkey '^[[1;3D' backward-subword  # Alt+Left
        bindkey '^[[1;3C' forward-subword   # Alt+Right
        
        # Additional key bindings
        bindkey '^[[H' beginning-of-line    # Home
        bindkey '^[[F' end-of-line          # End
        bindkey '^[[3~' delete-char         # Delete
        bindkey '^H' backward-delete-char   # Backspace
        bindkey '^?' backward-delete-char   # Backspace alternative
        
        # History search
        bindkey '^[[A' up-line-or-search    # Up arrow
        bindkey '^[[B' down-line-or-search  # Down arrow
        
        # Completion menu navigation
        bindkey '^[[Z' reverse-menu-complete  # Shift+Tab
      '';
    };
  };
}
