function Install-GoogleChromeTheme {
    param (
        [string]$ThemeRoot = $PSScriptRoot,
        [switch]$AutoApply
    )
    
    Write-Host "Installing NordShade for Google Chrome..." -ForegroundColor Yellow
    
    # Get Chrome extensions directory
    $extensionsPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Extensions"
    $themePath = "$env:USERPROFILE\Documents\NordShade\GoogleChrome"
    
    # Check if Chrome is installed
    if (-not (Test-Path $extensionsPath)) {
        Write-Host "Google Chrome doesn't appear to be installed on this system." -ForegroundColor Red
        return
    }
    
    # Create theme directory if it doesn't exist
    if (-not (Test-Path $themePath)) {
        New-Item -Path $themePath -ItemType Directory -Force | Out-Null
    }
    
    # Copy theme files
    Copy-Item "$ThemeRoot\manifest.json" -Destination $themePath
    Copy-Item "$ThemeRoot\theme_resources.pak" -Destination $themePath
    Copy-Item "$ThemeRoot\nordshade_theme_preview.png" -Destination $themePath
    
    # Determine if we should try to assist with theme application
    if (-not $PSBoundParameters.ContainsKey('AutoApply')) {
        $applyTheme = Read-Host "Would you like to automatically apply the theme? (y/n)"
        $AutoApply = $applyTheme -eq 'y'
    }
    
    if ($AutoApply) {
        Write-Host "Chrome themes need to be loaded as an unpacked extension." -ForegroundColor Cyan
        Write-Host "Instructions:" -ForegroundColor Cyan
        Write-Host "1. Open Chrome and navigate to chrome://extensions/" -ForegroundColor Cyan
        Write-Host "2. Enable 'Developer mode' (toggle in top-right)" -ForegroundColor Cyan
        Write-Host "3. Click 'Load unpacked' and select this folder: $themePath" -ForegroundColor Cyan
        
        # Try to open Chrome to the extensions page
        try {
            Start-Process "chrome.exe" -ArgumentList "chrome://extensions/"
            Start-Process "explorer.exe" -ArgumentList $themePath
            Write-Host "Chrome has been opened to the extensions page and the theme folder has been opened." -ForegroundColor Green
        } catch {
            Write-Host "Unable to automatically open Chrome. Please follow the manual instructions above." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Theme files have been installed to: $themePath" -ForegroundColor Green
        Write-Host "To apply the theme:" -ForegroundColor Cyan
        Write-Host "1. Open Chrome and navigate to chrome://extensions/" -ForegroundColor Cyan
        Write-Host "2. Enable 'Developer mode' (toggle in top-right)" -ForegroundColor Cyan
        Write-Host "3. Click 'Load unpacked' and select this folder: $themePath" -ForegroundColor Cyan
    }
    
    Write-Host "Google Chrome theme installation complete." -ForegroundColor Green
}

# Call the function if script is run directly
if ($MyInvocation.InvocationName -ne ".") {
    Install-GoogleChromeTheme
} 