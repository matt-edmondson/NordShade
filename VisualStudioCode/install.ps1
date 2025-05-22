# NordShade for Visual Studio Code - Installation Script
# This script installs the NordShade theme for Visual Studio Code

function Install-VisualStudioCodeTheme {
    param (
        [string]$ThemeRoot = $PSScriptRoot,
        [switch]$AutoApply
    )
    
    Write-Host "Installing NordShade for Visual Studio Code..." -ForegroundColor Yellow
    
    $vsCodeExtPath = "${env:USERPROFILE}\.vscode\extensions\nordshade-theme"
    
    # Create directory if it doesn't exist
    if (-not (Test-Path $vsCodeExtPath)) {
        New-Item -Path $vsCodeExtPath -ItemType Directory -Force | Out-Null
    }
    
    # Copy theme files
    Copy-Item "$ThemeRoot\NordShade.json" -Destination $vsCodeExtPath
    Copy-Item "$ThemeRoot\package.json" -Destination $vsCodeExtPath
    Copy-Item "$ThemeRoot\README.md" -Destination $vsCodeExtPath -ErrorAction SilentlyContinue
    
    Write-Host "Theme files installed to $vsCodeExtPath" -ForegroundColor Green
    
    # Determine if we should apply the theme
    if (-not $PSBoundParameters.ContainsKey('AutoApply')) {
        $applyTheme = Read-Host "Would you like to automatically apply the NordShade theme? (y/n)"
        $AutoApply = $applyTheme -eq 'y'
    }
    
    # Automatically apply the theme by updating settings.json
    if ($AutoApply) {
        $settingsPath = "${env:APPDATA}\Code\User\settings.json"
        
        # Backup settings first if they exist
        if (Test-Path $settingsPath) {
            $backupPath = "$settingsPath.backup"
            Copy-Item -Path $settingsPath -Destination $backupPath -Force
            Write-Host "Settings backup created at $backupPath" -ForegroundColor Green
        }
        
        try {
            # Approach 1: Try to read and modify the existing settings.json
            if (Test-Path $settingsPath) {
                # Read current settings as text first to ensure proper handling
                $settingsContent = Get-Content -Path $settingsPath -Raw -ErrorAction Stop
                
                # If the file is empty or only whitespace, initialize with empty JSON object
                if ([string]::IsNullOrWhiteSpace($settingsContent)) {
                    $settingsContent = "{}"
                }
                
                try {
                    # Parse the JSON and modify it
                    $settings = $settingsContent | ConvertFrom-Json -ErrorAction Stop
                    
                    # Handle both PSCustomObject and Hashtable depending on PowerShell version
                    if ($settings -is [PSCustomObject]) {
                        # Check if the property exists before removing it
                        if ($settings.PSObject.Properties['workbench.colorTheme']) {
                            $settings.PSObject.Properties.Remove('workbench.colorTheme')
                        }
                        # Add the property
                        $settings | Add-Member -Type NoteProperty -Name 'workbench.colorTheme' -Value 'NordShade' -Force
                    } else {
                        # It's a hashtable
                        $settings['workbench.colorTheme'] = 'NordShade'
                    }
                    
                    # Convert to formatted JSON with careful handling to avoid syntax errors
                    $newContent = $settings | ConvertTo-Json -Depth 20 -ErrorAction Stop
                    
                    # Write the file with UTF8 encoding without BOM
                    $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $false
                    [System.IO.File]::WriteAllText($settingsPath, $newContent, $Utf8NoBomEncoding)
                    
                    Write-Host "VS Code settings updated to use NordShade theme!" -ForegroundColor Green
                }
                catch {
                    # If JSON parsing fails, try approach 2
                    throw "Error parsing settings.json: $_"
                }
            }
            else {
                # Approach 2: Create a new settings.json with minimal content
                $newSettingsDir = Split-Path -Parent $settingsPath
                if (-not (Test-Path $newSettingsDir)) {
                    New-Item -Path $newSettingsDir -ItemType Directory -Force | Out-Null
                }
                
                $newSettings = @{
                    "workbench.colorTheme" = "NordShade"
                }
                
                $newContent = $newSettings | ConvertTo-Json -Depth 1 -ErrorAction Stop
                
                # Write the file with UTF8 encoding without BOM
                $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $false
                [System.IO.File]::WriteAllText($settingsPath, $newContent, $Utf8NoBomEncoding)
                
                Write-Host "Created new VS Code settings.json with NordShade theme!" -ForegroundColor Green
            }
            
            Write-Host "VS Code theme automatically applied!" -ForegroundColor Green
            Write-Host "To revert changes, use the backup file or manually change the theme in VS Code settings." -ForegroundColor Yellow
        }
        catch {
            Write-Host "Error updating VS Code settings: $_" -ForegroundColor Red
            Write-Host "Please apply the theme manually through VS Code settings." -ForegroundColor Yellow
            
            # Try to restore backup if we created one and the operation failed
            if (Test-Path $backupPath) {
                try {
                    Copy-Item -Path $backupPath -Destination $settingsPath -Force
                    Write-Host "Original settings restored from backup." -ForegroundColor Green
                }
                catch {
                    Write-Host "Failed to restore backup settings: $_" -ForegroundColor Red
                }
            }
        }
    } else {
        Write-Host "Theme installed but not automatically applied." -ForegroundColor Yellow
        Write-Host "To apply the theme manually, go to VS Code -> Settings -> Color Theme and select 'NordShade'" -ForegroundColor Yellow
    }
}

# If script is run directly (not imported), install the theme
if ($MyInvocation.InvocationName -ne ".") {
    Install-VisualStudioCodeTheme
}

# Export the function for import by the main installer
Export-ModuleMember -Function Install-VisualStudioCodeTheme -ErrorAction SilentlyContinue 