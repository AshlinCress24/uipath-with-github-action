# scripts/DownloadUiPathCli.ps1

param(
    [string]$WorkspacePath
)

# Define the target directory for the UiPath CLI
$cliDir = Join-Path $WorkspacePath "uipathcli"

# Define the UiPath CLI download URL from GitHub releases (recommended for latest public CLI)
$cliDownloadUrl = "https://github.com/UiPath/uipathcli/releases/latest/download/uipathcli-windows-amd64.zip"
$zipFilePath = Join-Path $cliDir "uipath.cli.zip" # Using a generic name for the downloaded zip
$cliExecutableName = "uipath.exe" # Name of the executable inside the zip

Write-Host "Downloading UiPath CLI from $cliDownloadUrl (latest Windows AMD64 release)..."

try {
    # Create the directory if it doesn't exist
    if (-not (Test-Path $cliDir -PathType Container)) {
        New-Item -ItemType Directory -Path $cliDir -Force | Out-Null
        Write-Host "Created directory: $cliDir"
    }

    # Download the ZIP file
    Invoke-WebRequest -Uri $cliDownloadUrl -OutFile $zipFilePath -UseBasicParsing

    Write-Host "Successfully downloaded UiPath CLI to $zipFilePath."

    # Expand-Archive requires the destination path to exist for the files to be extracted directly into it.
    # The previous code created $cliDir, so this should work.
    Expand-Archive -Path $zipFilePath -DestinationPath $cliDir -Force

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
