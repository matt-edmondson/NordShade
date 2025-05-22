# NordShade for Cursor IDE - Installation Script
# This script installs the NordShade theme for Cursor IDE

function Install-CursorTheme {
    param (
        [string]$ThemeRoot = $PSScriptRoot,
        [switch]$AutoApply
    )
    
    Write-Host "Installing NordShade for Cursor IDE..." -ForegroundColor Yellow
    
    # Check if Cursor is installed
    $cursorPath = "$env:LOCALAPPDATA\Programs\Cursor\resources\app\extensions"
    if (-not (Test-Path $cursorPath)) {
        $cursorPath = "$env:APPDATA\cursor-editor\extensions"
    }
    
    if (-not (Test-Path $cursorPath)) {
        Write-Host "Cursor IDE not found. Please make sure it's installed." -ForegroundColor Red
        return
    }
    
    $cursorExtPath = "$cursorPath\nordshade-theme"
    
    # Create directory if it doesn't exist
    if (-not (Test-Path $cursorExtPath)) {
        New-Item -Path $cursorExtPath -ItemType Directory -Force | Out-Null
    }
    
    # Copy theme files
    Copy-Item "$ThemeRoot\NordShade.json" -Destination $cursorExtPath
    Copy-Item "$ThemeRoot\package.json" -Destination $cursorExtPath
    
    Write-Host "Theme files installed to $cursorExtPath" -ForegroundColor Green
    
    # Determine if we should apply the theme
    if (-not $PSBoundParameters.ContainsKey('AutoApply')) {
        $applyTheme = Read-Host "Would you like to automatically apply the NordShade theme? (y/n)"
        $AutoApply = $applyTheme -eq 'y'
    }
    
    # Automatically apply the theme by updating settings.json
    if ($AutoApply) {
        $settingsPath = "$env:APPDATA\Cursor\User\settings.json"
        
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
        
        Write-Host "Cursor IDE theme automatically applied!" -ForegroundColor Green
        Write-Host "Settings backup created at $settingsPath.backup" -ForegroundColor Green
    } else {
        Write-Host "Theme installed but not automatically applied." -ForegroundColor Yellow
        Write-Host "To apply the theme manually, go to Cursor IDE -> Settings -> Color Theme and select 'NordShade'" -ForegroundColor Yellow
    }
}

# If script is run directly (not imported), install the theme
if ($MyInvocation.InvocationName -ne ".") {
    Install-CursorTheme
}

# Export the function for import by the main installer
Export-ModuleMember -Function Install-CursorTheme -ErrorAction SilentlyContinue 