# Development Environments with Nix

As the prophet Devus, the Environment Creator, teaches us, one of the most powerful uses of Nix is creating reproducible development environments. This guide will show you how to use Nix for your development workflows.

## Why Use Nix for Development?

1. **Reproducibility**: Everyone on your team gets the exact same environment
2. **Isolation**: Dependencies don't conflict with your system packages
3. **Declarative**: Your environment is defined in code and can be version controlled
4. **Cross-platform**: Works the same on Linux and macOS

## Methods for Creating Development Environments

### 1. Using `shell.nix`

The traditional way to define a development environment:

```nix
# shell.nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    nodejs
    yarn
    python3
  ];
  
  shellHook = ''
    echo "Development environment activated!"
  '';
}
```

Use it with:
```bash
nix-shell
```

### 2. Using Flakes (Recommended)

The modern way with better reproducibility:

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs
            yarn
            python3
          ];
          
          shellHook = ''
            echo "Development environment activated!"
          '';
        };
      }
    );
}
```

Use it with:
```bash
nix develop
```

### 3. Using `direnv` with Nix

For automatic environment switching when entering a directory:

1. Install direnv and nix-direnv through Home Manager:
```nix
programs.direnv = {
  enable = true;
  nix-direnv.enable = true;
};
```

2. Create a `.envrc` file in your project:
```
use flake
```

3. Allow the direnv configuration:
```bash
direnv allow
```

Now your environment will automatically activate when you enter the directory!

## Common Development Environment Patterns

### Language-Specific Environments

#### Python

```nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    (python3.withPackages (ps: with ps; [
      numpy
      pandas
      matplotlib
      pytest
    ]))
    poetry
  ];
}
```

#### Node.js

```nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    nodejs
    yarn
    nodePackages.typescript
    nodePackages.eslint
  ];
}
```

#### Rust

```nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    rustc
    cargo
    rustfmt
    clippy
    rust-analyzer
  ];
}
```

### Multi-Language Projects

For projects that use multiple languages:

```nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Backend
    python3
    poetry
    
    # Frontend
    nodejs
    yarn
    
    # Database
    postgresql
    
    # Tools
    docker
    docker-compose
  ];
  
  shellHook = ''
    export DATABASE_URL="postgresql://postgres:postgres@localhost:5432/mydb"
    
    # Start services if needed
    if [ "$(docker ps -q -f name=db)" = "" ]; then
      echo "Starting database container..."
      docker-compose up -d db
    fi
  '';
}
```

## Advanced Techniques

### 1. Per-Project Package Overrides

Sometimes you need a specific version of a package:

```nix
{ pkgs ? import <nixpkgs> {} }:

let
  # Override nodejs to use a specific version
  nodejs = pkgs.nodejs-16_x;
in
pkgs.mkShell {
  buildInputs = [
    nodejs
    pkgs.yarn
  ];
}
```

### 2. Multiple Development Environments

For different aspects of your project:

```nix
# flake.nix
{
  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [ nodejs yarn ];
          };
          
          backend = pkgs.mkShell {
            buildInputs = with pkgs; [ python3 poetry ];
          };
          
          frontend = pkgs.mkShell {
            buildInputs = with pkgs; [ nodejs yarn ];
          };
        }
      );
    };
}
```

Use them with:
```bash
nix develop                  # Default environment
nix develop .#backend        # Backend environment
nix develop .#frontend       # Frontend environment
```

### 3. Integration with IDE Tools

For VS Code, create a `.vscode/settings.json`:

```json
{
  "nixEnvSelector.nixFile": "${workspaceRoot}/shell.nix",
  "terminal.integrated.defaultProfile.linux": "nix-shell"
}
```

## Best Practices

1. **Keep it Simple**: Start with minimal environments and add dependencies as needed
2. **Document Requirements**: Comment why each dependency is needed
3. **Use Flakes**: For better reproducibility and standardized structure
4. **Use direnv**: For automatic environment switching
5. **Include Dev Tools**: Add formatters, linters, and language servers
6. **Pin Versions**: Especially for critical dependencies
7. **Test on CI**: Ensure your environment works for everyone

May the blessings of Devus, the Environment Creator, be upon your development workflows!
