#!/bin/bash
# NordShade for Firefox - Installation Script

# Define colors for output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

install_firefox_theme() {
    local THEME_ROOT="${1:-$(dirname "$0")}"
    local AUTO_APPLY="$2"
    
    echo -e "${YELLOW}Installing NordShade for Firefox...${NC}"
    
    # Determine OS and set paths
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        FIREFOX_PATH="/Applications/Firefox.app/Contents/MacOS/firefox"
        THEME_PATH="$HOME/Documents/NordShade/Firefox"
    else
        # Linux
        FIREFOX_PATH=$(which firefox 2>/dev/null)
        THEME_PATH="$HOME/Documents/NordShade/Firefox"
    fi
    
    # Check if Firefox is installed
    if [[ ! -f "$FIREFOX_PATH" && -z $(which firefox 2>/dev/null) ]]; then
        echo -e "${RED}Firefox doesn't appear to be installed on this system.${NC}"
        return 1
    fi
    
    # Create theme directory if it doesn't exist
    mkdir -p "$THEME_PATH"
    
    # Copy theme files
    cp "$THEME_ROOT/manifest.json" "$THEME_PATH/"
    cp "$THEME_ROOT/nordshade.xpi" "$THEME_PATH/"
    
    # Determine if we should try to assist with theme application
    if [[ -z "$AUTO_APPLY" ]]; then
        read -p "Would you like to automatically apply the theme? (y/n): " APPLY_CHOICE
        [[ "$APPLY_CHOICE" == "y" ]] && AUTO_APPLY="true" || AUTO_APPLY="false"
    fi
    
    if [[ "$AUTO_APPLY" == "true" ]]; then
        echo -e "${CYAN}Attempting to install the Firefox theme...${NC}"
        
        # Try to open Firefox with the XPI file
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            open -a Firefox "$THEME_PATH/nordshade.xpi"
        else
            # Linux
            if [[ -n "$FIREFOX_PATH" ]]; then
                "$FIREFOX_PATH" "$THEME_PATH/nordshade.xpi" &
            else
                firefox "$THEME_PATH/nordshade.xpi" &
            fi
        fi
        
        echo -e "${GREEN}Firefox has been opened with the theme package.${NC}"
        echo -e "${CYAN}Follow the prompts in Firefox to complete installation.${NC}"
    else
        echo -e "${GREEN}Theme files have been installed to: $THEME_PATH${NC}"
        echo -e "${CYAN}To apply the theme:${NC}"
        echo -e "${CYAN}1. Open Firefox${NC}"
        echo -e "${CYAN}2. Navigate to about:addons${NC}"
        echo -e "${CYAN}3. Click the gear icon and select 'Install Add-on From File...'${NC}"
        echo -e "${CYAN}4. Browse to $THEME_PATH/nordshade.xpi and open it${NC}"
        echo -e "${CYAN}5. Follow the prompts to install the theme${NC}"
    fi
    
    echo -e "${GREEN}Firefox theme installation complete.${NC}"
    return 0
}

# Call the function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_firefox_theme
fi 