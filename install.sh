#!/bin/bash
# NordShade Installation Script for macOS/Linux
# This script detects and installs NordShade themes for available applications
# Can be run without cloning the repository

REPO_URL="https://github.com/matt-edmondson/NordShade"
TEMP_PATH="/tmp/NordShade"
CURRENT_PATH=$(pwd)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLOBAL_AUTO_APPLY=""

# Define colors for output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Determine if we're running from the cloned repo or standalone
if [ -f "$SCRIPT_DIR/README.md" ]; then
    NORDSHADE_ROOT="$SCRIPT_DIR"
    IS_REPO=true
    echo -e "${CYAN}Installing NordShade themes from local repository at $NORDSHADE_ROOT${NC}"
else
    NORDSHADE_ROOT="$TEMP_PATH"
    IS_REPO=false
    echo -e "${CYAN}Running standalone installation - will download required files on demand${NC}"
fi

# Index.json caching
INDEX_JSON=""

get_index_json() {
    # Return cached index if already fetched
    if [ -n "$INDEX_JSON" ]; then
        echo "$INDEX_JSON"
        return 0
    fi
    
    local index_url="$REPO_URL/raw/main/index.json"
    local index_path="$TEMP_PATH/index.json"
    
    # Create temp directory if it doesn't exist
    mkdir -p "$TEMP_PATH"
    
    # Download the index file
    if curl -s "$index_url" -o "$index_path"; then
        # Cache the index.json content
        INDEX_JSON=$(cat "$index_path")
        echo "$INDEX_JSON"
        return 0
    else
        echo "Failed to download index.json" >&2
        return 1
    fi
}

download_theme_files() {
    local THEME_NAME="$1"
    
    echo -e "${YELLOW}Downloading files for $THEME_NAME theme...${NC}"
    
    # Create directory for theme
    mkdir -p "$TEMP_PATH/$THEME_NAME"
    
    # Try to get index.json
    local index_json=$(get_index_json)
    local result=$?
    
    if [ $result -ne 0 ] || [ -z "$index_json" ]; then
        echo -e "${RED}Failed to download or parse index.json. Installation may be incomplete.${NC}"
        return 1
    fi
    
    # Use jq if available for proper JSON parsing
    if command -v jq &> /dev/null; then
        local BASE_URL=$(echo "$index_json" | jq -r '.baseUrl')
        local THEME_FILES=$(echo "$index_json" | jq -r ".themes[\"$THEME_NAME\"][]" 2>/dev/null)
        
        if [ -z "$THEME_FILES" ]; then
            echo -e "${RED}Theme $THEME_NAME not found in index.json${NC}"
            return 1
        fi
        
        # Download each file
        for FILE in $THEME_FILES; do
            local FILE_URL="$BASE_URL/$THEME_NAME/$FILE"
            local FILE_PATH="$TEMP_PATH/$THEME_NAME/$FILE"
            echo -e "  - $FILE"
            curl -s "$FILE_URL" -o "$FILE_PATH"
            
            # Make shell scripts executable
            if [[ "$FILE" == *.sh ]]; then
                chmod +x "$FILE_PATH"
            fi
        done
    else
        # Basic parsing without jq (limited functionality)
        echo -e "${YELLOW}jq not available, using basic parsing for index.json${NC}"
        
        # Simple grep-based parsing - not ideal but works for basic cases
        local BASE_URL=$(grep -o '"baseUrl"[^,]*' "$TEMP_PATH/index.json" | cut -d '"' -f 4)
        
        # Extract theme section - very basic and may break with complex JSON
        local THEME_SECTION=$(sed -n "/$THEME_NAME/,/\]/p" "$TEMP_PATH/index.json")
        
        # Extract filenames - again, very basic
        local THEME_FILES=$(echo "$THEME_SECTION" | grep -o '"[^"]*"' | grep -v "$THEME_NAME" | tr -d '"')
        
        if [ -z "$THEME_FILES" ]; then
            echo -e "${RED}Theme $THEME_NAME not found or could not be parsed from index.json${NC}"
            return 1
        fi
        
        # Download each file
        for FILE in $THEME_FILES; do
            # Skip if not a file name
            if [[ "$FILE" == *":"* ]] || [[ "$FILE" == *"{"* ]] || [[ "$FILE" == *"}"* ]]; then
                continue
            fi
            
            local FILE_URL="$BASE_URL/$THEME_NAME/$FILE"
            local FILE_PATH="$TEMP_PATH/$THEME_NAME/$FILE"
            echo -e "  - $FILE"
            curl -s "$FILE_URL" -o "$FILE_PATH"
            
            # Make shell scripts executable
            if [[ "$FILE" == *.sh ]]; then
                chmod +x "$FILE_PATH"
            fi
        done
    fi
    
    # Check if installer script exists
    if [ -f "$TEMP_PATH/$THEME_NAME/install.sh" ]; then
        chmod +x "$TEMP_PATH/$THEME_NAME/install.sh"
        return 0
    else
        echo -e "${RED}Installer script not found for $THEME_NAME${NC}"
        return 1
    fi
}

install_theme() {
    local THEME_NAME="$1"
    
    echo -e "${YELLOW}Installing NordShade for $THEME_NAME...${NC}"
    
    # Download theme files if running standalone
    if [ "$IS_REPO" = false ]; then
        download_theme_files "$THEME_NAME"
        if [ $? -ne 0 ]; then
            echo -e "${RED}Failed to download theme files for $THEME_NAME${NC}"
            return 1
        fi
    fi
    
    # Check if installer script exists
    if [ -f "$NORDSHADE_ROOT/$THEME_NAME/install.sh" ]; then
        # Call the theme-specific installer with the auto-apply parameter
        bash "$NORDSHADE_ROOT/$THEME_NAME/install.sh" "$NORDSHADE_ROOT/$THEME_NAME" "$GLOBAL_AUTO_APPLY"
    else
        echo -e "${RED}Installer script not found for $THEME_NAME${NC}"
        return 1
    fi
    
    return 0
}

get_available_themes() {
    # Try to get themes from index.json
    local index_json=$(get_index_json)
    
    if [ $? -ne 0 ] || [ -z "$index_json" ]; then
        # Fallback to hardcoded list if index.json is not available
        echo "VisualStudioCode Obsidian Neovim JetBrains WindowsTerminal Discord GitHubDesktop"
        return
    fi
    
    # Extract themes using jq if available
    if command -v jq &> /dev/null; then
        echo "$index_json" | jq -r '.themes | keys[]'
    else
        # Very basic extraction without jq - may break with complex JSON
        grep -o '"themes":{[^}]*}' "$TEMP_PATH/index.json" | grep -o '"[^"]*":' | cut -d '"' -f 2 | grep -v "themes"
    fi
}

detect_applications() {
    # Get available themes
    local AVAILABLE_THEMES=$(get_available_themes)
    local DETECTED_APPS=""
    
    # Check for VS Code
    if command -v code &> /dev/null && echo "$AVAILABLE_THEMES" | grep -q "VisualStudioCode"; then
        DETECTED_APPS="$DETECTED_APPS VisualStudioCode"
    fi
    
    # Check for Cursor IDE
    CURSOR_PATHS=(
        "$HOME/.cursor"
        "$HOME/.config/cursor-editor"
        "$HOME/Library/Application Support/cursor-editor"
    )
    for path in "${CURSOR_PATHS[@]}"; do
        if [ -d "$path" ] && echo "$AVAILABLE_THEMES" | grep -q "Cursor"; then
            DETECTED_APPS="$DETECTED_APPS Cursor"
            break
        fi
    done
    
    # Check for Neovim
    if (command -v nvim &> /dev/null || command -v vim &> /dev/null) && echo "$AVAILABLE_THEMES" | grep -q "Neovim"; then
        DETECTED_APPS="$DETECTED_APPS Neovim"
    fi
    
    # Check for JetBrains IDEs
    if detect_jetbrains && echo "$AVAILABLE_THEMES" | grep -q "JetBrains"; then
        DETECTED_APPS="$DETECTED_APPS JetBrains"
    fi
    
    # Check for Discord
    if [ -d "$HOME/.config/BetterDiscord" ] || [ -d "$HOME/Library/Application Support/BetterDiscord" ] || 
       [ -d "$HOME/.config/VencordDesktop" ] && echo "$AVAILABLE_THEMES" | grep -q "Discord"; then
        DETECTED_APPS="$DETECTED_APPS Discord"
    fi
    
    # Check for GitHub Desktop
    if [ -d "/Applications/GitHub Desktop.app" ] || command -v github &> /dev/null && echo "$AVAILABLE_THEMES" | grep -q "GitHubDesktop"; then
        DETECTED_APPS="$DETECTED_APPS GitHubDesktop"
    fi
    
    # Check for Windows Terminal (WSL)
    if command -v wsl.exe &> /dev/null && command -v powershell.exe &> /dev/null && echo "$AVAILABLE_THEMES" | grep -q "WindowsTerminal"; then
        DETECTED_APPS="$DETECTED_APPS WindowsTerminal"
    fi
    
    # Check for Obsidian - ask later since it's difficult to detect
    if ([ -d "$HOME/.config/obsidian" ] || [ -d "$HOME/Library/Application Support/obsidian" ]) && 
       echo "$AVAILABLE_THEMES" | grep -q "Obsidian"; then
        DETECTED_APPS="$DETECTED_APPS Obsidian"
    fi
    
    echo "$DETECTED_APPS"
}

# Function to detect JetBrains IDEs
detect_jetbrains() {
    # Patterns to look for JetBrains config directories
    patterns=(
        "$HOME/.config/JetBrains/*"
        "$HOME/.JetBrains/*"
        "$HOME/.IntelliJIdea*"
        "$HOME/.WebStorm*"
        "$HOME/.PyCharm*"
        "$HOME/.CLion*"
        "$HOME/.DataGrip*"
        "$HOME/.GoLand*"
        "$HOME/.PhpStorm*"
        "$HOME/.Rider*"
        "$HOME/.RubyMine*"
        "$HOME/Library/Application Support/JetBrains/*"
    )
    
    for pattern in "${patterns[@]}"; do
        if compgen -G "$pattern" > /dev/null; then
            return 0  # Found JetBrains IDE
        fi
    done
    
    return 1  # No JetBrains IDE found
}

install_all_themes() {
    local DETECTED_APPS=$(detect_applications)
    
    if [ -z "$DETECTED_APPS" ]; then
        echo -e "${YELLOW}No supported applications detected.${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Installing NordShade for all detected applications...${NC}"
    
    for app in $DETECTED_APPS; do
        install_theme "$app"
    done
    
    return 0
}

# Create temp directory if running standalone
if [ "$IS_REPO" = false ]; then
    mkdir -p "$TEMP_PATH"
fi

# Present the menu to the user
echo -e "${CYAN}===== NordShade Theme Installer =====${NC}"
echo -e "${CYAN}==================================${NC}"

# Ask about global auto-apply preference
read -p "Would you like themes to be automatically applied after installation? (y/n): " AUTO_APPLY_SETTING
if [ "$AUTO_APPLY_SETTING" = "y" ]; then
    GLOBAL_AUTO_APPLY="true"
    echo -e "${YELLOW}Themes will be automatically applied when possible${NC}"
else
    GLOBAL_AUTO_APPLY="false"
    echo -e "${YELLOW}Themes will be installed but not automatically applied${NC}"
    echo -e "${YELLOW}You'll need to activate them manually in each application${NC}"
fi

echo "Please select an option:"
echo "1) Install for all detected applications"
echo "2) Pick and choose which applications to install for"
echo "3) Exit"
read -p "Enter your choice (1-3): " MENU_CHOICE

case $MENU_CHOICE in
    1)
        install_all_themes
        ;;
    2)
        # Get detected applications
        DETECTED_APPS=$(detect_applications)
        
        if [ -z "$DETECTED_APPS" ]; then
            echo -e "${YELLOW}No supported applications detected.${NC}"
            exit 0
        fi
        
        echo -e "${YELLOW}The following applications were detected:${NC}"
        
        # Convert space-separated string to array
        IFS=' ' read -r -a APP_ARRAY <<< "$DETECTED_APPS"
        
        # Display menu
        for i in "${!APP_ARRAY[@]}"; do
            APP_NAME="${APP_ARRAY[$i]}"
            # Convert theme name to display name
            case "$APP_NAME" in
                "VisualStudioCode") DISPLAY_NAME="Visual Studio Code" ;;
                "JetBrains") DISPLAY_NAME="JetBrains IDEs" ;;
                "WindowsTerminal") DISPLAY_NAME="Windows Terminal (WSL)" ;;
                "GitHubDesktop") DISPLAY_NAME="GitHub Desktop" ;;
                *) DISPLAY_NAME="$APP_NAME" ;;
            esac
            echo "$((i+1))) $DISPLAY_NAME"
        done
        
        echo "Enter the numbers of the applications you want to install themes for (comma-separated, e.g. '1,3,4'):"
        read SELECTION
        
        # Process selection
        IFS=',' read -r -a SELECTED_INDICES <<< "$SELECTION"
        for INDEX in "${SELECTED_INDICES[@]}"; do
            # Remove any spaces and check if it's a valid number
            INDEX=$(echo "$INDEX" | tr -d ' ')
            if [[ "$INDEX" =~ ^[0-9]+$ ]] && [ "$INDEX" -gt 0 ] && [ "$INDEX" -le "${#APP_ARRAY[@]}" ]; then
                # Arrays are 0-indexed, but our menu is 1-indexed
                APP_NAME="${APP_ARRAY[$((INDEX-1))]}"
                install_theme "$APP_NAME"
            fi
        done
        ;;
    3)
        echo -e "${GREEN}Exiting NordShade installer. No changes were made.${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option. Exiting.${NC}"
        exit 1
        ;;
esac

# Clean up temp files if we downloaded them
if [ "$IS_REPO" = false ] && [ -d "$TEMP_PATH" ]; then
    read -p "Remove temporary downloaded files? (y/n): " CLEANUP
    if [ "$CLEANUP" == "y" ]; then
        rm -rf "$TEMP_PATH"
        echo -e "${GREEN}Temporary files removed${NC}"
    fi
fi

echo -e "${GREEN}NordShade installation complete!${NC}" 