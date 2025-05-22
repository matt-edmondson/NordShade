# NordShade for GitHub Desktop - Installation Script
# This script installs the NordShade theme for GitHub Desktop

function Install-GitHubDesktopTheme {
    param (
        [string]$ThemeRoot = $PSScriptRoot
    )
    
    Write-Host "Installing NordShade for GitHub Desktop..." -ForegroundColor Yellow
    
    # Check if GitHub Desktop is installed
    $desktopPath = "$env:LOCALAPPDATA\GitHubDesktop"
    
    if (Test-Path $desktopPath) {
        Write-Host "GitHub Desktop detected..." -ForegroundColor Green
        
        # Look for the correct path for less files
        $themesPaths = @(
            "$env:APPDATA\GitHub Desktop\*\styles\ui\theme-*.less",
            "$env:USERPROFILE\.config\GitHub Desktop\*\styles\ui\theme-*.less",
            "$env:LOCALAPPDATA\GitHub Desktop\app-*\resources\app\styles\themes"
        )
        
        $themeDirFound = $false
        $themeDir = $null
        
        foreach ($path in $themesPaths) {
            $possiblePaths = Get-ChildItem -Path $path -ErrorAction SilentlyContinue
            if ($possiblePaths.Count -gt 0) {
                $themeDir = Split-Path -Parent $possiblePaths[0].FullName
                $themeDirFound = $true
                break
            }
        }
        
        if ($themeDirFound) {
            # Copy the theme file
            $installPath = Join-Path $themeDir "theme-nord-shade.less"
            Copy-Item "$ThemeRoot\nord-shade.less" -Destination $installPath
            Write-Host "Theme installed to: $installPath" -ForegroundColor Green
            Write-Host "To activate, add the following line to variables.less in the same directory:" -ForegroundColor Yellow
            Write-Host '@import "theme-nord-shade";' -ForegroundColor Yellow
            Write-Host "Then restart GitHub Desktop." -ForegroundColor Yellow
        } else {
            # Couldn't find themes folder - just copy to Documents
            $fallbackPath = "$env:USERPROFILE\Documents\NordShade-GitHubDesktop.less"
            Copy-Item "$ThemeRoot\nord-shade.less" -Destination $fallbackPath
            Write-Host "Could not locate GitHub Desktop themes folder." -ForegroundColor Red
            Write-Host "Theme file copied to: $fallbackPath" -ForegroundColor Yellow
            Write-Host "For manual installation instructions, please refer to the README.md file." -ForegroundColor Yellow
        }
    } else {
        # GitHub Desktop not found - just copy to Documents
        $fallbackPath = "$env:USERPROFILE\Documents\NordShade-GitHubDesktop.less"
        Copy-Item "$ThemeRoot\nord-shade.less" -Destination $fallbackPath
        Write-Host "GitHub Desktop not detected." -ForegroundColor Red
        Write-Host "Theme file copied to: $fallbackPath" -ForegroundColor Yellow
        Write-Host "For manual installation instructions, please refer to the README.md file." -ForegroundColor Yellow
    }
}

# If script is run directly (not imported), install the theme
if ($MyInvocation.InvocationName -ne ".") {
    Install-GitHubDesktopTheme
}

# Export the function for import by the main installer
Export-ModuleMember -Function Install-GitHubDesktopTheme -ErrorAction SilentlyContinue 