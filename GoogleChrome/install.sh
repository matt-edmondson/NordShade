#!/bin/bash
# NordShade for Google Chrome - Installation Script

# Define colors for output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

install_google_chrome_theme() {
    local THEME_ROOT="${1:-$(dirname "$0")}"
    local AUTO_APPLY="$2"
    
    echo -e "${YELLOW}Installing NordShade for Google Chrome...${NC}"
    
    # Determine OS and set paths
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        CHROME_DIR="$HOME/Library/Application Support/Google/Chrome"
        THEME_PATH="$HOME/Documents/NordShade/GoogleChrome"
    else
        # Linux
        CHROME_DIR="$HOME/.config/google-chrome"
        THEME_PATH="$HOME/Documents/NordShade/GoogleChrome"
    fi
    
    # Check if Chrome is installed
    if [ ! -d "$CHROME_DIR" ]; then
        echo -e "${RED}Google Chrome doesn't appear to be installed on this system.${NC}"
        return 1
    fi
    
    # Create theme directory if it doesn't exist
    mkdir -p "$THEME_PATH"
    
    # Copy theme files
    cp "$THEME_ROOT/manifest.json" "$THEME_PATH/"
    cp "$THEME_ROOT/theme_resources.pak" "$THEME_PATH/"
    cp "$THEME_ROOT/nordshade_theme_preview.png" "$THEME_PATH/"
    
    # Determine if we should try to assist with theme application
    if [[ -z "$AUTO_APPLY" ]]; then
        read -p "Would you like to automatically apply the theme? (y/n): " APPLY_CHOICE
        [[ "$APPLY_CHOICE" == "y" ]] && AUTO_APPLY="true" || AUTO_APPLY="false"
    fi
    
    if [[ "$AUTO_APPLY" == "true" ]]; then
        echo -e "${CYAN}Chrome themes need to be loaded as an unpacked extension.${NC}"
        echo -e "${CYAN}Instructions:${NC}"
        echo -e "${CYAN}1. Open Chrome and navigate to chrome://extensions/${NC}"
        echo -e "${CYAN}2. Enable 'Developer mode' (toggle in top-right)${NC}"
        echo -e "${CYAN}3. Click 'Load unpacked' and select this folder: $THEME_PATH${NC}"
        
        # Try to open Chrome to the extensions page
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            open -a "Google Chrome" "chrome://extensions/"
            open "$THEME_PATH"
            echo -e "${GREEN}Chrome has been opened to the extensions page and the theme folder has been opened.${NC}"
        else
            # Linux
            if command -v google-chrome > /dev/null; then
                google-chrome "chrome://extensions/" &
                xdg-open "$THEME_PATH" &
                echo -e "${GREEN}Chrome has been opened to the extensions page and the theme folder has been opened.${NC}"
            else
                echo -e "${YELLOW}Unable to automatically open Chrome. Please follow the manual instructions above.${NC}"
            fi
        fi
    else
        echo -e "${GREEN}Theme files have been installed to: $THEME_PATH${NC}"
        echo -e "${CYAN}To apply the theme:${NC}"
        echo -e "${CYAN}1. Open Chrome and navigate to chrome://extensions/${NC}"
        echo -e "${CYAN}2. Enable 'Developer mode' (toggle in top-right)${NC}"
        echo -e "${CYAN}3. Click 'Load unpacked' and select this folder: $THEME_PATH${NC}"
    fi
    
    echo -e "${GREEN}Google Chrome theme installation complete.${NC}"
    return 0
}

# Call the function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_google_chrome_theme
fi 