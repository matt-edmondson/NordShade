#!/bin/bash
# NordShade for Brave Browser - Installation Script

# Define colors for output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

install_brave_theme() {
    local THEME_ROOT="${1:-$(dirname "$0")}"
    local AUTO_APPLY="$2"
    
    echo -e "${YELLOW}Installing NordShade for Brave Browser...${NC}"
    
    # Determine OS and set paths
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        BRAVE_PATH="/Applications/Brave Browser.app"
        THEME_PATH="$HOME/Documents/NordShade/Brave"
    else
        # Linux
        BRAVE_PATH="$HOME/.config/BraveSoftware/Brave-Browser"
        THEME_PATH="$HOME/Documents/NordShade/Brave"
    fi
    
    # Check if Brave is installed
    BRAVE_EXISTS=false
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        [[ -d "$BRAVE_PATH" ]] && BRAVE_EXISTS=true
    else
        # Linux
        [[ -d "$BRAVE_PATH" ]] && BRAVE_EXISTS=true
        
        # Check if Brave is in PATH
        if command -v brave-browser > /dev/null; then
            BRAVE_EXISTS=true
        fi
    fi
    
    if [[ "$BRAVE_EXISTS" == "false" ]]; then
        echo -e "${RED}Brave Browser doesn't appear to be installed on this system.${NC}"
        return 1
    fi
    
    # Create theme directory if it doesn't exist
    mkdir -p "$THEME_PATH"
    
    # Copy theme files
    cp "$THEME_ROOT/manifest.json" "$THEME_PATH/"
    cp "$THEME_ROOT/theme_resources.pak" "$THEME_PATH/"
    cp "$THEME_ROOT/nordshade_preview.png" "$THEME_PATH/"
    
    # Determine if we should try to assist with theme application
    if [[ -z "$AUTO_APPLY" ]]; then
        read -p "Would you like to automatically apply the theme? (y/n): " APPLY_CHOICE
        [[ "$APPLY_CHOICE" == "y" ]] && AUTO_APPLY="true" || AUTO_APPLY="false"
    fi
    
    if [[ "$AUTO_APPLY" == "true" ]]; then
        echo -e "${CYAN}Brave themes need to be loaded as an unpacked extension.${NC}"
        echo -e "${CYAN}Instructions:${NC}"
        echo -e "${CYAN}1. Open Brave and navigate to brave://extensions/${NC}"
        echo -e "${CYAN}2. Enable 'Developer mode' (toggle in top-right)${NC}"
        echo -e "${CYAN}3. Click 'Load unpacked' and select this folder: $THEME_PATH${NC}"
        
        # Try to open Brave to the extensions page
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            open -a "Brave Browser" "brave://extensions/"
            open "$THEME_PATH"
            echo -e "${GREEN}Brave has been opened to the extensions page and the theme folder has been opened.${NC}"
        else
            # Linux
            if command -v brave-browser > /dev/null; then
                brave-browser "brave://extensions/" &
                xdg-open "$THEME_PATH" &
                echo -e "${GREEN}Brave has been opened to the extensions page and the theme folder has been opened.${NC}"
            else
                echo -e "${YELLOW}Unable to automatically open Brave. Please follow the manual instructions above.${NC}"
            fi
        fi
    else
        echo -e "${GREEN}Theme files have been installed to: $THEME_PATH${NC}"
        echo -e "${CYAN}To apply the theme:${NC}"
        echo -e "${CYAN}1. Open Brave and navigate to brave://extensions/${NC}"
        echo -e "${CYAN}2. Enable 'Developer mode' (toggle in top-right)${NC}"
        echo -e "${CYAN}3. Click 'Load unpacked' and select this folder: $THEME_PATH${NC}"
    fi
    
    echo -e "${GREEN}Brave theme installation complete.${NC}"
    return 0
}

# Call the function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_brave_theme
fi 