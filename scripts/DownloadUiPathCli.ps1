# scripts/DownloadUiPathCli.ps1

param(
    [string]$WorkspacePath
)

# Define the target directory for the UiPath CLI
$cliDir = Join-Path $WorkspacePath "uipathcli"

# Define the UiPath CLI download URL from GitHub releases (recommended for latest public CLI)
# This link directly points to the latest Windows AMD64 build from the official UiPath CLI GitHub repo.
$cliDownloadUrl = "https://github.com/UiPath/uipathcli/releases/latest/download/uipathcli-windows-amd64.zip"
$zipFilePath = Join-Path $cliDir "uipath.cli.zip" # Using a generic name for the downloaded zip
$cliExecutableName = "uipath.exe" # Name of the executable inside the zip (expected after extraction)

Write-Host "Downloading UiPath CLI from $cliDownloadUrl (latest Windows AMD64 release)..."

try {
    # --- IMPORTANT CHANGE: Clean up any existing CLI folder to ensure a fresh download and extraction ---
    if (Test-Path $cliDir -PathType Container) {
        Write-Host "Removing existing UiPath CLI directory: $cliDir"
        Remove-Item -Path $cliDir -Recurse -Force -ErrorAction Stop # Added -ErrorAction Stop for better error handling
    }

    # Create the directory
    New-Item -ItemType Directory -Path $cliDir -Force | Out-Null
    Write-Host "Created directory: $cliDir"

    # Download the ZIP file
    Invoke-WebRequest -Uri $cliDownloadUrl -OutFile $zipFilePath -UseBasicParsing -ErrorAction Stop

    Write-Host "Successfully downloaded UiPath CLI to $zipFilePath."

    # Extract the ZIP file
    Expand-Archive -Path $zipFilePath -DestinationPath $cliDir -Force -ErrorAction Stop

    Write-Host "Successfully extracted UiPath CLI to $cliDir."

    # Add the CLI directory to the PATH for the current job
    $env:Path += ";$cliDir"
    Write-Host "Added '$cliDir' to PATH for this session."

    # Make the executable name available to subsequent steps via GITHUB_ENV
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_EXECUTABLE_NAME=$cliExecutableName"
    Write-Host "Set UIPATH_CLI_EXECUTABLE_NAME to '$cliExecutableName' in GITHUB_ENV."

} catch {
    Write-Error ("Failed to download or setup UiPath CLI: " + $_.Exception.Message)
    exit 1
}

Write-Host "UiPath CLI Setup completed."
