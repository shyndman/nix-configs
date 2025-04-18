#!/usr/bin/env bash

# Utility functions for remote execution on Raspberry Pi

# Function to ensure script is running on the correct host
# Usage: ensure_on_host "script_name" ["args"...]
# Example: ensure_on_host "$0" "$@"
ensure_on_host() {
    # Configuration
    local EXPECTED_HOSTNAME="pi"
    local REMOTE_HOSTNAME="pi.van"
    local REMOTE_USER="vantron"
    local REMOTE_PATH="~/nix-configs"
    
    # Get the script name and arguments
    local SCRIPT_NAME="$1"
    shift
    local SCRIPT_ARGS=("$@")
    
    # Get the current hostname
    local CURRENT_HOSTNAME=$(hostname)
    
    # Check if we're already on the expected host
    if [ "$CURRENT_HOSTNAME" = "$EXPECTED_HOSTNAME" ]; then
        # Already on the correct host, do nothing
        return 0
    fi
    
    # Not on the expected host, use SSH to run the script remotely
    echo "Not running on $EXPECTED_HOSTNAME, using SSH to run on $REMOTE_HOSTNAME..."
    
    # Construct the SSH command
    local SSH_CMD="cd $REMOTE_PATH && $SCRIPT_NAME"
    if [ ${#SCRIPT_ARGS[@]} -gt 0 ]; then
        # Add arguments if provided
        SSH_CMD="$SSH_CMD ${SCRIPT_ARGS[*]}"
    fi
    
    # Execute the command via SSH
    ssh "$REMOTE_USER@$REMOTE_HOSTNAME" "$SSH_CMD"
    local SSH_EXIT_CODE=$?
    
    # Exit with the same code as the remote command
    exit $SSH_EXIT_CODE
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if we're running as root
is_root() {
    [ "$(id -u)" -eq 0 ]
}

# Function to print colored output
print_colored() {
    local COLOR_CODE="$1"
    local MESSAGE="$2"
    echo -e "\033[${COLOR_CODE}m${MESSAGE}\033[0m"
}

# Define color codes
GREEN="32"
YELLOW="33"
RED="31"

# Function to print success message
print_success() {
    print_colored "$GREEN" "$1"
}

# Function to print warning message
print_warning() {
    print_colored "$YELLOW" "$1"
}

# Function to print error message
print_error() {
    print_colored "$RED" "$1"
}
