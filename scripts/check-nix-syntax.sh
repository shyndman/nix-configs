#!/usr/bin/env bash

# check-nix-syntax.sh
# A script to check Nix configuration files for syntax errors

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print usage information
function print_usage() {
  echo -e "${BLUE}Usage:${NC}"
  echo -e "  $0 [options] [file1.nix file2.nix ...]"
  echo
  echo -e "${BLUE}Options:${NC}"
  echo -e "  -a, --all         Check all .nix files in the repository"
  echo -e "  -b, --build       Also run home-manager build (dry-run) to check entire configuration"
  echo -e "  -h, --help        Show this help message"
  echo
  echo -e "${BLUE}Examples:${NC}"
  echo -e "  $0 home.nix                   # Check a single file"
  echo -e "  $0 home.nix modules/git.nix   # Check multiple specific files"
  echo -e "  $0 --all                      # Check all .nix files"
  echo -e "  $0 --all --build              # Check all files and run home-manager build"
}

# Check a single Nix file for syntax errors
function check_file() {
  local file="$1"
  
  if [[ ! -f "$file" ]]; then
    echo -e "${RED}Error: File not found: $file${NC}"
    return 1
  fi
  
  echo -e "${BLUE}Checking syntax for:${NC} $file"
  
  # Use nix-instantiate to check syntax
  if nix-instantiate --parse "$file" > /dev/null 2>&1; then
    echo -e "  ${GREEN}✓ Syntax OK${NC}"
    return 0
  else
    echo -e "  ${RED}✗ Syntax Error${NC}"
    echo -e "${YELLOW}Details:${NC}"
    nix-instantiate --parse "$file" 2>&1 | sed 's/^/  /'
    return 1
  fi
}

# Check all Nix files in the repository
function check_all_files() {
  local files=$(find . -name "*.nix" -type f | sort)
  local errors=0
  local total=0
  
  echo -e "${BLUE}Checking all Nix files in repository...${NC}"
  
  for file in $files; do
    ((total++))
    if ! check_file "$file"; then
      ((errors++))
    fi
    echo
  done
  
  echo -e "${BLUE}Summary:${NC} Checked $total files, found $errors with errors"
  
  if [[ $errors -eq 0 ]]; then
    echo -e "${GREEN}All files passed syntax check!${NC}"
    return 0
  else
    echo -e "${RED}Found $errors files with syntax errors.${NC}"
    return 1
  fi
}

# Run home-manager build to check the entire configuration
function check_build() {
  echo -e "\n${BLUE}Running home-manager build (dry-run)...${NC}"
  
  # Get the username from flake.nix or use the current user
  local username=$(grep -o '"[^"]*"' flake.nix | grep -v "github:" | head -1 | tr -d '"' || whoami)
  
  if command -v home-manager &> /dev/null; then
    if home-manager build --flake ".#$username" --dry-run; then
      echo -e "${GREEN}✓ Configuration builds successfully!${NC}"
      return 0
    else
      echo -e "${RED}✗ Configuration build failed${NC}"
      return 1
    fi
  else
    echo -e "${YELLOW}Warning: home-manager command not found. Skipping build check.${NC}"
    echo -e "Install home-manager with: nix-shell '<home-manager>' -A install"
    return 0
  fi
}

# Main function
function main() {
  local check_all=false
  local do_build=false
  local files=()
  local exit_code=0
  
  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -a|--all)
        check_all=true
        shift
        ;;
      -b|--build)
        do_build=true
        shift
        ;;
      -h|--help)
        print_usage
        exit 0
        ;;
      *)
        if [[ "$1" == -* ]]; then
          echo -e "${RED}Unknown option: $1${NC}"
          print_usage
          exit 1
        fi
        files+=("$1")
        shift
        ;;
    esac
  done
  
  # Check if we should check all files
  if [[ "$check_all" = true ]]; then
    if ! check_all_files; then
      exit_code=1
    fi
  elif [[ ${#files[@]} -gt 0 ]]; then
    # Check specific files
    local errors=0
    for file in "${files[@]}"; do
      if ! check_file "$file"; then
        ((errors++))
      fi
      echo
    done
    
    if [[ $errors -gt 0 ]]; then
      exit_code=1
    fi
  else
    # No files specified
    echo -e "${YELLOW}No files specified. Use --all to check all files or specify individual files.${NC}"
    print_usage
    exit 1
  fi
  
  # Run build check if requested
  if [[ "$do_build" = true ]]; then
    if ! check_build; then
      exit_code=1
    fi
  fi
  
  exit $exit_code
}

# Run the main function
main "$@"
