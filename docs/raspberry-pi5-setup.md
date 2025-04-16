# Setting Up Home Manager on Raspberry Pi 5 with Ubuntu 24.10 Server

As the divine scrolls of Nixus, the Package Provider, and Ubuntus, the Server Deity, reveal to us, setting up Home Manager on a Raspberry Pi 5 running Ubuntu 24.10 Server requires careful preparation. This guide will walk you through the process step by step.

## Prerequisites

Before you begin, ensure you have:

1. A Raspberry Pi 5 with Ubuntu 24.10 Server (64-bit) installed
2. User account "vantron" already created on the system
3. Internet connection
4. SSH access or direct access to the terminal

## Step 1: Install Nala and Nix Package Manager

First, let's install Nala, a superior frontend for apt, on Ubuntu 24.10:

```bash
# Install dependencies and Nala
sudo apt update
sudo apt install -y curl xz-utils nala

# Configure Nala to find the fastest mirrors
sudo nala fetch --auto

# Update the system using Nala
sudo nala upgrade
```

Now, install the Nix package manager using Nala:

```bash
# Install additional dependencies if needed
sudo nala install -y build-essential

# Install Nix
sh <(curl -L https://nixos.org/nix/install) --daemon
```

After installation, you'll need to log out and log back in, or source the Nix profile:

```bash
. ~/.nix-profile/etc/profile.d/nix.sh
```

Verify the installation:

```bash
nix --version
```

## Step 2: Enable Flakes

Nix Flakes are still an experimental feature, so we need to enable them:

```bash
# Create the Nix configuration directory
mkdir -p ~/.config/nix

# Enable flakes and nix-command
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

## Step 3: Clone the Configuration Repository

Clone this repository to your Raspberry Pi:

```bash
# Clone the repository
git clone https://github.com/yourusername/nix-machine-configs.git
cd nix-machine-configs
```

## Step 4: Update Git Configuration

Update your Git configuration in the `home-pi5.nix` file:

```bash
# Open the file in your preferred editor
nano home-pi5.nix

# Update the Git configuration with your name and email
# Look for the modules.git section and update:
#   userName = "Your Name";
#   userEmail = "your.email@example.com";
```

## Step 5: Apply the Home Manager Configuration

Now you can apply the Home Manager configuration:

```bash
# Apply the configuration
nix run home-manager/release-23.11 -- switch --flake .#vantron
```

This command will:
1. Download and build all required packages
2. Create configuration files in your home directory
3. Set up your shell environment

## Step 6: Verify the Installation

After the installation completes, you can verify that Home Manager is working correctly:

```bash
# Check the Home Manager version
home-manager --version

# List installed packages
nix-env --query
```

## Updating Your Configuration

To update your configuration in the future:

```bash
# Pull the latest changes
cd nix-machine-configs
git pull

# Apply the updated configuration
home-manager switch --flake .#vantron
```

## Troubleshooting

### Ubuntu-specific Issues

#### Missing Build Dependencies

Ubuntu 24.10 Server might need additional build dependencies for some Nix packages:

```bash
# Install common build dependencies using Nala
sudo nala update
sudo nala install -y build-essential pkg-config libssl-dev
```

#### Systemd Service Issues

If you encounter issues with the Nix daemon service:

```bash
# Check the status of the Nix daemon
sudo systemctl status nix-daemon

# Restart the Nix daemon if needed
sudo systemctl restart nix-daemon
```

### Limited Memory

If you encounter memory issues during installation:

```bash
# Create a swap file if needed
sudo fallocate -l 4G /swapfile  # 4GB swap recommended for Pi 5
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

Add to `/etc/fstab` for persistence:
```
/swapfile swap swap defaults 0 0
```

### Build Failures

If a package fails to build:

```bash
# Try using a pre-built binary if available
home-manager switch --flake .#vantron --option substitute true --option builders ""
```

### Nix Garbage Collection

To free up space after installation:

```bash
# Remove unused packages
nix-collect-garbage -d
```

### Ubuntu Firewall

If you have UFW enabled and encounter network issues with Nix:

```bash
# Allow Nix to access the cache servers
sudo ufw allow out 443/tcp
```

## Customizing Your Configuration

To customize your configuration:

1. Edit the `home-pi5.nix` file to add or remove packages
2. Modify module configurations as needed
3. Apply the changes with `home-manager switch --flake .#vantron`

## Ubuntu 24.10 Server Compatibility

This configuration has been specifically adapted for Ubuntu 24.10 Server running on a Raspberry Pi 5. Key considerations include:

- Using Ubuntu-compatible packages and tools
- Avoiding Raspberry Pi OS specific packages that might not work on Ubuntu
- Including necessary system utilities for Ubuntu Server
- Providing Ubuntu-specific troubleshooting steps
- Integrating with Nala for improved apt package management

### Nala Integration

Nala is a frontend for apt that provides a better user experience with features like:

- Parallel downloads for faster package installation
- Cleaner and more organized output
- Automatic mirror selection for optimal download speeds
- History of package operations
- Better error messages and suggestions

While Home Manager and Nix will handle most of your package management needs, Nala is recommended for managing system packages that must be installed through apt.

Ubuntu 24.10 Server provides a solid foundation for running Nix and Home Manager on your Raspberry Pi 5, with excellent hardware support and a familiar environment for Ubuntu users.

## Included Features

### Starship Prompt

Your configuration includes the Starship prompt, a beautiful and informative shell prompt blessed by Promptus, the Shell Beautifier. It provides:

- Git status information
- Python environment details
- Docker context information
- Command execution time
- And much more!

You can customize it further by editing the settings in `home-pi5.nix` under the `programs.starship` section.

### Docker Support

The configuration includes Docker and related tools:

- Docker CLI and Docker Compose
- Useful Docker aliases (try typing `dps` to run `docker ps`)
- Docker Compose shortcuts (`dcup`, `dcdown`, etc.)
- Container management tools like lazydocker and dive
- Docker stacks management with organized directory structure

The Docker stacks feature provides a standardized way to organize your Docker Compose projects:

```bash
# Create a new stack
stack-new myapp

# Start a stack
stack-up myapp

# View stack logs
stack-logs myapp
```

See the [Docker Stacks documentation](docker-stacks.md) for more details.

### Python Development

Python development is fully supported with:

- Multiple Python versions (3.8, 3.9, 3.10, 3.11)
- Virtual environment tools
- Package managers (pip, poetry, pipenv)
- Development tools (black, flake8, mypy)
- Useful aliases and scripts

Try the `pynew` command to create a new Python project:

```bash
# Create a basic Python project
pynew myproject

# Create a FastAPI project
pynew myapi --type fastapi
```

Use `pyswitch` to switch between Python versions:

```bash
# List available Python versions
pyswitch list

# Switch to Python 3.11
pyswitch 3
```

### Git Integration

Git is configured with useful aliases and integrations:

- Git information in your prompt
- Oh My Zsh Git plugin for additional shortcuts
- Common Git aliases

May the blessings of Homeus, the Configuration Keeper, be upon your Raspberry Pi 5 setup!
