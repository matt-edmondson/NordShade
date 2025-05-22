function Install-FirefoxTheme {
    param (
        [string]$ThemeRoot = $PSScriptRoot,
        [switch]$AutoApply
    )
    
    Write-Host "Installing NordShade for Firefox..." -ForegroundColor Yellow
    
    # Paths
    $themePath = "$env:USERPROFILE\Documents\NordShade\Firefox"
    
    # Check if Firefox is installed
    $firefoxPath = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\firefox.exe" -ErrorAction SilentlyContinue)."(default)"
    if (-not $firefoxPath) {
        Write-Host "Firefox doesn't appear to be installed on this system." -ForegroundColor Red
        return
    }
    
    # Create theme directory if it doesn't exist
    if (-not (Test-Path $themePath)) {
        New-Item -Path $themePath -ItemType Directory -Force | Out-Null
    }
    
    # Copy theme files
    Copy-Item "$ThemeRoot\manifest.json" -Destination $themePath
    Copy-Item "$ThemeRoot\nordshade.xpi" -Destination $themePath
    
    # Determine if we should try to assist with theme application
    if (-not $PSBoundParameters.ContainsKey('AutoApply')) {
        $applyTheme = Read-Host "Would you like to automatically apply the theme? (y/n)"
        $AutoApply = $applyTheme -eq 'y'
    }
    
    # Firefox themes can be loaded in two ways:
    # 1. As a temporary add-on (for development)
    # 2. As a published extension (for regular users)
    
    if ($AutoApply) {
        # The easier way for users is to open the XPI file with Firefox
        Write-Host "Attempting to install the Firefox theme..." -ForegroundColor Cyan
        
        try {
            Start-Process $firefoxPath -ArgumentList """$themePath\nordshade.xpi"""
            Write-Host "Firefox has been opened with the theme package." -ForegroundColor Green
            Write-Host "Follow the prompts in Firefox to complete installation." -ForegroundColor Cyan
        } catch {
            Write-Host "Unable to automatically open Firefox. Please follow the manual instructions below." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Theme files have been installed to: $themePath" -ForegroundColor Green
        Write-Host "To apply the theme:" -ForegroundColor Cyan
        Write-Host "1. Open Firefox" -ForegroundColor Cyan
        Write-Host "2. Navigate to about:addons" -ForegroundColor Cyan
        Write-Host "3. Click the gear icon and select 'Install Add-on From File...'" -ForegroundColor Cyan
        Write-Host "4. Browse to $themePath\nordshade.xpi and open it" -ForegroundColor Cyan
        Write-Host "5. Follow the prompts to install the theme" -ForegroundColor Cyan
    }
    
    Write-Host "Firefox theme installation complete." -ForegroundColor Green
}

# Call the function if script is run directly
if ($MyInvocation.InvocationName -ne ".") {
    Install-FirefoxTheme
} 