# NordShade for Obsidian - Installation Script
# This script installs the NordShade theme for Obsidian

function Install-ObsidianTheme {
    param (
        [string]$ThemeRoot = $PSScriptRoot,
        [string]$VaultPath = "",
        [switch]$AutoApply
    )
    
    Write-Host "Installing NordShade for Obsidian..." -ForegroundColor Yellow
    
    # Ask for Obsidian vault location if not provided
    if ([string]::IsNullOrWhiteSpace($VaultPath)) {
        $defaultVault = Join-Path -Path ([Environment]::GetFolderPath("MyDocuments")) -ChildPath "Obsidian"
        $VaultPath = Read-Host "Enter your Obsidian vault path (or press Enter for default: $defaultVault)"
        
        if ([string]::IsNullOrWhiteSpace($VaultPath)) {
            $VaultPath = $defaultVault
        }
    }
    
    # Check if vault exists
    if (-not (Test-Path $VaultPath)) {
        Write-Host "Vault not found at $VaultPath. Please check the path and try again." -ForegroundColor Red
        return
    }
    
    # Create theme directory
    $obsidianThemePath = "${VaultPath}\.obsidian\themes\NordShade"
    if (-not (Test-Path $obsidianThemePath)) {
        New-Item -Path $obsidianThemePath -ItemType Directory -Force | Out-Null
    }
    
    # Ensure we have the correct path to theme files
    $themeFile = Join-Path -Path $ThemeRoot -ChildPath "theme.css"
    $manifestFile = Join-Path -Path $ThemeRoot -ChildPath "manifest.json"
    
    # Verify theme files exist
    if (-not (Test-Path $themeFile)) {
        Write-Host "Theme file not found at: $themeFile" -ForegroundColor Red
        return
    }
    
    if (-not (Test-Path $manifestFile)) {
        Write-Host "Manifest file not found at: $manifestFile" -ForegroundColor Red
        return
    }
    
    # Copy theme files
    Copy-Item $themeFile -Destination $obsidianThemePath
    Copy-Item $manifestFile -Destination $obsidianThemePath
    
    Write-Host "Theme files installed to $obsidianThemePath" -ForegroundColor Green
    
    # Determine if we should apply the theme
    if (-not $PSBoundParameters.ContainsKey('AutoApply')) {
        $applyTheme = Read-Host "Would you like to automatically apply the NordShade theme? (y/n)"
        $AutoApply = $applyTheme -eq 'y'
    }
    
    # Try to auto-apply theme by updating appearance.json if requested
    if ($AutoApply) {
        $appearanceJsonPath = "$VaultPath\.obsidian\appearance.json"
        
        if (Test-Path $appearanceJsonPath) {
            # Backup appearance.json
            Copy-Item -Path $appearanceJsonPath -Destination "$appearanceJsonPath.backup" -Force
            Write-Host "Backed up Obsidian appearance settings to $appearanceJsonPath.backup" -ForegroundColor Green
            
            try {
                # Read appearance.json
                $appearanceConfig = Get-Content -Path $appearanceJsonPath -Raw | ConvertFrom-Json
                
                # Update theme setting
                $appearanceConfig.theme = "NordShade"
                
                # Save updated config
                $appearanceConfig | ConvertTo-Json -Depth 20 | Set-Content -Path $appearanceJsonPath
                
                Write-Host "Obsidian theme automatically applied!" -ForegroundColor Green
                Write-Host "If Obsidian is currently running, you may need to restart it for changes to take effect." -ForegroundColor Yellow
            } catch {
                Write-Host "Could not automatically apply Obsidian theme." -ForegroundColor Yellow
                Write-Host "To activate, open Obsidian -> Settings -> Appearance -> Select 'NordShade' theme" -ForegroundColor Yellow
            }
        } else {
            Write-Host "Could not find Obsidian appearance settings. Theme has been installed but must be activated manually." -ForegroundColor Yellow
            Write-Host "To activate, open Obsidian -> Settings -> Appearance -> Select 'NordShade' theme" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Theme installed but not automatically applied." -ForegroundColor Yellow
        Write-Host "To activate, open Obsidian -> Settings -> Appearance -> Select 'NordShade' theme" -ForegroundColor Yellow
    }
}

# If script is run directly (not imported), install the theme
if ($MyInvocation.InvocationName -ne ".") {
    Install-ObsidianTheme
}

# Export the function for import by the main installer
try {
    # Only attempt to export if we're inside a module context
    Export-ModuleMember -Function Install-ObsidianTheme -ErrorAction Stop
} catch {
    # Silently ignore export error when running directly
} 