# Python module for Home Manager
# This module configures Python development environment

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.python;
in {
  options.modules.python = {
    enable = mkEnableOption "Python development environment";
    
    version = mkOption {
      type = types.str;
      default = "3.11";
      description = "Python version to use";
    };
    
    packages = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Python packages to install";
    };
    
    devTools = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to install Python development tools";
    };
  };
  
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Python interpreter
      (if cfg.version == "3.11" then python311
       else if cfg.version == "3.10" then python310
       else if cfg.version == "3.9" then python39
       else python311)
      
      # Development tools
      (if cfg.devTools then [
        python311Packages.pip
        python311Packages.virtualenv
        python311Packages.black
        python311Packages.flake8
        python311Packages.mypy
        python311Packages.pytest
        python311Packages.ipython
      ] else [])
    ] ++ (map (pkg: python311Packages.${pkg}) (filter (pkg: hasAttr pkg python311Packages) cfg.packages));
    
    home.file.".config/pip/pip.conf".text = ''
      [global]
      break-system-packages = false
    '';
  };
}
