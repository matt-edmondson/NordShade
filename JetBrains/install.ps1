# NordShade for JetBrains IDEs - Installation Script (PowerShell)
# Installs the NordShade theme for JetBrains IDEs (IntelliJ IDEA, WebStorm, PyCharm, DataGrip, Rider, etc.)

# Define JetBrains config paths (varies based on version)
# Look for JetBrains config folders in the expected locations
$JetBrainsConfigFolders = @(
    # Windows paths
    "$env:APPDATA\JetBrains\*",
    "$env:USERPROFILE\.JetBrains\*",
    # Direct product paths
    "$env:USERPROFILE\.IntelliJIdea*",
    "$env:USERPROFILE\.WebStorm*",
    "$env:USERPROFILE\.PyCharm*",
    "$env:USERPROFILE\.CLion*",
    "$env:USERPROFILE\.DataGrip*",
    "$env:USERPROFILE\.GoLand*",
    "$env:USERPROFILE\.PhpStorm*",
    "$env:USERPROFILE\.Rider*",
    "$env:USERPROFILE\.RubyMine*",
    "$env:APPDATA\JetBrains\IntelliJIdea*",
    "$env:APPDATA\JetBrains\WebStorm*",
    "$env:APPDATA\JetBrains\PyCharm*",
    "$env:APPDATA\JetBrains\CLion*",
    "$env:APPDATA\JetBrains\DataGrip*",
    "$env:APPDATA\JetBrains\GoLand*",
    "$env:APPDATA\JetBrains\PhpStorm*",
    "$env:APPDATA\JetBrains\Rider*",
    "$env:APPDATA\JetBrains\RubyMine*"
)

# Find all matching config folders
$ConfigFolders = @()
foreach ($FolderPattern in $JetBrainsConfigFolders) {
    $ConfigFolders += Get-ChildItem -Path $FolderPattern -Directory -ErrorAction SilentlyContinue
}

if ($ConfigFolders.Count -eq 0) {
    Write-Host "No JetBrains configuration folders found. Make sure a JetBrains IDE is installed and has been run at least once." -ForegroundColor Red
    exit 1
}

# Install the theme for each found config folder
$SourceThemePath = "$PSScriptRoot\NordShade.xml"
$InstallationCount = 0
$DetectedIDEs = @()

foreach ($ConfigFolder in $ConfigFolders) {
    # Each JetBrains config folder should have a "colors" subfolder
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
    
    # Extract IDE name from path for reporting
    $IDEName = "Unknown"
    if ($ConfigFolder.Name -match "(IntelliJIdea|WebStorm|PyCharm|CLion|DataGrip|GoLand|PhpStorm|Rider|RubyMine)") {
        $IDEName = $Matches[1]
    }
    if ($DetectedIDEs -notcontains $IDEName) {
        $DetectedIDEs += $IDEName
    }
}

if ($InstallationCount -gt 0) {
    Write-Host "`nNordShade theme has been installed for $InstallationCount JetBrains configuration folder(s)!" -ForegroundColor Green
    Write-Host "Detected IDEs: $($DetectedIDEs -join ', ')" -ForegroundColor Green
    Write-Host "`nTo use the theme:" -ForegroundColor Yellow
    Write-Host "1. Restart your JetBrains IDE if it's running" -ForegroundColor Yellow
    Write-Host "2. Open Settings (Ctrl+Alt+S)" -ForegroundColor Yellow
    Write-Host "3. Go to Editor > Color Scheme" -ForegroundColor Yellow
    Write-Host "4. Select 'NordShade' from the dropdown" -ForegroundColor Yellow
    Write-Host "5. Click 'Apply' or 'OK'" -ForegroundColor Yellow
} else {
    Write-Host "Failed to install NordShade theme for JetBrains IDEs" -ForegroundColor Red
} 