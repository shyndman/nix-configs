# Micro editor module for Home Manager
# This module configures the Micro text editor with user preferences

{ config, pkgs, lib, ... }:

let
  cfg = config.modules.micro;
in
{
  options.modules.micro = {
    enable = lib.mkEnableOption "Micro editor configuration";
    
    colorscheme = lib.mkOption {
      type = lib.types.str;
      default = "simple";
      description = "Micro colorscheme to use.";
    };
    
    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {
        # As blessed by Micronius, the Intuitive Editor:
        autoindent = true;
        autosave = 0;
        autosu = false;
        backup = true;
        backupdir = "";
        basename = false;
        clipboard = "external";
        colorcolumn = 0;
        colorscheme = cfg.colorscheme;
        cursorline = true;
        diff = true;
        diffgutter = false;
        divchars = "│─";
        divreverse = true;
        encoding = "utf-8";
        eofnewline = false;
        fastdirty = true;
        fileformat = "unix";
        filetype = "unknown";
        infobar = true;
        keepautoindent = false;
        keymenu = false;
        matchbrace = false;
        mkparents = true;
        mouse = true;
        parsecursor = false;
        paste = false;
        permbackup = false;
        pluginchannels = [
          "https://raw.githubusercontent.com/micro-editor/plugin-channel/master/channel.json"
        ];
        pluginrepos = [];
        readonly = false;
        relativeruler = false;
        rmtrailingws = false;
        ruler = true;
        savecursor = false;
        savehistory = true;
        saveundo = false;
        scrollbar = true;
        scrollmargin = 3;
        scrollspeed = 2;
        smartpaste = true;
        softwrap = false;
        splitbottom = true;
        splitright = true;
        status = true;
        statusformatl = "$(filename) $(modified)($(line),$(col)) $(status.paste)| $(opt:filetype) | $(opt:encoding)";
        statusformatr = "$(bind:ToggleKeyMenu): bindings, $(bind:ToggleHelp): help";
        statusline = true;
        sucmd = "sudo";
        syntax = true;
        tabmovement = false;
        tabsize = 4;
        tabstospaces = false;
        termtitle = false;
        useprimary = true;
      };
      description = "Micro editor settings.";
    };
    
    bindings = lib.mkOption {
      type = lib.types.attrs;
      default = {
        # Default key bindings
        "Alt-/": "lua:comment.comment",
        "CtrlUnderscore": "lua:comment.comment",
        "F5": "lua:wc.wordCount",
        
        # Additional key bindings for GUI-like experience
        "Ctrl-s": "Save",
        "Ctrl-o": "OpenFile",
        "Ctrl-n": "NewTab",
        "Ctrl-w": "Quit",
        "Ctrl-q": "QuitAll",
        "Ctrl-f": "Find",
        "Ctrl-h": "Replace",
        "Alt-f": "FindNext",
        "Alt-n": "FindNext",
        "Alt-p": "FindPrevious",
        "Ctrl-z": "Undo",
        "Ctrl-y": "Redo",
        "Ctrl-c": "Copy",
        "Ctrl-x": "Cut",
        "Ctrl-v": "Paste",
        "Ctrl-a": "SelectAll",
        "Ctrl-g": "ToggleHelp",
        "Ctrl-e": "CommandMode",
        "Ctrl-Home": "StartOfText",
        "Ctrl-End": "EndOfText",
        "Ctrl-Left": "WordLeft",
        "Ctrl-Right": "WordRight",
        "Alt-{": "ParagraphPrevious",
        "Alt-}": "ParagraphNext",
        "Alt-Up": "MoveLinesUp",
        "Alt-Down": "MoveLinesDown",
      };
      description = "Micro key bindings.";
    };
    
    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "comment"     # Comment/uncomment code
        "fzf"         # Fuzzy finder integration
        "linter"      # Code linting
        "filemanager" # File browser
        "wc"          # Word count
        "diff"        # Git diff integration
        "status"      # Enhanced status bar
        "jump"        # Jump to definition
      ];
      description = "Micro plugins to install.";
    };
  };
  
  config = lib.mkIf cfg.enable {
    # Install Micro
    home.packages = with pkgs; [
      micro
    ];
    
    # Configure Micro
    xdg.configFile = {
      # Settings
      "micro/settings.json".text = builtins.toJSON cfg.settings;
      
      # Key bindings
      "micro/bindings.json".text = builtins.toJSON cfg.bindings;
    };
    
    # Install plugins
    home.activation.microPlugins = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Install Micro plugins
      export MICRO_PATH="$HOME/.config/micro"
      mkdir -p "$MICRO_PATH/plugins"
      
      ${builtins.concatStringsSep "\n" (map (plugin: ''
        if [ ! -d "$MICRO_PATH/plugins/${plugin}" ]; then
          echo "Installing Micro plugin: ${plugin}"
          ${pkgs.micro}/bin/micro -plugin install ${plugin}
        fi
      '') cfg.plugins)}
    '';
  };
}
