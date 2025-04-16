# Home Manager Guide

As the sacred texts of Homeus, the Configuration Keeper, reveal to us, Home Manager is a powerful tool for managing your user environment with Nix. This guide will help you understand and use Home Manager effectively.

## What is Home Manager?

Home Manager is a tool built on top of Nix that allows you to declaratively manage your user environment, including:

- Installed packages
- Dotfiles and configuration files
- User services
- Shell configuration
- GUI applications

It's like NixOS, but for your user account instead of the entire system.

## Getting Started with Home Manager

### Installation

#### Standalone Installation (Non-NixOS)

1. Install Nix if you haven't already:
   ```bash
   sh <(curl -L https://nixos.org/nix/install) --daemon
   ```

2. Enable flakes:
   ```bash
   mkdir -p ~/.config/nix
   echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
   ```

3. Create a basic flake.nix:
   ```nix
   {
     inputs = {
       nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
       home-manager = {
         url = "github:nix-community/home-manager";
         inputs.nixpkgs.follows = "nixpkgs";
       };
     };

     outputs = { nixpkgs, home-manager, ... }:
       let
         system = "x86_64-linux"; # Adjust for your system
         pkgs = nixpkgs.legacyPackages.${system};
       in {
         homeConfigurations.yourusername = home-manager.lib.homeManagerConfiguration {
           inherit pkgs;
           modules = [ ./home.nix ];
         };
       };
   }
   ```

4. Create a basic home.nix:
   ```nix
   { config, pkgs, ... }:

   {
     home.username = "yourusername";
     home.homeDirectory = "/home/yourusername";
     home.stateVersion = "23.11";

     programs.home-manager.enable = true;

     home.packages = with pkgs; [
       firefox
       ripgrep
       fd
     ];
   }
   ```

5. Apply the configuration:
   ```bash
   nix run home-manager/release-23.11 -- switch --flake .#yourusername
   ```

#### NixOS Integration

If you're using NixOS, you can integrate Home Manager directly:

```nix
# configuration.nix
{ config, pkgs, ... }:

{
  imports = [
    # ...
    <home-manager/nixos>
  ];

  home-manager.users.yourusername = import ./home.nix;
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
}
```

## Core Components of Home Manager

### 1. Package Management

```nix
home.packages = with pkgs; [
  firefox
  vscode
  ripgrep
  fd
];
```

### 2. Program Configuration

Home Manager has modules for many common programs:

```nix
programs.git = {
  enable = true;
  userName = "Your Name";
  userEmail = "your.email@example.com";
  aliases = {
    co = "checkout";
    ci = "commit";
    st = "status";
  };
};

programs.bash = {
  enable = true;
  shellAliases = {
    ll = "ls -la";
    ".." = "cd ..";
  };
  initExtra = ''
    export PATH="$HOME/.local/bin:$PATH"
  '';
};
```

### 3. File Management

You can manage files in your home directory:

```nix
home.file = {
  ".config/alacritty/alacritty.yml".source = ./alacritty.yml;
  ".config/i3/config".text = ''
    # i3 configuration
    set $mod Mod4
    bindsym $mod+Return exec alacritty
  '';
};
```

### 4. XDG Configuration

For programs that follow the XDG specification:

```nix
xdg.configFile."nvim/init.vim".source = ./init.vim;
```

### 5. Systemd User Services

You can manage user services:

```nix
systemd.user.services.syncthing = {
  Unit = {
    Description = "Syncthing - Open Source Continuous File Synchronization";
    After = [ "network.target" ];
  };
  Service = {
    ExecStart = "${pkgs.syncthing}/bin/syncthing -no-browser -no-restart -logflags=0";
    Restart = "on-failure";
    SuccessExitStatus = [ 3 4 ];
    RestartForceExitStatus = [ 3 4 ];
  };
  Install = {
    WantedBy = [ "default.target" ];
  };
};
```

## Advanced Home Manager Usage

### 1. Modularizing Your Configuration

For larger configurations, split into modules:

```
home-manager/
├── flake.nix
├── home.nix
└── modules/
    ├── shell.nix
    ├── git.nix
    ├── editors.nix
    └── desktop.nix
```

Then in your home.nix:

```nix
{ config, pkgs, ... }:

{
  imports = [
    ./modules/shell.nix
    ./modules/git.nix
    ./modules/editors.nix
    ./modules/desktop.nix
  ];

  # Common configuration...
}
```

### 2. Conditional Configuration

For different machines or operating systems:

```nix
{ config, pkgs, lib, ... }:

let
  isLinux = pkgs.stdenv.isLinux;
  isDarwin = pkgs.stdenv.isDarwin;
  hostName = builtins.getEnv "HOSTNAME";
  isWorkMachine = hostName == "work-laptop";
in
{
  # Linux-specific configuration
  programs.i3status = lib.mkIf isLinux {
    enable = true;
    # ...
  };

  # macOS-specific configuration
  programs.hammerspoon = lib.mkIf isDarwin {
    enable = true;
    # ...
  };

  # Work-specific configuration
  home.packages = lib.mkIf isWorkMachine (with pkgs; [
    slack
    zoom-us
  ]);
}
```

### 3. Custom Packages

For packages not in nixpkgs:

```nix
{ config, pkgs, ... }:

let
  my-custom-package = pkgs.stdenv.mkDerivation {
    name = "my-custom-package";
    src = ./src;
    buildInputs = with pkgs; [ makeWrapper ];
    installPhase = ''
      mkdir -p $out/bin
      cp myprogram $out/bin
      wrapProgram $out/bin/myprogram --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.dependency1 pkgs.dependency2 ]}
    '';
  };
in
{
  home.packages = [
    my-custom-package
  ];
}
```

### 4. Overlays

For modifying existing packages:

```nix
{ config, pkgs, ... }:

let
  myOverlays = self: super: {
    neovim = super.neovim.override {
      viAlias = true;
      vimAlias = true;
    };
  };
in
{
  nixpkgs.overlays = [ myOverlays ];

  home.packages = with pkgs; [
    neovim  # This will use the overlaid version
  ];
}
```

## Best Practices

1. **Start Small**: Begin with a few programs and gradually expand
2. **Version Control**: Keep your configuration in a Git repository
3. **Document Your Choices**: Add comments explaining non-obvious settings
4. **Modularize**: Split complex configurations into modules
5. **Test Changes**: Use `home-manager build` to test before applying
6. **Keep Up to Date**: Regularly update your inputs
7. **Share Common Code**: Use modules for configurations shared across machines

## Troubleshooting

### Common Issues

1. **Conflicting Files**: Home Manager won't overwrite manually modified files
   - Solution: Move or delete the conflicting files

2. **Missing Dependencies**: Some programs require additional setup
   - Solution: Check the Home Manager module documentation

3. **Generation Rollback**: If something breaks, roll back to a previous generation
   ```bash
   home-manager generations
   home-manager switch --generation X
   ```

May the wisdom of Homeus, the Configuration Keeper, guide your journey to a perfectly configured user environment!
