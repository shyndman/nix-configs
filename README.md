# Nix Machine Configurations

This repository contains Nix configurations for managing packages and development environments across machines in a reproducible way. By the divine wisdom of Nixus, the Package Provider, this configuration will bring harmony to your development workflow!

## Repository Structure

```
.
├── flake.nix                # Main entry point for Nix configuration
├── home.nix                 # User-specific configuration using Home Manager
├── docs/                    # Documentation
│   ├── nix-concepts.md      # Core Nix concepts explained
│   ├── nix-flakes.md        # Guide to using Nix flakes
│   ├── home-manager-guide.md # Guide to using Home Manager
│   └── development-environments.md # Guide to development environments
├── dev-environments/        # Development environment templates
│   ├── python/              # Python development environment
│   ├── node/                # Node.js development environment
│   └── rust/                # Rust development environment
├── examples/                # Example projects
│   └── simple-project/      # Simple project with Nix packaging
└── scripts/                 # Utility scripts
    └── setup-nix.sh         # Setup script for Nix and Home Manager
```

## Getting Started

### Automatic Setup

The easiest way to get started is to use the provided setup script:

```bash
# Clone this repository
git clone https://github.com/yourusername/nix-machine-configs.git
cd nix-machine-configs

# Run the setup script
./scripts/setup-nix.sh
```

The script will:
1. Install Nix if not already installed
2. Enable flakes
3. Update configuration files with your username and home directory
4. Set up Git configuration
5. Initialize a Git repository if needed
6. Install Home Manager

### Manual Setup

If you prefer to set things up manually:

1. [Install Nix](https://nixos.org/download.html) if you haven't already
2. Enable [flakes](https://nixos.wiki/wiki/Flakes) by creating `~/.config/nix/nix.conf` with:
   ```
   experimental-features = nix-command flakes
   ```
3. Clone this repository
4. Edit the configuration files to match your system:
   - Replace `your-username` with your actual username in `flake.nix` and `home.nix`
   - Update the Git configuration in `home.nix` with your name and email

5. Apply the Home Manager configuration:
   ```bash
   # Build and activate the home configuration
   nix run home-manager/release-23.11 -- switch --flake .#your-username
   ```

## Adding a New User Profile

To add a configuration for another user:

1. Create a new home configuration file: `home-username.nix`
2. Add the new user to the `homeConfigurations` in `flake.nix`

## Updating

To update your packages with the latest versions:

```bash
# Update the flake inputs
nix flake update

# Apply the updated configuration
nix run home-manager/release-23.11 -- switch --flake .#your-username
```

## Development Environments

This repository includes development environments for various programming languages and project types. These environments provide isolated, reproducible development setups with all the necessary tools.

### Using the Included Development Environments

```bash
# Enter a development shell for a specific language
nix develop .#python  # Python environment
nix develop .#node    # Node.js environment
nix develop .#rust    # Rust environment

# Or run a command in that environment without entering a shell
nix develop .#node -c "npm start"
```

### Using the Environment Templates

You can also use the included templates for your own projects:

```bash
# Copy a template to your project
cp -r dev-environments/python /path/to/your/project
cd /path/to/your/project

# Enter the development environment
nix-shell
```

## Learning More

This repository includes comprehensive documentation to help you learn Nix:

- [Nix Concepts](docs/nix-concepts.md) - Core concepts of Nix
- [Nix Flakes](docs/nix-flakes.md) - Guide to using Nix flakes
- [Home Manager Guide](docs/home-manager-guide.md) - Guide to using Home Manager
- [Development Environments](docs/development-environments.md) - Guide to creating development environments
- [Docker with Nix](docs/docker-with-nix.md) - Guide to using Docker with Nix
- [Python with Nix](docs/python-with-nix.md) - Guide to using Python with Nix (including pyenv-like functionality)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

*"May your builds be pure and your dependencies reproducible." - Nixus, the Package Provider*
