# NordShade Installation Script for Windows
# This script detects and installs NordShade themes for available applications
# Can be run without cloning the repository

$ErrorActionPreference = "SilentlyContinue"
$RepoURL = "https://github.com/matt-edmondson/NordShade"
$RepoAPIURL = "https://api.github.com/repos/matt-edmondson/NordShade/contents"
$TempPath = "$env:TEMP\NordShade"
$CurrentPath = Get-Location
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

# Determine if we're running from the cloned repo or standalone
if (Test-Path "$PSScriptRoot\README.md") {
    $NordShadeRoot = $PSScriptRoot
    $IsRepo = $true
    Write-Host "Installing NordShade themes from local repository at $NordShadeRoot" -ForegroundColor Cyan
} else {
    $NordShadeRoot = $TempPath
    $IsRepo = $false
    Write-Host "Running standalone installation - will download required files" -ForegroundColor Cyan
}

function Download-Repository {
    Write-Host "Downloading NordShade repository files..." -ForegroundColor Yellow
    
    # Create temp directory if it doesn't exist
    if (-not (Test-Path $TempPath)) {
        New-Item -Path $TempPath -ItemType Directory -Force | Out-Null
    }
    
    # Check for git and use it if available
    if (Get-Command git -ErrorAction SilentlyContinue) {
        Write-Host "Using git to clone repository..." -ForegroundColor Yellow
        Push-Location $env:TEMP
        & git clone --depth 1 $RepoURL
        Pop-Location
        return
    }
    
    # Fall back to downloading individual theme files
    Write-Host "Git not found. Downloading individual theme files..." -ForegroundColor Yellow
    
    # First, download the index.json file
    $indexUrl = "$RepoURL/raw/main/index.json"
    $indexPath = "$TempPath\index.json"
    
    try {
        Invoke-WebRequest -Uri $indexUrl -OutFile $indexPath
        $indexJson = Get-Content -Path $indexPath -Raw | ConvertFrom-Json
        $baseUrl = $indexJson.baseUrl
        
        # Loop through each theme in the index
        foreach ($themeName in $indexJson.themes.PSObject.Properties.Name) {
            Write-Host "Downloading files for $themeName..." -ForegroundColor Yellow
            
            # Create directory for theme if it doesn't exist
            if (-not (Test-Path "$TempPath\$themeName")) {
                New-Item -Path "$TempPath\$themeName" -ItemType Directory -Force | Out-Null
            }
            
            # Download each file listed for this theme
            foreach ($file in $indexJson.themes.$themeName) {
                $fileUrl = "$baseUrl/$themeName/$file"
                $filePath = "$TempPath\$themeName\$file"
                Write-Host "  - $file" -ForegroundColor Gray
                try {
                    Invoke-WebRequest -Uri $fileUrl -OutFile $filePath
                } catch {
                    Write-Host "    Failed to download $file: $_" -ForegroundColor Red
                }
            }
        }
    } catch {
        Write-Host "Failed to download or parse index.json: $_" -ForegroundColor Red
        Write-Host "Falling back to essential files..." -ForegroundColor Yellow
        
        # Create basic theme directories in case index.json fails
        $themeDirs = @(
            "VisualStudioCode", "VisualStudio2022", "WindowsTerminal", "Windows11", 
            "MicrosoftEdge", "Obsidian", "Neovim", "JetBrains", "Discord", "GitHubDesktop"
        )
        foreach ($dir in $themeDirs) {
            if (-not (Test-Path "$TempPath\$dir")) {
                New-Item -Path "$TempPath\$dir" -ItemType Directory -Force | Out-Null
            }
        }
        
        # Essential files minimum required
        Invoke-WebRequest -Uri "$RepoURL/raw/main/VisualStudioCode/NordShade.json" -OutFile "$TempPath\VisualStudioCode\NordShade.json"
        Invoke-WebRequest -Uri "$RepoURL/raw/main/VisualStudio2022/NordShade.vssettings" -OutFile "$TempPath\VisualStudio2022\NordShade.vssettings"
        Invoke-WebRequest -Uri "$RepoURL/raw/main/WindowsTerminal/NordShade.json" -OutFile "$TempPath\WindowsTerminal\NordShade.json"
        Invoke-WebRequest -Uri "$RepoURL/raw/main/Windows11/theme.deskthemepack" -OutFile "$TempPath\Windows11\theme.deskthemepack"
        Invoke-WebRequest -Uri "$RepoURL/raw/main/Neovim/nord_shade.vim" -OutFile "$TempPath\Neovim\nord_shade.vim"
        Invoke-WebRequest -Uri "$RepoURL/raw/main/JetBrains/NordShade.xml" -OutFile "$TempPath\JetBrains\NordShade.xml"
    }
    
    Write-Host "Theme files downloaded successfully" -ForegroundColor Green
}

function Install-VSCodeTheme {
    $vsCodeExtPath = "$env:USERPROFILE\.vscode\extensions\nordshade-theme"
    Write-Host "Installing NordShade for Visual Studio Code..." -ForegroundColor Yellow
    
    # Create directory if it doesn't exist
    if (-not (Test-Path $vsCodeExtPath)) {
        New-Item -Path $vsCodeExtPath -ItemType Directory -Force | Out-Null
    }
    
    # Copy theme files
    Copy-Item "$NordShadeRoot\VisualStudioCode\NordShade.json" -Destination $vsCodeExtPath
    Copy-Item "$NordShadeRoot\VisualStudioCode\package.json" -Destination $vsCodeExtPath
    Copy-Item "$NordShadeRoot\VisualStudioCode\README.md" -Destination $vsCodeExtPath
    
    # Automatically apply the theme by updating settings.json
    $settingsPath = "$env:APPDATA\Code\User\settings.json"
    
    # Create settings.json if it doesn't exist
    if (-not (Test-Path $settingsPath)) {
        New-Item -Path $settingsPath -ItemType File -Force | Out-Null
        Set-Content -Path $settingsPath -Value "{}"
    }
    
    # Read current settings
    try {
        $settings = Get-Content -Path $settingsPath -Raw | ConvertFrom-Json
    } catch {
        # If the file is invalid JSON, create a new settings object
        $settings = [PSCustomObject]@{}
    }

    # Backup settings
    Copy-Item -Path $settingsPath -Destination "$settingsPath.backup" -Force
    
    # Update workbench color theme
    $settings.PSObject.Properties.Remove('workbench.colorTheme')
    $settings | Add-Member -Type NoteProperty -Name 'workbench.colorTheme' -Value 'NordShade'
    
    # Save settings
    $settings | ConvertTo-Json -Depth 20 | Set-Content -Path $settingsPath
    
    Write-Host "VS Code theme installed and automatically applied!" -ForegroundColor Green
    Write-Host "Settings backup created at $settingsPath.backup" -ForegroundColor Green
}

function Install-VisualStudioTheme {
    Write-Host "Installing NordShade for Visual Studio 2022..." -ForegroundColor Yellow
    
    # Copy settings file to a location the user can easily access
    $settingsPath = "$env:USERPROFILE\Documents\NordShade.vssettings"
    Copy-Item "$NordShadeRoot\VisualStudio2022\NordShade.vssettings" -Destination $settingsPath
    
    # Try to apply settings automatically using devenv.exe
    $vsPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\VisualStudio\SxS\VS7" -Name "17.0" -ErrorAction SilentlyContinue)."17.0"
    if ($vsPath) {
        $devenvPath = Join-Path $vsPath "Common7\IDE\devenv.exe"
        if (Test-Path $devenvPath) {
            Write-Host "Attempting to apply Visual Studio settings automatically..." -ForegroundColor Yellow
            Start-Process -FilePath $devenvPath -ArgumentList "/resetuserdata", "/command", "Tools.ImportandExportSettings /import:""$settingsPath""" -Wait
            Write-Host "Visual Studio theme should be applied. If Visual Studio was running, you may need to restart it." -ForegroundColor Green
        } else {
            Write-Host "Could not find Visual Studio executable. Theme installed but must be applied manually." -ForegroundColor Yellow
            Write-Host "To apply the theme, open Visual Studio -> Tools -> Import and Export Settings..." -ForegroundColor Yellow
            Write-Host "Then select 'Import selected environment settings' and browse to: $settingsPath" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Visual Studio settings file copied to $settingsPath" -ForegroundColor Green
        Write-Host "To apply the theme, open Visual Studio -> Tools -> Import and Export Settings..." -ForegroundColor Yellow
        Write-Host "Then select 'Import selected environment settings' and browse to the file location." -ForegroundColor Yellow
    }
}

function Install-WindowsTerminalTheme {
    Write-Host "Installing NordShade for Windows Terminal..." -ForegroundColor Yellow
    
    # Get Windows Terminal settings path
    $settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    $settingsPathPreview = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
    
    # Check if settings.json exists in either location
    if (Test-Path $settingsPath) {
        $terminalSettingsPath = $settingsPath
    } elseif (Test-Path $settingsPathPreview) {
        $terminalSettingsPath = $settingsPathPreview
    } else {
        Write-Host "Windows Terminal settings.json not found." -ForegroundColor Red
        return
    }
    
    # Read terminal settings
    $settings = Get-Content -Path $terminalSettingsPath -Raw | ConvertFrom-Json
    
    # Backup existing settings
    Copy-Item -Path $terminalSettingsPath -Destination "$terminalSettingsPath.backup"
    Write-Host "Backed up existing settings to $terminalSettingsPath.backup" -ForegroundColor Green
    
    # Get NordShade scheme
    $nordShadeScheme = Get-Content -Path "$NordShadeRoot\WindowsTerminal\NordShade.json" -Raw | ConvertFrom-Json
    
    # Check if schemes property exists, create if it doesn't
    if (-not $settings.schemes) {
        $settings | Add-Member -Type NoteProperty -Name schemes -Value @()
    }
    
    # Remove existing NordShade scheme if it exists
    $settings.schemes = $settings.schemes | Where-Object { $_.name -ne "NordShade" }
    
    # Add NordShade scheme
    $settings.schemes += $nordShadeScheme
    
    # Apply theme to all profiles
    if ($settings.profiles -and $settings.profiles.defaults) {
        # Set the colorScheme property in defaults to apply to all profiles
        $settings.profiles.defaults | Add-Member -Type NoteProperty -Name colorScheme -Value "NordShade" -Force
    }
    
    # Save settings
    $settings | ConvertTo-Json -Depth 20 | Set-Content -Path $terminalSettingsPath
    
    Write-Host "Windows Terminal theme installed and applied as the default color scheme!" -ForegroundColor Green
}

function Install-Windows11Theme {
    Write-Host "Installing NordShade for Windows 11..." -ForegroundColor Yellow
    
    # Create destination folder for the wallpaper
    $themeDir = "$env:WINDIR\Resources\Themes\NordShade"
    if (-not (Test-Path $themeDir)) {
        New-Item -Path $themeDir -ItemType Directory -Force | Out-Null
    }
    
    # Copy theme file
    $themePath = "$env:USERPROFILE\AppData\Local\Microsoft\Windows\Themes\NordShade.theme"
    Copy-Item "$NordShadeRoot\Windows11\theme.deskthemepack" -Destination $themePath
    
    # Copy the wallpaper if it exists
    $wallpaperSource = "$NordShadeRoot\Windows11\NordShade.jpg"
    $wallpaperDest = "$themeDir\NordShade.jpg"
    
    if (Test-Path $wallpaperSource) {
        Write-Host "Copying NordShade wallpaper..." -ForegroundColor Yellow
        Copy-Item $wallpaperSource -Destination $wallpaperDest -Force
        Write-Host "Wallpaper installed to $wallpaperDest" -ForegroundColor Green
    } else {
        Write-Host "NordShade wallpaper not found at $wallpaperSource" -ForegroundColor Red
        Write-Host "Please provide a wallpaper named 'NordShade.jpg' in $themeDir" -ForegroundColor Yellow
    }
    
    # Try to apply the theme automatically
    Write-Host "Attempting to apply Windows 11 theme automatically..." -ForegroundColor Yellow
    
    try {
        # Apply the theme using rundll32
        Start-Process -FilePath "rundll32.exe" -ArgumentList "desk.cpl,InstallTheme $themePath" -Wait
        Write-Host "Windows 11 theme applied successfully!" -ForegroundColor Green
    } catch {
        Write-Host "Could not apply theme automatically. Theme installed to $themePath" -ForegroundColor Yellow
        Write-Host "To apply the theme, double-click the theme file or go to Settings -> Personalization -> Themes" -ForegroundColor Yellow
    }
    
    if (Test-Path $wallpaperDest) {
        Write-Host "Wallpaper is ready and will be used by the theme" -ForegroundColor Green
    } else {
        Write-Host "Note: You'll need to provide a wallpaper named 'NordShade.jpg' in $themeDir" -ForegroundColor Yellow
    }
}

function Install-EdgeTheme {
    Write-Host "Installing NordShade for Microsoft Edge..." -ForegroundColor Yellow
    
    # Create extension directory
    $edgeExtPath = "$env:USERPROFILE\EdgeExtensions\NordShade"
    if (-not (Test-Path $edgeExtPath)) {
        New-Item -Path $edgeExtPath -ItemType Directory -Force | Out-Null
    }
    
    # Copy extension files
    Copy-Item "$NordShadeRoot\MicrosoftEdge\manifest.json" -Destination $edgeExtPath
    
    Write-Host "Microsoft Edge theme prepared at $edgeExtPath" -ForegroundColor Green
    Write-Host "Edge themes require manual installation. To install:" -ForegroundColor Yellow
    Write-Host "1. Open Edge and go to edge://extensions/" -ForegroundColor Yellow
    Write-Host "2. Enable Developer Mode (toggle in the bottom-left)" -ForegroundColor Yellow
    Write-Host "3. Click 'Load unpacked' and select the folder: $edgeExtPath" -ForegroundColor Yellow
}

function Install-ObsidianTheme {
    Write-Host "Installing NordShade for Obsidian..." -ForegroundColor Yellow
    
    # Ask for Obsidian vault location
    $defaultVault = "$env:USERPROFILE\Documents\Obsidian"
    $vaultPath = Read-Host "Enter your Obsidian vault path (or press Enter for default: $defaultVault)"
    
    if ([string]::IsNullOrWhiteSpace($vaultPath)) {
        $vaultPath = $defaultVault
    }
    
    # Check if vault exists
    if (-not (Test-Path $vaultPath)) {
        Write-Host "Vault not found at $vaultPath. Please check the path and try again." -ForegroundColor Red
        return
    }
    
    # Create theme directory
    $obsidianThemePath = "$vaultPath\.obsidian\themes\NordShade"
    if (-not (Test-Path $obsidianThemePath)) {
        New-Item -Path $obsidianThemePath -ItemType Directory -Force | Out-Null
    }
    
    # Copy theme files
    Copy-Item "$NordShadeRoot\Obsidian\theme.css" -Destination $obsidianThemePath
    Copy-Item "$NordShadeRoot\Obsidian\manifest.json" -Destination $obsidianThemePath
    
    # Try to auto-apply theme by updating appearance.json
    $appearanceJsonPath = "$vaultPath\.obsidian\appearance.json"
    
    if (Test-Path $appearanceJsonPath) {
        # Backup appearance.json
        Copy-Item -Path $appearanceJsonPath -Destination "$appearanceJsonPath.backup" -Force
        Write-Host "Backed up Obsidian appearance settings to $appearanceJsonPath.backup" -ForegroundColor Green
        
        try {
            # Read appearance.json
            $appearanceConfig = Get-Content -Path $appearanceJsonPath -Raw | ConvertFrom-Json
            
            # Update theme setting
            $appearanceConfig.theme = "NordShade"
            
            # Save updated config
            $appearanceConfig | ConvertTo-Json -Depth 20 | Set-Content -Path $appearanceJsonPath
            
            Write-Host "Obsidian theme installed and applied successfully!" -ForegroundColor Green
            Write-Host "If Obsidian is currently running, you may need to restart it for changes to take effect." -ForegroundColor Yellow
        } catch {
            Write-Host "Could not automatically apply Obsidian theme." -ForegroundColor Yellow
            Write-Host "Theme installed successfully to $obsidianThemePath" -ForegroundColor Green
            Write-Host "To activate, open Obsidian -> Settings -> Appearance -> Select 'NordShade' theme" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Could not find Obsidian appearance settings. Theme has been installed but must be activated manually." -ForegroundColor Yellow
        Write-Host "Theme installed successfully to $obsidianThemePath" -ForegroundColor Green
        Write-Host "To activate, open Obsidian -> Settings -> Appearance -> Select 'NordShade' theme" -ForegroundColor Yellow
    }
}

function Install-NeovimTheme {
    Write-Host "Installing NordShade for Neovim..." -ForegroundColor Yellow
    
    # Call the Neovim-specific installer
    & "$NordShadeRoot\Neovim\install.ps1"
}

function Install-JetBrainsTheme {
    Write-Host "Installing NordShade for JetBrains IDEs..." -ForegroundColor Yellow
    
    # Call the JetBrains-specific installer
    & "$NordShadeRoot\JetBrains\install.ps1"
}

function Install-DiscordTheme {
    Write-Host "Installing NordShade for Discord..." -ForegroundColor Yellow
    
    # Check if BetterDiscord is installed
    $betterDiscordPath = "$env:APPDATA\BetterDiscord\themes"
    
    if (Test-Path $betterDiscordPath) {
        Copy-Item "$NordShadeRoot\Discord\nord_shade.theme.css" -Destination $betterDiscordPath
        Write-Host "Theme installed to BetterDiscord themes folder: $betterDiscordPath" -ForegroundColor Green
        Write-Host "To activate, open Discord and go to User Settings > BetterDiscord > Themes and enable NordShade" -ForegroundColor Yellow
    } else {
        # Just copy theme to Documents folder for manual installation
        $targetPath = "$env:USERPROFILE\Documents\NordShade-Discord.theme.css"
        Copy-Item "$NordShadeRoot\Discord\nord_shade.theme.css" -Destination $targetPath
        Write-Host "BetterDiscord not detected. Theme file copied to: $targetPath" -ForegroundColor Yellow
        Write-Host "Please refer to $NordShadeRoot\Discord\README.md for manual installation instructions" -ForegroundColor Yellow
    }
}

function Install-GitHubDesktopTheme {
    Write-Host "Installing NordShade for GitHub Desktop..." -ForegroundColor Yellow
    
    # Copy file to Documents for user to manually install
    $targetPath = "$env:USERPROFILE\Documents\NordShade-GitHubDesktop.less"
    Copy-Item "$NordShadeRoot\GitHubDesktop\nord-shade.less" -Destination $targetPath
    
    Write-Host "GitHub Desktop theme file copied to: $targetPath" -ForegroundColor Yellow
    Write-Host "Please refer to $NordShadeRoot\GitHubDesktop\README.md for manual installation instructions" -ForegroundColor Yellow
}

function Install-AllThemes {
    Write-Host "Installing NordShade for all detected applications..." -ForegroundColor Yellow
    
    # Check and install for each supported application
    if (Get-Command code -ErrorAction SilentlyContinue) {
        Install-VSCodeTheme
    }
    
    if (Get-Command devenv -ErrorAction SilentlyContinue) {
        Install-VisualStudioTheme
    }
    
    if (Test-Path "$env:LOCALAPPDATA\Microsoft\Windows Terminal") {
        Install-WindowsTerminalTheme
    }
    
    if ([Environment]::OSVersion.Version.Major -ge 10) {
        Install-Windows11Theme
    }
    
    if (Test-Path "$env:PROGRAMFILES\Microsoft\Edge\Application\msedge.exe" -or Test-Path "${env:PROGRAMFILES(x86)}\Microsoft\Edge\Application\msedge.exe") {
        Install-EdgeTheme
    }
    
    if (Test-Path "$env:APPDATA\obsidian") {
        Install-ObsidianTheme
    }
    
    if (Get-Command nvim -ErrorAction SilentlyContinue) {
        Install-NeovimTheme
    }
    
    # Check for JetBrains IDEs
    if ($JetBrainsDetected) {
        Install-JetBrainsTheme
    }
    
    if (Test-Path "$env:APPDATA\BetterDiscord" -or Test-Path "$env:APPDATA\BetterDiscord\plugins" -or Test-Path "$env:APPDATA\Vencord") {
        Install-DiscordTheme
    }
    
    if (Test-Path "$env:LOCALAPPDATA\GitHubDesktop") {
        Install-GitHubDesktopTheme
    }
}

# Check if we need to download files
if (-not $IsRepo) {
    Download-Repository
}

# Check for VS Code
if (Get-Command code -ErrorAction SilentlyContinue) {
    $installVSCode = Read-Host "Visual Studio Code detected. Install NordShade theme? (y/n)"
    if ($installVSCode -eq "y") {
        Install-VSCodeTheme
    }
} elseif (Test-Path "$env:USERPROFILE\.vscode") {
    $installVSCode = Read-Host "Visual Studio Code directory detected. Install NordShade theme? (y/n)"
    if ($installVSCode -eq "y") {
        Install-VSCodeTheme
    }
}

# Check for Visual Studio 2022
if (Test-Path "HKLM:\SOFTWARE\Microsoft\VisualStudio\17.0") {
    $installVS = Read-Host "Visual Studio 2022 detected. Install NordShade theme? (y/n)"
    if ($installVS -eq "y") {
        Install-VisualStudioTheme
    }
}

# Check for Windows Terminal
if (Get-AppxPackage -Name Microsoft.WindowsTerminal -ErrorAction SilentlyContinue) {
    $installWT = Read-Host "Windows Terminal detected. Install NordShade theme? (y/n)"
    if ($installWT -eq "y") {
        Install-WindowsTerminalTheme
    }
} elseif (Get-AppxPackage -Name Microsoft.WindowsTerminalPreview -ErrorAction SilentlyContinue) {
    $installWT = Read-Host "Windows Terminal Preview detected. Install NordShade theme? (y/n)"
    if ($installWT -eq "y") {
        Install-WindowsTerminalTheme
    }
}

# Check for Edge
if (Test-Path "$env:PROGRAMFILES (x86)\Microsoft\Edge\Application\msedge.exe") {
    $installEdge = Read-Host "Microsoft Edge detected. Install NordShade theme? (y/n)"
    if ($installEdge -eq "y") {
        Install-EdgeTheme
    }
}

# Check for Windows 11
if ([Environment]::OSVersion.Version.Build -ge 22000) {
    $installWin11 = Read-Host "Windows 11 detected. Install NordShade theme? (y/n)"
    if ($installWin11 -eq "y") {
        Install-Windows11Theme
    }
}

# Obsidian (ask always since it's difficult to detect)
$installObsidian = Read-Host "Do you use Obsidian? Install NordShade theme? (y/n)"
if ($installObsidian -eq "y") {
    Install-ObsidianTheme
}

# Check for JetBrains IDEs
$JetBrainsPatterns = @(
    "$env:APPDATA\JetBrains\*",
    "$env:USERPROFILE\.JetBrains\*",
    "$env:USERPROFILE\.IntelliJIdea*",
    "$env:USERPROFILE\.WebStorm*",
    "$env:USERPROFILE\.PyCharm*",
    "$env:USERPROFILE\.CLion*",
    "$env:USERPROFILE\.DataGrip*",
    "$env:USERPROFILE\.GoLand*",
    "$env:USERPROFILE\.PhpStorm*",
    "$env:USERPROFILE\.Rider*",
    "$env:USERPROFILE\.RubyMine*"
)

$JetBrainsDetected = $false
foreach ($pattern in $JetBrainsPatterns) {
    if (Get-ChildItem -Path $pattern -Directory -ErrorAction SilentlyContinue) {
        $JetBrainsDetected = $true
        break
    }
}

if ($JetBrainsDetected) {
    $installJetBrains = Read-Host "JetBrains IDE detected. Install NordShade theme? (y/n)"
    if ($installJetBrains -eq "y") {
        Install-JetBrainsTheme
    }
}

# Clean up temp files if we downloaded them
if (-not $IsRepo -and (Test-Path $TempPath)) {
    $cleanUp = Read-Host "Remove temporary downloaded files? (y/n)"
    if ($cleanUp -eq "y") {
        Remove-Item -Path $TempPath -Recurse -Force
        Write-Host "Temporary files removed" -ForegroundColor Green
    }
}

# Present the menu to the user
Write-Host "===== NordShade Theme Installer =====" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host "Please select an option:"
Write-Host "1) Install for all detected applications"
Write-Host "2) Pick and choose which applications to install for"
Write-Host "3) Exit"
$menuChoice = Read-Host "Enter your choice (1-3)"

switch ($menuChoice) {
    "1" {
        Install-AllThemes
    }
    "2" {
        # Individual application checks
        
        # Check for VS Code
        if (Get-Command code -ErrorAction SilentlyContinue) {
            $installVSCode = Read-Host "Visual Studio Code detected. Install NordShade theme? (y/n)"
            if ($installVSCode -eq "y") {
                Install-VSCodeTheme
            }
        }
        
        # Check for VS 2022
        if (Get-Command devenv -ErrorAction SilentlyContinue) {
            $installVS2022 = Read-Host "Visual Studio 2022 detected. Install NordShade theme? (y/n)"
            if ($installVS2022 -eq "y") {
                Install-VisualStudioTheme
            }
        }
        
        # Check for Windows Terminal
        if (Test-Path "$env:LOCALAPPDATA\Microsoft\Windows Terminal") {
            $installWT = Read-Host "Windows Terminal detected. Install NordShade theme? (y/n)"
            if ($installWT -eq "y") {
                Install-WindowsTerminalTheme
            }
        }
        
        # Check for Windows 11
        if ([Environment]::OSVersion.Version.Major -ge 10) {
            $installW11 = Read-Host "Windows 11 detected. Install NordShade theme? (y/n)"
            if ($installW11 -eq "y") {
                Install-Windows11Theme
            }
        }
        
        # Check for Microsoft Edge
        if (Test-Path "$env:PROGRAMFILES\Microsoft\Edge\Application\msedge.exe" -or Test-Path "${env:PROGRAMFILES(x86)}\Microsoft\Edge\Application\msedge.exe") {
            $installEdge = Read-Host "Microsoft Edge detected. Install NordShade theme? (y/n)"
            if ($installEdge -eq "y") {
                Install-EdgeTheme
            }
        }
        
        # Check for Obsidian
        if (Test-Path "$env:APPDATA\obsidian") {
            $installObsidian = Read-Host "Obsidian detected. Install NordShade theme? (y/n)"
            if ($installObsidian -eq "y") {
                Install-ObsidianTheme
            }
        }
        
        # Check for Neovim
        if (Get-Command nvim -ErrorAction SilentlyContinue) {
            $installNeovim = Read-Host "Neovim detected. Install NordShade theme? (y/n)"
            if ($installNeovim -eq "y") {
                Install-NeovimTheme
            }
        }
        
        # Check for JetBrains IDEs
        if ($JetBrainsDetected) {
            $installJetBrains = Read-Host "JetBrains IDE detected. Install NordShade theme? (y/n)"
            if ($installJetBrains -eq "y") {
                Install-JetBrainsTheme
            }
        }
        
        # Check for Discord (BetterDiscord/Vencord)
        if (Test-Path "$env:APPDATA\BetterDiscord" -or Test-Path "$env:APPDATA\BetterDiscord\plugins" -or Test-Path "$env:APPDATA\Vencord") {
            $installDiscord = Read-Host "Discord with BetterDiscord/Vencord detected. Install NordShade theme? (y/n)"
            if ($installDiscord -eq "y") {
                Install-DiscordTheme
            }
        }
        
        # Check for GitHub Desktop
        if (Test-Path "$env:LOCALAPPDATA\GitHubDesktop") {
            $installGitHub = Read-Host "GitHub Desktop detected. Install NordShade theme? (y/n)"
            if ($installGitHub -eq "y") {
                Install-GitHubDesktopTheme
            }
        }
    }
    "3" {
        Write-Host "Exiting NordShade installer. No changes were made." -ForegroundColor Green
        exit 0
    }
    default {
        Write-Host "Invalid option. Exiting." -ForegroundColor Red
        exit 1
    }
}

Write-Host "NordShade installation complete!" -ForegroundColor Cyan 