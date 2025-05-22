# NordShade for Microsoft Edge - Installation Script
# This script installs the NordShade theme for Microsoft Edge

function Install-EdgeTheme {
    param (
        [string]$ThemeRoot = $PSScriptRoot
    )
    
    Write-Host "Installing NordShade for Microsoft Edge..." -ForegroundColor Yellow
    
    # Check if Edge is installed
    $edgePath = "${env:ProgramFiles}\Microsoft\Edge\Application\msedge.exe"
    $edgePath86 = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
    
    if (-not (Test-Path $edgePath) -and -not (Test-Path $edgePath86)) {
        Write-Host "Microsoft Edge not detected." -ForegroundColor Red
        Write-Host "Edge themes require manual installation." -ForegroundColor Yellow
        return
    }
    
    # Create extension directory
    $edgeExtPath = "${env:USERPROFILE}\EdgeExtensions\NordShade"
    if (-not (Test-Path $edgeExtPath)) {
        New-Item -Path $edgeExtPath -ItemType Directory -Force | Out-Null
    }
    
    # Copy manifest and theme files
    Copy-Item "$ThemeRoot\manifest.json" -Destination $edgeExtPath
    
    # If we have other theme assets, copy them too
    $themeAssets = @("theme_resources.json", "icon.png", "icon_128.png", "images")
    foreach ($asset in $themeAssets) {
        $assetPath = "$ThemeRoot\$asset"
        if (Test-Path $assetPath) {
            if ((Get-Item $assetPath).PSIsContainer) {
                # It's a directory, so copy the whole directory
                Copy-Item $assetPath -Destination $edgeExtPath -Recurse -Force
            } else {
                # It's a file
                Copy-Item $assetPath -Destination $edgeExtPath
            }
        }
    }
    
    Write-Host "Microsoft Edge theme prepared at $edgeExtPath" -ForegroundColor Green
    Write-Host "Edge themes require manual installation. To install:" -ForegroundColor Yellow
    Write-Host "1. Open Edge and go to edge://extensions/" -ForegroundColor Yellow
    Write-Host "2. Enable Developer Mode (toggle in the bottom-left)" -ForegroundColor Yellow
    Write-Host "3. Click 'Load unpacked' and select the folder: $edgeExtPath" -ForegroundColor Yellow
    Write-Host "4. The theme should now be installed and active" -ForegroundColor Yellow
}

# If script is run directly (not imported), install the theme
if ($MyInvocation.InvocationName -ne ".") {
    Install-EdgeTheme
}

# Export the function for import by the main installer
Export-ModuleMember -Function Install-EdgeTheme -ErrorAction SilentlyContinue 