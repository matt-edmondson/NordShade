#!/bin/bash
# NordShade Installation Script for macOS/Linux
# This script detects and installs NordShade themes for available applications

NORDSHADE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo -e "\033[36mInstalling NordShade themes from $NORDSHADE_ROOT\033[0m"

install_vscode_theme() {
    echo -e "\033[33mInstalling NordShade for Visual Studio Code...\033[0m"
    
    # Determine OS and set paths
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        VSCODE_PATH="$HOME/.vscode/extensions/nordshade-theme"
    else
        # Linux
        VSCODE_PATH="$HOME/.vscode/extensions/nordshade-theme"
    fi
    
    # Create directory if it doesn't exist
    mkdir -p "$VSCODE_PATH"
    
    # Copy theme files
    cp "$NORDSHADE_ROOT/VisualStudioCode/NordShade.json" "$VSCODE_PATH/"
    cp "$NORDSHADE_ROOT/VisualStudioCode/package.json" "$VSCODE_PATH/"
    cp "$NORDSHADE_ROOT/VisualStudioCode/README.md" "$VSCODE_PATH/"
    
    echo -e "\033[32mVS Code theme installed successfully. Please restart VS Code and select the theme.\033[0m"
}

install_obsidian_theme() {
    echo -e "\033[33mInstalling NordShade for Obsidian...\033[0m"
    
    # Ask for Obsidian vault location
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
    
    # Check if vault exists
    if [ ! -d "$VAULT_PATH" ]; then
        echo -e "\033[31mVault not found at $VAULT_PATH. Please check the path and try again.\033[0m"
        return
    fi
    
    # Create theme directory
    THEME_PATH="$VAULT_PATH/.obsidian/themes/NordShade"
    mkdir -p "$THEME_PATH"
    
    # Copy theme files
    cp "$NORDSHADE_ROOT/Obsidian/theme.css" "$THEME_PATH/"
    cp "$NORDSHADE_ROOT/Obsidian/manifest.json" "$THEME_PATH/"
    
    echo -e "\033[32mObsidian theme installed successfully to $THEME_PATH\033[0m"
    echo -e "\033[32mTo activate, open Obsidian -> Settings -> Appearance -> Select 'NordShade' theme\033[0m"
}

# Check for VS Code
if command -v code &> /dev/null || [ -d "$HOME/.vscode" ]; then
    read -p "Visual Studio Code detected. Install NordShade theme? (y/n): " INSTALL_VSCODE
    if [ "$INSTALL_VSCODE" == "y" ]; then
        install_vscode_theme
    fi
fi

# Obsidian (ask always since it's difficult to detect)
read -p "Do you use Obsidian? Install NordShade theme? (y/n): " INSTALL_OBSIDIAN
if [ "$INSTALL_OBSIDIAN" == "y" ]; then
    install_obsidian_theme
fi

echo -e "\033[36mNordShade installation complete!\033[0m" 