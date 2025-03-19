#!/usr/bin/env bash
# phase-one.sh - First-time Hyprland dotfiles installation
# Author : Evrenos

# Color definitions
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
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

# Function to display step messages
print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
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

# Function to prompt user for confirmation
confirm_step() {
    local prompt="$1"
    local response

    read -p "$prompt (y/n): " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

# Ask if proxychains should be used
if confirm_step "Use proxychains for network operations?"; then
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

# Step 1: Check if HyDE repository exists, clone if it doesn't
print_step "Step 1: Clone HyDE repository if needed"
if confirm_step "Proceed with HyDE repository check/clone?"; then
    if [[ -d "$HOME/HyDE" && -d "$HOME/HyDE/Scripts" ]]; then
        print_status "HyDE repository already exists, skipping clone"
    else
        if [[ -d "$HOME/HyDE" ]]; then
            print_warning "Incomplete HyDE directory found, removing and re-cloning"
            rm -rf "$HOME/HyDE"
        fi

        print_status "Cloning HyDE repository"
        if [[ -n "$PROXY" ]]; then
            $PROXY git clone --depth 1 https://github.com/HyDE-Project/HyDE "$HOME/HyDE" || print_error "Failed to clone HyDE repository with proxychains"
        else
            git clone --depth 1 https://github.com/HyDE-Project/HyDE "$HOME/HyDE" || print_error "Failed to clone HyDE repository"
        fi
    fi

    # Verify HyDE repository exists correctly
    check_dir_exists "$HOME/HyDE"
    check_dir_exists "$HOME/HyDE/Scripts"
else
    print_status "Skipping HyDE repository check/clone"
fi

# Step 2: Create ~/Clone directory if it doesn't exist
print_step "Step 2: Create Clone directory if needed"
if confirm_step "Proceed with creating Clone directory?"; then
    print_status "Creating Clone directory if it doesn't exist"
    mkdir -p "$HOME/Clone"
else
    print_status "Skipping Clone directory creation"
fi

# Step 3: Check if HyDEco repository exists, clone if it doesn't
print_step "Step 3: Clone HyDEco repository if needed"
if confirm_step "Proceed with HyDEco repository check/clone?"; then
    if [[ -d "$HOME/Clone/HyDEco" && -d "$HOME/Clone/HyDEco/Scripts" ]]; then
        print_status "HyDEco repository already exists, skipping clone"
    else
        if [[ -d "$HOME/Clone/HyDEco" ]]; then
            print_warning "Incomplete HyDEco directory found, removing and re-cloning"
            rm -rf "$HOME/Clone/HyDEco"
        fi

        print_status "Cloning HyDEco repository"
        if [[ -n "$PROXY" ]]; then
            $PROXY git clone --depth 1 https://github.com/Evren-os/HyDEco "$HOME/Clone/HyDEco" || print_error "Failed to clone HyDEco repository with proxychains"
        else
            git clone --depth 1 https://github.com/Evren-os/HyDEco "$HOME/Clone/HyDEco" || print_error "Failed to clone HyDEco repository"
        fi
    fi

    # Verify HyDEco repository exists correctly
    check_dir_exists "$HOME/Clone/HyDEco"
    check_dir_exists "$HOME/Clone/HyDEco/Scripts"
else
    print_status "Skipping HyDEco repository check/clone"
fi

# Step 4: Verify required files exist in HyDEco
print_step "Step 4: Verify required files in HyDEco"
if confirm_step "Proceed with file verification?"; then
    print_status "Verifying required files in HyDEco"
    check_file_exists "$HOME/Clone/HyDEco/Scripts/sysfetch"
    check_file_exists "$HOME/Clone/HyDEco/Scripts/post-hyde.sh"
    check_file_exists "$HOME/Clone/HyDEco/Scripts/pkg_core.lst"
    check_file_exists "$HOME/Clone/HyDEco/Scripts/pkg_extra.lst"
else
    print_status "Skipping file verification"
fi

# Step 5: Remove pkg_core.lst and pkg_extra.lst from ~/HyDE/Scripts
print_step "Step 5: Remove existing package lists from HyDE"
if confirm_step "Proceed with removing package lists from HyDE?"; then
    print_status "Removing package lists from HyDE"
    rm -f "$HOME/HyDE/Scripts/pkg_core.lst" "$HOME/HyDE/Scripts/pkg_extra.lst"
else
    print_status "Skipping package list removal"
fi

# Step 6: Copy files from ~/Clone/HyDEco/Scripts to ~/HyDE/Scripts
print_step "Step 6: Copy script files from HyDEco to HyDE"
if confirm_step "Proceed with copying script files?"; then
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
else
    print_status "Skipping script file copying"
fi

# Step 7: Verify install.sh exists and is executable
print_step "Step 7: Verify install.sh exists and is executable"
if confirm_step "Proceed with verifying install.sh?"; then
    check_file_exists "$HOME/HyDE/Scripts/install.sh"
    if [[ ! -x "$HOME/HyDE/Scripts/install.sh" ]]; then
        print_status "Making install.sh executable"
        chmod +x "$HOME/HyDE/Scripts/install.sh" || print_error "Failed to make install.sh executable"
    fi
else
    print_status "Skipping install.sh verification"
fi

# Step 8: Run install.sh with pkg_extra.lst
print_step "Step 8: Run install.sh with pkg_extra.lst"
if confirm_step "Proceed with running install.sh?"; then
    print_status "Running install.sh with pkg_extra.lst"
    cd "$HOME/HyDE/Scripts" || print_error "Failed to change directory to $HOME/HyDE/Scripts"
    if [[ -n "$PROXY" ]]; then
        $PROXY ./install.sh pkg_extra.lst || print_error "Failed to run install.sh with proxychains"
    else
        ./install.sh pkg_extra.lst || print_error "Failed to run install.sh"
    fi
else
    print_status "Skipping install.sh execution"
fi

print_status "Phase one complete. You can now run phase-two.sh"