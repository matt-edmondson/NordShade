# NordShade for Visual Studio Code - Installation Script
# This script installs the NordShade theme for Visual Studio Code

function Install-VSCodeTheme {
    param (
        [string]$ThemeRoot = $PSScriptRoot,
        [switch]$AutoApply
    )
    
    Write-Host "Installing NordShade for Visual Studio Code..." -ForegroundColor Yellow
    
    $vsCodeExtPath = "$env:USERPROFILE\.vscode\extensions\nordshade-theme"
    
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
        $settingsPath = "$env:APPDATA\Code\User\settings.json"
        
        # Create settings.json if it doesn't exist
        if (-not (Test-Path $settingsPath)) {
            New-Item -Path $settingsPath -ItemType File -Force | Out-Null
            Set-Content -Path $settingsPath -Value "{}"
        }
        
        # Read current settings
        try {
            $settings = Get-Content -Path $settingsPath -Raw | ConvertFrom-Json
        } catch {
            # If the file is invalid JSON, create a new settings object
            $settings = [PSCustomObject]@{}
        }

        # Backup settings
        Copy-Item -Path $settingsPath -Destination "$settingsPath.backup" -Force
        
        # Update workbench color theme
        $settings.PSObject.Properties.Remove('workbench.colorTheme')
        $settings | Add-Member -Type NoteProperty -Name 'workbench.colorTheme' -Value 'NordShade'
        
        # Save settings
        $settings | ConvertTo-Json -Depth 20 | Set-Content -Path $settingsPath
        
        Write-Host "VS Code theme automatically applied!" -ForegroundColor Green
        Write-Host "Settings backup created at $settingsPath.backup" -ForegroundColor Green
    } else {
        Write-Host "Theme installed but not automatically applied." -ForegroundColor Yellow
        Write-Host "To apply the theme manually, go to VS Code -> Settings -> Color Theme and select 'NordShade'" -ForegroundColor Yellow
    }
}

# If script is run directly (not imported), install the theme
if ($MyInvocation.InvocationName -ne ".") {
    Install-VSCodeTheme
}

# Export the function for import by the main installer
Export-ModuleMember -Function Install-VSCodeTheme -ErrorAction SilentlyContinue 