# scripts/DownloadUiPathCli.ps1

param(
    [string]$WorkspacePath
)

# Define the target directory for the UiPath CLI
$cliDir = Join-Path $WorkspacePath "uipathcli"

# Define the UiPath CLI version and download URL
# IMPORTANT: Use a recent stable version that supports the 'auth' command.
# For example, 23.10.0 or 24.4.0 (check UiPath docs for latest stable LTS or Enterprise release)
$cliVersion = "24.4.0" # <--- IMPORTANT: Update to a recent UiPath CLI version (e.g., 23.10.0, 24.4.0)
$cliDownloadUrl = "https://download.uipath.com/platform/uipathcli/$cliVersion/uipath.cli.zip"
$zipFilePath = Join-Path $cliDir "uipath.cli.zip"
$cliExecutableName = "uipath.exe" # Name of the executable inside the zip

Write-Host "Downloading UiPath CLI v$cliVersion from $cliDownloadUrl..."

try {
    # Create the directory if it doesn't exist
    if (-not (Test-Path $cliDir -PathType Container)) {
        New-Item -ItemType Directory -Path $cliDir -Force | Out-Null
        Write-Host "Created directory: $cliDir"
    }

    # Download the ZIP file
    Invoke-WebRequest -Uri $cliDownloadUrl -OutFile $zipFilePath -UseBasicParsing

    Write-Host "Successfully downloaded UiPath CLI to $zipFilePath."

    # Extract the ZIP file
    Expand-Archive -Path $zipFilePath -DestinationPath $cliDir -Force

    Write-Host "Successfully extracted UiPath CLI to $cliDir."

    # Add the CLI directory to the PATH for the current job
    # The UiPath CLI executable name (e.g., uipath.exe) might be directly in $cliDir
    # or in a subfolder like 'cli' depending on the zip structure.
    # We will assume it's directly in $cliDir for now, as indicated by previous logs.
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
