#!/bin/bash
# NordShade for Neovim - Installation Script (Bash)
# Installs the NordShade theme for Neovim

# Define colors for output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Define paths
NEOVIM_COLORS_DIR="$HOME/.config/nvim/colors"

# Create colors directory if it doesn't exist
if [ ! -d "$NEOVIM_COLORS_DIR" ]; then
    echo -e "${CYAN}Creating Neovim colors directory: $NEOVIM_COLORS_DIR${NC}"
    mkdir -p "$NEOVIM_COLORS_DIR"
fi

# Copy theme file to colors directory
SOURCE_THEME_PATH="$(dirname "$0")/nord_shade.vim"
DEST_THEME_PATH="$NEOVIM_COLORS_DIR/nord_shade.vim"

echo -e "${CYAN}Installing NordShade theme for Neovim...${NC}"
if cp "$SOURCE_THEME_PATH" "$DEST_THEME_PATH"; then
    echo -e "${GREEN}Successfully installed NordShade theme for Neovim!${NC}"
    echo -e "${YELLOW}Add the following to your init.vim or init.lua to activate the theme:${NC}"
    echo -e "${YELLOW}For init.vim:${NC}"
    echo -e "${WHITE}colorscheme nord_shade${NC}"
    echo -e "${YELLOW}For init.lua:${NC}"
    echo -e "${WHITE}vim.cmd(\"colorscheme nord_shade\")${NC}"
else
    echo -e "${RED}Error installing NordShade theme for Neovim${NC}"
    exit 1
fi 