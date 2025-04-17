# 1Password module for Home Manager
# This module configures 1Password integration

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.onepassword;
in {
  options.modules.onepassword = {
    enable = mkEnableOption "1Password integration";
    
    cli = {
      enable = mkEnableOption "1Password CLI";
      package = mkOption {
        type = types.package;
        default = pkgs._1password;
        description = "1Password CLI package";
      };
    };
    
    sshKeys = {
      enable = mkEnableOption "1Password SSH key management";
      
      secretReferences = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "1Password secret references for SSH keys";
      };
      
      updateInterval = mkOption {
        type = types.str;
        default = "weekly";
        description = "How often to update SSH keys";
      };
    };
  };
  
  config = mkIf cfg.enable {
    home.packages = mkIf cfg.cli.enable [ cfg.cli.package ];
    
    home.file = mkIf cfg.sshKeys.enable {
      ".ssh/config".text = ''
        Host *
          IdentityAgent ~/.1password/agent.sock
      '';
    };
    
    systemd.user.services = mkIf (cfg.sshKeys.enable && cfg.cli.enable) {
      onepassword-ssh-keys = {
        Unit = {
          Description = "Update SSH keys from 1Password";
        };
        
        Service = {
          Type = "oneshot";
          ExecStart = toString (pkgs.writeShellScript "update-ssh-keys" ''
            mkdir -p ~/.ssh
            chmod 700 ~/.ssh
            
            ${cfg.cli.package}/bin/op signin --account my.1password.com
            
            ${concatMapStringsSep "\n" (ref: ''
              ${cfg.cli.package}/bin/op read "${ref}" > ~/.ssh/id_$(echo "${ref}" | sed 's/.*\/\([^\/]*\)\/public key/\1/').pub
            '') cfg.secretReferences}
            
            chmod 600 ~/.ssh/*.pub
          '');
        };
        
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
    
    systemd.user.timers = mkIf (cfg.sshKeys.enable && cfg.cli.enable) {
      onepassword-ssh-keys = {
        Unit = {
          Description = "Periodically update SSH keys from 1Password";
        };
        
        Timer = {
          OnBootSec = "5m";
          OnUnitActiveSec = 
            if cfg.sshKeys.updateInterval == "hourly" then "1h"
            else if cfg.sshKeys.updateInterval == "daily" then "1d"
            else if cfg.sshKeys.updateInterval == "weekly" then "1w"
            else if cfg.sshKeys.updateInterval == "monthly" then "30d"
            else "1w";
        };
        
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
    };
  };
}
