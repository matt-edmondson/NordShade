# NordShade for JetBrains DataGrip - Installation Script (PowerShell)
# Installs the NordShade theme for JetBrains DataGrip

# Define JetBrains config paths (varies based on version)
# Look for DataGrip config folders in the expected locations
$JetBrainsConfigFolders = @(
    "$env:APPDATA\JetBrains\DataGrip*",
    "$env:USERPROFILE\.DataGrip*"
)

# Find all matching config folders
$ConfigFolders = @()
foreach ($FolderPattern in $JetBrainsConfigFolders) {
    $ConfigFolders += Get-ChildItem -Path $FolderPattern -Directory -ErrorAction SilentlyContinue
}

if ($ConfigFolders.Count -eq 0) {
    Write-Host "No JetBrains DataGrip configuration folders found. Make sure DataGrip is installed and has been run at least once." -ForegroundColor Red
    exit 1
}

# Install the theme for each found config folder
$SourceThemePath = "$PSScriptRoot\NordShade.xml"
$InstallationCount = 0

foreach ($ConfigFolder in $ConfigFolders) {
    # Each DataGrip config folder should have a "colors" subfolder
    $ColorsDir = Join-Path -Path $ConfigFolder.FullName -ChildPath "colors"
    
    # Create colors directory if it doesn't exist
    if (-not (Test-Path $ColorsDir)) {
        Write-Host "Creating colors directory: $ColorsDir" -ForegroundColor Cyan
        New-Item -ItemType Directory -Path $ColorsDir -Force | Out-Null
    }
    
    # Copy theme file to colors directory
    $DestThemePath = Join-Path -Path $ColorsDir -ChildPath "NordShade.xml"
    
    Write-Host "Installing NordShade theme to: $DestThemePath" -ForegroundColor Cyan
    Copy-Item -Path $SourceThemePath -Destination $DestThemePath -Force
    $InstallationCount++
}

if ($InstallationCount -gt 0) {
    Write-Host "`nNordShade theme has been installed for $InstallationCount DataGrip configuration folder(s)!" -ForegroundColor Green
    Write-Host "`nTo use the theme:" -ForegroundColor Yellow
    Write-Host "1. Restart DataGrip if it's running" -ForegroundColor Yellow
    Write-Host "2. Open Settings (Ctrl+Alt+S)" -ForegroundColor Yellow
    Write-Host "3. Go to Editor > Color Scheme" -ForegroundColor Yellow
    Write-Host "4. Select 'NordShade' from the dropdown" -ForegroundColor Yellow
    Write-Host "5. Click 'Apply' or 'OK'" -ForegroundColor Yellow
} else {
    Write-Host "Failed to install NordShade theme for JetBrains DataGrip" -ForegroundColor Red
} 