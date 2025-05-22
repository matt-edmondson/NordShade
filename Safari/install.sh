#!/bin/bash
# NordShade for Safari - Installation Script
# Note: Safari themes are primarily supported on macOS

# Define colors for output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

install_safari_theme() {
    local THEME_ROOT="${1:-$(dirname "$0")}"
    local AUTO_APPLY="$2"
    
    echo -e "${YELLOW}Installing NordShade for Safari...${NC}"
    
    # Check if running on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo -e "${RED}Safari theming is primarily supported on macOS.${NC}"
        echo -e "${YELLOW}If you're using Safari for Windows (legacy), the installation may not work as expected.${NC}"
    fi
    
    # Set theme path
    THEME_PATH="$HOME/Documents/NordShade/Safari"
    
    # Check if Safari is installed (macOS)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if [ ! -d "/Applications/Safari.app" ]; then
            echo -e "${RED}Safari doesn't appear to be installed on this system.${NC}"
            return 1
        fi
    fi
    
    # Create theme directory if it doesn't exist
    mkdir -p "$THEME_PATH"
    
    # Copy theme files
    cp "$THEME_ROOT/nordshade.css" "$THEME_PATH/"
    cp "$THEME_ROOT/nordshade-safari.safariextz" "$THEME_PATH/"
    
    # Determine if we should try to assist with theme application
    if [[ -z "$AUTO_APPLY" ]]; then
        read -p "Would you like to automatically apply the theme? (y/n): " APPLY_CHOICE
        [[ "$APPLY_CHOICE" == "y" ]] && AUTO_APPLY="true" || AUTO_APPLY="false"
    fi
    
    if [[ "$AUTO_APPLY" == "true" && "$OSTYPE" == "darwin"* ]]; then
        echo -e "${CYAN}Attempting to install the Safari theme...${NC}"
        
        # Try to open Safari with the extension
        open -a Safari "$THEME_PATH/nordshade-safari.safariextz"
        
        echo -e "${GREEN}Safari has been opened with the theme extension.${NC}"
        echo -e "${CYAN}Follow the prompts in Safari to complete installation.${NC}"
        echo -e "${CYAN}Note: You may need to enable developer features in Safari:${NC}"
        echo -e "${CYAN}1. Open Safari Preferences${NC}"
        echo -e "${CYAN}2. Go to Advanced tab${NC}"
        echo -e "${CYAN}3. Check 'Show Develop menu in menu bar'${NC}"
        echo -e "${CYAN}4. In the Develop menu, select 'Allow Unsigned Extensions'${NC}"
    else
        echo -e "${GREEN}Theme files have been installed to: $THEME_PATH${NC}"
        echo -e "${CYAN}To apply the theme:${NC}"
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo -e "${CYAN}1. Open Safari Preferences${NC}"
            echo -e "${CYAN}2. Go to Advanced tab${NC}"
            echo -e "${CYAN}3. Check 'Show Develop menu in menu bar'${NC}"
            echo -e "${CYAN}4. In the Develop menu, select 'Allow Unsigned Extensions'${NC}"
            echo -e "${CYAN}5. Double-click $THEME_PATH/nordshade-safari.safariextz${NC}"
            echo -e "${CYAN}6. Follow the prompts to install the extension${NC}"
        else
            echo -e "${CYAN}For Safari on other platforms, you may need to manually apply the CSS:${NC}"
            echo -e "${CYAN}1. Look for browser extension that allows custom CSS (like Stylus)${NC}"
            echo -e "${CYAN}2. Import the CSS file from: $THEME_PATH/nordshade.css${NC}"
        fi
    fi
    
    echo -e "${GREEN}Safari theme installation complete.${NC}"
    return 0
}

# Call the function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_safari_theme
fi 