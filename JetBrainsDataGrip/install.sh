#!/bin/bash
# NordShade for JetBrains DataGrip - Installation Script (Bash)
# Installs the NordShade theme for JetBrains DataGrip

# Define colors for output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to find DataGrip config directories
find_datagrip_configs() {
    local patterns=(
        "$HOME/.DataGrip"*
        "$HOME/Library/Application Support/JetBrains/DataGrip"*
        "$HOME/.config/JetBrains/DataGrip"*
    )
    
    local found_configs=()
    
    for pattern in "${patterns[@]}"; do
        # Use compgen to avoid errors when no matching directories exist
        if compgen -G "$pattern" > /dev/null; then
            mapfile -t matches < <(find $pattern -maxdepth 0 -type d 2>/dev/null)
            found_configs+=("${matches[@]}")
        fi
    done
    
    echo "${found_configs[@]}"
}

# Get DataGrip config directories
CONFIG_DIRS=($(find_datagrip_configs))

if [ ${#CONFIG_DIRS[@]} -eq 0 ]; then
    echo -e "${RED}No JetBrains DataGrip configuration folders found. Make sure DataGrip is installed and has been run at least once.${NC}"
    exit 1
fi

# Source theme path
SOURCE_THEME_PATH="$(dirname "$0")/NordShade.xml"

# Install the theme for each found config folder
INSTALL_COUNT=0

for CONFIG_DIR in "${CONFIG_DIRS[@]}"; do
    # Each DataGrip config folder should have a "colors" subfolder
    COLORS_DIR="$CONFIG_DIR/colors"
    
    # Create colors directory if it doesn't exist
    if [ ! -d "$COLORS_DIR" ]; then
        echo -e "${CYAN}Creating colors directory: $COLORS_DIR${NC}"
        mkdir -p "$COLORS_DIR"
    fi
    
    # Copy theme file to colors directory
    DEST_THEME_PATH="$COLORS_DIR/NordShade.xml"
    
    echo -e "${CYAN}Installing NordShade theme to: $DEST_THEME_PATH${NC}"
    cp "$SOURCE_THEME_PATH" "$DEST_THEME_PATH"
    INSTALL_COUNT=$((INSTALL_COUNT + 1))
done

if [ $INSTALL_COUNT -gt 0 ]; then
    echo -e "\n${GREEN}NordShade theme has been installed for $INSTALL_COUNT DataGrip configuration folder(s)!${NC}"
    echo -e "\n${YELLOW}To use the theme:${NC}"
    echo -e "${YELLOW}1. Restart DataGrip if it's running${NC}"
    echo -e "${YELLOW}2. Open Settings (Ctrl+Alt+S)${NC}"
    echo -e "${YELLOW}3. Go to Editor > Color Scheme${NC}"
    echo -e "${YELLOW}4. Select 'NordShade' from the dropdown${NC}"
    echo -e "${YELLOW}5. Click 'Apply' or 'OK'${NC}"
else
    echo -e "${RED}Failed to install NordShade theme for JetBrains DataGrip${NC}"
fi 