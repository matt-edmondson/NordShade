#!/bin/bash
# NordShade for Cursor IDE - Installation Script
# This script installs the NordShade theme for Cursor IDE

install_cursor_theme() {
    local THEME_ROOT="${1:-$(dirname "$0")}"
    local AUTO_APPLY=$2
    
    echo -e "\033[1;33mInstalling NordShade for Cursor IDE...\033[0m"
    
    # Define possible Cursor installation paths
    CURSOR_PATHS=(
        "$HOME/.cursor/extensions"
        "$HOME/.config/cursor-editor/extensions"
        "$HOME/Library/Application Support/cursor-editor/extensions"
    )
    
    CURSOR_PATH=""
    for path in "${CURSOR_PATHS[@]}"; do
        if [ -d "$path" ]; then
            CURSOR_PATH="$path"
            break
        fi
    done
    
    if [ -z "$CURSOR_PATH" ]; then
        echo -e "\033[1;31mCursor IDE not found. Please make sure it's installed.\033[0m"
        return 1
    fi
    
    CURSOR_EXT_PATH="$CURSOR_PATH/nordshade-theme"
    
    # Create directory if it doesn't exist
    mkdir -p "$CURSOR_EXT_PATH"
    
    # Copy theme files
    cp "$THEME_ROOT/NordShade.json" "$CURSOR_EXT_PATH/"
    cp "$THEME_ROOT/package.json" "$CURSOR_EXT_PATH/"
    
    echo -e "\033[1;32mTheme files installed to $CURSOR_EXT_PATH\033[0m"
    
    # Check if we should apply the theme
    if [ -z "$AUTO_APPLY" ]; then
        read -p "Would you like to automatically apply the NordShade theme? (y/n) " APPLY_THEME
        AUTO_APPLY=$(echo "$APPLY_THEME" | grep -i "^y" > /dev/null && echo "yes" || echo "no")
    fi
    
    # Automatically apply the theme by updating settings.json
    if [ "$AUTO_APPLY" = "yes" ]; then
        # Determine settings path based on OS
        if [[ "$OSTYPE" == "darwin"* ]]; then
            SETTINGS_PATH="$HOME/Library/Application Support/Cursor/User/settings.json"
        else
            SETTINGS_PATH="$HOME/.config/Cursor/User/settings.json"
        fi
        
        # Create settings dir if it doesn't exist
        mkdir -p "$(dirname "$SETTINGS_PATH")"
        
        # Create settings.json if it doesn't exist
        if [ ! -f "$SETTINGS_PATH" ]; then
            echo "{}" > "$SETTINGS_PATH"
        fi
        
        # Backup settings
        cp "$SETTINGS_PATH" "$SETTINGS_PATH.backup"
        
        # Try to use jq for JSON manipulation if available
        if command -v jq >/dev/null 2>&1; then
            jq '.["workbench.colorTheme"] = "NordShade"' "$SETTINGS_PATH" > "$SETTINGS_PATH.tmp" && mv "$SETTINGS_PATH.tmp" "$SETTINGS_PATH"
        else
            # Fallback to simple text replacement if jq is not available
            if grep -q "workbench.colorTheme" "$SETTINGS_PATH"; then
                sed -i.bak 's/"workbench.colorTheme": "[^"]*"/"workbench.colorTheme": "NordShade"/g' "$SETTINGS_PATH"
            else
                # Add the theme setting to the JSON
                sed -i.bak 's/{/{\n  "workbench.colorTheme": "NordShade",/g' "$SETTINGS_PATH"
            fi
        fi
        
        echo -e "\033[1;32mCursor IDE theme automatically applied!\033[0m"
        echo -e "\033[1;32mSettings backup created at $SETTINGS_PATH.backup\033[0m"
    else
        echo -e "\033[1;33mTheme installed but not automatically applied.\033[0m"
        echo -e "\033[1;33mTo apply the theme manually, go to Cursor IDE -> Settings -> Color Theme and select 'NordShade'\033[0m"
    fi
    
    return 0
}

# If the script is being run directly, install the theme
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_cursor_theme "$@"
fi 