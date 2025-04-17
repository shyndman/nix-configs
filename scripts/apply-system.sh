#!/usr/bin/env bash

# Script to apply system configuration for Raspberry Pi 5
# This script applies the system-level configuration using system-manager

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Error: This script must be run as root${NC}" 
   exit 1
fi

# Check if system-manager is installed
if ! command -v system-manager &> /dev/null; then
    echo -e "${YELLOW}system-manager not found. Installing...${NC}"
    nix-env -iA nixpkgs.system-manager
fi

# Apply the system configuration
echo -e "${GREEN}Applying system configuration for Raspberry Pi 5...${NC}"
system-manager switch --flake .#pi5

# Verify the configuration was applied
if [ $? -eq 0 ]; then
    echo -e "${GREEN}System configuration successfully applied!${NC}"
    
    # Display system information
    echo -e "${YELLOW}System Information:${NC}"
    uname -a
    echo ""
    
    # Display running services
    echo -e "${YELLOW}Running Services:${NC}"
    systemctl list-units --type=service --state=running | grep -E 'pi-monitor|van-monitor|mosquitto|gpsd'
    echo ""
    
    # Display network information
    echo -e "${YELLOW}Network Information:${NC}"
    ip addr show | grep -E 'inet '
    echo ""
    
    echo -e "${GREEN}System is ready for use in the van!${NC}"
else
    echo -e "${RED}Failed to apply system configuration. Please check the logs.${NC}"
    exit 1
fi
