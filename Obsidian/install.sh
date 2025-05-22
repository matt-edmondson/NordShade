#!/bin/bash
# NordShade for Obsidian - Installation Script
# This script installs the NordShade theme for Obsidian

# Define colors for output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

install_obsidian_theme() {
    local THEME_ROOT="${1:-$(dirname "$0")}"
    local VAULT_PATH="$2"
    local AUTO_APPLY="$3"
    
    echo -e "${YELLOW}Installing NordShade for Obsidian...${NC}"
    
    # Ask for Obsidian vault location if not provided
    if [[ -z "$VAULT_PATH" ]]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            DEFAULT_VAULT="$HOME/Documents/Obsidian"
        else
            # Linux
            DEFAULT_VAULT="$HOME/Documents/Obsidian"
        fi
        
        read -p "Enter your Obsidian vault path (or press Enter for default: $DEFAULT_VAULT): " VAULT_PATH
        
        if [ -z "$VAULT_PATH" ]; then
            VAULT_PATH="$DEFAULT_VAULT"
        fi
    fi
    
    # Check if vault exists
    if [ ! -d "$VAULT_PATH" ]; then
        echo -e "${RED}Vault not found at $VAULT_PATH. Please check the path and try again.${NC}"
        return 1
    fi
    
    # Create theme directory
    THEME_PATH="$VAULT_PATH/.obsidian/themes/NordShade"
    mkdir -p "$THEME_PATH"
    
    # Copy theme files
    cp "$THEME_ROOT/theme.css" "$THEME_PATH/"
    cp "$THEME_ROOT/manifest.json" "$THEME_PATH/"
    
    echo -e "${GREEN}Theme files installed to $THEME_PATH${NC}"
    
    # Determine if we should apply the theme
    if [ -z "$AUTO_APPLY" ]; then
        read -p "Would you like to automatically apply the NordShade theme? (y/n): " APPLY_THEME
        AUTO_APPLY=$([ "$APPLY_THEME" = "y" ] && echo "true" || echo "false")
    fi
    
    # Try to auto-apply theme by updating appearance.json if requested
    if [ "$AUTO_APPLY" = "true" ]; then
        APPEARANCE_PATH="$VAULT_PATH/.obsidian/appearance.json"
        
        if [ -f "$APPEARANCE_PATH" ]; then
            # Backup appearance.json
            cp "$APPEARANCE_PATH" "$APPEARANCE_PATH.backup"
            echo -e "${GREEN}Backed up Obsidian appearance settings to $APPEARANCE_PATH.backup${NC}"
            
            # Update theme setting
            if command -v jq &> /dev/null; then
                # Using jq for proper JSON manipulation
                jq '.theme = "NordShade"' "$APPEARANCE_PATH" > "$APPEARANCE_PATH.tmp" && mv "$APPEARANCE_PATH.tmp" "$APPEARANCE_PATH"
                echo -e "${GREEN}Obsidian theme automatically applied!${NC}"
            else
                # Attempt a basic manipulation if jq is not available
                if grep -q "\"theme\"" "$APPEARANCE_PATH"; then
                    # Replace existing theme setting
                    sed -i.bak 's/"theme"\s*:\s*"[^"]*"/"theme": "NordShade"/g' "$APPEARANCE_PATH"
                    echo -e "${GREEN}Obsidian theme automatically applied!${NC}"
                else
                    # Add theme setting
                    sed -i.bak 's/{/{\"theme\": \"NordShade\", /g' "$APPEARANCE_PATH"
                    echo -e "${GREEN}Obsidian theme automatically applied!${NC}"
                fi
            fi
            
            echo -e "${YELLOW}If Obsidian is currently running, you may need to restart it for changes to take effect.${NC}"
        else
            echo -e "${YELLOW}Could not find Obsidian appearance settings. Theme has been installed but must be activated manually.${NC}"
            echo -e "${YELLOW}To activate, open Obsidian -> Settings -> Appearance -> Select 'NordShade' theme${NC}"
        fi
    else
        echo -e "${YELLOW}Theme installed but not automatically applied.${NC}"
        echo -e "${YELLOW}To activate, open Obsidian -> Settings -> Appearance -> Select 'NordShade' theme${NC}"
    fi
    
    return 0
}

# If script is run directly (not sourced), install the theme
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_obsidian_theme
fi 