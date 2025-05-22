function Install-OperaTheme {
    param (
        [string]$ThemeRoot = $PSScriptRoot,
        [switch]$AutoApply
    )
    
    Write-Host "Installing NordShade for Opera..." -ForegroundColor Yellow
    
    # Paths
    $operaPath = "$env:LOCALAPPDATA\Programs\Opera"
    $operaGXPath = "$env:LOCALAPPDATA\Programs\Opera GX"
    $themePath = "$env:USERPROFILE\Documents\NordShade\Opera"
    
    # Check if Opera or Opera GX is installed
    $operaExists = Test-Path $operaPath
    $operaGXExists = Test-Path $operaGXPath
    
    if (-not ($operaExists -or $operaGXExists)) {
        Write-Host "Opera doesn't appear to be installed on this system." -ForegroundColor Red
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
    
    $operaExecutable = if ($operaGXExists) { "$operaGXPath\launcher.exe" } else { "$operaPath\launcher.exe" }
    $operaType = if ($operaGXExists) { "Opera GX" } else { "Opera" }
    
    if ($AutoApply) {
        Write-Host "Opera themes need to be loaded as an unpacked extension." -ForegroundColor Cyan
        Write-Host "Instructions:" -ForegroundColor Cyan
        Write-Host "1. Open Opera and navigate to opera://extensions/" -ForegroundColor Cyan
        Write-Host "2. Enable 'Developer mode' (toggle in top-right)" -ForegroundColor Cyan
        Write-Host "3. Click 'Load unpacked' and select this folder: $themePath" -ForegroundColor Cyan
        
        # Try to open Opera to the extensions page
        try {
            Start-Process $operaExecutable -ArgumentList "opera://extensions/"
            Start-Process "explorer.exe" -ArgumentList $themePath
            Write-Host "$operaType has been opened to the extensions page and the theme folder has been opened." -ForegroundColor Green
        } catch {
            Write-Host "Unable to automatically open $operaType. Please follow the manual instructions above." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Theme files have been installed to: $themePath" -ForegroundColor Green
        Write-Host "To apply the theme:" -ForegroundColor Cyan
        Write-Host "1. Open Opera and navigate to opera://extensions/" -ForegroundColor Cyan
        Write-Host "2. Enable 'Developer mode' (toggle in top-right)" -ForegroundColor Cyan
        Write-Host "3. Click 'Load unpacked' and select this folder: $themePath" -ForegroundColor Cyan
    }
    
    Write-Host "Opera theme installation complete." -ForegroundColor Green
}

# Call the function if script is run directly
if ($MyInvocation.InvocationName -ne ".") {
    Install-OperaTheme
} 