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
            Write-Host "Latest GitHub Desktop version found: $latestVersionDir" -ForegroundColor Green
            
            # Try multiple possible locations for the main CSS/JS files
            $possiblePaths = @(
                # Classic path
                Join-Path $latestVersionDir "resources\app\static\common\main.js",
                # Try renderer directory
                Join-Path $latestVersionDir "resources\app\renderer\main.js",
                # Try just static directory
                Join-Path $latestVersionDir "resources\app\static\main.js",
                # Try renderer-specific files
                Join-Path $latestVersionDir "resources\app\renderer\index.js",
                # Try in app directory
                Join-Path $latestVersionDir "resources\app\main.js",
                # Try styles directory
                Join-Path $latestVersionDir "resources\app\static\styles\styles.css",
                # Try dist directory
                Join-Path $latestVersionDir "resources\app\dist\main.js",
                # Try dist static directory
                Join-Path $latestVersionDir "resources\app\dist\static\main.js"
            )
            
            # Try to find the CSS file by searching
            $foundCssFile = $null
            $cssFiles = Get-ChildItem -Path $latestVersionDir -Filter "*.css" -Recurse -ErrorAction SilentlyContinue | 
                        Where-Object { $_.FullName -like "*static*" -or $_.FullName -like "*styles*" -or $_.FullName -like "*renderer*" }
            
            if ($cssFiles.Count -gt 0) {
                # Sort by file size (assuming larger CSS files are more likely to be the main stylesheet)
                $foundCssFile = $cssFiles | Sort-Object Length -Descending | Select-Object -First 1
                Write-Host "Found potential CSS file: $($foundCssFile.FullName)" -ForegroundColor Green
                $possiblePaths += $foundCssFile.FullName
            }
            
            # Try to find the renderer.js file
            $rendererFiles = Get-ChildItem -Path $latestVersionDir -Filter "renderer*.js" -Recurse -ErrorAction SilentlyContinue
            if ($rendererFiles.Count -gt 0) {
                foreach ($rendererFile in $rendererFiles) {
                    Write-Host "Found potential renderer file: $($rendererFile.FullName)" -ForegroundColor Green
                    $possiblePaths += $rendererFile.FullName
                }
            }
            
            $mainJsPath = $null
            foreach ($path in $possiblePaths) {
                if (Test-Path $path) {
                    $mainJsPath = $path
                    Write-Host "Found potential theme file at: $mainJsPath" -ForegroundColor Green
                    break
                }
            }
            
            if ($mainJsPath) {
                # Create a backup if it doesn't exist
                $backupPath = "$mainJsPath.backup"
                if (-not (Test-Path $backupPath)) {
                    Copy-Item $mainJsPath -Destination $backupPath
                    Write-Host "Created backup at: $backupPath" -ForegroundColor Green
                }
                
                # Now read the nord-shade.less file content
                $themeContent = Get-Content -Path "$ThemeRoot\nord-shade.less" -Raw
                
                if ($AutoApply) {
                    # We need to integrate the theme into main.js or CSS file
                    try {
                        $content = Get-Content -Path $mainJsPath -Raw
                        
                        # Check if theme is already installed
                        if ($content -match "nord-shade-theme") {
                            Write-Host "NordShade theme already installed in GitHub Desktop." -ForegroundColor Yellow
                        } else {
                            # If it's a CSS file
                            if ($mainJsPath -like "*.css") {
                                # For CSS files, we can simply append our theme content
                                $themeInsertion = "`n/* begin nord-shade-theme */`n$themeContent`n/* end nord-shade-theme */`n"
                                Add-Content -Path $mainJsPath -Value $themeInsertion
                                Write-Host "Successfully integrated NordShade theme into GitHub Desktop CSS file!" -ForegroundColor Green
                            } else {
                                # For JS files, find the right spot to insert the theme
                                # Try to find CSS section by looking for common selectors
                                $insertionPoints = @(
                                    'body {',
                                    '.theme-dark {',
                                    'body.theme-dark {',
                                    '/* Globals */',
                                    '/* Global styles */',
                                    'body[class*="theme-"] {'
                                )
                                
                                $insertIndex = -1
                                foreach ($point in $insertionPoints) {
                                    if ($content.Contains($point)) {
                                        $insertIndex = $content.IndexOf($point)
                                        break
                                    }
                                }
                                
                                if ($insertIndex -ge 0) {
                                    # Add a comment to identify our theme - insert at the found position
                                    $themeInsertion = "/* begin nord-shade-theme */`n$themeContent`n/* end nord-shade-theme */`n"
                                    $newContent = $content.Substring(0, $insertIndex) + $themeInsertion + $content.Substring($insertIndex)
                                    
                                    # Write the modified content back
                                    Set-Content -Path $mainJsPath -Value $newContent
                                    Write-Host "Successfully integrated NordShade theme into GitHub Desktop!" -ForegroundColor Green
                                } else {
                                    # Fallback - try to insert at the end of the file or before the last closing bracket
                                    $cssEndIndex = $content.LastIndexOf("}")
                                    if ($cssEndIndex -gt 0) {
                                        $themeInsertion = "/* begin nord-shade-theme */`n$themeContent`n/* end nord-shade-theme */`n}"
                                        $newContent = $content.Substring(0, $cssEndIndex) + $themeInsertion
                                        
                                        # Write the modified content back
                                        Set-Content -Path $mainJsPath -Value $newContent
                                        Write-Host "Successfully integrated NordShade theme into GitHub Desktop! (fallback method)" -ForegroundColor Green
                                    } else {
                                        # Last resort - just append to the end
                                        $themeInsertion = "`n/* begin nord-shade-theme */`n$themeContent`n/* end nord-shade-theme */`n"
                                        Add-Content -Path $mainJsPath -Value $themeInsertion
                                        Write-Host "Added NordShade theme to the end of file - may require manual adjustment." -ForegroundColor Yellow
                                    }
                                }
                            }
                            
                            Write-Host "Please restart GitHub Desktop to see the changes." -ForegroundColor Yellow
                        }
                    } catch {
                        Write-Host "Error integrating theme: $_" -ForegroundColor Red
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
                Write-Host "Could not find a suitable CSS or JS file in the latest GitHub Desktop version." -ForegroundColor Red
                
                # Create detailed instructions for manual installation
                $fallbackPath = "${env:USERPROFILE}\Documents\NordShade-GitHubDesktop.less"
                Copy-Item "$ThemeRoot\nord-shade.less" -Destination $fallbackPath
                Write-Host "Theme file copied to: $fallbackPath" -ForegroundColor Yellow
                
                # Create more detailed instructions
                $instructionsPath = "${env:USERPROFILE}\Documents\NordShade-GitHubDesktop-Instructions.txt"
                $instructions = @"
NordShade for GitHub Desktop - Manual Installation Instructions

1. Close GitHub Desktop completely if it's running.

2. Navigate to your GitHub Desktop installation folder:
   ${env:LOCALAPPDATA}\GitHubDesktop\app-*\

3. Look for one of these files (or similar):
   - resources\app\static\common\main.js
   - resources\app\static\styles.css
   - resources\app\renderer\index.js
   - resources\app\dist\static\main.js

4. Create a backup of the file before making any changes.

5. Open the file with a text editor like Notepad++ or VSCode.

6. For CSS files:
   - Add the theme content at the end of the file.

7. For JS files:
   - Look for a section containing CSS style definitions.
   - These often look like large blocks with selectors such as "body", ".theme-dark", etc.
   - Add the theme content within this CSS section.

8. The theme content is located at:
   $fallbackPath

9. Save the file and restart GitHub Desktop.

Note: After GitHub Desktop updates, you may need to reapply these changes.
"@
                Set-Content -Path $instructionsPath -Value $instructions
                Write-Host "Detailed manual installation instructions saved to: $instructionsPath" -ForegroundColor Yellow
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