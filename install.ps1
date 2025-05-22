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
    
    # Create necessary directories
    $themeDirs = @("VisualStudioCode", "VisualStudio2022", "WindowsTerminal", "Windows11", "MicrosoftEdge", "Obsidian")
    foreach ($dir in $themeDirs) {
        if (-not (Test-Path "$TempPath\$dir")) {
            New-Item -Path "$TempPath\$dir" -ItemType Directory -Force | Out-Null
        }
    }
    
    # Download VS Code files
    Invoke-WebRequest -Uri "$RepoURL/raw/main/VisualStudioCode/NordShade.json" -OutFile "$TempPath\VisualStudioCode\NordShade.json"
    Invoke-WebRequest -Uri "$RepoURL/raw/main/VisualStudioCode/package.json" -OutFile "$TempPath\VisualStudioCode\package.json"
    Invoke-WebRequest -Uri "$RepoURL/raw/main/VisualStudioCode/README.md" -OutFile "$TempPath\VisualStudioCode\README.md"
    
    # Download VS2022 files
    Invoke-WebRequest -Uri "$RepoURL/raw/main/VisualStudio2022/NordShade.vssettings" -OutFile "$TempPath\VisualStudio2022\NordShade.vssettings"
    Invoke-WebRequest -Uri "$RepoURL/raw/main/VisualStudio2022/README.md" -OutFile "$TempPath\VisualStudio2022\README.md"
    
    # Download Windows Terminal files
    Invoke-WebRequest -Uri "$RepoURL/raw/main/WindowsTerminal/NordShade.json" -OutFile "$TempPath\WindowsTerminal\NordShade.json"
    Invoke-WebRequest -Uri "$RepoURL/raw/main/WindowsTerminal/README.md" -OutFile "$TempPath\WindowsTerminal\README.md"
    
    # Download Windows 11 files
    Invoke-WebRequest -Uri "$RepoURL/raw/main/Windows11/theme.deskthemepack" -OutFile "$TempPath\Windows11\theme.deskthemepack"
    Invoke-WebRequest -Uri "$RepoURL/raw/main/Windows11/README.md" -OutFile "$TempPath\Windows11\README.md"
    
    # Download Edge files
    Invoke-WebRequest -Uri "$RepoURL/raw/main/MicrosoftEdge/manifest.json" -OutFile "$TempPath\MicrosoftEdge\manifest.json"
    Invoke-WebRequest -Uri "$RepoURL/raw/main/MicrosoftEdge/README.md" -OutFile "$TempPath\MicrosoftEdge\README.md"
    
    # Download Obsidian files
    Invoke-WebRequest -Uri "$RepoURL/raw/main/Obsidian/theme.css" -OutFile "$TempPath\Obsidian\theme.css"
    Invoke-WebRequest -Uri "$RepoURL/raw/main/Obsidian/manifest.json" -OutFile "$TempPath\Obsidian\manifest.json"
    Invoke-WebRequest -Uri "$RepoURL/raw/main/Obsidian/README.md" -OutFile "$TempPath\Obsidian\README.md"
    
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
    
    Write-Host "VS Code theme installed successfully. Please restart VS Code and select the theme." -ForegroundColor Green
}

function Install-VisualStudioTheme {
    Write-Host "Installing NordShade for Visual Studio 2022..." -ForegroundColor Yellow
    
    # Copy settings file to a location the user can easily access
    $settingsPath = "$env:USERPROFILE\Documents\NordShade.vssettings"
    Copy-Item "$NordShadeRoot\VisualStudio2022\NordShade.vssettings" -Destination $settingsPath
    
    Write-Host "Visual Studio settings file copied to $settingsPath" -ForegroundColor Green
    Write-Host "To apply the theme, open Visual Studio -> Tools -> Import and Export Settings..." -ForegroundColor Green
    Write-Host "Then select 'Import selected environment settings' and browse to the file location." -ForegroundColor Green
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
    
    # Save settings
    $settings | ConvertTo-Json -Depth 20 | Set-Content -Path $terminalSettingsPath
    
    Write-Host "Windows Terminal theme installed successfully." -ForegroundColor Green
    Write-Host "To activate, open Windows Terminal settings and select 'NordShade' as your color scheme." -ForegroundColor Green
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
    
    Write-Host "Windows 11 theme installed to $themePath" -ForegroundColor Green
    Write-Host "Note: You'll need to provide a wallpaper named 'NordShade.jpg' in $themeDir" -ForegroundColor Yellow
    Write-Host "To apply the theme, double-click the theme file or go to Settings -> Personalization -> Themes" -ForegroundColor Green
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
    Write-Host "To install, open Edge -> edge://extensions/ -> Enable Developer Mode -> Load Unpacked -> Select the folder" -ForegroundColor Green
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
    
    Write-Host "Obsidian theme installed successfully to $obsidianThemePath" -ForegroundColor Green
    Write-Host "To activate, open Obsidian -> Settings -> Appearance -> Select 'NordShade' theme" -ForegroundColor Green
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

# Clean up temp files if we downloaded them
if (-not $IsRepo -and (Test-Path $TempPath)) {
    $cleanUp = Read-Host "Remove temporary downloaded files? (y/n)"
    if ($cleanUp -eq "y") {
        Remove-Item -Path $TempPath -Recurse -Force
        Write-Host "Temporary files removed" -ForegroundColor Green
    }
}

Write-Host "NordShade installation complete!" -ForegroundColor Cyan 