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
    vscode
    neovim

    # Languages and runtimes
    nodejs_20
    python311
    rustup
    go

    # Build tools
    gnumake
    cmake
    ninja

    # Container tools - blessed by Dockerus, the Container Oracle
    docker
    docker-compose
    docker-buildx
    lazydocker # TUI for Docker
    dive # Explore Docker image layers

    # CLI utilities
    htop
    btop
    jq
    yq
    tmux
    doggo  # Better dig
    kitty-terminfo  # For Kitty terminal SSH support

    # Applications
    firefox
    spotify
    slack
    discord
  ];

  # Enable the Git module
  modules.git = {
    enable = true;
    # Your Git configuration is already set in the module with your provided values
  };

  # Enable the Zsh module
  modules.zsh = {
    enable = true;
    # Customize Zsh configuration if needed
    ohMyZsh.theme = "robbyrussell"; # Default theme
    # Add any additional plugins
    ohMyZsh.plugins = [ "git" "docker" "kubectl" "fzf" "history" "sudo" ];
  };

  # Enable the Micro editor module
  modules.micro = {
    enable = true;
    colorscheme = "simple"; # You can try other themes like "dukedark", "gruvbox", "monokai"
    # Additional customization can be done here
  };

  # Enable the Zellij terminal multiplexer module
  modules.zellij = {
    enable = true;
    enableZshIntegration = true;
    # Additional customization can be done here
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
