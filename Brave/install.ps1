function Install-BraveTheme {
    param (
        [string]$ThemeRoot = $PSScriptRoot,
        [switch]$AutoApply
    )
    
    Write-Host "Installing NordShade for Brave Browser..." -ForegroundColor Yellow
    
    # Paths
    $bravePath = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser"
    $themePath = "$env:USERPROFILE\Documents\NordShade\Brave"
    
    # Check if Brave is installed
    if (-not (Test-Path $bravePath)) {
        Write-Host "Brave Browser doesn't appear to be installed on this system." -ForegroundColor Red
        return
    }
    
    # Create theme directory if it doesn't exist
    if (-not (Test-Path $themePath)) {
        New-Item -Path $themePath -ItemType Directory -Force | Out-Null
    }
    
    # Copy theme files
    Copy-Item "$ThemeRoot\manifest.json" -Destination $themePath
    Copy-Item "$ThemeRoot\theme_resources.pak" -Destination $themePath
    Copy-Item "$ThemeRoot\nordshade_preview.png" -Destination $themePath
    
    # Determine if we should try to assist with theme application
    if (-not $PSBoundParameters.ContainsKey('AutoApply')) {
        $applyTheme = Read-Host "Would you like to automatically apply the theme? (y/n)"
        $AutoApply = $applyTheme -eq 'y'
    }
    
    if ($AutoApply) {
        Write-Host "Brave themes need to be loaded as an unpacked extension." -ForegroundColor Cyan
        Write-Host "Instructions:" -ForegroundColor Cyan
        Write-Host "1. Open Brave and navigate to brave://extensions/" -ForegroundColor Cyan
        Write-Host "2. Enable 'Developer mode' (toggle in top-right)" -ForegroundColor Cyan
        Write-Host "3. Click 'Load unpacked' and select this folder: $themePath" -ForegroundColor Cyan
        
        # Try to open Brave to the extensions page
        try {
            Start-Process "$bravePath\Application\brave.exe" -ArgumentList "brave://extensions/"
            Start-Process "explorer.exe" -ArgumentList $themePath
            Write-Host "Brave has been opened to the extensions page and the theme folder has been opened." -ForegroundColor Green
        } catch {
            Write-Host "Unable to automatically open Brave. Please follow the manual instructions above." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Theme files have been installed to: $themePath" -ForegroundColor Green
        Write-Host "To apply the theme:" -ForegroundColor Cyan
        Write-Host "1. Open Brave and navigate to brave://extensions/" -ForegroundColor Cyan
        Write-Host "2. Enable 'Developer mode' (toggle in top-right)" -ForegroundColor Cyan
        Write-Host "3. Click 'Load unpacked' and select this folder: $themePath" -ForegroundColor Cyan
    }
    
    Write-Host "Brave theme installation complete." -ForegroundColor Green
}

# Call the function if script is run directly
if ($MyInvocation.InvocationName -ne ".") {
    Install-BraveTheme
} 