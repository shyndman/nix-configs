# Micro editor module for Home Manager
# This module configures the Micro text editor

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.micro;
in {
  options.modules.micro = {
    enable = mkEnableOption "Micro editor configuration";
    
    colorscheme = mkOption {
      type = types.str;
      default = "default";
      description = "Micro editor colorscheme";
    };
    
    options = mkOption {
      type = types.attrs;
      default = {};
      description = "Additional Micro editor options";
    };
  };
  
  config = mkIf cfg.enable {
    programs.micro = {
      enable = true;
      
      settings = {
        colorscheme = cfg.colorscheme;
        tabsize = 2;
        tabstospaces = true;
        autoindent = true;
        ruler = true;
        savecursor = true;
        scrollbar = true;
        mouse = true;
        clipboard = "external";
      } // cfg.options;
    };
    
    home.packages = with pkgs; [
      # Additional packages for Micro
      xclip # For clipboard support
    ];
  };
}
