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
        # If debugging is needed, you can use Write-Host for each item.
        # Do not use Format-Table in a script directly as it can cause parsing issues if not handled carefully.
        Get-ChildItem -Path $tempExtractDir -Recurse | ForEach-Object { Write-Host $_.FullName }
        exit 1
    }
    $extractedContentPath = $extractedContentFolders[0].FullName
    
    Write-Host "Moving contents from '$extractedContentPath' to '$cliDir'..."
    # Move all items (files and subdirectories) from inside the extracted subfolder to the final $cliDir
    Move-Item -Path (Join-Path $extractedContentPath "*") -Destination $cliDir -Force -ErrorAction Stop
    Write-Host "Successfully moved contents to $cliDir."

    # --- Step 5: Clean up temporary files and directories ---
    Write-Host "Cleaning up temporary files and directories..."
    # Remove the temporary extraction directory (which should now be empty or contain only the moved files if Move-Item copies)
    Remove-Item -Path $tempExtractDir -Recurse -Force -ErrorAction SilentlyContinue
    # Remove the downloaded zip file
    Remove-Item -Path $zipFilePath -Force -ErrorAction SilentlyContinue
    Write-Host "Cleanup complete."

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
