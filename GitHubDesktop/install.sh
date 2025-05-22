#!/bin/bash
# NordShade for GitHub Desktop - Installation Script
# This script installs the NordShade theme for GitHub Desktop

# Define colors for output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

install_github_desktop_theme() {
    local THEME_ROOT="${1:-$(dirname "$0")}"
    
    echo -e "${YELLOW}Installing NordShade for GitHub Desktop...${NC}"
    
    # Check for GitHub Desktop locations
    DESKTOP_PATHS=(
        "$HOME/.config/GitHub Desktop"  # Linux
        "$HOME/Library/Application Support/GitHub Desktop"  # macOS
    )
    
    # Possible theme paths
    THEME_PATHS=(
        "$HOME/.config/GitHub Desktop/*/styles/ui"  # Linux
        "$HOME/Library/Application Support/GitHub Desktop/*/styles/ui"  # macOS
        "/Applications/GitHub Desktop.app/Contents/Resources/app/styles/themes"  # macOS app
    )
    
    DESKTOP_FOUND=false
    THEME_DIR_FOUND=false
    THEME_DIR=""
    
    # Check if GitHub Desktop is installed
    for path in "${DESKTOP_PATHS[@]}"; do
        if [ -d "$path" ]; then
            DESKTOP_FOUND=true
            echo -e "${GREEN}GitHub Desktop detected at $path${NC}"
            break
        fi
    done
    
    # Try to find themes directory
    if [ "$DESKTOP_FOUND" = true ]; then
        for path in "${THEME_PATHS[@]}"; do
            # Use ls to expand wildcards
            POSSIBLE_PATHS=$(ls -d $path 2>/dev/null)
            if [ -n "$POSSIBLE_PATHS" ]; then
                # Use the first match
                THEME_DIR=$(echo "$POSSIBLE_PATHS" | head -n 1)
                THEME_DIR_FOUND=true
                break
            fi
        done
    fi
    
    if [ "$THEME_DIR_FOUND" = true ]; then
        # Copy the theme file
        INSTALL_PATH="$THEME_DIR/theme-nord-shade.less"
        cp "$THEME_ROOT/nord-shade.less" "$INSTALL_PATH"
        echo -e "${GREEN}Theme installed to: $INSTALL_PATH${NC}"
        echo -e "${YELLOW}To activate, add the following line to variables.less in the same directory:${NC}"
        echo -e "${YELLOW}@import \"theme-nord-shade\";${NC}"
        echo -e "${YELLOW}Then restart GitHub Desktop.${NC}"
    else
        # Couldn't find themes folder - just copy to home directory
        FALLBACK_PATH="$HOME/NordShade-GitHubDesktop.less"
        cp "$THEME_ROOT/nord-shade.less" "$FALLBACK_PATH"
        
        if [ "$DESKTOP_FOUND" = true ]; then
            echo -e "${RED}Could not locate GitHub Desktop themes folder.${NC}"
        else
            echo -e "${RED}GitHub Desktop not detected.${NC}"
        fi
        
        echo -e "${YELLOW}Theme file copied to: $FALLBACK_PATH${NC}"
        echo -e "${YELLOW}For manual installation instructions, please refer to the README.md file.${NC}"
    fi
    
    return 0
}

# If script is run directly (not sourced), install the theme
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_github_desktop_theme
fi 