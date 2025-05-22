# NordShade for Visual Studio 2022 - Installation Script
# This script installs the NordShade theme for Visual Studio 2022

function Install-VisualStudioTheme {
    param (
        [string]$ThemeRoot = $PSScriptRoot,
        [switch]$AutoApply
    )
    
    Write-Host "Installing NordShade for Visual Studio 2022..." -ForegroundColor Yellow
    
    # Copy settings file to a location the user can easily access
    $settingsPath = "${env:USERPROFILE}\Documents\NordShade.vssettings"
    Copy-Item "$ThemeRoot\NordShade.vssettings" -Destination $settingsPath
    
    Write-Host "Visual Studio settings file copied to $settingsPath" -ForegroundColor Green
    
    # Determine if we should try to apply the theme
    if (-not $PSBoundParameters.ContainsKey('AutoApply')) {
        $applyTheme = Read-Host "Would you like to automatically apply the NordShade theme? (y/n)"
        $AutoApply = $applyTheme -eq 'y'
    }
    
    # Try to apply settings automatically using devenv.exe if auto-apply is enabled
    if ($AutoApply) {
        $vsPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\VisualStudio\SxS\VS7" -Name "17.0" -ErrorAction SilentlyContinue)."17.0"
        if ($vsPath) {
            $devenvPath = Join-Path $vsPath "Common7\IDE\devenv.exe"
            if (Test-Path $devenvPath) {
                Write-Host "Attempting to apply Visual Studio settings automatically..." -ForegroundColor Yellow
                Start-Process -FilePath $devenvPath -ArgumentList "/resetuserdata", "/command", "Tools.ImportandExportSettings /import:""$settingsPath""" -Wait
                Write-Host "Visual Studio theme should be applied. If Visual Studio was running, you may need to restart it." -ForegroundColor Green
            } else {
                Write-Host "Could not find Visual Studio executable. Theme installed but must be applied manually." -ForegroundColor Yellow
                Write-Host "To apply the theme, open Visual Studio -> Tools -> Import and Export Settings..." -ForegroundColor Yellow
                Write-Host "Then select 'Import selected environment settings' and browse to: $settingsPath" -ForegroundColor Yellow
            }
        } else {
            Write-Host "Could not detect Visual Studio 2022 installation path." -ForegroundColor Yellow
            Write-Host "To apply the theme, open Visual Studio -> Tools -> Import and Export Settings..." -ForegroundColor Yellow
            Write-Host "Then select 'Import selected environment settings' and browse to: $settingsPath" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Theme installed but not automatically applied." -ForegroundColor Yellow
        Write-Host "To apply the theme, open Visual Studio -> Tools -> Import and Export Settings..." -ForegroundColor Yellow
        Write-Host "Then select 'Import selected environment settings' and browse to: $settingsPath" -ForegroundColor Yellow
    }
}

# If script is run directly (not imported), install the theme
if ($MyInvocation.InvocationName -ne ".") {
    Install-VisualStudioTheme
}

# Export the function for import by the main installer
Export-ModuleMember -Function Install-VisualStudioTheme -ErrorAction SilentlyContinue 