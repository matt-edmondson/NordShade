#!/bin/bash
# NordShade for Discord - Installation Script
# This script installs the NordShade theme for Discord (BetterDiscord or Vencord)

# Define colors for output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

install_discord_theme() {
    local THEME_ROOT="${1:-$(dirname "$0")}"
    
    echo -e "${YELLOW}Installing NordShade for Discord...${NC}"
    
    # Check for BetterDiscord locations
    BETTER_DISCORD_PATHS=(
        "$HOME/.config/BetterDiscord/themes"  # Linux
        "$HOME/Library/Application Support/BetterDiscord/themes"  # macOS
    )
    
    VENCORD_PATHS=(
        "$HOME/.config/Vencord/themes"  # Linux
        "$HOME/Library/Application Support/Vencord/themes"  # macOS
    )
    
    INSTALLED=false
    
    # Try BetterDiscord first
    for path in "${BETTER_DISCORD_PATHS[@]}"; do
        if [ -d "$path" ]; then
            echo -e "${GREEN}BetterDiscord detected...${NC}"
            cp "$THEME_ROOT/nord_shade.theme.css" "$path/"
            echo -e "${GREEN}Theme installed to BetterDiscord themes folder: $path${NC}"
            echo -e "${YELLOW}To activate, open Discord and go to User Settings > BetterDiscord > Themes and enable NordShade${NC}"
            INSTALLED=true
            break
        fi
    done
    
    # Then try Vencord
    for path in "${VENCORD_PATHS[@]}"; do
        if [ -d "$path" ]; then
            echo -e "${GREEN}Vencord detected...${NC}"
            cp "$THEME_ROOT/nord_shade.theme.css" "$path/"
            echo -e "${GREEN}Theme installed to Vencord themes folder: $path${NC}"
            echo -e "${YELLOW}To activate, open Discord and go to User Settings > Vencord > Themes and enable NordShade${NC}"
            INSTALLED=true
            break
        fi
    done
    
    # If neither is installed, just copy theme to home directory
    if [ "$INSTALLED" = false ]; then
        TARGET_PATH="$HOME/NordShade-Discord.theme.css"
        cp "$THEME_ROOT/nord_shade.theme.css" "$TARGET_PATH"
        echo -e "${YELLOW}BetterDiscord or Vencord not detected. Theme file copied to: $TARGET_PATH${NC}"
        echo -e "${YELLOW}To use this theme, you need to install BetterDiscord or Vencord and manually move the theme file to the appropriate themes folder.${NC}"
    fi
    
    return 0
}

# If script is run directly (not sourced), install the theme
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_discord_theme
fi 