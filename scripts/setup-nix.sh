
#!/usr/bin/env bash

# Setup script for Nix and Home Manager
# By the divine guidance of Nixus, the Package Provider

set -e

echo "🔄 Setting up Nix and Home Manager..."

# Check if Nix is already installed
if command -v nix >/dev/null 2>&1; then
    echo "✅ Nix is already installed."
else
    echo "🔄 Installing Nix..."
    curl -L https://nixos.org/nix/install | sh
    
    # Source nix
    if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then
        . ~/.nix-profile/etc/profile.d/nix.sh
    fi
fi

# Enable flakes
echo "🔄 Enabling flakes..."
mkdir -p ~/.config/nix
if ! grep -q "experimental-features" ~/.config/nix/nix.conf 2>/dev/null; then
    echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
    echo "✅ Flakes enabled."
else
    echo "✅ Flakes already enabled."
fi

# Ensure Home Manager is installed and in PATH
echo "🔄 Setting up Home Manager..."
if ! command -v home-manager >/dev/null 2>&1; then
    echo "🔄 Installing Home Manager..."
    nix run home-manager/release-23.11 -- init --switch
    
    # Add Home Manager to PATH
    if ! grep -q "home-manager" ~/.profile; then
        echo "export PATH=\$HOME/.nix-profile/bin:\$PATH" >> ~/.profile
        echo "✅ Added Home Manager to PATH in ~/.profile"
    fi
    source ~/.profile
else
    echo "✅ Home Manager is already installed."
fi

# Get username
USERNAME=$(whoami)
HOMEDIR=$(eval echo ~$USERNAME)

# Update flake.nix with correct username
echo "🔄 Updating flake.nix with your username..."
sed -i "s/your-username/$USERNAME/g" flake.nix
echo "✅ Updated flake.nix"

# Update home.nix with correct username and home directory
echo "🔄 Updating home.nix with your username and home directory..."
sed -i "s/your-username/$USERNAME/g" home.nix
sed -i "s|/home/your-username|$HOMEDIR|g" home.nix
echo "✅ Updated home.nix"

# Ask for Git configuration
echo "🔄 Setting up Git configuration..."
read -p "Enter your Git name: " GIT_NAME
read -p "Enter your Git email: " GIT_EMAIL

sed -i "s/Your Name/$GIT_NAME/g" home.nix
sed -i "s/your.email@example.com/$GIT_EMAIL/g" home.nix
echo "✅ Updated Git configuration."

# Initialize git repository if not already initialized
if [ ! -d .git ]; then
    echo "🔄 Initializing Git repository..."
    git init
    git add .
    git commit -m "Initial commit"
    echo "✅ Git repository initialized."
fi

echo "🔄 Installing Home Manager..."
nix run home-manager/release-23.11 -- init --switch

echo "
🎉 Setup complete! 🎉

Your Nix configuration is now ready. Here are some useful commands:

- Update your Home Manager configuration:
  home-manager switch

- Enter a development environment:
  cd examples/simple-project
  nix develop

- Build and run the example project:
  cd examples/simple-project
  nix build
  nix run

- Learn more about Nix concepts:
  less docs/nix-concepts.md

May the blessings of Nixus be upon your configurations!
"

