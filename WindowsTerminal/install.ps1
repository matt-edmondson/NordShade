# NordShade for Windows Terminal - Installation Script
# This script installs the NordShade theme for Windows Terminal

function Install-WindowsTerminalTheme {
    param (
        [string]$ThemeRoot = $PSScriptRoot,
        [switch]$AutoApply
    )
    
    Write-Host "Installing NordShade for Windows Terminal..." -ForegroundColor Yellow
    
    # Get Windows Terminal settings path
    $settingsPath = "${env:LOCALAPPDATA}\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    $settingsPathPreview = "${env:LOCALAPPDATA}\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
    
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
    try {
        $settings = Get-Content -Path $terminalSettingsPath -Raw | ConvertFrom-Json
    } catch {
        Write-Host "Error reading Windows Terminal settings: ${_}" -ForegroundColor Red
        return
    }
    
    # Backup existing settings
    Copy-Item -Path $terminalSettingsPath -Destination "$terminalSettingsPath.backup" -Force
    Write-Host "Backed up existing settings to $terminalSettingsPath.backup" -ForegroundColor Green
    
    # Get NordShade scheme
    $nordShadeScheme = Get-Content -Path "$ThemeRoot\NordShade.json" -Raw | ConvertFrom-Json
    
    # Check if schemes property exists, create if it doesn't
    if (-not $settings.schemes) {
        $settings | Add-Member -Type NoteProperty -Name schemes -Value @()
    }
    
    # Remove existing NordShade scheme if it exists
    $settings.schemes = $settings.schemes | Where-Object { $_.name -ne "NordShade" }
    
    # Add NordShade scheme
    $settings.schemes += $nordShadeScheme
    
    # Determine if we should apply the theme
    if (-not $PSBoundParameters.ContainsKey('AutoApply')) {
        $applyTheme = Read-Host "Would you like to automatically apply the NordShade theme as the default color scheme? (y/n)"
        $AutoApply = $applyTheme -eq 'y'
    }
    
    # Apply theme to all profiles if auto-apply is enabled
    if ($AutoApply) {
        if ($settings.profiles -and $settings.profiles.defaults) {
            # Set the colorScheme property in defaults to apply to all profiles
            $settings.profiles.defaults | Add-Member -Type NoteProperty -Name colorScheme -Value "NordShade" -Force
        }
        Write-Host "NordShade theme applied as the default color scheme!" -ForegroundColor Green
    } else {
        Write-Host "NordShade theme added to available schemes but not applied." -ForegroundColor Yellow
        Write-Host "To activate, open Windows Terminal -> Settings -> Color Schemes and select 'NordShade'" -ForegroundColor Yellow
    }
    
    # Save settings
    $settings | ConvertTo-Json -Depth 20 | Set-Content -Path $terminalSettingsPath
    
    Write-Host "Windows Terminal theme installation complete!" -ForegroundColor Green
}

# If script is run directly (not imported), install the theme
if ($MyInvocation.InvocationName -ne ".") {
    Install-WindowsTerminalTheme
}

# Export the function for import by the main installer
Export-ModuleMember -Function Install-WindowsTerminalTheme -ErrorAction SilentlyContinue 