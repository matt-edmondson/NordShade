#!/bin/bash
# NordShade Installation Script for macOS/Linux
# This script detects and installs NordShade themes for available applications
# Can be run without cloning the repository

REPO_URL="https://github.com/matt-edmondson/NordShade"
TEMP_PATH="/tmp/NordShade"
CURRENT_PATH=$(pwd)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Determine if we're running from the cloned repo or standalone
if [ -f "$SCRIPT_DIR/README.md" ]; then
    NORDSHADE_ROOT="$SCRIPT_DIR"
    IS_REPO=true
    echo -e "\033[36mInstalling NordShade themes from local repository at $NORDSHADE_ROOT\033[0m"
else
    NORDSHADE_ROOT="$TEMP_PATH"
    IS_REPO=false
    echo -e "\033[36mRunning standalone installation - will download required files\033[0m"
fi

download_repository() {
    echo -e "\033[33mDownloading NordShade repository files...\033[0m"
    
    # Create temp directory if it doesn't exist
    mkdir -p "$TEMP_PATH"
    
    # Check for git and use it if available
    if command -v git &> /dev/null; then
        echo -e "\033[33mUsing git to clone repository...\033[0m"
        pushd /tmp > /dev/null
        git clone --depth 1 $REPO_URL
        popd > /dev/null
        return
    fi
    
    # Fall back to downloading individual theme files
    echo -e "\033[33mGit not found. Downloading individual theme files...\033[0m"
    
    # First, download the index.json file
    INDEX_URL="$REPO_URL/raw/main/index.json"
    INDEX_PATH="$TEMP_PATH/index.json"
    
    # Download the index file
    if curl -s "$INDEX_URL" -o "$INDEX_PATH"; then
        # Check if we have jq available for JSON parsing
        if command -v jq &> /dev/null; then
            echo -e "\033[33mUsing jq to parse index.json...\033[0m"
            BASE_URL=$(jq -r '.baseUrl' "$INDEX_PATH")
            
            # Get all theme names
            THEME_NAMES=$(jq -r '.themes | keys[]' "$INDEX_PATH")
            
            # Loop through each theme
            for THEME_NAME in $THEME_NAMES; do
                echo -e "\033[33mDownloading files for $THEME_NAME...\033[0m"
                
                # Create directory for theme
                mkdir -p "$TEMP_PATH/$THEME_NAME"
                
                # Get all files for this theme
                FILES=$(jq -r ".themes[\"$THEME_NAME\"][]" "$INDEX_PATH")
                
                # Download each file
                for FILE in $FILES; do
                    FILE_URL="$BASE_URL/$THEME_NAME/$FILE"
                    FILE_PATH="$TEMP_PATH/$THEME_NAME/$FILE"
                    echo -e "  - $FILE"
                    curl -s "$FILE_URL" -o "$FILE_PATH"
                    
                    # Make shell scripts executable
                    if [[ "$FILE" == *.sh ]]; then
                        chmod +x "$FILE_PATH"
                    fi
                done
            done
        else
            # Fallback to basic parsing if jq is not available
            echo -e "\033[33mjq not found, using basic parsing for index.json...\033[0m"
            
            # Create basic theme directories
            theme_dirs=("VisualStudioCode" "Obsidian" "Neovim" "JetBrains" "Discord" "GitHubDesktop")
            for dir in "${theme_dirs[@]}"; do
                mkdir -p "$TEMP_PATH/$dir"
            done
            
            # Download essential files
            curl -s "$REPO_URL/raw/main/VisualStudioCode/NordShade.json" -o "$TEMP_PATH/VisualStudioCode/NordShade.json"
            curl -s "$REPO_URL/raw/main/Obsidian/theme.css" -o "$TEMP_PATH/Obsidian/theme.css"
            curl -s "$REPO_URL/raw/main/Obsidian/manifest.json" -o "$TEMP_PATH/Obsidian/manifest.json"
            curl -s "$REPO_URL/raw/main/Neovim/nord_shade.vim" -o "$TEMP_PATH/Neovim/nord_shade.vim"
            curl -s "$REPO_URL/raw/main/Neovim/install.sh" -o "$TEMP_PATH/Neovim/install.sh"
            chmod +x "$TEMP_PATH/Neovim/install.sh"
            curl -s "$REPO_URL/raw/main/JetBrains/NordShade.xml" -o "$TEMP_PATH/JetBrains/NordShade.xml"
            curl -s "$REPO_URL/raw/main/JetBrains/install.sh" -o "$TEMP_PATH/JetBrains/install.sh"
            chmod +x "$TEMP_PATH/JetBrains/install.sh"
            curl -s "$REPO_URL/raw/main/Discord/nord_shade.theme.css" -o "$TEMP_PATH/Discord/nord_shade.theme.css"
            curl -s "$REPO_URL/raw/main/GitHubDesktop/nord-shade.less" -o "$TEMP_PATH/GitHubDesktop/nord-shade.less"
        fi
    else
        echo -e "\033[31mFailed to download index.json, falling back to essential files...\033[0m"
        
        # Create basic theme directories in case index.json fails
        theme_dirs=("VisualStudioCode" "Obsidian" "Neovim" "JetBrains" "Discord" "GitHubDesktop")
        for dir in "${theme_dirs[@]}"; do
            mkdir -p "$TEMP_PATH/$dir"
        done
        
        # Download essential files
        curl -s "$REPO_URL/raw/main/VisualStudioCode/NordShade.json" -o "$TEMP_PATH/VisualStudioCode/NordShade.json"
        curl -s "$REPO_URL/raw/main/Obsidian/theme.css" -o "$TEMP_PATH/Obsidian/theme.css"
        curl -s "$REPO_URL/raw/main/Obsidian/manifest.json" -o "$TEMP_PATH/Obsidian/manifest.json"
        curl -s "$REPO_URL/raw/main/Neovim/nord_shade.vim" -o "$TEMP_PATH/Neovim/nord_shade.vim"
        curl -s "$REPO_URL/raw/main/Neovim/install.sh" -o "$TEMP_PATH/Neovim/install.sh"
        chmod +x "$TEMP_PATH/Neovim/install.sh"
        curl -s "$REPO_URL/raw/main/JetBrains/NordShade.xml" -o "$TEMP_PATH/JetBrains/NordShade.xml"
        curl -s "$REPO_URL/raw/main/JetBrains/install.sh" -o "$TEMP_PATH/JetBrains/install.sh"
        chmod +x "$TEMP_PATH/JetBrains/install.sh"
        curl -s "$REPO_URL/raw/main/Discord/nord_shade.theme.css" -o "$TEMP_PATH/Discord/nord_shade.theme.css"
        curl -s "$REPO_URL/raw/main/GitHubDesktop/nord-shade.less" -o "$TEMP_PATH/GitHubDesktop/nord-shade.less"
    fi
    
    echo -e "\033[32mTheme files downloaded successfully\033[0m"
}

install_vscode_theme() {
    echo -e "\033[33mInstalling NordShade for Visual Studio Code...\033[0m"
    
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
    cp "$NORDSHADE_ROOT/VisualStudioCode/NordShade.json" "$VSCODE_PATH/"
    cp "$NORDSHADE_ROOT/VisualStudioCode/package.json" "$VSCODE_PATH/"
    cp "$NORDSHADE_ROOT/VisualStudioCode/README.md" "$VSCODE_PATH/"
    
    # Automatically apply the theme by updating settings.json
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
    
    echo -e "\033[32mVS Code theme installed and automatically applied!\033[0m"
    echo -e "\033[32mSettings backup created at $SETTINGS_PATH.backup\033[0m"
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
    
    # Try to auto-apply theme by updating appearance.json
    APPEARANCE_PATH="$VAULT_PATH/.obsidian/appearance.json"
    
    if [ -f "$APPEARANCE_PATH" ]; then
        # Backup appearance.json
        cp "$APPEARANCE_PATH" "$APPEARANCE_PATH.backup"
        echo -e "\033[32mBacked up Obsidian appearance settings to $APPEARANCE_PATH.backup\033[0m"
        
        # Update theme setting
        if command -v jq &> /dev/null; then
            # Using jq for proper JSON manipulation
            jq '.theme = "NordShade"' "$APPEARANCE_PATH" > "$APPEARANCE_PATH.tmp" && mv "$APPEARANCE_PATH.tmp" "$APPEARANCE_PATH"
            echo -e "\033[32mObsidian theme installed and applied successfully!\033[0m"
        else
            # Attempt a basic manipulation if jq is not available
            if grep -q "\"theme\"" "$APPEARANCE_PATH"; then
                # Replace existing theme setting
                sed -i.bak 's/"theme"\s*:\s*"[^"]*"/"theme": "NordShade"/g' "$APPEARANCE_PATH"
                echo -e "\033[32mObsidian theme installed and applied successfully!\033[0m"
            else
                # Add theme setting
                sed -i.bak 's/{/{\"theme\": \"NordShade\", /g' "$APPEARANCE_PATH"
                echo -e "\033[32mObsidian theme installed and applied successfully!\033[0m"
            fi
        fi
        
        echo -e "\033[33mIf Obsidian is currently running, you may need to restart it for changes to take effect.\033[0m"
    else
        echo -e "\033[33mCould not find Obsidian appearance settings. Theme has been installed but must be activated manually.\033[0m"
        echo -e "\033[32mTheme installed successfully to $THEME_PATH\033[0m"
        echo -e "\033[33mTo activate, open Obsidian -> Settings -> Appearance -> Select 'NordShade' theme\033[0m"
    fi
}

install_neovim_theme() {
    echo -e "\033[33mInstalling NordShade for Neovim...\033[0m"
    # Call the Neovim-specific installer
    "$NORDSHADE_ROOT/Neovim/install.sh"
}

install_jetbrains_theme() {
    echo -e "\033[33mInstalling NordShade for JetBrains IDEs...\033[0m"
    
    # Call the JetBrains-specific installer
    bash "$NORDSHADE_ROOT/JetBrains/install.sh"
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

install_discord_theme() {
    echo -e "\033[33mInstalling NordShade for Discord...\033[0m"
    
    # Check for BetterDiscord locations
    BETTER_DISCORD_PATHS=(
        "$HOME/.config/BetterDiscord/themes"  # Linux
        "$HOME/Library/Application Support/BetterDiscord/themes"  # macOS
    )
    
    FOUND_BD=false
    for path in "${BETTER_DISCORD_PATHS[@]}"; do
        if [ -d "$path" ]; then
            cp "$NORDSHADE_ROOT/Discord/nord_shade.theme.css" "$path/"
            echo -e "\033[32mTheme installed to BetterDiscord themes folder: $path\033[0m"
            echo -e "\033[33mTo activate, open Discord and go to User Settings > BetterDiscord > Themes and enable NordShade\033[0m"
            FOUND_BD=true
            break
        fi
    done
    
    if [ "$FOUND_BD" = false ]; then
        # Just copy theme to home directory for manual installation
        TARGET_PATH="$HOME/NordShade-Discord.theme.css"
        cp "$NORDSHADE_ROOT/Discord/nord_shade.theme.css" "$TARGET_PATH"
        echo -e "\033[33mBetterDiscord not detected. Theme file copied to: $TARGET_PATH\033[0m"
        echo -e "\033[33mPlease refer to Discord theme README.md for manual installation instructions\033[0m"
    fi
}

install_github_desktop_theme() {
    echo -e "\033[33mInstalling NordShade for GitHub Desktop...\033[0m"
    
    # Copy file to home directory for user to manually install
    TARGET_PATH="$HOME/NordShade-GitHubDesktop.less"
    cp "$NORDSHADE_ROOT/GitHubDesktop/nord-shade.less" "$TARGET_PATH"
    
    echo -e "\033[33mGitHub Desktop theme file copied to: $TARGET_PATH\033[0m"
    echo -e "\033[33mPlease refer to GitHubDesktop README.md for manual installation instructions\033[0m"
}

# Check if we need to download files
if [ "$IS_REPO" = false ]; then
    download_repository
fi

# Present the menu to the user
echo -e "\033[36m===== NordShade Theme Installer =====\033[0m"
echo -e "\033[36m==================================\033[0m"
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

        # Obsidian (ask always since it's difficult to detect)
        read -p "Do you want to install NordShade theme for Obsidian? (y/n): " INSTALL_OBSIDIAN
        if [ "$INSTALL_OBSIDIAN" == "y" ]; then
            install_obsidian_theme
        fi
        ;;
    3)
        echo -e "\033[32mExiting NordShade installer. No changes were made.\033[0m"
        exit 0
        ;;
    *)
        echo -e "\033[31mInvalid option. Exiting.\033[0m"
        exit 1
        ;;
esac

echo -e "\033[32mNordShade installation complete!\033[0m"

install_all_themes() {
    echo -e "\033[33mInstalling NordShade for all detected applications...\033[0m"
    
    # Check and install for each supported application
    if command -v code &> /dev/null; then
        install_vscode_theme
    fi
    
    if [ -d "/Applications/Visual Studio.app" ] || [ -d "/Applications/Visual Studio Code.app" ] || command -v devenv &> /dev/null; then
        install_vs2022_theme
    fi
    
    if [ -d "$HOME/.config/Microsoft/Windows Terminal" ] || [ -d "$HOME/Library/Application Support/Microsoft/Windows Terminal" ]; then
        install_windows_terminal_theme
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
} 