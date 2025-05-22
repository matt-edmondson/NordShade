# NordShade for Discord - Installation Script
# This script installs the NordShade theme for Discord (BetterDiscord or Vencord)

function Install-DiscordTheme {
    param (
        [string]$ThemeRoot = $PSScriptRoot
    )
    
    Write-Host "Installing NordShade for Discord..." -ForegroundColor Yellow
    
    # Check if BetterDiscord is installed
    $betterDiscordPath = "${env:APPDATA}\BetterDiscord\themes"
    $vencordPath = "${env:APPDATA}\Vencord\themes"
    
    $installed = $false
    
    # Try BetterDiscord first
    if (Test-Path $betterDiscordPath) {
        Write-Host "BetterDiscord detected..." -ForegroundColor Green
        Copy-Item "$ThemeRoot\nord_shade.theme.css" -Destination $betterDiscordPath
        Write-Host "Theme installed to BetterDiscord themes folder: $betterDiscordPath" -ForegroundColor Green
        Write-Host "To activate, open Discord and go to User Settings > BetterDiscord > Themes and enable NordShade" -ForegroundColor Yellow
        $installed = $true
    }
    
    # Then try Vencord
    if (Test-Path $vencordPath) {
        Write-Host "Vencord detected..." -ForegroundColor Green
        Copy-Item "$ThemeRoot\nord_shade.theme.css" -Destination $vencordPath
        Write-Host "Theme installed to Vencord themes folder: $vencordPath" -ForegroundColor Green
        Write-Host "To activate, open Discord and go to User Settings > Vencord > Themes and enable NordShade" -ForegroundColor Yellow
        $installed = $true
    }
    
    # If neither is installed, just copy theme to Documents folder
    if (-not $installed) {
        $targetPath = "${env:USERPROFILE}\Documents\NordShade-Discord.theme.css"
        Copy-Item "$ThemeRoot\nord_shade.theme.css" -Destination $targetPath
        Write-Host "BetterDiscord or Vencord not detected. Theme file copied to: $targetPath" -ForegroundColor Yellow
        Write-Host "To use this theme, you need to install BetterDiscord or Vencord and manually move the theme file to the appropriate themes folder." -ForegroundColor Yellow
    }
}

# If script is run directly (not imported), install the theme
if ($MyInvocation.InvocationName -ne ".") {
    Install-DiscordTheme
}

# Export the function for import by the main installer
Export-ModuleMember -Function Install-DiscordTheme -ErrorAction SilentlyContinue 