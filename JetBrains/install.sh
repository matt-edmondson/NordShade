#!/bin/bash
# NordShade for JetBrains IDEs - Installation Script (Bash)
# Installs the NordShade theme for JetBrains IDEs (IntelliJ IDEA, WebStorm, PyCharm, DataGrip, Rider, etc.)

# Define colors for output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to find JetBrains IDE config directories
find_jetbrains_configs() {
    local patterns=(
        # Linux patterns
        "$HOME/.config/JetBrains/*"
        "$HOME/.JetBrains/*"
        # Direct product paths - Linux
        "$HOME/.config/JetBrains/IntelliJIdea*"
        "$HOME/.config/JetBrains/WebStorm*"
        "$HOME/.config/JetBrains/PyCharm*"
        "$HOME/.config/JetBrains/CLion*"
        "$HOME/.config/JetBrains/DataGrip*"
        "$HOME/.config/JetBrains/GoLand*"
        "$HOME/.config/JetBrains/PhpStorm*"
        "$HOME/.config/JetBrains/Rider*"
        "$HOME/.config/JetBrains/RubyMine*"
        "$HOME/.IntelliJIdea*"
        "$HOME/.WebStorm*"
        "$HOME/.PyCharm*"
        "$HOME/.CLion*"
        "$HOME/.DataGrip*"
        "$HOME/.GoLand*"
        "$HOME/.PhpStorm*"
        "$HOME/.Rider*"
        "$HOME/.RubyMine*"
        # macOS patterns
        "$HOME/Library/Application Support/JetBrains/*"
        # Direct product paths - macOS
        "$HOME/Library/Application Support/JetBrains/IntelliJIdea*"
        "$HOME/Library/Application Support/JetBrains/WebStorm*"
        "$HOME/Library/Application Support/JetBrains/PyCharm*"
        "$HOME/Library/Application Support/JetBrains/CLion*"
        "$HOME/Library/Application Support/JetBrains/DataGrip*"
        "$HOME/Library/Application Support/JetBrains/GoLand*"
        "$HOME/Library/Application Support/JetBrains/PhpStorm*"
        "$HOME/Library/Application Support/JetBrains/Rider*"
        "$HOME/Library/Application Support/JetBrains/RubyMine*"
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

# Get JetBrains IDE config directories
CONFIG_DIRS=($(find_jetbrains_configs))

if [ ${#CONFIG_DIRS[@]} -eq 0 ]; then
    echo -e "${RED}No JetBrains IDE configuration folders found. Make sure a JetBrains IDE is installed and has been run at least once.${NC}"
    exit 1
fi

# Source theme path
SOURCE_THEME_PATH="$(dirname "$0")/NordShade.xml"

# Install the theme for each found config folder
INSTALL_COUNT=0
DETECTED_IDES=()

for CONFIG_DIR in "${CONFIG_DIRS[@]}"; do
    # Each JetBrains IDE config folder should have a "colors" subfolder
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
    
    # Extract IDE name from path for reporting
    IDE_NAME="Unknown"
    if [[ "$CONFIG_DIR" =~ (IntelliJIdea|WebStorm|PyCharm|CLion|DataGrip|GoLand|PhpStorm|Rider|RubyMine) ]]; then
        IDE_NAME="${BASH_REMATCH[1]}"
        if [[ ! " ${DETECTED_IDES[@]} " =~ " ${IDE_NAME} " ]]; then
            DETECTED_IDES+=("$IDE_NAME")
        fi
    fi
done

if [ $INSTALL_COUNT -gt 0 ]; then
    echo -e "\n${GREEN}NordShade theme has been installed for $INSTALL_COUNT JetBrains IDE configuration folder(s)!${NC}"
    if [ ${#DETECTED_IDES[@]} -gt 0 ]; then
        echo -e "${GREEN}Detected IDEs: ${DETECTED_IDES[*]}${NC}"
    fi
    echo -e "\n${YELLOW}To use the theme:${NC}"
    echo -e "${YELLOW}1. Restart your JetBrains IDE if it's running${NC}"
    echo -e "${YELLOW}2. Open Settings (Ctrl+Alt+S)${NC}"
    echo -e "${YELLOW}3. Go to Editor > Color Scheme${NC}"
    echo -e "${YELLOW}4. Select 'NordShade' from the dropdown${NC}"
    echo -e "${YELLOW}5. Click 'Apply' or 'OK'${NC}"
else
    echo -e "${RED}Failed to install NordShade theme for JetBrains IDEs${NC}"
fi 