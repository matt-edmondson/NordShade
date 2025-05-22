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
    
    # Create necessary directories
    theme_dirs=("VisualStudioCode" "Obsidian")
    for dir in "${theme_dirs[@]}"; do
        mkdir -p "$TEMP_PATH/$dir"
    done
    
    # Download VS Code files
    curl -s "$REPO_URL/raw/main/VisualStudioCode/NordShade.json" -o "$TEMP_PATH/VisualStudioCode/NordShade.json"
    curl -s "$REPO_URL/raw/main/VisualStudioCode/package.json" -o "$TEMP_PATH/VisualStudioCode/package.json"
    curl -s "$REPO_URL/raw/main/VisualStudioCode/README.md" -o "$TEMP_PATH/VisualStudioCode/README.md"
    
    # Download Obsidian files
    curl -s "$REPO_URL/raw/main/Obsidian/theme.css" -o "$TEMP_PATH/Obsidian/theme.css"
    curl -s "$REPO_URL/raw/main/Obsidian/manifest.json" -o "$TEMP_PATH/Obsidian/manifest.json"
    curl -s "$REPO_URL/raw/main/Obsidian/README.md" -o "$TEMP_PATH/Obsidian/README.md"
    
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

# Check if we need to download files
if [ "$IS_REPO" = false ]; then
    download_repository
fi

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

# Clean up temp files if we downloaded them
if [ "$IS_REPO" = false ] && [ -d "$TEMP_PATH" ]; then
    read -p "Remove temporary downloaded files? (y/n): " CLEANUP
    if [ "$CLEANUP" == "y" ]; then
        rm -rf "$TEMP_PATH"
        echo -e "\033[32mTemporary files removed\033[0m"
    fi
fi

echo -e "\033[36mNordShade installation complete!\033[0m" 