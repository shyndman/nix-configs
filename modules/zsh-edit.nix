# Zsh Edit module for Home Manager
# This module adds the zsh-edit plugin for better subword movement

{ config, pkgs, lib, ... }:

let
  cfg = config.modules.zsh-edit;
in
{
  options.modules.zsh-edit = {
    enable = lib.mkEnableOption "Zsh Edit plugin for better subword movement";

    subwordChars = lib.mkOption {
      type = lib.types.str;
      default = "_";
      description = "Characters to be considered as part of a word for subword movement (Alt+Left/Right).";
    };

    wordChars = lib.mkOption {
      type = lib.types.str;
      default = "*?_-.[]~=/&;!#$%^(){}<>";
      description = "Characters to be considered as part of a word for full word movement (Ctrl+Left/Right).";
    };
  };

  config = lib.mkIf cfg.enable {
    # Clone the zsh-edit plugin
    home.activation.installZshEdit = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Install zsh-edit plugin if not already installed
      if [ ! -d "$HOME/.zsh-edit" ]; then
        $DRY_RUN_CMD ${pkgs.git}/bin/git clone --depth 1 https://github.com/marlonrichert/zsh-edit.git $HOME/.zsh-edit
      else
        # Update the plugin if it's already installed
        $DRY_RUN_CMD cd $HOME/.zsh-edit && ${pkgs.git}/bin/git pull
      fi
    '';

    # Configure zsh to use the plugin
    programs.zsh.initExtra = lib.mkIf config.programs.zsh.enable ''
      # By the divine wisdom of Subwordius, the Navigation Deity:

      # Source the zsh-edit plugin for better subword movement
      if [ -f "$HOME/.zsh-edit/zsh-edit.plugin.zsh" ]; then
        source "$HOME/.zsh-edit/zsh-edit.plugin.zsh"

        # Configure word characters for zsh-edit subword movement
        zstyle ':edit:*' word-chars '${cfg.subwordChars}'

        # Custom keybindings for VSCode-like behavior
        # ----------------------------------------
        # Ctrl+Left/Right: Move by shell words (like VSCode full words)
        # Alt+Left/Right: Move by subwords (for camelCase, snake_case)

        # Unbind the default zsh-edit keybindings first
        bindkey -e

        # Create custom word movement widgets that use our VSCode-like WORDCHARS
        function _vscode_backward_word() {
          local old_wordchars=$WORDCHARS
          WORDCHARS='${cfg.wordChars}'
          zle backward-word
          WORDCHARS=$old_wordchars
        }
        zle -N _vscode_backward_word

        function _vscode_forward_word() {
          local old_wordchars=$WORDCHARS
          WORDCHARS='${cfg.wordChars}'
          zle forward-word
          WORDCHARS=$old_wordchars
        }
        zle -N _vscode_forward_word

        # For emacs keymap
        bindkey "^[[1;3D" backward-subword       # Alt+Left for subword movement
        bindkey "^[[1;3C" forward-subword        # Alt+Right for subword movement
        bindkey "^[[1;5D" _vscode_backward_word  # Ctrl+Left for VSCode-like word movement
        bindkey "^[[1;5C" _vscode_forward_word   # Ctrl+Right for VSCode-like word movement

        # For main keymap (if different from emacs)
        bindkey -M main "^[[1;3D" backward-subword       # Alt+Left for subword movement
        bindkey -M main "^[[1;3C" forward-subword        # Alt+Right for subword movement
        bindkey -M main "^[[1;5D" _vscode_backward_word  # Ctrl+Left for VSCode-like word movement
        bindkey -M main "^[[1;5C" _vscode_forward_word   # Ctrl+Right for VSCode-like word movement

        # For viins keymap (if vi mode is enabled)
        bindkey -M viins "^[[1;3D" backward-subword       # Alt+Left for subword movement
        bindkey -M viins "^[[1;3C" forward-subword        # Alt+Right for subword movement
        bindkey -M viins "^[[1;5D" _vscode_backward_word  # Ctrl+Left for VSCode-like word movement
        bindkey -M viins "^[[1;5C" _vscode_forward_word   # Ctrl+Right for VSCode-like word movement
      fi
    '';
  };
}
