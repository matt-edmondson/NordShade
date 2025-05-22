#!/bin/bash
# NordShade for Visual Studio Code - Installation Script
# This script installs the NordShade theme for Visual Studio Code

# Define colors for output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

install_vscode_theme() {
    local THEME_ROOT="${1:-$(dirname "$0")}"
    local AUTO_APPLY="$2"
    
    echo -e "${YELLOW}Installing NordShade for Visual Studio Code...${NC}"
    
    # Determine OS and set paths
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        VSCODE_PATH="$HOME/.vscode/extensions/nordshade-theme"
        SETTINGS_PATH="$HOME/Library/Application Support/Code/User/settings.json"
    else
        # Linux
        VSCODE_PATH="$HOME/.vscode/extensions/nordshade-theme"
        SETTINGS_PATH="$HOME/.config/Code/User/settings.json"
    fi
    
    # Create directory if it doesn't exist
    mkdir -p "$VSCODE_PATH"
    
    # Copy theme files
    cp "$THEME_ROOT/NordShade.json" "$VSCODE_PATH/"
    cp "$THEME_ROOT/package.json" "$VSCODE_PATH/" 2>/dev/null
    cp "$THEME_ROOT/README.md" "$VSCODE_PATH/" 2>/dev/null
    
    echo -e "${GREEN}Theme files installed to $VSCODE_PATH${NC}"
    
    # Determine if we should apply the theme
    if [ -z "$AUTO_APPLY" ]; then
        read -p "Would you like to automatically apply the NordShade theme? (y/n): " APPLY_THEME
        AUTO_APPLY=$([ "$APPLY_THEME" = "y" ] && echo "true" || echo "false")
    fi
    
    # Automatically apply the theme by updating settings.json
    if [ "$AUTO_APPLY" = "true" ]; then
        # Create settings directory if it doesn't exist
        mkdir -p "$(dirname "$SETTINGS_PATH")"
        
        # Create settings.json if it doesn't exist
        if [ ! -f "$SETTINGS_PATH" ]; then
            echo "{}" > "$SETTINGS_PATH"
        fi
        
        # Backup settings
        cp "$SETTINGS_PATH" "$SETTINGS_PATH.backup"
        
        # Update settings to use NordShade theme
        # Use jq if available, otherwise use a more basic approach
        if command -v jq &> /dev/null; then
            # Using jq for proper JSON manipulation
            jq '.["workbench.colorTheme"] = "NordShade"' "$SETTINGS_PATH" > "$SETTINGS_PATH.tmp" && mv "$SETTINGS_PATH.tmp" "$SETTINGS_PATH"
        else
            # Attempt a basic manipulation if jq is not available
            # Check if file has workbench.colorTheme already
            if grep -q "workbench.colorTheme" "$SETTINGS_PATH"; then
                # Replace existing setting
                sed -i.bak 's/"workbench.colorTheme"\s*:\s*"[^"]*"/"workbench.colorTheme": "NordShade"/g' "$SETTINGS_PATH"
            else
                # Add new setting
                content=$(cat "$SETTINGS_PATH")
                if [ "$content" = "{}" ]; then
                    # Empty settings file
                    echo '{"workbench.colorTheme": "NordShade"}' > "$SETTINGS_PATH"
                else
                    # Non-empty settings file, add setting
                    sed -i.bak 's/{/{\"workbench.colorTheme\": \"NordShade\", /g' "$SETTINGS_PATH"
                fi
            fi
        fi
        
        echo -e "${GREEN}VS Code theme automatically applied!${NC}"
        echo -e "${GREEN}Settings backup created at $SETTINGS_PATH.backup${NC}"
    else
        echo -e "${YELLOW}Theme installed but not automatically applied.${NC}"
        echo -e "${YELLOW}To apply the theme manually, go to VS Code -> Settings -> Color Theme and select 'NordShade'${NC}"
    fi
}

# If script is run directly (not sourced), install the theme
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_vscode_theme
fi 