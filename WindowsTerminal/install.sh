#!/bin/bash
# NordShade for Windows Terminal - Installation Script
# This script installs the NordShade theme for Windows Terminal
# Note: Windows Terminal is primarily a Windows application
# This script is included for WSL users who want to modify their Windows Terminal theme

# Define colors for output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

install_windows_terminal_theme() {
    local THEME_ROOT="${1:-$(dirname "$0")}"
    local AUTO_APPLY="$2"
    
    echo -e "${YELLOW}Installing NordShade for Windows Terminal...${NC}"
    echo -e "${YELLOW}Note: Windows Terminal is primarily a Windows application${NC}"
    echo -e "${YELLOW}This installer is for WSL users who want to modify their Windows Terminal settings${NC}"
    
    # The path to Windows Terminal settings in Windows
    # We need to convert this to a WSL path
    WINDOWS_APPDATA=$(wslpath -u "$(powershell.exe -Command 'Write-Host $env:LOCALAPPDATA' | tr -d '\r')")
    
    # Check for both regular and preview versions
    SETTINGS_PATH="$WINDOWS_APPDATA/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
    SETTINGS_PATH_PREVIEW="$WINDOWS_APPDATA/Packages/Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe/LocalState/settings.json"
    
    # Check if settings.json exists in either location
    if [ -f "$SETTINGS_PATH" ]; then
        TERMINAL_SETTINGS_PATH="$SETTINGS_PATH"
    elif [ -f "$SETTINGS_PATH_PREVIEW" ]; then
        TERMINAL_SETTINGS_PATH="$SETTINGS_PATH_PREVIEW"
    else
        echo -e "${RED}Windows Terminal settings.json not found.${NC}"
        echo -e "${RED}Make sure Windows Terminal is installed and you're running from WSL.${NC}"
        return 1
    fi
    
    # Backup existing settings
    cp "$TERMINAL_SETTINGS_PATH" "$TERMINAL_SETTINGS_PATH.backup"
    echo -e "${GREEN}Backed up existing settings to $TERMINAL_SETTINGS_PATH.backup${NC}"
    
    # Get the theme file
    THEME_FILE="$THEME_ROOT/NordShade.json"
    
    # Check if jq is available for JSON manipulation
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}Error: jq is not installed. It's required for JSON manipulation.${NC}"
        echo -e "${YELLOW}Please install jq or use the PowerShell script from Windows.${NC}"
        return 1
    fi
    
    # Read the theme file
    THEME_JSON=$(cat "$THEME_FILE")
    
    # Extract the theme name (should be "NordShade")
    THEME_NAME=$(echo "$THEME_JSON" | jq -r '.name')
    
    # Determine if we should apply the theme
    if [ -z "$AUTO_APPLY" ]; then
        read -p "Would you like to automatically apply the NordShade theme as the default color scheme? (y/n): " APPLY_THEME
        AUTO_APPLY=$([ "$APPLY_THEME" = "y" ] && echo "true" || echo "false")
    fi
    
    # Update the settings file based on auto-apply preference
    if [ "$AUTO_APPLY" = "true" ]; then
        # 1. Remove any existing NordShade theme
        # 2. Add the new theme
        # 3. Apply it as the default
        jq --argjson theme "$THEME_JSON" '
        # Ensure schemes array exists
        if .schemes == null then . + {schemes: []} else . end
        # Remove existing theme with same name if it exists
        | .schemes = (.schemes | map(select(.name != $theme.name)))
        # Add new theme
        | .schemes = (.schemes + [$theme])
        # Set as default for all profiles if profiles.defaults exists
        | if .profiles.defaults then
            .profiles.defaults.colorScheme = $theme.name
          else
            if .profiles then
              .profiles = (.profiles + {defaults: {colorScheme: $theme.name}})
            else
              . + {profiles: {defaults: {colorScheme: $theme.name}}}
            end
          end
        ' "$TERMINAL_SETTINGS_PATH" > "$TERMINAL_SETTINGS_PATH.tmp"
        
        echo -e "${GREEN}Windows Terminal theme applied as the default color scheme!${NC}"
    else
        # Only add the theme without setting it as default
        jq --argjson theme "$THEME_JSON" '
        # Ensure schemes array exists
        if .schemes == null then . + {schemes: []} else . end
        # Remove existing theme with same name if it exists
        | .schemes = (.schemes | map(select(.name != $theme.name)))
        # Add new theme
        | .schemes = (.schemes + [$theme])
        ' "$TERMINAL_SETTINGS_PATH" > "$TERMINAL_SETTINGS_PATH.tmp"
        
        echo -e "${YELLOW}NordShade theme added to available schemes but not applied.${NC}"
        echo -e "${YELLOW}To activate, open Windows Terminal -> Settings -> Color Schemes and select 'NordShade'${NC}"
    fi
    
    # Replace the original file with our modified one
    mv "$TERMINAL_SETTINGS_PATH.tmp" "$TERMINAL_SETTINGS_PATH"
    
    echo -e "${GREEN}Windows Terminal theme installation complete!${NC}"
    echo -e "${GREEN}You may need to restart Windows Terminal for the changes to take effect.${NC}"
}

# If script is run directly (not sourced), install the theme
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_windows_terminal_theme
fi 