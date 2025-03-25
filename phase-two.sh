#!/usr/bin/env bash

# Author : Evrenos

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function for comprehensive dry run
dry_run() {
    echo -e "${YELLOW}Dry Run Validation:${NC}"

    # Check source repository exists
    if [[ ! -d "$HOME/Clone/HyDEco" ]]; then
        echo -e "${RED}❌ HyDEco repository not found${NC}"
        exit 1
    else
        echo -e "${GREEN}✓ HyDEco repository found${NC}"
    fi

    # Check HyDE scripts directory
    if [[ ! -d "$HOME/HyDE/Scripts" ]]; then
        echo -e "${RED}❌ HyDE Scripts directory not found${NC}"
        exit 1
    else
        echo -e "${GREEN}✓ HyDE Scripts directory found${NC}"
    fi

    # Validate configuration files exist
    config_folders=("alacritty" "cava" "fastfetch" "ghostty" "mpv" "qimgv")
    config_files=("codium-flags.conf" "starship.toml" "kdeglobals")
    hypr_files=("themes/theme.conf" "themes/wallbash.conf" "keybindings.conf" "monitors.conf" "windowrules.conf")

    echo -e "\n${YELLOW}Checking Configuration Files:${NC}"

    # Check config folders
    for folder in "${config_folders[@]}"; do
        if [[ ! -d "$HOME/Clone/HyDEco/Configs/.config/$folder" ]]; then
            echo -e "${RED}❌ $folder configuration not found${NC}"
        else
            echo -e "${GREEN}✓ $folder configuration exists${NC}"
        fi
    done

    # Check config files
    for file in "${config_files[@]}"; do
        if [[ ! -f "$HOME/Clone/HyDEco/Configs/.config/$file" ]]; then
            echo -e "${RED}❌ $file not found${NC}"
        else
            echo -e "${GREEN}✓ $file exists${NC}"
        fi
    done

    # Check Hyprland configuration files
    for file in "${hypr_files[@]}"; do
        if [[ ! -f "$HOME/Clone/HyDEco/Configs/.config/hypr/$file" ]]; then
            echo -e "${RED}❌ Hyprland $file not found${NC}"
        else
            echo -e "${GREEN}✓ Hyprland $file exists${NC}"
        fi
    done

    # Check post-hyde.sh script
    if [[ ! -f "$HOME/Clone/HyDEco/Scripts/post-hyde.sh" ]]; then
        echo -e "${RED}❌ post-hyde.sh not found${NC}"
        exit 1
    else
        echo -e "${GREEN}✓ post-hyde.sh exists${NC}"
    fi

    # Check .zshrc
    if [[ ! -f "$HOME/Clone/HyDEco/Configs/.zshrc" ]]; then
        echo -e "${RED}❌ .zshrc not found${NC}"
        exit 1
    else
        echo -e "${GREEN}✓ .zshrc exists${NC}"
    fi

    # Check proxychains (optional)
    if command -v proxychains &> /dev/null; then
        echo -e "${GREEN}✓ Proxychains is available${NC}"
    else
        echo -e "${YELLOW}⚠ Proxychains not installed${NC}"
    fi

    echo -e "\n${YELLOW}Potential Actions:${NC}"
    echo "1. Remove existing config files in ~/.config"
    echo "2. Copy new configuration files from HyDEco"
    echo "3. Update Hyprland configuration files"
    echo "4. Make post-hyde.sh executable"
    echo "5. Run post-hyde.sh script"
    echo "6. Replace .zshrc"
}

main() {
    # Dry run check
    if [[ "$1" == "--dry-run" ]]; then
        dry_run
        exit 0
    fi

    # Proxychains option
    echo -e "${YELLOW}Use proxychains? (y/n)${NC}"
    read -r use_proxychains

    # Check and potentially install proxychains
    [[ "$use_proxychains" == "y" ]] && check_proxychains

    # Config folders to copy
    config_folders=("alacritty" "cava" "fastfetch" "ghostty" "mpv" "qimgv")
    config_files=("codium-flags.conf" "starship.toml" "kdeglobals")

    # Remove specific config folders and files
    for folder in "${config_folders[@]}"; do
        rm -rf "$HOME/.config/$folder"
    done
    for file in "${config_files[@]}"; do
        rm -f "$HOME/.config/$file"
    done

    # Copy config folders and files
    for folder in "${config_folders[@]}"; do
        cp -r "$HOME/Clone/HyDEco/Configs/.config/$folder" "$HOME/.config/"
    done
    for file in "${config_files[@]}"; do
        cp "$HOME/Clone/HyDEco/Configs/.config/$file" "$HOME/.config/"
    done

    # Hyprland configuration
    rm -f ~/.config/hypr/themes/theme.conf ~/.config/hypr/themes/wallbash.conf \
          ~/.config/hypr/keybindings.conf ~/.config/hypr/monitors.conf \
          ~/.config/hypr/windowrules.conf

    cp "$HOME/Clone/HyDEco/Configs/.config/hypr/themes/theme.conf" ~/.config/hypr/themes/
    cp "$HOME/Clone/HyDEco/Configs/.config/hypr/themes/wallbash.conf" ~/.config/hypr/themes/
    cp "$HOME/Clone/HyDEco/Configs/.config/hypr/keybindings.conf" ~/.config/hypr/
    cp "$HOME/Clone/HyDEco/Configs/.config/hypr/monitors.conf" ~/.config/hypr/
    cp "$HOME/Clone/HyDEco/Configs/.config/hypr/windowrules.conf" ~/.config/hypr/

    # Make post-hyde.sh executable
    chmod +x "$HOME/HyDE/Scripts/post-hyde.sh"

    # Run post-hyde script
    cd "$HOME/HyDE/Scripts" || exit
    echo -e "${GREEN}Running post-hyde script...${NC}"
    if [[ "$use_proxychains" == "y" ]]; then
        proxychains ./post-hyde.sh
    else
        ./post-hyde.sh
    fi

    # Remove old shell config files
    rm -f ~/.hyde.zshrc ~/.zshenv ~/.zshrc

    # Copy new .zshrc
    cp "$HOME/Clone/HyDEco/Configs/.zshrc" ~/

    # Final message
    echo -e "${GREEN}Configuration complete. Please log out for all changes to take effect.${NC}"
}

main "$@"