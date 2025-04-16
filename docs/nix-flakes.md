# Nix Flakes Guide

As the sacred scrolls of Flakeus, the Input Provider, reveal to us, Nix flakes are a powerful way to manage dependencies and create reproducible builds. This guide will help you understand and use flakes effectively.

## What are Nix Flakes?

Flakes are an experimental feature in Nix that provides:

1. **Reproducibility**: Precise control over dependencies
2. **Standardization**: Consistent structure for Nix projects
3. **Composability**: Easy to combine and reuse
4. **Hermetic evaluation**: Evaluation depends only on the declared inputs

Flakes replace the old channels system with a more explicit and reproducible approach.

## Enabling Flakes

Flakes are still experimental, so you need to enable them:

```bash
# For a single command
nix --experimental-features "nix-command flakes" <command>

# Permanently (recommended)
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

On NixOS, add to your configuration.nix:
```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

## Anatomy of a Flake

A flake consists of two main files:

1. **flake.nix**: Defines inputs and outputs
2. **flake.lock**: Locks input versions for reproducibility

### Basic flake.nix Structure

```nix
{
  description = "A simple flake";

  inputs = {
    # Sources of dependencies
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    
    # Other flakes can be inputs
    home-manager = {
      url = "github:nix-community/home-manager";
      # Make home-manager use the same nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    # Outputs can include packages, NixOS modules, etc.
    packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;
    
    # Default package
    defaultPackage.x86_64-linux = self.packages.x86_64-linux.hello;
  };
}
```

## Common Flake Outputs

Flakes can produce various outputs:

### 1. Packages

```nix
outputs = { self, nixpkgs }: 
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system} = {
      hello = pkgs.hello;
      custom = pkgs.stdenv.mkDerivation {
        name = "custom-package";
        src = ./src;
        buildInputs = [ pkgs.zlib ];
        # ...
      };
      default = self.packages.${system}.hello;
    };
  };
```

### 2. NixOS Configurations

```nix
outputs = { self, nixpkgs }: {
  nixosConfigurations = {
    mySystem = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
    };
  };
};
```

### 3. Home Manager Configurations

```nix
outputs = { self, nixpkgs, home-manager }: {
  homeConfigurations = {
    "username" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [ ./home.nix ];
    };
  };
};
```

### 4. Development Shells

```nix
outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShells.${system} = {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [ nodejs yarn ];
      };
    };
  };
```

### 5. Library Functions

```nix
outputs = { self, nixpkgs }: {
  lib = {
    myFunction = arg: arg + 1;
  };
};
```

## Working with Flakes

### Creating a New Flake

```bash
# Initialize a new flake
mkdir my-flake
cd my-flake
nix flake init
```

### Updating Flake Inputs

```bash
# Update all inputs
nix flake update

# Update specific input
nix flake update nixpkgs
```

### Using Flake Outputs

```bash
# Build a package
nix build .#packageName

# Run a package
nix run .#packageName

# Enter a development shell
nix develop .#devShellName

# Apply a NixOS configuration
nixos-rebuild switch --flake .#hostname

# Apply a Home Manager configuration
home-manager switch --flake .#username
```

## Advanced Flake Techniques

### 1. Supporting Multiple Systems

```nix
{
  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in {
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system}; in
        {
          default = pkgs.hello;
        }
      );
    };
}
```

### 2. Overlays

```nix
{
  outputs = { self, nixpkgs }: {
    overlays.default = final: prev: {
      myPackage = final.callPackage ./myPackage.nix {};
    };
    
    packages = forAllSystems (system:
      let 
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
      in {
        default = pkgs.myPackage;
      }
    );
  };
}
```

### 3. Flake Templates

```nix
{
  outputs = { self, nixpkgs }: {
    templates = {
      python = {
        path = ./templates/python;
        description = "Python development environment";
      };
      default = self.templates.python;
    };
  };
}
```

Use with:
```bash
nix flake init -t github:username/flake-repo#python
```

### 4. Flake References

You can reference other flakes in various ways:

```
# GitHub
github:owner/repo/reference

# GitLab
gitlab:owner/repo/reference

# Direct URL
https://example.com/path/to/tarball.tar.gz

# Local path
path:/absolute/path
./relative/path

# Git repository
git+https://example.com/repo.git?ref=branch

# Flake in a subdirectory
github:owner/repo?dir=subdir
```

## Best Practices

1. **Lock Your Dependencies**: Always commit flake.lock to version control
2. **Use `follows`**: Avoid duplicate dependencies with `inputs.x.follows = "y"`
3. **Structure Your Outputs**: Use a consistent pattern for outputs
4. **Document Your Flake**: Include a good description and README
5. **Test Your Flake**: Ensure it works on all target systems
6. **Use Templates**: Create templates for common project types
7. **Keep It Simple**: Start with minimal flakes and expand as needed

## Troubleshooting

### Common Issues

1. **Flake Not Found**: Make sure the flake.nix is in the current directory
2. **Input Not Found**: Check your input URLs and network connection
3. **Evaluation Error**: Syntax or semantic error in your Nix code
4. **Build Failure**: Issue with the build process for a package

### Debugging Tips

1. Use `nix flake show` to see all outputs
2. Use `nix flake metadata` to see input information
3. Use `--show-trace` for more detailed error information

May the blessings of Flakeus, the Input Provider, guide your journey to reproducible builds and declarative configurations!
