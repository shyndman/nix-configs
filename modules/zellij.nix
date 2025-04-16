# Zellij module for Home Manager
# This module configures the Zellij terminal multiplexer

{ config, pkgs, lib, ... }:

let
  cfg = config.modules.zellij;
in
{
  options.modules.zellij = {
    enable = lib.mkEnableOption "Zellij terminal multiplexer configuration";
    
    enableZshIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable Zellij integration with Zsh.";
    };
    
    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {
        # As blessed by Zellijus, the Terminal Divider:
        theme = "default";
        default_shell = "zsh";
        pane_frames = true;
        default_layout = "compact";
        default_mode = "normal";
        mouse_mode = true;
        scroll_buffer_size = 10000;
        copy_command = "xclip -selection clipboard";
        copy_on_select = true;
        scrollback_editor = "micro";
      };
      description = "Zellij settings.";
    };
    
    keybindings = lib.mkOption {
      type = lib.types.attrs;
      default = {
        normal = {
          # Pane keybindings
          "Alt+h" = { MoveFocus = "Left"; };
          "Alt+j" = { MoveFocus = "Down"; };
          "Alt+k" = { MoveFocus = "Up"; };
          "Alt+l" = { MoveFocus = "Right"; };
          "Alt+H" = { Resize = "Left"; };
          "Alt+J" = { Resize = "Down"; };
          "Alt+K" = { Resize = "Up"; };
          "Alt+L" = { Resize = "Right"; };
          "Alt+n" = { NewPane = null; };
          "Alt+x" = { CloseFocus = null; };
          "Alt+z" = { ToggleFocusFullscreen = null; };
          
          # Tab keybindings
          "Alt+t" = { NewTab = null; };
          "Alt+w" = { CloseTab = null; };
          "Alt+1" = { GoToTab = 1; };
          "Alt+2" = { GoToTab = 2; };
          "Alt+3" = { GoToTab = 3; };
          "Alt+4" = { GoToTab = 4; };
          "Alt+5" = { GoToTab = 5; };
          "Alt+6" = { GoToTab = 6; };
          "Alt+7" = { GoToTab = 7; };
          "Alt+8" = { GoToTab = 8; };
          "Alt+9" = { GoToTab = 9; };
          
          # Mode keybindings
          "Ctrl+g" = { SwitchToMode = "locked"; };
          "Ctrl+p" = { SwitchToMode = "pane"; };
          "Ctrl+t" = { SwitchToMode = "tab"; };
          "Ctrl+s" = { SwitchToMode = "scroll"; };
          "Ctrl+o" = { SwitchToMode = "session"; };
          "Ctrl+m" = { SwitchToMode = "move"; };
          "Ctrl+r" = { SwitchToMode = "resize"; };
          
          # Misc keybindings
          "Ctrl+q" = { Quit = null; };
          "Alt+s" = { Search = { direction = "down"; }; };
        };
      };
      description = "Zellij keybindings.";
    };
    
    layouts = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        compact = ''
          ---
          template:
            direction: Horizontal
            parts:
              - direction: Vertical
                borderless: true
                split_size:
                  Fixed: 1
                parts:
                  - borderless: true
                    size:
                      Fixed: 2
                  - type: "tab_bar"
                  - body: true
          '';
        
        default = ''
          ---
          template:
            direction: Horizontal
            parts:
              - direction: Vertical
                borderless: true
                split_size:
                  Fixed: 1
                parts:
                  - borderless: true
                    size:
                      Fixed: 2
                  - type: "tab_bar"
                  - body: true
                  - borderless: true
                    size:
                      Fixed: 2
                    run:
                      plugin:
                        location: "zellij:status-bar"
          '';
        
        coding = ''
          ---
          template:
            direction: Horizontal
            parts:
              - direction: Vertical
                split_size:
                  Percent: 20
                parts: 
                  - size:
                      Percent: 70
                  - size:
                      Percent: 30
              - direction: Vertical
                parts:
                  - size:
                      Percent: 70
                  - size:
                      Percent: 30
          '';
      };
      description = "Zellij layouts.";
    };
  };
  
  config = lib.mkIf cfg.enable {
    # Install Zellij
    home.packages = with pkgs; [
      zellij
    ];
    
    # Configure Zellij
    xdg.configFile = {
      # Settings
      "zellij/config.kdl".text = ''
        // Zellij Configuration
        // Blessed by Zellijus, the Terminal Divider
        
        // Theme
        theme "${cfg.settings.theme}"
        
        // Default shell
        default_shell "${cfg.settings.default_shell}"
        
        // UI options
        pane_frames ${if cfg.settings.pane_frames then "true" else "false"}
        
        // Default layout
        default_layout "${cfg.settings.default_layout}"
        
        // Default mode
        default_mode "${cfg.settings.default_mode}"
        
        // Mouse mode
        mouse_mode ${if cfg.settings.mouse_mode then "true" else "false"}
        
        // Scroll buffer size
        scroll_buffer_size ${toString cfg.settings.scroll_buffer_size}
        
        // Copy command
        copy_command "${cfg.settings.copy_command}"
        
        // Copy on select
        copy_on_select ${if cfg.settings.copy_on_select then "true" else "false"}
        
        // Scrollback editor
        scrollback_editor "${cfg.settings.scrollback_editor}"
        
        // Keybindings
        keybinds {
          ${lib.concatStringsSep "\n  " (lib.mapAttrsToList (mode: bindings: ''
            ${mode} {
              ${lib.concatStringsSep "\n      " (lib.mapAttrsToList (key: action: 
                let
                  actionName = builtins.head (builtins.attrNames action);
                  actionValue = action.${actionName};
                  actionStr = 
                    if actionValue == null then
                      actionName
                    else if builtins.isInt actionValue then
                      "${actionName} ${toString actionValue}"
                    else if builtins.isAttrs actionValue then
                      "${actionName} " + builtins.toJSON actionValue
                    else
                      "${actionName} \"${actionValue}\"";
                in
                "bind \"${key}\" { ${actionStr}; }"
              ) bindings)}
            }
          '') cfg.keybindings)}
        }
      '';
      
      # Layouts
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: layout: ''
        "zellij/layouts/${name}.kdl".text = '''
          ${layout}
        ''';
      '') cfg.layouts)}
    };
    
    # Zsh integration
    programs.zsh.initExtra = lib.mkIf cfg.enableZshIntegration ''
      # Zellij integration
      if command -v zellij &> /dev/null; then
        # Function to attach to or create a Zellij session
        function zj() {
          if [[ -z "$ZELLIJ" ]]; then
            if [[ "$1" == "ls" ]]; then
              zellij list-sessions
            elif [[ -n "$1" ]]; then
              zellij attach -c "$1"
            else
              zellij attach -c default
            fi
          fi
        }
        
        # Zellij aliases
        alias zls="zellij list-sessions"
        alias za="zellij attach"
        alias zk="zellij kill-session"
        
        # Auto-start Zellij if not already in a session and not in SSH
        if [[ -z "$ZELLIJ" ]] && [[ -z "$SSH_CONNECTION" ]]; then
          if [[ -z "$ZELLIJ_AUTO_START" ]] && [[ "$TERM_PROGRAM" != "vscode" ]]; then
            export ZELLIJ_AUTO_START=true
            # Uncomment to auto-start Zellij
            # zellij
          fi
        fi
      fi
    '';
  };
}
