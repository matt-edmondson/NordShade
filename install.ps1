# NordShade Installation Script for Windows
# This script detects and installs NordShade themes for available applications
# Can be run without cloning the repository

$ErrorActionPreference = "SilentlyContinue"
$RepoURL = "https://github.com/matt-edmondson/NordShade"
$RepoAPIURL = "https://api.github.com/repos/matt-edmondson/NordShade/contents"
$TempPath = "$env:TEMP\NordShade"
$CurrentPath = Get-Location
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$GlobalAutoApply = $null

# Determine if we're running from the cloned repo or standalone
if (Test-Path "$PSScriptRoot\README.md") {
    $NordShadeRoot = $PSScriptRoot
    $IsRepo = $true
    Write-Host "Installing NordShade themes from local repository at $NordShadeRoot" -ForegroundColor Cyan
} else {
    $NordShadeRoot = $TempPath
    $IsRepo = $false
    Write-Host "Running standalone installation - will download required files on demand" -ForegroundColor Cyan
}

# Index.json caching
$IndexJson = $null

function Get-IndexJson {
    if ($null -ne $IndexJson) {
        return $IndexJson
    }
    
    $indexUrl = "$RepoURL/raw/main/index.json"
    $indexPath = "$TempPath\index.json"
    
    if (-not (Test-Path $TempPath)) {
        New-Item -Path $TempPath -ItemType Directory -Force | Out-Null
    }
    
    try {
        Invoke-WebRequest -Uri $indexUrl -OutFile $indexPath
        $script:IndexJson = Get-Content -Path $indexPath -Raw | ConvertFrom-Json
        return $script:IndexJson
    } catch {
        Write-Host "Failed to download index.json: $_" -ForegroundColor Red
        return $null
    }
}

function Download-ThemeFiles {
    param (
        [string]$ThemeName
    )
    
    Write-Host "Downloading files for $ThemeName theme..." -ForegroundColor Yellow
    
    # Create directory for theme if it doesn't exist
    if (-not (Test-Path "$TempPath\$ThemeName")) {
        New-Item -Path "$TempPath\$ThemeName" -ItemType Directory -Force | Out-Null
    }
    
    $indexJson = Get-IndexJson
    if ($null -eq $indexJson) {
        # Fallback for essential files if index.json fails
        Write-Host "Using fallback download method for $ThemeName..." -ForegroundColor Yellow
        
        switch ($ThemeName) {
            "VisualStudioCode" {
                Invoke-WebRequest -Uri "$RepoURL/raw/main/VisualStudioCode/NordShade.json" -OutFile "$TempPath\VisualStudioCode\NordShade.json"
                Invoke-WebRequest -Uri "$RepoURL/raw/main/VisualStudioCode/package.json" -OutFile "$TempPath\VisualStudioCode\package.json"
                Invoke-WebRequest -Uri "$RepoURL/raw/main/VisualStudioCode/README.md" -OutFile "$TempPath\VisualStudioCode\README.md"
                Invoke-WebRequest -Uri "$RepoURL/raw/main/VisualStudioCode/install.ps1" -OutFile "$TempPath\VisualStudioCode\install.ps1"
            }
            "VisualStudio2022" {
                Invoke-WebRequest -Uri "$RepoURL/raw/main/VisualStudio2022/NordShade.vssettings" -OutFile "$TempPath\VisualStudio2022\NordShade.vssettings"
                Invoke-WebRequest -Uri "$RepoURL/raw/main/VisualStudio2022/install.ps1" -OutFile "$TempPath\VisualStudio2022\install.ps1"
            }
            "WindowsTerminal" {
                Invoke-WebRequest -Uri "$RepoURL/raw/main/WindowsTerminal/NordShade.json" -OutFile "$TempPath\WindowsTerminal\NordShade.json"
                Invoke-WebRequest -Uri "$RepoURL/raw/main/WindowsTerminal/install.ps1" -OutFile "$TempPath\WindowsTerminal\install.ps1"
            }
            "Windows11" {
                Invoke-WebRequest -Uri "$RepoURL/raw/main/Windows11/theme.deskthemepack" -OutFile "$TempPath\Windows11\theme.deskthemepack"
                Invoke-WebRequest -Uri "$RepoURL/raw/main/Windows11/NordShade.jpg" -OutFile "$TempPath\Windows11\NordShade.jpg" -ErrorAction SilentlyContinue
                Invoke-WebRequest -Uri "$RepoURL/raw/main/Windows11/install.ps1" -OutFile "$TempPath\Windows11\install.ps1"
            }
            "MicrosoftEdge" {
                Invoke-WebRequest -Uri "$RepoURL/raw/main/MicrosoftEdge/manifest.json" -OutFile "$TempPath\MicrosoftEdge\manifest.json"
                Invoke-WebRequest -Uri "$RepoURL/raw/main/MicrosoftEdge/install.ps1" -OutFile "$TempPath\MicrosoftEdge\install.ps1" -ErrorAction SilentlyContinue
            }
            "Obsidian" {
                Invoke-WebRequest -Uri "$RepoURL/raw/main/Obsidian/theme.css" -OutFile "$TempPath\Obsidian\theme.css"
                Invoke-WebRequest -Uri "$RepoURL/raw/main/Obsidian/manifest.json" -OutFile "$TempPath\Obsidian\manifest.json"
                Invoke-WebRequest -Uri "$RepoURL/raw/main/Obsidian/install.ps1" -OutFile "$TempPath\Obsidian\install.ps1"
            }
            "Neovim" {
                Invoke-WebRequest -Uri "$RepoURL/raw/main/Neovim/nord_shade.vim" -OutFile "$TempPath\Neovim\nord_shade.vim"
                Invoke-WebRequest -Uri "$RepoURL/raw/main/Neovim/install.ps1" -OutFile "$TempPath\Neovim\install.ps1"
            }
            "JetBrains" {
                Invoke-WebRequest -Uri "$RepoURL/raw/main/JetBrains/NordShade.xml" -OutFile "$TempPath\JetBrains\NordShade.xml"
                Invoke-WebRequest -Uri "$RepoURL/raw/main/JetBrains/install.ps1" -OutFile "$TempPath\JetBrains\install.ps1"
                Invoke-WebRequest -Uri "$RepoURL/raw/main/JetBrains/README.md" -OutFile "$TempPath\JetBrains\README.md" -ErrorAction SilentlyContinue
            }
            "Discord" {
                Invoke-WebRequest -Uri "$RepoURL/raw/main/Discord/nord_shade.theme.css" -OutFile "$TempPath\Discord\nord_shade.theme.css"
                Invoke-WebRequest -Uri "$RepoURL/raw/main/Discord/install.ps1" -OutFile "$TempPath\Discord\install.ps1"
            }
            "GitHubDesktop" {
                Invoke-WebRequest -Uri "$RepoURL/raw/main/GitHubDesktop/nord-shade.less" -OutFile "$TempPath\GitHubDesktop\nord-shade.less"
                Invoke-WebRequest -Uri "$RepoURL/raw/main/GitHubDesktop/install.ps1" -OutFile "$TempPath\GitHubDesktop\install.ps1" -ErrorAction SilentlyContinue
            }
            default {
                Write-Host "No fallback download method for $ThemeName" -ForegroundColor Red
                return $false
            }
        }
        
        return $true
    }
    
    $baseUrl = $indexJson.baseUrl
    $themeFiles = $indexJson.themes.$ThemeName
    
    if ($null -eq $themeFiles) {
        Write-Host "Theme $ThemeName not found in index.json" -ForegroundColor Red
        return $false
    }
    
    # Download each file listed for this theme
    foreach ($file in $themeFiles) {
        $fileUrl = "$baseUrl/$ThemeName/$file"
        $filePath = "$TempPath\$ThemeName\$file"
        Write-Host "  - $file" -ForegroundColor Gray
        try {
            Invoke-WebRequest -Uri $fileUrl -OutFile $filePath
        } catch {
            Write-Host "    Failed to download $file: $_" -ForegroundColor Red
        }
    }
    
    return $true
}

function Install-VSCodeTheme {
    Write-Host "Installing NordShade for Visual Studio Code..." -ForegroundColor Yellow
    
    # Download theme files if running standalone
    if (-not $IsRepo) {
        Download-ThemeFiles -ThemeName "VisualStudioCode"
    }
    
    # Call the VSCode-specific installer
    & "$NordShadeRoot\VisualStudioCode\install.ps1" -AutoApply:$GlobalAutoApply
}

function Install-VisualStudioTheme {
    Write-Host "Installing NordShade for Visual Studio 2022..." -ForegroundColor Yellow
    
    # Download theme files if running standalone
    if (-not $IsRepo) {
        Download-ThemeFiles -ThemeName "VisualStudio2022"
    }
    
    # Call the Visual Studio-specific installer
    & "$NordShadeRoot\VisualStudio2022\install.ps1" -AutoApply:$GlobalAutoApply
}

function Install-WindowsTerminalTheme {
    Write-Host "Installing NordShade for Windows Terminal..." -ForegroundColor Yellow
    
    # Download theme files if running standalone
    if (-not $IsRepo) {
        Download-ThemeFiles -ThemeName "WindowsTerminal"
    }
    
    # Call the Windows Terminal-specific installer
    & "$NordShadeRoot\WindowsTerminal\install.ps1" -AutoApply:$GlobalAutoApply
}

function Install-Windows11Theme {
    Write-Host "Installing NordShade for Windows 11..." -ForegroundColor Yellow
    
    # Download theme files if running standalone
    if (-not $IsRepo) {
        Download-ThemeFiles -ThemeName "Windows11"
    }
    
    # Call the Windows 11-specific installer
    & "$NordShadeRoot\Windows11\install.ps1" -AutoApply:$GlobalAutoApply
}

function Install-EdgeTheme {
    Write-Host "Installing NordShade for Microsoft Edge..." -ForegroundColor Yellow
    
    # Download theme files if running standalone
    if (-not $IsRepo) {
        Download-ThemeFiles -ThemeName "MicrosoftEdge"
    }
    
    # Check if there's a specific installer script
    if (Test-Path "$NordShadeRoot\MicrosoftEdge\install.ps1") {
        & "$NordShadeRoot\MicrosoftEdge\install.ps1"
    } else {
        # Fallback to manual instructions
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
}

function Install-ObsidianTheme {
    Write-Host "Installing NordShade for Obsidian..." -ForegroundColor Yellow
    
    # Download theme files if running standalone
    if (-not $IsRepo) {
        Download-ThemeFiles -ThemeName "Obsidian"
    }
    
    # Call the Obsidian-specific installer
    & "$NordShadeRoot\Obsidian\install.ps1" -AutoApply:$GlobalAutoApply
}

function Install-NeovimTheme {
    Write-Host "Installing NordShade for Neovim..." -ForegroundColor Yellow
    
    # Download theme files if running standalone
    if (-not $IsRepo) {
        Download-ThemeFiles -ThemeName "Neovim"
    }
    
    # Call the Neovim-specific installer
    & "$NordShadeRoot\Neovim\install.ps1"
}

function Install-JetBrainsTheme {
    Write-Host "Installing NordShade for JetBrains IDEs..." -ForegroundColor Yellow
    
    # Download theme files if running standalone
    if (-not $IsRepo) {
        Download-ThemeFiles -ThemeName "JetBrains"
    }
    
    # Call the JetBrains-specific installer
    & "$NordShadeRoot\JetBrains\install.ps1" -AutoApply:$GlobalAutoApply
}

function Install-DiscordTheme {
    Write-Host "Installing NordShade for Discord..." -ForegroundColor Yellow
    
    # Download theme files if running standalone
    if (-not $IsRepo) {
        Download-ThemeFiles -ThemeName "Discord"
    }
    
    # Call the Discord-specific installer
    & "$NordShadeRoot\Discord\install.ps1" -AutoApply:$GlobalAutoApply
}

function Install-GitHubDesktopTheme {
    Write-Host "Installing NordShade for GitHub Desktop..." -ForegroundColor Yellow
    
    # Download theme files if running standalone
    if (-not $IsRepo) {
        Download-ThemeFiles -ThemeName "GitHubDesktop"
    }
    
    # Check if there's a specific installer script
    if (Test-Path "$NordShadeRoot\GitHubDesktop\install.ps1") {
        & "$NordShadeRoot\GitHubDesktop\install.ps1" -AutoApply:$GlobalAutoApply
    } else {
        # Fallback to manual instructions
        $targetPath = "$env:USERPROFILE\Documents\NordShade-GitHubDesktop.less"
        Copy-Item "$NordShadeRoot\GitHubDesktop\nord-shade.less" -Destination $targetPath
        
        Write-Host "GitHub Desktop theme file copied to: $targetPath" -ForegroundColor Yellow
        Write-Host "GitHub Desktop themes require manual installation." -ForegroundColor Yellow
        Write-Host "Please check the project README for installation instructions." -ForegroundColor Yellow
    }
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

# Create temp directory structure if running standalone
if (-not $IsRepo) {
    if (-not (Test-Path $TempPath)) {
        New-Item -Path $TempPath -ItemType Directory -Force | Out-Null
    }
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

# Present the menu to the user
Write-Host "===== NordShade Theme Installer =====" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan

# Ask about global auto-apply preference
$autoApplySetting = Read-Host "Would you like themes to be automatically applied after installation? (y/n)"
$GlobalAutoApply = $autoApplySetting -eq 'y'

if ($GlobalAutoApply) {
    Write-Host "Themes will be automatically applied when possible" -ForegroundColor Yellow
} else {
    Write-Host "Themes will be installed but not automatically applied" -ForegroundColor Yellow
    Write-Host "You'll need to activate them manually in each application" -ForegroundColor Yellow
}

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

# Clean up temp files if we downloaded them
if (-not $IsRepo -and (Test-Path $TempPath)) {
    $cleanUp = Read-Host "Remove temporary downloaded files? (y/n)"
    if ($cleanUp -eq "y") {
        Remove-Item -Path $TempPath -Recurse -Force
        Write-Host "Temporary files removed" -ForegroundColor Green
    }
}

Write-Host "NordShade installation complete!" -ForegroundColor Cyan 