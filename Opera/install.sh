#!/bin/bash
# NordShade for Opera - Installation Script

# Define colors for output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

install_opera_theme() {
    local THEME_ROOT="${1:-$(dirname "$0")}"
    local AUTO_APPLY="$2"
    
    echo -e "${YELLOW}Installing NordShade for Opera...${NC}"
    
    # Determine OS and set paths
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        OPERA_PATH="/Applications/Opera.app"
        OPERA_GX_PATH="/Applications/Opera GX.app"
        THEME_PATH="$HOME/Documents/NordShade/Opera"
    else
        # Linux
        OPERA_PATH="$HOME/.local/share/Opera"
        OPERA_GX_PATH="$HOME/.local/share/Opera GX"
        THEME_PATH="$HOME/Documents/NordShade/Opera"
    fi
    
    # Check if Opera is installed
    OPERA_EXISTS=false
    OPERA_GX_EXISTS=false
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        [[ -d "$OPERA_PATH" ]] && OPERA_EXISTS=true
        [[ -d "$OPERA_GX_PATH" ]] && OPERA_GX_EXISTS=true
    else
        # Linux
        [[ -d "$OPERA_PATH" ]] && OPERA_EXISTS=true
        [[ -d "$OPERA_GX_PATH" ]] && OPERA_GX_EXISTS=true
        
        # Check if Opera is in PATH
        if command -v opera > /dev/null; then
            OPERA_EXISTS=true
        fi
        
        if command -v opera-gx > /dev/null; then
            OPERA_GX_EXISTS=true
        fi
    fi
    
    if [[ "$OPERA_EXISTS" == "false" && "$OPERA_GX_EXISTS" == "false" ]]; then
        echo -e "${RED}Opera doesn't appear to be installed on this system.${NC}"
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
    
    # Determine Opera type
    OPERA_TYPE="Opera"
    if [[ "$OPERA_GX_EXISTS" == "true" ]]; then
        OPERA_TYPE="Opera GX"
    fi
    
    if [[ "$AUTO_APPLY" == "true" ]]; then
        echo -e "${CYAN}Opera themes need to be loaded as an unpacked extension.${NC}"
        echo -e "${CYAN}Instructions:${NC}"
        echo -e "${CYAN}1. Open Opera and navigate to opera://extensions/${NC}"
        echo -e "${CYAN}2. Enable 'Developer mode' (toggle in top-right)${NC}"
        echo -e "${CYAN}3. Click 'Load unpacked' and select this folder: $THEME_PATH${NC}"
        
        # Try to open Opera to the extensions page
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            if [[ "$OPERA_GX_EXISTS" == "true" ]]; then
                open -a "Opera GX" "opera://extensions/"
            else
                open -a "Opera" "opera://extensions/"
            fi
            open "$THEME_PATH"
            echo -e "${GREEN}$OPERA_TYPE has been opened to the extensions page and the theme folder has been opened.${NC}"
        else
            # Linux
            if command -v opera > /dev/null && [[ "$OPERA_EXISTS" == "true" ]]; then
                opera "opera://extensions/" &
                xdg-open "$THEME_PATH" &
                echo -e "${GREEN}$OPERA_TYPE has been opened to the extensions page and the theme folder has been opened.${NC}"
            elif command -v opera-gx > /dev/null && [[ "$OPERA_GX_EXISTS" == "true" ]]; then
                opera-gx "opera://extensions/" &
                xdg-open "$THEME_PATH" &
                echo -e "${GREEN}$OPERA_TYPE has been opened to the extensions page and the theme folder has been opened.${NC}"
            else
                echo -e "${YELLOW}Unable to automatically open $OPERA_TYPE. Please follow the manual instructions above.${NC}"
            fi
        fi
    else
        echo -e "${GREEN}Theme files have been installed to: $THEME_PATH${NC}"
        echo -e "${CYAN}To apply the theme:${NC}"
        echo -e "${CYAN}1. Open $OPERA_TYPE and navigate to opera://extensions/${NC}"
        echo -e "${CYAN}2. Enable 'Developer mode' (toggle in top-right)${NC}"
        echo -e "${CYAN}3. Click 'Load unpacked' and select this folder: $THEME_PATH${NC}"
    fi
    
    echo -e "${GREEN}Opera theme installation complete.${NC}"
    return 0
}

# Call the function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_opera_theme
fi 