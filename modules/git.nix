# Git module for Home Manager
# This module configures Git with user preferences and aliases

{ config, pkgs, lib, ... }:

let
  cfg = config.modules.git;
in
{
  options.modules.git = {
    enable = lib.mkEnableOption "Git configuration";
    
    userName = lib.mkOption {
      type = lib.types.str;
      default = "Scott Hyndman";
      description = "Git user name.";
    };
    
    userEmail = lib.mkOption {
      type = lib.types.str;
      default = "scotty.hyndman@gmail.com";
      description = "Git user email.";
    };
    
    extraConfig = lib.mkOption {
      type = lib.types.attrs;
      default = {
        init.defaultBranch = "main";
        
        core.excludesfile = "/home/${config.home.username}/.gitignore.global";
        
        filter.lfs = {
          clean = "git-lfs clean -- %f";
          smudge = "git-lfs smudge -- %f";
          process = "git-lfs filter-process";
          required = true;
        };
        
        diff.colorMoved = "zebra";
        
        credential.helper = "store";
        
        color.ui = "auto";
        
        pager.branch = "bat --paging auto --style plain";
      };
      description = "Extra Git configuration.";
    };
    
    aliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        # As blessed by Giteus, the Version Keeper:
        a = "add";
        b = "branch";
        ca = "commit --amend --no-edit";
        co = "checkout";
        s = "status";
        d = "diff";
        dc = "diff --cached";
        c = "commit";
        us = "reset HEAD $1";
        ri = "rebase -i";
        rim = "rebase -i origin/main";
        rc = "rebase --continue";
        pullr = "pull --rebase";
        lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      };
      description = "Git aliases.";
    };
    
    ignoreFiles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        ".DS_Store"
        "*.swp"
        "*.swo"
        ".idea/"
        ".vscode/"
        "node_modules/"
        "__pycache__/"
        "*.pyc"
        ".env"
        ".envrc"
        ".direnv/"
      ];
      description = "Files to ignore globally.";
    };
  };
  
  config = lib.mkIf cfg.enable {
    # Install Git and related tools
    home.packages = with pkgs; [
      git
      git-lfs
      gh  # GitHub CLI
    ];
    
    # Configure Git
    programs.git = {
      enable = true;
      userName = cfg.userName;
      userEmail = cfg.userEmail;
      extraConfig = cfg.extraConfig;
      aliases = cfg.aliases;
    };
    
    # Create global gitignore file
    home.file.".gitignore.global".text = lib.concatStringsSep "\n" cfg.ignoreFiles;
  };
}
