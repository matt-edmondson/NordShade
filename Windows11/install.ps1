# NordShade for Windows 11 - Installation Script
# This script installs the NordShade theme for Windows 11

function Install-Windows11Theme {
    param (
        [string]$ThemeRoot = $PSScriptRoot
    )
    
    Write-Host "Installing NordShade for Windows 11..." -ForegroundColor Yellow
    
    # Create destination folder for the wallpaper
    $themeDir = "${env:WINDIR}\Resources\Themes\NordShade"
    if (-not (Test-Path $themeDir)) {
        New-Item -Path $themeDir -ItemType Directory -Force | Out-Null
    }
    
    # Copy theme file
    $themePath = "${env:USERPROFILE}\AppData\Local\Microsoft\Windows\Themes\NordShade.theme"
    Copy-Item "$ThemeRoot\theme.deskthemepack" -Destination $themePath
    
    # Copy the wallpaper if it exists
    $wallpaperSource = "${ThemeRoot}\NordShade.jpg"
    $wallpaperDest = "${themeDir}\NordShade.jpg"
    
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

# If script is run directly (not imported), install the theme
if ($MyInvocation.InvocationName -ne ".") {
    Install-Windows11Theme
}

# Export the function for import by the main installer
Export-ModuleMember -Function Install-Windows11Theme -ErrorAction SilentlyContinue 