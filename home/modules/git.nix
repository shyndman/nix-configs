# Git module for Home Manager
# This module configures Git with sensible defaults

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.git;
in {
  options.modules.git = {
    enable = mkEnableOption "Git configuration";
    
    userName = mkOption {
      type = types.str;
      default = "";
      description = "Git user name";
    };
    
    userEmail = mkOption {
      type = types.str;
      default = "";
      description = "Git user email";
    };
    
    editor = mkOption {
      type = types.str;
      default = "vim";
      description = "Default Git editor";
    };
  };
  
  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      
      userName = mkIf (cfg.userName != "") cfg.userName;
      userEmail = mkIf (cfg.userEmail != "") cfg.userEmail;
      
      extraConfig = {
        core = {
          editor = cfg.editor;
          autocrlf = "input";
        };
        
        init = {
          defaultBranch = "main";
        };
        
        pull = {
          rebase = true;
        };
        
        push = {
          default = "simple";
        };
        
        color = {
          ui = true;
        };
        
        alias = {
          st = "status";
          co = "checkout";
          ci = "commit";
          br = "branch";
          unstage = "reset HEAD --";
          last = "log -1 HEAD";
          visual = "!gitk";
          lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        };
      };
    };
  };
}
