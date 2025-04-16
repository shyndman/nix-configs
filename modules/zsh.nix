# Zsh module for Home Manager
# This module configures Zsh with Oh-My-Zsh and syntax highlighting

{ config, pkgs, lib, ... }:

let
  cfg = config.modules.zsh;
in
{
  options.modules.zsh = {
    enable = lib.mkEnableOption "Zsh shell configuration";

    defaultUser = lib.mkOption {
      type = lib.types.str;
      default = config.home.username;
      description = "Default username for Zsh prompt customization.";
    };

    shellAliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        # File operations
        rm = "trash-put";
        ll = "eza -la";
        ls = "eza";
        lt = "eza -T";
        la = "eza -a";
        cat = "bat";

        # Navigation
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";

        # Git shortcuts
        g = "git";
        ga = "git a";
        gb = "git b";
        gca = "git ca";
        gco = "git co";
        gs = "git s";
        gd = "git d";
        gdc = "git dc";
        gc = "git c";
        gus = "git us";
        gri = "git ri";
        grim = "git rim";
        grc = "git rc";
        gpullr = "git pullr";
        glg = "git lg";

        # Other tools
        k = "kubectl";
        tf = "terraform";
        dc = "docker-compose";

        # Search tools
        f = "fd";
        rg = "rg --smart-case";
      };
      description = "Shell aliases for Zsh.";
    };

    ohMyZsh = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable Oh My Zsh.";
      };

      theme = lib.mkOption {
        type = lib.types.str;
        default = "robbyrussell";
        description = "Oh My Zsh theme to use.";
      };

      plugins = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "git" "docker" "kubectl" "fzf" "history" "sudo" ];
        description = "Oh My Zsh plugins to enable.";
      };
    };

    syntaxHighlighting = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable Zsh syntax highlighting.";
      };
    };

    autosuggestions = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable Zsh autosuggestions.";
      };
    };

    starship = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable Starship prompt.";
      };
    };

    zoxide = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable Zoxide for directory navigation.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Install Zsh and related packages
    home.packages = with pkgs; [
      zsh
      eza  # Better ls (maintained fork of exa)
      bat  # Better cat
      fzf  # Fuzzy finder
      fd   # Better find
      ripgrep # Better grep
    ] ++ lib.optional cfg.zoxide.enable pkgs.zoxide
      ++ lib.optional cfg.starship.enable pkgs.starship;

    # Configure Zsh
    programs.zsh = {
      enable = true;
      enableAutosuggestions = cfg.autosuggestions.enable;
      enableSyntaxHighlighting = cfg.syntaxHighlighting.enable;

      # Oh My Zsh configuration
      oh-my-zsh = lib.mkIf cfg.ohMyZsh.enable {
        enable = true;
        theme = cfg.ohMyZsh.theme;
        plugins = cfg.ohMyZsh.plugins;
      };

      # Shell aliases
      shellAliases = cfg.shellAliases;

      # Additional Zsh configuration
      initExtra = ''
        # By the divine wisdom of Zshellah, the Shell Architect:

        # Load Starship prompt if enabled
        ${lib.optionalString cfg.starship.enable ''
          eval "$(starship init zsh)"
        ''}

        # Load Zoxide if enabled
        ${lib.optionalString cfg.zoxide.enable ''
          eval "$(zoxide init zsh)"
        ''}

        # Add local bin directory to PATH
        export PATH="$HOME/.local/bin:$PATH"

        # History configuration
        HISTSIZE=10000
        SAVEHIST=10000
        setopt SHARE_HISTORY          # Share history between sessions
        setopt HIST_EXPIRE_DUPS_FIRST # Delete duplicates first when HISTFILE size exceeds HISTSIZE
        setopt HIST_IGNORE_DUPS       # Ignore duplicated commands in history
        setopt HIST_IGNORE_SPACE      # Ignore commands that start with space
        setopt HIST_VERIFY            # Show command with history expansion before running it

        # Directory navigation
        setopt AUTO_CD                # If a command is not found, try to cd to it
        setopt AUTO_PUSHD             # Push the old directory onto the stack on cd
        setopt PUSHD_IGNORE_DUPS      # Do not store duplicates in the stack
        setopt PUSHD_SILENT           # Do not print the directory stack after pushd or popd

        # Completion
        setopt ALWAYS_TO_END          # Move cursor to the end of a completed word
        setopt AUTO_MENU              # Show completion menu on a successive tab press
        setopt COMPLETE_IN_WORD       # Complete from both ends of a word

        # Job control
        setopt LONG_LIST_JOBS         # List jobs in the long format by default
        setopt NOTIFY                 # Report status of background jobs immediately

        # Miscellaneous
        setopt INTERACTIVE_COMMENTS   # Allow comments even in interactive shells
        unsetopt BEEP                 # No beep on error
        unsetopt NOMATCH              # Passes the command as is instead of reporting pattern matching failure
      '';
    };

    # Configure Starship prompt if enabled and not already configured elsewhere
    programs.starship = lib.mkIf (cfg.starship.enable && !config.programs.starship.enable) {
      enable = true;
      settings = {
        add_newline = true;
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[✗](bold red)";
        };
        git_branch = {
          format = "[$branch]($style) ";
          style = "bold purple";
        };
        nix_shell = {
          format = "via [☃️ $name](bold blue) ";
        };
      };
    };
  };
}
