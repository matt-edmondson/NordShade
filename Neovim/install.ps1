# NordShade for Neovim - Installation Script (PowerShell)
# Installs the NordShade theme for Neovim

# Define paths
$NeovimColorsDir = "${env:LOCALAPPDATA}\nvim\colors"

# Create colors directory if it doesn't exist
if (-not (Test-Path $NeovimColorsDir)) {
    Write-Host "Creating Neovim colors directory: $NeovimColorsDir" -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $NeovimColorsDir -Force | Out-Null
}

# Copy theme file to colors directory
try {
    $sourceThemePath = "${PSScriptRoot}\nord_shade.vim"
    $destThemePath = "${NeovimColorsDir}\nord_shade.vim"
    
    Write-Host "Installing NordShade theme for Neovim..." -ForegroundColor Cyan
    Copy-Item -Path $sourceThemePath -Destination $destThemePath -Force
    
    Write-Host "Successfully installed NordShade theme for Neovim!" -ForegroundColor Green
    Write-Host "Add the following to your init.vim or init.lua to activate the theme:" -ForegroundColor Yellow
    Write-Host "`nFor init.vim:" -ForegroundColor Yellow
    Write-Host 'colorscheme nord_shade' -ForegroundColor White
    Write-Host "`nFor init.lua:" -ForegroundColor Yellow
    Write-Host 'vim.cmd("colorscheme nord_shade")' -ForegroundColor White
} catch {
    Write-Host "Error installing NordShade theme for Neovim: ${_}" -ForegroundColor Red
} 