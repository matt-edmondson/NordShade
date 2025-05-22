# NordShade Installation Script for Windows
# This script detects and installs NordShade themes for available applications
# Can be run without cloning the repository

$ErrorActionPreference = "SilentlyContinue"
$RepoURL = "https://github.com/matt-edmondson/NordShade"
$RepoAPIURL = "https://api.github.com/repos/matt-edmondson/NordShade/contents"
$TempPath = "${env:TEMP}\NordShade"
$CurrentPath = Get-Location
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$GlobalAutoApply = $null

# Add debugging flag
$VerbosePreference = "Continue"
$DebugMode = $true

# Add debugging function
function Write-DebugMessage {
    param(
        [string]$Message,
        [string]$Source = "Main"
    )
    
    if ($DebugMode) {
        Write-Host "[DEBUG:$Source] $Message" -ForegroundColor Magenta
    }
}

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
        
        try {
            $script:IndexJson = Get-Content -Path $indexPath -Raw | ConvertFrom-Json
            return $script:IndexJson
        } catch {
            Write-Host "Failed to parse index.json: $_" -ForegroundColor Red
            return $null
        }
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
        Write-Host "Failed to download or parse index.json. Installation may be incomplete." -ForegroundColor Red
        return $false
    }
    
    try {
        $baseUrl = $indexJson.baseUrl
        $themeFiles = $null
        
        # Safely access theme files
        if ($indexJson.themes -and $indexJson.themes.PSObject.Properties[$ThemeName]) {
            $themeFiles = $indexJson.themes.$ThemeName
        }
        
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
                
                # Make script files executable (PowerShell doesn't need this but keeping for consistency)
                if ($file -like "*.ps1" -or $file -like "*.sh") {
                    # PowerShell scripts don't need to be marked executable
                }
            } catch {
                Write-Host "    Failed to download ${file}: $_" -ForegroundColor Red
            }
        }
        
        # Check if installer script exists
        $installerPath = "$TempPath\$ThemeName\install.ps1"
        if (Test-Path $installerPath) {
            return $true
        } else {
            Write-Host "Installer script not found for $ThemeName" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "Error processing theme files for $ThemeName`: $_" -ForegroundColor Red
        return $false
    }
}

# Add wrapper function for theme-specific installers
function Invoke-ThemeInstaller {
    param (
        [string]$ThemeName,
        [string]$InstallerPath,
        [switch]$AutoApply
    )
    
    Write-DebugMessage "Invoking installer: $InstallerPath" "Invoke-ThemeInstaller"
    
    # Create a temporary module name
    $moduleName = "NordShade$ThemeName"
    $tempModulePath = "$TempPath\$moduleName.psm1"
    
    try {
        # Copy the installer content to a proper module file
        Copy-Item -Path $InstallerPath -Destination $tempModulePath -Force
        
        # Append proper module export if needed
        $moduleContent = Get-Content -Path $tempModulePath -Raw
        if (-not ($moduleContent -match "Export-ModuleMember")) {
            $functionName = "Install-${ThemeName}Theme"
            Write-DebugMessage "Adding Export-ModuleMember for $functionName" "Invoke-ThemeInstaller"
            Add-Content -Path $tempModulePath -Value "`nExport-ModuleMember -Function $functionName"
        }
        
        # Import the temporary module
        Import-Module -Name $tempModulePath -Force -DisableNameChecking
        
        # Get the install function name based on the theme name
        $functionName = "Install-${ThemeName}Theme"
        Write-DebugMessage "Calling function: $functionName" "Invoke-ThemeInstaller"
        
        # Call the function with parameters
        if ($AutoApply) {
            & $functionName -AutoApply -ThemeRoot "$NordShadeRoot\$ThemeName"
        } else {
            & $functionName -ThemeRoot "$NordShadeRoot\$ThemeName"
        }
        
        # Clean up
        Remove-Module -Name $moduleName -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $tempModulePath -Force -ErrorAction SilentlyContinue
        
        return $true
    } catch {
        Write-Host "Error in theme installer: $_" -ForegroundColor Red
        Write-DebugMessage "Exception details: $($_.Exception.GetType().FullName)" "Invoke-ThemeInstaller"
        Write-DebugMessage "Exception message: $($_.Exception.Message)" "Invoke-ThemeInstaller"
        return $false
    }
}

# Update Install-Theme to use the wrapper
function Install-Theme {
    param (
        [string]$ThemeName
    )
    
    Write-Host "Installing NordShade for $ThemeName..." -ForegroundColor Yellow
    Write-DebugMessage "Starting installation for $ThemeName" "Install-Theme"
    
    # Download theme files if running standalone
    if (-not $IsRepo) {
        Write-DebugMessage "Running in standalone mode, downloading theme files" "Install-Theme"
        $success = Download-ThemeFiles -ThemeName $ThemeName
        if (-not $success) {
            Write-Host "Failed to download theme files for $ThemeName" -ForegroundColor Red
            return
        }
    }
    
    # Check if installer script exists
    $installerPath = "$NordShadeRoot\$ThemeName\install.ps1"
    Write-DebugMessage "Checking for installer at: $installerPath" "Install-Theme"
    
    if (Test-Path $installerPath) {
        try {
            Write-DebugMessage "Found installer, attempting to execute" "Install-Theme"
            
            # Use the wrapper function to invoke the installer
            if ($null -ne $GlobalAutoApply -and $GlobalAutoApply) {
                Invoke-ThemeInstaller -ThemeName $ThemeName -InstallerPath $installerPath -AutoApply
            } else {
                Invoke-ThemeInstaller -ThemeName $ThemeName -InstallerPath $installerPath
            }
        } catch {
            Write-Host "Error executing installer for $ThemeName`: $_" -ForegroundColor Red
            Write-DebugMessage "Exception details: $($_.Exception.GetType().FullName)" "Install-Theme"
            Write-DebugMessage "Exception message: $($_.Exception.Message)" "Install-Theme"
        }
    } else {
        Write-Host "Installer script not found for $ThemeName" -ForegroundColor Red
    }
}

function Get-AvailableThemes {
    # Get available themes from index.json
    $indexJson = Get-IndexJson
    if ($null -eq $indexJson) {
        # Fallback to hardcoded list if index.json is not available
        return @(
            "VisualStudioCode",
            "VisualStudio2022",
            "WindowsTerminal",
            "Windows11",
            "MicrosoftEdge",
            "Obsidian",
            "Neovim",
            "JetBrains",
            "Discord",
            "GitHubDesktop"
        )
    }
    
    # Get themes from index.json
    $themes = @()
    foreach ($themeName in $indexJson.themes.PSObject.Properties.Name) {
        $themes += $themeName
    }
    
    return $themes
}

function Detect-Applications {
    $detectedApps = @{}
    
    # Get available themes from index.json
    $availableThemes = Get-AvailableThemes
    
    # Check for VS Code
    if (Get-Command code -ErrorAction SilentlyContinue) {
        if ($availableThemes -contains "VisualStudioCode") {
            $detectedApps["VisualStudioCode"] = "Visual Studio Code"
        }
    }
    
    # Check for Cursor IDE
    if ((Test-Path "${env:LOCALAPPDATA}\Programs\Cursor\cursor.exe") -or 
        (Test-Path "${env:APPDATA}\cursor-editor")) {
        if ($availableThemes -contains "Cursor") {
            $detectedApps["Cursor"] = "Cursor IDE"
        }
    }
    
    # Check for VS 2022
    if (Get-Command devenv -ErrorAction SilentlyContinue) {
        if ($availableThemes -contains "VisualStudio2022") {
            $detectedApps["VisualStudio2022"] = "Visual Studio 2022"
        }
    }
    
    # Check for Windows Terminal
    if (Test-Path "${env:LOCALAPPDATA}\Microsoft\Windows Terminal") {
        if ($availableThemes -contains "WindowsTerminal") {
            $detectedApps["WindowsTerminal"] = "Windows Terminal"
        }
    }
    
    # Check for Windows 11
    if ([Environment]::OSVersion.Version.Major -ge 10) {
        if ($availableThemes -contains "Windows11") {
            $detectedApps["Windows11"] = "Windows 11"
        }
    }
    
    # Check for Microsoft Edge
    if ((Test-Path "${env:ProgramFiles}\Microsoft\Edge\Application\msedge.exe") -or 
        (Test-Path "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe")) {
        if ($availableThemes -contains "MicrosoftEdge") {
            $detectedApps["MicrosoftEdge"] = "Microsoft Edge"
        }
    }
    
    # Check for Obsidian
    if (Test-Path "${env:APPDATA}\obsidian") {
        if ($availableThemes -contains "Obsidian") {
            $detectedApps["Obsidian"] = "Obsidian"
        }
    }
    
    # Check for Neovim
    if (Get-Command nvim -ErrorAction SilentlyContinue) {
        if ($availableThemes -contains "Neovim") {
            $detectedApps["Neovim"] = "Neovim"
        }
    }
    
    # Check for JetBrains IDEs
    $JetBrainsPatterns = @(
        "${env:APPDATA}\JetBrains\*",
        "${env:USERPROFILE}\.JetBrains\*",
        "${env:USERPROFILE}\.IntelliJIdea*",
        "${env:USERPROFILE}\.WebStorm*",
        "${env:USERPROFILE}\.PyCharm*",
        "${env:USERPROFILE}\.CLion*",
        "${env:USERPROFILE}\.DataGrip*",
        "${env:USERPROFILE}\.GoLand*",
        "${env:USERPROFILE}\.PhpStorm*",
        "${env:USERPROFILE}\.Rider*",
        "${env:USERPROFILE}\.RubyMine*"
    )
    
    foreach ($pattern in $JetBrainsPatterns) {
        if (Get-ChildItem -Path $pattern -Directory -ErrorAction SilentlyContinue) {
            if ($availableThemes -contains "JetBrains") {
                $detectedApps["JetBrains"] = "JetBrains IDEs"
                break
            }
        }
    }
    
    # Check for Discord (BetterDiscord/Vencord)
    if (Test-Path "${env:APPDATA}\BetterDiscord" -or 
        Test-Path "${env:APPDATA}\BetterDiscord\plugins" -or 
        Test-Path "${env:APPDATA}\Vencord") {
        if ($availableThemes -contains "Discord") {
            $detectedApps["Discord"] = "Discord"
        }
    }
    
    # Check for GitHub Desktop
    if (Test-Path "${env:LOCALAPPDATA}\GitHubDesktop") {
        if ($availableThemes -contains "GitHubDesktop") {
            $detectedApps["GitHubDesktop"] = "GitHub Desktop"
        }
    }
    
    return $detectedApps
}

function Install-AllThemes {
    $detectedApps = Detect-Applications
    
    if ($detectedApps.Count -eq 0) {
        Write-Host "No supported applications detected." -ForegroundColor Yellow
        return
    }
    
    Write-Host "Installing NordShade for all detected applications..." -ForegroundColor Yellow
    
    foreach ($app in $detectedApps.Keys) {
        Install-Theme -ThemeName $app
    }
}

# Create temp directory structure if running standalone
if (-not $IsRepo) {
    if (-not (Test-Path $TempPath)) {
        New-Item -Path $TempPath -ItemType Directory -Force | Out-Null
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
        $detectedApps = Detect-Applications
        
        if ($detectedApps.Count -eq 0) {
            Write-Host "No supported applications detected." -ForegroundColor Yellow
            break
        }
        
        Write-Host "The following applications were detected:" -ForegroundColor Yellow
        $i = 1
        $appList = @()
        foreach ($app in $detectedApps.Keys) {
            $appList += $app
            Write-Host "$i) $($detectedApps[$app])"
            $i++
        }
        
        Write-Host "Enter the numbers of the applications you want to install themes for (comma-separated, e.g. '1,3,4'):"
        $selection = Read-Host
        
        $selectedIndices = $selection -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -match '^\d+$' }
        
        foreach ($index in $selectedIndices) {
            if ([int]$index -gt 0 -and [int]$index -le $appList.Count) {
                $appName = $appList[[int]$index - 1]
                Install-Theme -ThemeName $appName
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