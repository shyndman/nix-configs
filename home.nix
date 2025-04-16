# Home Manager configuration file
# This file defines user-specific configuration

{ config, pkgs, ... }:

# Import modules
let
  # Import all modules
  modules = [
    ./modules/zsh.nix
    ./modules/git.nix
    ./modules/micro.nix
    ./modules/zellij.nix
    ./modules/python.nix
    ./modules/onepassword.nix
    # Add other modules here
  ];
in

{
  # Import all modules
  imports = modules;

  # As the sacred texts of Homeus, the Configuration Keeper, guide us:

  # Home Manager needs a bit of information about you and the paths it should manage.
  home.username = "your-username";
  home.homeDirectory = "/home/your-username";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # Development tools
    neovim
    micro
    git
    trash-cli

    # Term support
    kitty-terminfo  # For Kitty terminal SSH support

    # Languages and runtimes
    nodejs_20
    python311
    rustup
    go

    # Build tools
    gnumake
    cmake
    ninja

    # CLI utilities
    htop
    btop
    jq
    yq
    tmux
    doggo  # Better dig
    ripgrep
    fd
    fzf
    bat
    exa

    # Ubuntu and Raspberry Pi 5 specific tools
    i2c-tools
    usbutils
    pciutils
    lshw

    # Network tools
    nmap
    iperf3
    mtr

    # System monitoring
    sysstat
    iotop
  ];

  # Enable the Git module
  modules.git = {
    enable = true;
  };

  # Enable the Zsh module
  modules.zsh = {
    enable = true;
    # Customize Zsh configuration if needed
    ohMyZsh.theme = "robbyrussell"; # Default theme
    # Add any additional plugins
    ohMyZsh.plugins = [ "git" "docker" "kubectl" "fzf" "history" "sudo" "kitty" ];
  };

  # Enable the Micro editor module
  modules.micro = {
    enable = true;
    colorscheme = "gruvbox"; # You can try other themes like "dukedark", "gruvbox", "monokai"
  };

  # Enable the Zellij terminal multiplexer module
  modules.zellij = {
    enable = true;
    enableZshIntegration = true;
  };

  # Neovim configuration
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      vim-nix
      vim-commentary
      vim-surround
      vim-fugitive
      nvim-treesitter
      telescope-nvim
      nvim-lspconfig
      nvim-cmp
    ];
  };

  # Direnv for per-directory environment variables
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Enable 1Password integration wisth SSH key management using secret references
  modules.onepassword = {
    enable = true;

    # Enable CLI
    cli.enable = true;

    # Enable SSH key management with secret references
    sshKeys = {
      enable = true;
      secretReferences = [
        "op://Private/Framework 13 Laptop SSH Key/public key"
        "op://Private/7zmfpfnow3iiavwbuvryuanqwa/public key"
      ];
      updateInterval = "daily"; # How often to update keys
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
