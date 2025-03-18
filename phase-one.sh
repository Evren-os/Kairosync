#!/usr/bin/env bash

# phase-one.sh - First-time Hyprland dotfiles installation
# Author : Evrenos

# Color definitions
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to display status messages
print_status() {
    echo -e "${GREEN}[*]${NC} $1"
}

# Function to display warnings
print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Function to display errors and exit
print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Function to check file existence before operations
check_file_exists() {
    if [[ ! -f "$1" ]]; then
        print_error "File not found: $1"
    fi
}

# Function to check directory existence before operations
check_dir_exists() {
    if [[ ! -d "$1" ]]; then
        print_error "Directory not found: $1"
    fi
}

# Ask if proxychains should be used
read -p "Use proxychains for network operations? (y/n): " use_proxy
if [[ "$use_proxy" =~ ^[Yy]$ ]]; then
    PROXY="proxychains"
    print_status "Using proxychains for network operations"

    # Check if proxychains is installed
    if ! command -v proxychains &> /dev/null; then
        print_error "Proxychains is not installed. Please install it first."
    fi
else
    PROXY=""
    print_status "Not using proxychains"
fi

# Check if git is installed
if ! command -v git &> /dev/null; then
    print_error "Git is not installed. Please install it first."
fi

# Step 1: Remove any existing "HyDE" folder in $HOME
print_status "Removing any existing HyDE folder in $HOME"
rm -rf "$HOME/HyDE"

# Step 2: Clone HyDE repository
print_status "Cloning HyDE repository"
if [[ -n "$PROXY" ]]; then
    $PROXY git clone --depth 1 https://github.com/HyDE-Project/HyDE "$HOME/HyDE" || print_error "Failed to clone HyDE repository with proxychains"
else
    git clone --depth 1 https://github.com/HyDE-Project/HyDE "$HOME/HyDE" || print_error "Failed to clone HyDE repository"
fi

# Verify HyDE repository was cloned correctly
check_dir_exists "$HOME/HyDE"
check_dir_exists "$HOME/HyDE/Scripts"

# Step 3: Create ~/Clone directory if it doesn't exist
print_status "Creating Clone directory if it doesn't exist"
mkdir -p "$HOME/Clone"

# Step 4: Remove any existing "HyDEco" folder in ~/Clone
print_status "Removing any existing HyDEco folder in ~/Clone"
rm -rf "$HOME/Clone/HyDEco"

# Step 5: Clone HyDEco repository
print_status "Cloning HyDEco repository"
if [[ -n "$PROXY" ]]; then
    $PROXY git clone --depth 1 https://github.com/Evren-os/HyDEco "$HOME/Clone/HyDEco" || print_error "Failed to clone HyDEco repository with proxychains"
else
    git clone --depth 1 https://github.com/Evren-os/HyDEco "$HOME/Clone/HyDEco" || print_error "Failed to clone HyDEco repository"
fi

# Verify HyDEco repository was cloned correctly
check_dir_exists "$HOME/Clone/HyDEco"
check_dir_exists "$HOME/Clone/HyDEco/Scripts"

# Step 6: Check if required files exist in HyDEco
print_status "Verifying required files in HyDEco"
check_file_exists "$HOME/Clone/HyDEco/Scripts/sysfetch"
check_file_exists "$HOME/Clone/HyDEco/Scripts/post-hyde.sh"
check_file_exists "$HOME/Clone/HyDEco/Scripts/pkg_core.lst"
check_file_exists "$HOME/Clone/HyDEco/Scripts/pkg_extra.lst"

# Step 7: Remove pkg_core.lst and pkg_extra.lst from ~/HyDE/Scripts
print_status "Removing package lists from HyDE"
rm -f "$HOME/HyDE/Scripts/pkg_core.lst" "$HOME/HyDE/Scripts/pkg_extra.lst"

# Step 8: Copy files from ~/Clone/HyDEco/Scripts to ~/HyDE/Scripts
print_status "Copying script files from HyDEco to HyDE"
cp -f "$HOME/Clone/HyDEco/Scripts/sysfetch" \
      "$HOME/Clone/HyDEco/Scripts/post-hyde.sh" \
      "$HOME/Clone/HyDEco/Scripts/pkg_core.lst" \
      "$HOME/Clone/HyDEco/Scripts/pkg_extra.lst" \
      "$HOME/HyDE/Scripts/" || print_error "Failed to copy script files"

# Verify files were copied correctly
check_file_exists "$HOME/HyDE/Scripts/sysfetch"
check_file_exists "$HOME/HyDE/Scripts/post-hyde.sh"
check_file_exists "$HOME/HyDE/Scripts/pkg_core.lst"
check_file_exists "$HOME/HyDE/Scripts/pkg_extra.lst"

# Step 9: Verify install.sh exists and is executable
check_file_exists "$HOME/HyDE/install.sh"
if [[ ! -x "$HOME/HyDE/install.sh" ]]; then
    print_status "Making install.sh executable"
    chmod +x "$HOME/HyDE/install.sh" || print_error "Failed to make install.sh executable"
fi

# Step 10: Run install.sh with pkg_extra.lst
print_status "Running install.sh with pkg_extra.lst"
cd "$HOME/HyDE" || print_error "Failed to change directory to $HOME/HyDE"
if [[ -n "$PROXY" ]]; then
    $PROXY ./install.sh pkg_extra.lst || print_error "Failed to run install.sh with proxychains"
else
    ./install.sh pkg_extra.lst || print_error "Failed to run install.sh"
fi

print_status "Phase one complete. You can now run phase-two.sh"