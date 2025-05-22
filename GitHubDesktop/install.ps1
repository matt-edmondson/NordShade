# NordShade for GitHub Desktop - Installation Script
# This script installs the NordShade theme for GitHub Desktop

function Install-GitHubDesktopTheme {
    param (
        [string]$ThemeRoot = $PSScriptRoot,
        [switch]$AutoApply
    )
    
    Write-Host "Installing NordShade for GitHub Desktop..." -ForegroundColor Yellow
    
    # Check if GitHub Desktop is installed
    $desktopPath = "${env:LOCALAPPDATA}\GitHubDesktop"
    
    if (Test-Path $desktopPath) {
        Write-Host "GitHub Desktop detected..." -ForegroundColor Green
        
        # Find the latest version folder in GitHubDesktop directory
        $appVersionDirs = Get-ChildItem -Path "${env:LOCALAPPDATA}\GitHubDesktop" -Directory | Where-Object { $_.Name -like "app-*" } | Sort-Object Name -Descending
        
        if ($appVersionDirs.Count -gt 0) {
            $latestVersionDir = $appVersionDirs[0].FullName
            $mainJsPath = Join-Path $latestVersionDir "resources\app\static\common\main.js"
            
            if (Test-Path $mainJsPath) {
                Write-Host "Found main.js at: $mainJsPath" -ForegroundColor Green
                
                # Create a backup if it doesn't exist
                $backupPath = "$mainJsPath.backup"
                if (-not (Test-Path $backupPath)) {
                    Copy-Item $mainJsPath -Destination $backupPath
                    Write-Host "Created backup at: $backupPath" -ForegroundColor Green
                }
                
                # Now read the nord-shade.less file content
                $themeContent = Get-Content -Path "$ThemeRoot\nord-shade.less" -Raw
                
                if ($AutoApply) {
                    # We need to integrate the theme into main.js
                    try {
                        $mainJsContent = Get-Content -Path $mainJsPath -Raw
                        
                        # Check if theme is already installed
                        if ($mainJsContent -match "nord-shade-theme") {
                            Write-Host "NordShade theme already installed in GitHub Desktop." -ForegroundColor Yellow
                        } else {
                            # Find the right spot to insert the theme (right before the last close bracket of the CSS section)
                            $cssEndIndex = $mainJsContent.LastIndexOf("}")
                            if ($cssEndIndex -gt 0) {
                                # Add a comment to identify our theme
                                $themeInsertion = "/* begin nord-shade-theme */`n$themeContent`n/* end nord-shade-theme */`n}"
                                $newContent = $mainJsContent.Substring(0, $cssEndIndex) + $themeInsertion
                                
                                # Write the modified content back
                                Set-Content -Path $mainJsPath -Value $newContent
                                Write-Host "Successfully integrated NordShade theme into GitHub Desktop!" -ForegroundColor Green
                                Write-Host "Please restart GitHub Desktop to see the changes." -ForegroundColor Yellow
                            } else {
                                throw "Could not find CSS section end marker in main.js"
                            }
                        }
                    } catch {
                        Write-Host "Error integrating theme into main.js: $_" -ForegroundColor Red
                        Write-Host "Manual installation will be required." -ForegroundColor Yellow
                    }
                } else {
                    # Just save the theme file to Documents for manual installation
                    $themePath = "${env:USERPROFILE}\Documents\NordShade-GitHubDesktop.less"
                    Set-Content -Path $themePath -Value $themeContent
                    Write-Host "Theme file saved to: $themePath" -ForegroundColor Green
                    Write-Host "For manual installation:" -ForegroundColor Yellow
                    Write-Host "1. Open $mainJsPath with a text editor" -ForegroundColor Yellow
                    Write-Host "2. Find the CSS section containing theme definitions" -ForegroundColor Yellow
                    Write-Host "3. Copy and paste the theme code from $themePath" -ForegroundColor Yellow
                    Write-Host "4. Save the file and restart GitHub Desktop" -ForegroundColor Yellow
                }
            } else {
                Write-Host "Could not find main.js in the latest GitHub Desktop version." -ForegroundColor Red
                $fallbackPath = "${env:USERPROFILE}\Documents\NordShade-GitHubDesktop.less"
                Copy-Item "$ThemeRoot\nord-shade.less" -Destination $fallbackPath
                Write-Host "Theme file copied to: $fallbackPath" -ForegroundColor Yellow
                Write-Host "For manual installation instructions, please refer to the README.md file." -ForegroundColor Yellow
            }
        } else {
            Write-Host "Could not find any GitHubDesktop app version directories." -ForegroundColor Red
            $fallbackPath = "${env:USERPROFILE}\Documents\NordShade-GitHubDesktop.less"
            Copy-Item "$ThemeRoot\nord-shade.less" -Destination $fallbackPath
            Write-Host "Theme file copied to: $fallbackPath" -ForegroundColor Yellow
            Write-Host "For manual installation instructions, please refer to the README.md file." -ForegroundColor Yellow
        }
    } else {
        # GitHub Desktop not found - just copy to Documents
        $fallbackPath = "${env:USERPROFILE}\Documents\NordShade-GitHubDesktop.less"
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