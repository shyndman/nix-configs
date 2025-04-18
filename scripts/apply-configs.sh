
#!/usr/bin/env bash

# Script to apply both home and system configurations
# This script applies both the home-manager and system-manager configurations

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to print section headers
print_header() {
  echo -e "\n${BLUE}==== $1 ====${NC}"
}

# Function to print success messages
print_success() {
  echo -e "${GREEN}✓ $1${NC}"
}

# Function to print error messages
print_error() {
  echo -e "${RED}✗ $1${NC}"
}

# Function to print warning messages
print_warning() {
  echo -e "${YELLOW}! $1${NC}"
}

# Check for Nix
if ! command_exists nix; then
  print_error "Nix is not installed. Please install Nix first."
  echo "Visit https://nixos.org/download.html for installation instructions."
  exit 1
fi

# Check for Git (needed for flakes)
if ! command_exists git; then
  print_error "Git is not installed. Please install Git first."
  exit 1
fi

# Ensure we're in the project root directory (where flake.nix is located)
if [ ! -f "flake.nix" ]; then
  print_error "flake.nix not found. Please run this script from the project root directory."
  exit 1
fi

# Check if experimental features are enabled
if ! nix --version | grep -q "nix-command"; then
  print_warning "Nix experimental features might not be enabled."
  print_warning "Adding experimental features for this session..."
  export NIX_CONFIG="experimental-features = nix-command flakes"
fi

# Apply home configuration
apply_home_config() {
  print_header "Applying Home Manager Configuration for vantron"

  # First try with nix run if home-manager isn't in PATH
  if ! command_exists home-manager; then
    print_warning "home-manager not found in PATH. Using nix run..."
    if nix run home-manager/release-23.11 -- switch --flake .#vantron; then
      print_success "Home Manager configuration applied successfully using nix run!"

      # Suggest adding home-manager to PATH for future use
      print_warning "Consider running scripts/setup-nix.sh to add home-manager to your PATH"
      print_warning "Or add 'export PATH=$HOME/.nix-profile/bin:$PATH' to your shell profile"
      return 0
    else
      print_error "Failed to apply Home Manager configuration with nix run."
      print_error "Please ensure Home Manager is properly installed."
      print_error "Run scripts/setup-nix.sh to set up Nix and Home Manager."
      return 1
    fi
  fi

  # If home-manager is in PATH, use it directly
  print_success "Found home-manager in PATH, using it directly."
  if home-manager switch --flake .#vantron; then
    print_success "Home Manager configuration applied successfully!"
    return 0
  else
    print_error "Failed to apply Home Manager configuration with direct command."
    print_warning "Trying fallback method with nix run..."

    # Fallback to nix run if direct command failed
    if nix run home-manager/release-23.11 -- switch --flake .#vantron; then
      print_success "Home Manager configuration applied successfully using nix run fallback!"
      return 0
    else
      print_error "Failed to apply Home Manager configuration with all methods."
      print_error "Please ensure Home Manager is properly installed."
      print_error "Run scripts/setup-nix.sh to set up Nix and Home Manager."
      return 1
    fi
    return 0
  fi
}

# Apply system configuration
apply_system_config() {
  print_header "Applying System Manager Configuration for Pi 5"

  if ! command_exists system-manager; then
    print_warning "system-manager not found. Using nix run..."
    if nix run github:numtide/system-manager -- switch --flake .#pi5; then
      print_success "System Manager configuration applied successfully using nix run!"
      return 0
    else
      print_error "Failed to apply System Manager configuration with nix run."
      return 1
    fi
  fi

  if system-manager switch --flake .#pi5; then
    print_success "System Manager configuration applied successfully!"
  else
    print_error "Failed to apply System Manager configuration."
    return 1
  fi
}


# Verify configurations
verify_configs() {
  print_header "Verifying Configurations"

  # Verify home configuration
  echo "Checking Home Manager configuration..."
  if command_exists home-manager; then
    home-manager generations | head -n 1
  else
    nix run home-manager/release-23.11 -- generations | head -n 1
  fi

  # Verify system configuration
  echo "Checking System Manager configuration..."
  if command_exists system-manager; then
    system-manager generations | head -n 1
  else
    nix run github:numtide/system-manager -- generations | head -n 1
  fi

  # Check if zsh is configured correctly
  if [ -f "$HOME/.zshrc" ]; then
    echo "ZSH configuration found."
  else
    print_warning "ZSH configuration not found. Home Manager might not have applied correctly."
  fi

  # Check system services
  echo "Checking system services..."
  if systemctl is-active pi-monitor >/dev/null 2>&1; then
    print_success "pi-monitor service is active."
  else
    print_warning "pi-monitor service is not active. System Manager might not have applied correctly."
  fi

  if systemctl is-active van-monitor >/dev/null 2>&1; then
    print_success "van-monitor service is active."
  else
    print_warning "van-monitor service is not active. System Manager might not have applied correctly."
  fi
}

# Main execution
main() {
  print_header "Starting Configuration Application"

  # Check if running as root for system configuration
  if [[ $EUID -ne 0 ]]; then
    print_warning "Not running as root. System configuration may fail."
    print_warning "Consider running this script with sudo if you need to apply system configuration."
  fi

  # Apply home configuration
  if apply_home_config; then
    print_success "Home configuration applied successfully."
  else
    print_error "Failed to apply home configuration."
    exit 1
  fi

  # Apply system configuration
  if apply_system_config; then
    print_success "System configuration applied successfully."
  else
    print_error "Failed to apply system configuration."
    exit 1
  fi

  # Verify configurations
  verify_configs

  print_header "Configuration Application Complete"
  print_success "Both home and system configurations have been applied."
  print_success "Your Raspberry Pi 5 is now configured for use in the van!"
}

# Run the main function
main
