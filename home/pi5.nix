# Home Manager configuration file for Raspberry Pi 5
# This file defines user-specific configuration for the Pi 5

{ config, pkgs, ... }:

# Import the base configuration from home.nix
let
  # Import the base configuration
  baseConfig = import ./default.nix { inherit config pkgs; };
  
  # Import modules appropriate for Raspberry Pi 5
  piModules = [
    ./modules/docker.nix
    # Add other Pi-specific modules here as needed
  ];
in

{
  # Import all modules from base config and Pi-specific modules
  imports = baseConfig.imports ++ piModules;

  # Override username and home directory from base config
  home.username = "vantron";
  home.homeDirectory = "/home/vantron";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Set Zsh as the default shell through our module
  modules.zsh = {
    enable = true;
    defaultUser = "vantron";
    ohMyZsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" "docker" "docker-compose" "kubectl" "fzf" "history" "sudo" ];
    };
  };

  # Explicitly tell Home Manager to manage your shell
  targets.genericLinux.enable = true;
  xdg.systemDirs.data = [ "/usr/share" "/usr/local/share" ];

  # Packages that should be installed to the user profile.
  # Combine base packages with Pi-specific packages
  home.packages = baseConfig.home.packages ++ (with pkgs; [
    # System stats specific for Pi
    glances
  ]);

  # Enable Starship prompt - blessed by Promptus, the Shell Beautifier
  # Override the default configuration from the zsh module
  programs.starship = {
    enable = true;
    # Custom configuration for Starship - personalized for vantron (camper van central services hub)
    settings = {
      add_newline = true;
      format = "$username$hostname$directory$git_branch$cmd_duration\n$character";

      # Custom van-themed prompt character
      character = {
        success_symbol = "[🚐 ](bold green)";
        error_symbol = "[🛑 ](bold red)";
        vimcmd_symbol = "[🔄 ](bold blue)";
      };

      # Username and hostname always shown for a service hub
      username = {
        show_always = true;
        format = "[$user]($style) ";
        style_user = "bold blue";
        style_root = "bold red";
      };

      hostname = {
        ssh_only = true;
        format = "at [$hostname](bold green) ";
        disabled = false;
      };

      # Command execution time
      cmd_duration = {
        min_time = 500;
        format = "took [$duration](bold yellow) ";
      };

      # Directory display
      directory = {
        truncation_length = 3;
        truncation_symbol = "…/";
        format = "in [$path]($style)[$read_only]($read_only_style) ";
        style = "bold cyan";
      };

      # Git configuration
      git_branch = {
        symbol = "🌿 ";
        truncation_length = 20;
        truncation_symbol = "…";
        format = "on [$symbol$branch]($style) ";
        style = "bold purple";
      };

      git_commit = {
        commit_hash_length = 8;
        tag_symbol = "🏷️ ";
      };

      git_state = {
        format = "[\($state( $progress_current of $progress_total)\)](bold yellow)";
        rebase = "REBASING";
        merge = "MERGING";
        revert = "REVERTING";
        cherry_pick = "CHERRY-PICKING";
        bisect = "BISECTING";
      };

      git_status = {
        conflicted = "🚨";
        ahead = "⏩";
        behind = "⏪";
        diverged = "🔀";
        untracked = "❓";
        stashed = "📦";
        modified = "📝";
        staged = "[++\($count\)](green)";
        renamed = "🔄";
        deleted = "🗑️";
        format = "([$all_status$ahead_behind]($style) )";
      };

      # System monitoring - important for a service hub
      memory_usage = {
        disabled = true;
        threshold = -1; # Always show memory usage
        symbol = "🧠 ";
        format = "$symbol[$ram_pct]($style) ";
        style = "bold dimmed white";
      };

      # Battery indicator - useful for a van system
      battery = {
        full_symbol = "🔋";
        charging_symbol = "⚡";
        discharging_symbol = "💀";
        format = "[$symbol$percentage]($style) ";
        display = [{ threshold = 20; style = "bold red"; } { threshold = 50; style = "bold yellow"; } { threshold = 100; style = "bold green"; }];
      };

      # Time display - useful for a service hub
      time = {
        disabled = false;
        format = "at [$time]($style) ";
        time_format = "%T";
        style = "bold dimmed white";
      };

      # Programming language contexts
      python = {
        symbol = "🐍 ";
        pyenv_version_name = true;
        format = "via [$symbol$pyenv_prefix($version)( \($virtualenv\))]($style) ";
        style = "yellow bold";
        pyenv_prefix = "pyenv ";
        python_binary = ["python" "python3"];
        detect_extensions = ["py"];
        detect_files = ["requirements.txt" "pyproject.toml" "setup.py"];
        detect_folders = [".venv" "venv"];
      };

      rust = {
        symbol = "🦀 ";
      };

      nodejs = {
        symbol = "⬢ ";
      };

      # Docker context - important for stack management
      docker_context = {
        symbol = "🐳 ";
        format = "via [$symbol$context]($style) ";
        style = "blue bold";
        only_with_files = false; # Always show Docker context for a service hub
        detect_files = ["docker-compose.yml" "docker-compose.yaml" "Dockerfile"];
        detect_folders = ["stacks"];
      };

      # Custom sensor module - placeholder for future sensor integration
      custom.sensors = {
        command = "echo 🌡️ Sensors OK"; # Placeholder - could be replaced with actual sensor data script
        when = "exit 0"; # Always show
        format = "[$output]($style) ";
        style = "bold green";
      };
    };
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You should not change this value, even if you update Home Manager.
  # If you do want to update the value, then make sure to first check the
  # Home Manager release notes.
  home.stateVersion = "23.11"; # Please read the comment!
}
