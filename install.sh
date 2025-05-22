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
        echo -e "${YELLOW}Using fallback download method for $THEME_NAME...${NC}"
        
        # Fallback to basic downloads based on theme name
        case "$THEME_NAME" in
            "VisualStudioCode")
                curl -s "$REPO_URL/raw/main/VisualStudioCode/NordShade.json" -o "$TEMP_PATH/VisualStudioCode/NordShade.json"
                curl -s "$REPO_URL/raw/main/VisualStudioCode/package.json" -o "$TEMP_PATH/VisualStudioCode/package.json"
                curl -s "$REPO_URL/raw/main/VisualStudioCode/README.md" -o "$TEMP_PATH/VisualStudioCode/README.md"
                curl -s "$REPO_URL/raw/main/VisualStudioCode/install.sh" -o "$TEMP_PATH/VisualStudioCode/install.sh"
                chmod +x "$TEMP_PATH/VisualStudioCode/install.sh"
                ;;
            "Obsidian")
                curl -s "$REPO_URL/raw/main/Obsidian/theme.css" -o "$TEMP_PATH/Obsidian/theme.css"
                curl -s "$REPO_URL/raw/main/Obsidian/manifest.json" -o "$TEMP_PATH/Obsidian/manifest.json"
                curl -s "$REPO_URL/raw/main/Obsidian/install.sh" -o "$TEMP_PATH/Obsidian/install.sh"
                chmod +x "$TEMP_PATH/Obsidian/install.sh"
                ;;
            "Neovim")
                curl -s "$REPO_URL/raw/main/Neovim/nord_shade.vim" -o "$TEMP_PATH/Neovim/nord_shade.vim"
                curl -s "$REPO_URL/raw/main/Neovim/install.sh" -o "$TEMP_PATH/Neovim/install.sh"
                chmod +x "$TEMP_PATH/Neovim/install.sh"
                ;;
            "JetBrains")
                curl -s "$REPO_URL/raw/main/JetBrains/NordShade.xml" -o "$TEMP_PATH/JetBrains/NordShade.xml"
                curl -s "$REPO_URL/raw/main/JetBrains/install.sh" -o "$TEMP_PATH/JetBrains/install.sh"
                curl -s "$REPO_URL/raw/main/JetBrains/README.md" -o "$TEMP_PATH/JetBrains/README.md" 2>/dev/null
                chmod +x "$TEMP_PATH/JetBrains/install.sh"
                ;;
            "WindowsTerminal")
                curl -s "$REPO_URL/raw/main/WindowsTerminal/NordShade.json" -o "$TEMP_PATH/WindowsTerminal/NordShade.json"
                curl -s "$REPO_URL/raw/main/WindowsTerminal/install.sh" -o "$TEMP_PATH/WindowsTerminal/install.sh"
                chmod +x "$TEMP_PATH/WindowsTerminal/install.sh"
                ;;
            "Discord")
                curl -s "$REPO_URL/raw/main/Discord/nord_shade.theme.css" -o "$TEMP_PATH/Discord/nord_shade.theme.css"
                curl -s "$REPO_URL/raw/main/Discord/install.sh" -o "$TEMP_PATH/Discord/install.sh"
                chmod +x "$TEMP_PATH/Discord/install.sh"
                ;;
            "GitHubDesktop")
                curl -s "$REPO_URL/raw/main/GitHubDesktop/nord-shade.less" -o "$TEMP_PATH/GitHubDesktop/nord-shade.less"
                curl -s "$REPO_URL/raw/main/GitHubDesktop/install.sh" -o "$TEMP_PATH/GitHubDesktop/install.sh" 2>/dev/null
                chmod +x "$TEMP_PATH/GitHubDesktop/install.sh" 2>/dev/null
                ;;
            *)
                echo -e "${RED}No fallback download method for $THEME_NAME${NC}"
                return 1
                ;;
        esac
        
        return 0
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
        # Basic download for essential files if jq is not available
        echo -e "${YELLOW}jq not available, using fallback download for $THEME_NAME...${NC}"
        case "$THEME_NAME" in
            "VisualStudioCode")
                curl -s "$REPO_URL/raw/main/VisualStudioCode/NordShade.json" -o "$TEMP_PATH/VisualStudioCode/NordShade.json"
                curl -s "$REPO_URL/raw/main/VisualStudioCode/package.json" -o "$TEMP_PATH/VisualStudioCode/package.json"
                curl -s "$REPO_URL/raw/main/VisualStudioCode/README.md" -o "$TEMP_PATH/VisualStudioCode/README.md"
                curl -s "$REPO_URL/raw/main/VisualStudioCode/install.sh" -o "$TEMP_PATH/VisualStudioCode/install.sh"
                chmod +x "$TEMP_PATH/VisualStudioCode/install.sh"
                ;;
            "Obsidian")
                curl -s "$REPO_URL/raw/main/Obsidian/theme.css" -o "$TEMP_PATH/Obsidian/theme.css"
                curl -s "$REPO_URL/raw/main/Obsidian/manifest.json" -o "$TEMP_PATH/Obsidian/manifest.json"
                curl -s "$REPO_URL/raw/main/Obsidian/install.sh" -o "$TEMP_PATH/Obsidian/install.sh"
                chmod +x "$TEMP_PATH/Obsidian/install.sh"
                ;;
            "Neovim")
                curl -s "$REPO_URL/raw/main/Neovim/nord_shade.vim" -o "$TEMP_PATH/Neovim/nord_shade.vim"
                curl -s "$REPO_URL/raw/main/Neovim/install.sh" -o "$TEMP_PATH/Neovim/install.sh"
                chmod +x "$TEMP_PATH/Neovim/install.sh"
                ;;
            "JetBrains")
                curl -s "$REPO_URL/raw/main/JetBrains/NordShade.xml" -o "$TEMP_PATH/JetBrains/NordShade.xml"
                curl -s "$REPO_URL/raw/main/JetBrains/install.sh" -o "$TEMP_PATH/JetBrains/install.sh"
                curl -s "$REPO_URL/raw/main/JetBrains/README.md" -o "$TEMP_PATH/JetBrains/README.md" 2>/dev/null
                chmod +x "$TEMP_PATH/JetBrains/install.sh"
                ;;
            "WindowsTerminal")
                curl -s "$REPO_URL/raw/main/WindowsTerminal/NordShade.json" -o "$TEMP_PATH/WindowsTerminal/NordShade.json"
                curl -s "$REPO_URL/raw/main/WindowsTerminal/install.sh" -o "$TEMP_PATH/WindowsTerminal/install.sh"
                chmod +x "$TEMP_PATH/WindowsTerminal/install.sh"
                ;;
            "Discord")
                curl -s "$REPO_URL/raw/main/Discord/nord_shade.theme.css" -o "$TEMP_PATH/Discord/nord_shade.theme.css"
                curl -s "$REPO_URL/raw/main/Discord/install.sh" -o "$TEMP_PATH/Discord/install.sh"
                chmod +x "$TEMP_PATH/Discord/install.sh"
                ;;
            "GitHubDesktop")
                curl -s "$REPO_URL/raw/main/GitHubDesktop/nord-shade.less" -o "$TEMP_PATH/GitHubDesktop/nord-shade.less"
                curl -s "$REPO_URL/raw/main/GitHubDesktop/install.sh" -o "$TEMP_PATH/GitHubDesktop/install.sh" 2>/dev/null
                chmod +x "$TEMP_PATH/GitHubDesktop/install.sh" 2>/dev/null
                ;;
            *)
                echo -e "${RED}No fallback download method for $THEME_NAME${NC}"
                return 1
                ;;
        esac
    fi
    
    return 0
}

install_vscode_theme() {
    echo -e "${YELLOW}Installing NordShade for Visual Studio Code...${NC}"
    
    # Download theme files if running standalone
    if [ "$IS_REPO" = false ]; then
        download_theme_files "VisualStudioCode"
    fi
    
    # Call the VSCode-specific installer
    bash "$NORDSHADE_ROOT/VisualStudioCode/install.sh" "$NORDSHADE_ROOT/VisualStudioCode" "$GLOBAL_AUTO_APPLY"
}

install_obsidian_theme() {
    echo -e "${YELLOW}Installing NordShade for Obsidian...${NC}"
    
    # Download theme files if running standalone
    if [ "$IS_REPO" = false ]; then
        download_theme_files "Obsidian"
    fi
    
    # Call the Obsidian-specific installer
    bash "$NORDSHADE_ROOT/Obsidian/install.sh" "$NORDSHADE_ROOT/Obsidian" "$GLOBAL_AUTO_APPLY"
}

install_neovim_theme() {
    echo -e "${YELLOW}Installing NordShade for Neovim...${NC}"
    
    # Download theme files if running standalone
    if [ "$IS_REPO" = false ]; then
        download_theme_files "Neovim"
    fi
    
    # Call the Neovim-specific installer
    bash "$NORDSHADE_ROOT/Neovim/install.sh" "$NORDSHADE_ROOT/Neovim" "$GLOBAL_AUTO_APPLY"
}

install_jetbrains_theme() {
    echo -e "${YELLOW}Installing NordShade for JetBrains IDEs...${NC}"
    
    # Download theme files if running standalone
    if [ "$IS_REPO" = false ]; then
        download_theme_files "JetBrains"
    fi
    
    # Call the JetBrains-specific installer
    bash "$NORDSHADE_ROOT/JetBrains/install.sh" "$NORDSHADE_ROOT/JetBrains" "$GLOBAL_AUTO_APPLY"
}

install_windows_terminal_theme() {
    echo -e "${YELLOW}Installing NordShade for Windows Terminal...${NC}"
    
    # Download theme files if running standalone
    if [ "$IS_REPO" = false ]; then
        download_theme_files "WindowsTerminal"
    fi
    
    # Call the Windows Terminal-specific installer
    if [ -f "$NORDSHADE_ROOT/WindowsTerminal/install.sh" ]; then
        bash "$NORDSHADE_ROOT/WindowsTerminal/install.sh" "$NORDSHADE_ROOT/WindowsTerminal" "$GLOBAL_AUTO_APPLY"
    else
        echo -e "${RED}Windows Terminal installer script not found.${NC}"
        echo -e "${YELLOW}Note: Windows Terminal is primarily a Windows application.${NC}"
    fi
}

install_discord_theme() {
    echo -e "${YELLOW}Installing NordShade for Discord...${NC}"
    
    # Download theme files if running standalone
    if [ "$IS_REPO" = false ]; then
        download_theme_files "Discord"
    fi
    
    # Call the Discord-specific installer
    bash "$NORDSHADE_ROOT/Discord/install.sh" "$NORDSHADE_ROOT/Discord" "$GLOBAL_AUTO_APPLY"
}

install_github_desktop_theme() {
    echo -e "${YELLOW}Installing NordShade for GitHub Desktop...${NC}"
    
    # Download theme files if running standalone
    if [ "$IS_REPO" = false ]; then
        download_theme_files "GitHubDesktop"
    fi
    
    # Check if there's a specific installer script
    if [ -f "$NORDSHADE_ROOT/GitHubDesktop/install.sh" ]; then
        bash "$NORDSHADE_ROOT/GitHubDesktop/install.sh" "$NORDSHADE_ROOT/GitHubDesktop" "$GLOBAL_AUTO_APPLY"
    else
        # Fallback to manual instructions
        TARGET_PATH="$HOME/NordShade-GitHubDesktop.less"
        cp "$NORDSHADE_ROOT/GitHubDesktop/nord-shade.less" "$TARGET_PATH"
        
        echo -e "${YELLOW}GitHub Desktop theme file copied to: $TARGET_PATH${NC}"
        echo -e "${YELLOW}GitHub Desktop themes require manual installation.${NC}"
        echo -e "${YELLOW}Please check the project README for installation instructions.${NC}"
    fi
}

install_unix_shell_theme() {
    echo -e "${YELLOW}Installing NordShade for Unix Shell (Bash/Zsh)...${NC}"
    
    # Check if there's a specific installer script
    if [ -f "$NORDSHADE_ROOT/UnixShell/install.sh" ]; then
        bash "$NORDSHADE_ROOT/UnixShell/install.sh"
    else
        echo -e "${YELLOW}Unix Shell theme installer not available yet.${NC}"
    fi
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
    echo -e "${YELLOW}Installing NordShade for all detected applications...${NC}"
    
    # Check and install for each supported application
    if command -v code &> /dev/null; then
        install_vscode_theme
    fi
    
    if [ -f "$HOME/.bashrc" ] || [ -f "$HOME/.zshrc" ]; then
        install_unix_shell_theme
    fi
    
    if command -v obsidian &> /dev/null || [ -d "$HOME/.config/obsidian" ] || [ -d "$HOME/Library/Application Support/obsidian" ]; then
        install_obsidian_theme
    fi
    
    if command -v nvim &> /dev/null || command -v vim &> /dev/null; then
        install_neovim_theme
    fi
    
    # Check for JetBrains IDEs
    if detect_jetbrains; then
        install_jetbrains_theme
    fi
    
    if [ -d "$HOME/.config/BetterDiscord" ] || [ -d "$HOME/Library/Application Support/BetterDiscord" ] || [ -d "$HOME/.config/VencordDesktop" ]; then
        install_discord_theme
    fi
    
    if [ -d "/Applications/GitHub Desktop.app" ] || command -v github &> /dev/null; then
        install_github_desktop_theme
    fi
    
    if command -v wsl.exe &> /dev/null && command -v powershell.exe &> /dev/null; then
        install_windows_terminal_theme
    fi
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
        # Individual application checks

        # Check for VS Code
        if command -v code &> /dev/null; then
            read -p "Visual Studio Code detected. Install NordShade theme? (y/n): " INSTALL_VSCODE
            if [ "$INSTALL_VSCODE" == "y" ]; then
                install_vscode_theme
            fi
        fi

        # Check for Neovim
        if command -v nvim &> /dev/null; then
            read -p "Neovim detected. Install NordShade theme? (y/n): " INSTALL_NEOVIM
            if [ "$INSTALL_NEOVIM" == "y" ]; then
                install_neovim_theme
            fi
        fi

        # Check for JetBrains IDEs
        if detect_jetbrains; then
            read -p "JetBrains IDE detected. Install NordShade theme? (y/n): " INSTALL_JETBRAINS
            if [ "$INSTALL_JETBRAINS" == "y" ]; then
                install_jetbrains_theme
            fi
        fi

        # Check for Discord
        if command -v discord &> /dev/null || [ -d "$HOME/.config/discord" ] || [ -d "$HOME/Library/Application Support/discord" ]; then
            read -p "Discord detected. Install NordShade theme? (y/n): " INSTALL_DISCORD
            if [ "$INSTALL_DISCORD" == "y" ]; then
                install_discord_theme
            fi
        fi

        # Check for GitHub Desktop
        if command -v github-desktop &> /dev/null || [ -d "$HOME/.config/GitHub Desktop" ] || [ -d "$HOME/Applications/GitHub Desktop.app" ]; then
            read -p "GitHub Desktop detected. Install NordShade theme? (y/n): " INSTALL_GITHUB_DESKTOP
            if [ "$INSTALL_GITHUB_DESKTOP" == "y" ]; then
                install_github_desktop_theme
            fi
        fi
        
        # Check for Windows Terminal (WSL)
        if command -v wsl.exe &> /dev/null && command -v powershell.exe &> /dev/null; then
            read -p "Windows Terminal (WSL) detected. Install NordShade theme? (y/n): " INSTALL_WINDOWS_TERMINAL
            if [ "$INSTALL_WINDOWS_TERMINAL" == "y" ]; then
                install_windows_terminal_theme
            fi
        fi

        # Obsidian (ask always since it's difficult to detect)
        read -p "Do you want to install NordShade theme for Obsidian? (y/n): " INSTALL_OBSIDIAN
        if [ "$INSTALL_OBSIDIAN" == "y" ]; then
            install_obsidian_theme
        fi
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