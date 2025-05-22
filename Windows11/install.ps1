# NordShade for Windows 11 - Installation Script
# This script installs the NordShade theme for Windows 11

function Install-Windows11Theme {
    param (
        [string]$ThemeRoot = $PSScriptRoot,
        [switch]$AutoApply
    )
    
    Write-Host "Installing NordShade for Windows 11..." -ForegroundColor Yellow
    
    # Create destination folder for the wallpaper
    $themeDir = "${env:WINDIR}\Resources\Themes\NordShade"
    if (-not (Test-Path $themeDir)) {
        New-Item -Path $themeDir -ItemType Directory -Force | Out-Null
    }
    
    # Copy theme file - first try to copy to the proper Themes folder
    $themeSystemPath = "${env:LOCALAPPDATA}\Microsoft\Windows\Themes"
    $themePath = "$themeSystemPath\NordShade.theme"
    
    # Ensure Themes directory exists
    if (-not (Test-Path $themeSystemPath)) {
        New-Item -Path $themeSystemPath -ItemType Directory -Force | Out-Null
    }
    
    Copy-Item "$ThemeRoot\theme.deskthemepack" -Destination $themePath
    
    # Also copy to the user's Desktop for easy access
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $desktopThemePath = "$desktopPath\NordShade.deskthemepack"
    Copy-Item "$ThemeRoot\theme.deskthemepack" -Destination $desktopThemePath -Force
    
    # Check for wallpaper in different locations
    $wallpaperSource = "${ThemeRoot}\NordShade.jpg"
    $tempWallpaper = "${env:TEMP}\NordShade\NordShade.jpg"
    $wallpaperDest = "${themeDir}\NordShade.jpg"
    
    # First check if wallpaper exists in theme directory
    if (Test-Path $wallpaperSource) {
        Write-Host "Copying NordShade wallpaper from theme directory..." -ForegroundColor Yellow
        Copy-Item $wallpaperSource -Destination $wallpaperDest -Force
        Write-Host "Wallpaper installed to $wallpaperDest" -ForegroundColor Green
    }
    # Then check if wallpaper exists in temp directory (for standalone install)
    elseif (Test-Path $tempWallpaper) {
        Write-Host "Copying NordShade wallpaper from temp directory..." -ForegroundColor Yellow
        Copy-Item $tempWallpaper -Destination $wallpaperDest -Force
        Write-Host "Wallpaper installed to $wallpaperDest" -ForegroundColor Green
    }
    else {
        Write-Host "NordShade wallpaper not found at $wallpaperSource or $tempWallpaper" -ForegroundColor Red
        Write-Host "Please provide a wallpaper named 'NordShade.jpg' in $themeDir" -ForegroundColor Yellow
    }
    
    # Try to apply the theme automatically if requested
    if ($AutoApply) {
        Write-Host "Attempting to apply Windows 11 theme automatically..." -ForegroundColor Yellow
        
        $success = $false
        
        # Method 1: Try using rundll32
        try {
            Write-Host "Trying method 1 (rundll32)..." -ForegroundColor Gray
            Start-Process -FilePath "rundll32.exe" -ArgumentList "desk.cpl,InstallTheme $themePath" -Wait -ErrorAction SilentlyContinue
            
            # Check if the theme was successfully applied
            if ($LASTEXITCODE -eq 0) {
                $success = $true
                Write-Host "Windows 11 theme applied successfully via rundll32!" -ForegroundColor Green
            }
        } catch {
            Write-Host "Method 1 failed: $_" -ForegroundColor Gray
        }
        
        # Method 2: Try using the theme file directly
        if (-not $success) {
            try {
                Write-Host "Trying method 2 (direct file execution)..." -ForegroundColor Gray
                Start-Process -FilePath $desktopThemePath -ErrorAction SilentlyContinue
                
                Write-Host "Theme file opened, please follow the on-screen instructions to apply the theme." -ForegroundColor Yellow
                Write-Host "After applying the theme, you can delete the copy on your desktop." -ForegroundColor Yellow
                $success = $true
            } catch {
                Write-Host "Method 2 failed: $_" -ForegroundColor Gray
            }
        }
        
        # If all automated methods failed
        if (-not $success) {
            Write-Host "Could not apply theme automatically. Please apply manually." -ForegroundColor Yellow
            Write-Host "Manual method 1: Double-click the theme file on your desktop: $desktopThemePath" -ForegroundColor Yellow
            Write-Host "Manual method 2: Go to Settings -> Personalization -> Themes -> Browse themes" -ForegroundColor Yellow
            Write-Host "Manual method 3: Right-click the desktop -> Personalize -> Themes -> Desktop theme settings" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Theme installed but not automatically applied. Theme files available at:" -ForegroundColor Yellow
        Write-Host "1. System location: $themePath" -ForegroundColor Yellow
        Write-Host "2. Desktop: $desktopThemePath (you can double-click this file to apply the theme)" -ForegroundColor Yellow
        Write-Host "3. Settings -> Personalization -> Themes -> Browse themes" -ForegroundColor Yellow
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