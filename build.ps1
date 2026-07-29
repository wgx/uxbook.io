<#
.SYNOPSIS
    Builds the static site into a _dist folder ready for upload.
.DESCRIPTION
    This script cleans the _dist directory, copies all relevant files, 
    and performs basic regex minification on HTML, CSS, and JS files.
#>

param (
    [string]$SourceDir = ".",
    [string]$DestDir = ".\_dist"
)

Write-Host "Building site into $DestDir..." -ForegroundColor Cyan

# 1. Clean and create the destination directory
if (Test-Path $DestDir) {
    Write-Host "Cleaning existing $DestDir directory..."
    Remove-Item -Path $DestDir -Recurse -Force
}
$null = New-Item -ItemType Directory -Path $DestDir

# 2. Define exclusions (avoid copying git folders, documentation, or the build script itself)
$Exclusions = @("_dist", "_site", ".git", ".github", ".vscode", "node_modules", "build.ps1", "README.md", "doc")

# 3. Copy all files and folders except exclusions
Write-Host "Copying files to $DestDir..."
Get-ChildItem -Path $SourceDir | 
    Where-Object { $_.Name -notin $Exclusions } |
    Copy-Item -Destination $DestDir -Recurse -Container

# 4. Minify HTML files
Write-Host "Minifying HTML files..."
$htmlFiles = Get-ChildItem -Path $DestDir -Filter "*.html" -Recurse
foreach ($file in $htmlFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    $content = $content -replace '(?s)<!--.*?-->', '' # Remove HTML comments
    $content = $content -replace '(?m)^\s+', ''       # Remove leading whitespace
    $content = $content -replace '(?m)\s+$', ''       # Remove trailing whitespace
    Set-Content -Path $file.FullName -Value $content -NoNewline
    Write-Host "  Minified: $($file.Name)" -ForegroundColor Green
}

# 5. Minify CSS/JS (Basic)
Write-Host "Minifying CSS and JS files..."
$assetFiles = Get-ChildItem -Path $DestDir -Recurse | Where-Object { $_.Extension -match "\.(css|js)$" -and $_.Name -notmatch "\.min\.(css|js)$" }
foreach ($file in $assetFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    $content = $content -replace '(?s)/\*.*?\*/', ''  # Remove multi-line comments
    $content = $content -replace '(?m)^\s+', ''       # Remove leading whitespace
    $content = $content -replace '(?m)\s+$', ''       # Remove trailing whitespace
    Set-Content -Path $file.FullName -Value $content -NoNewline
    Write-Host "  Minified: $($file.Name)" -ForegroundColor Green
}

Write-Host "Build complete! The ready-to-upload site is in $DestDir" -ForegroundColor Cyan