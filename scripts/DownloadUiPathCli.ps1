# scripts/DownloadUiPathCli.ps1

param(
    [string]$WorkspacePath
)

# Define the final target directory for the UiPath CLI
$cliDir = Join-Path $WorkspacePath "uipathcli"
# Define a temporary directory for extracting the zip file contents
$tempExtractDir = Join-Path $WorkspacePath "uipathcli_temp_extract"

# Define the UiPath CLI download URL from GitHub releases
# This link directly points to the latest Windows AMD64 build from the official UiPath CLI GitHub repo.
$cliDownloadUrl = "https://github.com/UiPath/uipathcli/releases/latest/download/uipathcli-windows-amd64.zip"
# Name for the downloaded zip file
$zipFileName = "uipath.cli.zip"
$zipFilePath = Join-Path $cliDir $zipFileName # Store the zip in the final target dir temporarily

# Expected name of the executable after extraction
$cliExecutableName = "uipath.exe"

Write-Host "Starting UiPath CLI download and setup from GitHub Releases..."
Write-Host "Target directory for CLI: $cliDir"
Write-Host "Temporary extraction directory: $tempExtractDir"
Write-Host "Download URL: $cliDownloadUrl"

try {
    # --- Step 1: Clean up any existing directories to ensure a fresh start ---
    Write-Host "Performing cleanup of old CLI directories..."
    if (Test-Path $cliDir -PathType Container) {
        Write-Host "Removing existing UiPath CLI directory: $cliDir"
        Remove-Item -Path $cliDir -Recurse -Force -ErrorAction Stop
    }
    if (Test-Path $tempExtractDir -PathType Container) {
        Write-Host "Removing existing temporary extract directory: $tempExtractDir"
        Remove-Item -Path $tempExtractDir -Recurse -Force -ErrorAction Stop
    }

    # Create the final CLI directory (where uipath.exe will reside)
    New-Item -ItemType Directory -Path $cliDir -Force | Out-Null
    Write-Host "Created final CLI directory: $cliDir"

    # Create the temporary extraction directory
    New-Item -ItemType Directory -Path $tempExtractDir -Force | Out-Null
    Write-Host "Created temporary extraction directory: $tempExtractDir"

    # --- Step 2: Download the ZIP file ---
    Write-Host "Downloading UiPath CLI zip..."
    Invoke-WebRequest -Uri $cliDownloadUrl -OutFile $zipFilePath -UseBasicParsing -ErrorAction Stop

    Write-Host "Successfully downloaded UiPath CLI to $zipFilePath."

    # --- Step 3: Extract the ZIP to the temporary location ---
    # This zip contains a subfolder (e.g., uipathcli-windows-amd64).
    # Extracting to $tempExtractDir will put the subfolder inside $tempExtractDir.
    Write-Host "Extracting UiPath CLI to temporary directory..."
    Expand-Archive -Path $zipFilePath -DestinationPath $tempExtractDir -Force -ErrorAction Stop
    Write-Host "Successfully extracted UiPath CLI to $tempExtractDir."

    # --- Step 4: Move contents from the extracted subfolder to the final CLI directory ---
    # Find the actual content subfolder within the temporary extraction directory.
    # We expect there to be exactly one directory extracted from the zip.
    $extractedContentFolders = Get-ChildItem -Path $tempExtractDir -Directory
    
    if ($extractedContentFolders.Count -ne 1) {
        Write-Error "Unexpected content structure in temporary extraction: Expected exactly one subfolder."
        # Do not use Format-Table in a script directly as it
