# scripts/DownloadUiPathCli.ps1

param(
    [string]$WorkspacePath
)

# Define the final target directory for the UiPath CLI
$cliDir = Join-Path $WorkspacePath "uipathcli"

# Define the UiPath CLI download URL from GitHub releases
$cliDownloadUrl = "https://github.com/UiPath/uipathcli/releases/latest/download/uipathcli-windows-amd64.zip"
$zipFileName = "uipath.cli.zip"
$zipFilePath = Join-Path $cliDir $zipFileName # Store the zip temporarily in the final target dir

Write-Host "Starting UiPath CLI download and setup from GitHub Releases..."
Write-Host "Target directory for CLI: $cliDir"
Write-Host "Download URL: $cliDownloadUrl"

try {
    # --- Step 1: Guaranteed Clean-up of any existing CLI folder ---
    Write-Host "Performing cleanup of old CLI directory: $cliDir"
    if (Test-Path $cliDir -PathType Container) {
        Remove-Item -Path $cliDir -Recurse -Force -ErrorAction Stop
    }

    # Create the final CLI directory (where uipath.exe will eventually reside)
    New-Item -ItemType Directory -Path $cliDir -Force | Out-Null
    Write-Host "Created final CLI directory: $cliDir"

    # --- Step 2: Download the ZIP file ---
    Write-Host "Downloading UiPath CLI zip..."
    Invoke-WebRequest -Uri $cliDownloadUrl -OutFile $zipFilePath -UseBasicParsing -ErrorAction Stop
    Write-Host "Successfully downloaded UiPath CLI to $zipFilePath."

    # --- Step 3: Extract the ZIP directly into the $cliDir ---
    # This will either extract files directly to $cliDir OR create a subfolder (e.g., uipathcli-windows-amd64) inside $cliDir.
    Write-Host "Extracting UiPath CLI directly into $cliDir..."
    Expand-Archive -Path $zipFilePath -DestinationPath $cliDir -Force -ErrorAction Stop
    Write-Host "Successfully extracted UiPath CLI."

    # --- Step 4: Dynamically Find the actual uipath.exe and set its containing directory to PATH ---
    # Search for uipath.exe within $cliDir and any subfolders it might contain (up to 2 levels deep to be safe)
    $uipathExe = Get-ChildItem -Path $cliDir -Filter "uipath.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

    if (-not $uipathExe) {
        Write-Error "CRITICAL ERROR: Could not find 'uipath.exe' in '$cliDir' or its subfolders after extraction."
        Write-Host "Contents of '$cliDir' after extraction:"
        Get-ChildItem -Path $cliDir -Recurse | ForEach-Object { Write-Host $_.FullName }
        exit 1
    }

    # Get the directory where uipath.exe was actually found
    $cliExecutablePath = $uipathExe.DirectoryName
    $cliExecutableName = $uipathExe.Name # This will be "uipath.exe"

    Write-Host "Found 'uipath.exe' at: $uipathExe.FullName"
    Write-Host "Directory containing 'uipath.exe' (to be added to PATH): $cliExecutablePath"

    # Add the directory containing the executable to the PATH for the current job
    $env:Path += ";$cliExecutablePath"
    Write-Host "Added '$cliExecutablePath' to PATH for this session."

    # Make the executable name available to subsequent steps via GITHUB_ENV
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_EXECUTABLE_NAME=$cliExecutableName"
    Write-Host "Set UIPATH_CLI_EXECUTABLE_NAME to '$cliExecutableName' in GITHUB_ENV."

    # --- Step 5: Clean up the downloaded zip file ---
    Write-Host "Cleaning up downloaded zip file..."
    Remove-Item -Path $zipFilePath -Force -ErrorAction SilentlyContinue
    Write-Host "Cleanup complete."

} catch {
    Write-Error ("FATAL ERROR: Failed to download or setup UiPath CLI: " + $_.Exception.Message)
    exit 1
}

Write-Host "UiPath CLI Setup completed successfully."
