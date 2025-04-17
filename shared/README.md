# Shared Nix Modules

This directory contains Nix modules that are shared between home-manager and system-manager configurations.

## Usage

Modules in this directory can be imported by both home and system configurations:

```nix
# From a home configuration
imports = [ ../shared/some-module.nix ];

# From a system configuration
imports = [ ../shared/some-module.nix ];
```

## Available Modules

Currently, this directory is prepared for future shared modules. As the project evolves, common functionality between home and system configurations should be placed here.

Potential candidates for shared modules:
- Network configuration
- Hardware-specific settings
- Common package sets
- Shared environment variables
