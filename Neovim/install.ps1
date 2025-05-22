# NordShade for Neovim - Installation Script (PowerShell)
# Installs the NordShade theme for Neovim

function Install-NeovimTheme {
    param (
        [string]$ThemeRoot = $PSScriptRoot,
        [switch]$AutoApply
    )
    
    Write-Host "Installing NordShade for Neovim..." -ForegroundColor Yellow
    
    # Define paths
    $NeovimColorsDir = "${env:LOCALAPPDATA}\nvim\colors"
    
    # Create colors directory if it doesn't exist
    if (-not (Test-Path $NeovimColorsDir)) {
        Write-Host "Creating Neovim colors directory: $NeovimColorsDir" -ForegroundColor Cyan
        New-Item -ItemType Directory -Path $NeovimColorsDir -Force | Out-Null
    }
    
    # Copy theme file to colors directory
    try {
        $sourceThemePath = "${ThemeRoot}\nord_shade.vim"
        $destThemePath = "${NeovimColorsDir}\nord_shade.vim"
        
        Write-Host "Installing NordShade theme for Neovim..." -ForegroundColor Cyan
        Copy-Item -Path $sourceThemePath -Destination $destThemePath -Force
        
        Write-Host "Successfully installed NordShade theme for Neovim!" -ForegroundColor Green
        Write-Host "Add the following to your init.vim or init.lua to activate the theme:" -ForegroundColor Yellow
        Write-Host "`nFor init.vim:" -ForegroundColor Yellow
        Write-Host 'colorscheme nord_shade' -ForegroundColor White
        Write-Host "`nFor init.lua:" -ForegroundColor Yellow
        Write-Host 'vim.cmd("colorscheme nord_shade")' -ForegroundColor White
        
        # Check if we should try to automatically apply the theme
        if ($AutoApply) {
            # Try to find init.vim or init.lua
            $initFiles = @(
                "${env:LOCALAPPDATA}\nvim\init.vim",
                "${env:LOCALAPPDATA}\nvim\init.lua"
            )
            
            $configModified = $false
            
            foreach ($initFile in $initFiles) {
                if (Test-Path $initFile) {
                    $configContent = Get-Content -Path $initFile -Raw
                    
                    # Check if there's already a colorscheme line
                    $hasColorScheme = $configContent -match "colorscheme" -or $configContent -match "vim.cmd\(.*colorscheme"
                    
                    # Create backup
                    Copy-Item -Path $initFile -Destination "$initFile.backup" -Force
                    Write-Host "Created backup of $initFile to $initFile.backup" -ForegroundColor Cyan
                    
                    if ($initFile.EndsWith('.vim')) {
                        # For Vim script
                        if ($hasColorScheme) {
                            Write-Host "Found existing colorscheme in $initFile. Not automatically modifying." -ForegroundColor Yellow
                            Write-Host "Please update it manually to: colorscheme nord_shade" -ForegroundColor Yellow
                        } else {
                            # Append the colorscheme line
                            Add-Content -Path $initFile -Value "`n\" NordShade Theme"
                            Add-Content -Path $initFile -Value "colorscheme nord_shade"
                            Write-Host "Successfully updated $initFile to use NordShade theme!" -ForegroundColor Green
                            $configModified = $true
                        }
                    } elseif ($initFile.EndsWith('.lua')) {
                        # For Lua
                        if ($hasColorScheme) {
                            Write-Host "Found existing colorscheme in $initFile. Not automatically modifying." -ForegroundColor Yellow
                            Write-Host "Please update it manually to: vim.cmd(\"colorscheme nord_shade\")" -ForegroundColor Yellow
                        } else {
                            # Append the colorscheme line
                            Add-Content -Path $initFile -Value "`n-- NordShade Theme"
                            Add-Content -Path $initFile -Value "vim.cmd(\"colorscheme nord_shade\")"
                            Write-Host "Successfully updated $initFile to use NordShade theme!" -ForegroundColor Green
                            $configModified = $true
                        }
                    }
                }
            }
            
            if (-not $configModified) {
                Write-Host "No Neovim config files found (or all had existing colorscheme settings)." -ForegroundColor Yellow
                Write-Host "Please add the theme to your Neovim configuration manually." -ForegroundColor Yellow
            }
        }
    } catch {
        Write-Host "Error installing NordShade theme for Neovim: $_" -ForegroundColor Red
    }
}

# If script is run directly (not imported), install the theme
if ($MyInvocation.InvocationName -ne ".") {
    Install-NeovimTheme
}

# Export the function for import by the main installer
Export-ModuleMember -Function Install-NeovimTheme -ErrorAction SilentlyContinue
