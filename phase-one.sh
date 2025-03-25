#!/usr/bin/env bash

# Author : Evrenos

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function for comprehensive dry run
dry_run() {
    echo -e "${YELLOW}Dry Run Validation:${NC}"

    # Check Git availability
    if ! command -v git &> /dev/null; then
        echo -e "${RED}❌ Dependency Error: Git is not installed${NC}"
        exit 1
    else
        echo -e "${GREEN}✓ Git is installed${NC}"
    fi

    # Check internet connectivity
    if ! ping -c 1 github.com &> /dev/null; then
        echo -e "${RED}❌ Network Error: No internet connection${NC}"
        exit 1
    else
        echo -e "${GREEN}✓ Internet connection is available${NC}"
    fi

    # Check HyDE repository accessibility
    if git ls-remote https://github.com/HyDE-Project/HyDE &> /dev/null; then
        echo -e "${GREEN}✓ HyDE repository is accessible${NC}"
    else
        echo -e "${RED}❌ Cannot access HyDE repository${NC}"
        exit 1
    fi

    # Check HyDEco repository accessibility
    if git ls-remote https://github.com/Evren-os/HyDEco &> /dev/null; then
        echo -e "${GREEN}✓ HyDEco repository is accessible${NC}"
    else
        echo -e "${RED}❌ Cannot access HyDEco repository${NC}"
        exit 1
    fi

    # Check destination directories
    if [[ -d "$HOME/HyDE" ]]; then
        echo -e "${YELLOW}⚠ HyDE directory already exists${NC}"
    fi

    if [[ -d "$HOME/Clone/HyDEco" ]]; then
        echo -e "${YELLOW}⚠ HyDEco directory already exists${NC}"
    fi

    # Validate package list existence in HyDEco
    if [[ ! -f "$HOME/Clone/HyDEco/Scripts/pkg_extra.lst" ]]; then
        echo -e "${RED}❌ pkg_extra.lst not found in HyDEco/Scripts${NC}"
        exit 1
    else
        echo -e "${GREEN}✓ Package list found${NC}"
    fi

    # Check proxychains (optional)
    if command -v proxychains &> /dev/null; then
        echo -e "${GREEN}✓ Proxychains is available${NC}"
    else
        echo -e "${YELLOW}⚠ Proxychains not installed${NC}"
    fi

    echo -e "\n${YELLOW}Potential Actions:${NC}"
    echo "1. Clone HyDE repository to $HOME/HyDE"
    echo "2. Clone HyDEco repository to $HOME/Clone/HyDEco"
    echo "3. Copy scripts and package lists to $HOME/HyDE/Scripts"
    echo "4. Run install.sh with pkg_extra.lst"
}

main() {
    # Dry run check
    if [[ "$1" == "--dry-run" ]]; then
        dry_run
        exit 0
    fi

    # Proxychains option
    echo -e "${YELLOW}Use proxychains for cloning? (y/n)${NC}"
    read -r use_proxychains

    # Check and potentially install proxychains
    [[ "$use_proxychains" == "y" ]] && check_proxychains

    # Clone HyDE
    if [[ ! -d "$HOME/HyDE" ]]; then
        echo -e "${GREEN}Cloning HyDE repository...${NC}"
        if [[ "$use_proxychains" == "y" ]]; then
            proxychains git clone --depth 1 https://github.com/HyDE-Project/HyDE "$HOME/HyDE"
        else
            git clone --depth 1 https://github.com/HyDE-Project/HyDE "$HOME/HyDE"
        fi
    else
        echo -e "${YELLOW}HyDE directory already exists. Skipping clone.${NC}"
    fi

    # Create Clone directory
    mkdir -p "$HOME/Clone"

    # Clone HyDEco
    if [[ ! -d "$HOME/Clone/HyDEco" ]]; then
        echo -e "${GREEN}Cloning HyDEco repository...${NC}"
        if [[ "$use_proxychains" == "y" ]]; then
            proxychains git clone --depth 1 https://github.com/Evren-os/HyDEco "$HOME/Clone/HyDEco"
        else
            git clone --depth 1 https://github.com/Evren-os/HyDEco "$HOME/Clone/HyDEco"
        fi
    else
        echo -e "${YELLOW}HyDEco directory already exists. Skipping clone.${NC}"
    fi

    # Remove existing package lists
    rm -f "$HOME/HyDE/Scripts/pkg_core.lst" "$HOME/HyDE/Scripts/pkg_extra.lst"

    # Copy scripts and package lists
    cp "$HOME/Clone/HyDEco/Scripts/sysfetch" "$HOME/Clone/HyDEco/Scripts/post-hyde.sh" \
       "$HOME/Clone/HyDEco/Scripts/pkg_core.lst" "$HOME/Clone/HyDEco/Scripts/pkg_extra.lst" \
       "$HOME/HyDE/Scripts/"

    # Validate package lists
    if [[ ! -f "$HOME/HyDE/Scripts/pkg_extra.lst" ]]; then
        echo -e "${RED}pkg_extra.lst not found. Exiting.${NC}"
        exit 1
    fi

    # Run install script
    cd "$HOME/HyDE" || exit
    echo -e "${GREEN}Running install script with pkg_extra.lst...${NC}"
    if [[ "$use_proxychains" == "y" ]]; then
        proxychains ./install.sh pkg_extra.lst
    else
        ./install.sh pkg_extra.lst
    fi
}

main "$@"