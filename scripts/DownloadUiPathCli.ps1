# scripts/DownloadUiPathCli.ps1

param(
    [string]$WorkspacePath
)

# Define a dynamic target directory for the UiPath CLI to avoid potential caching/conflicts
# A random suffix is added to ensure a unique directory name for each run.
$cliDirName = "uipathcli_" + (Get-Random -Maximum 99999)
$cliDir = Join-Path $WorkspacePath $cliDirName

# Define the UiPath CLI download URL from GitHub releases.
# REVERTED TO 'latest' as hardcoded versions were encountering 404s.
# The post-download size check will now be CRITICAL to ensure the correct CLI is used.
$cliDownloadUrl = "https://github.com/UiPath/uipathcli/releases/latest/download/uipathcli-windows-amd64.zip"

$zipFileName = "uipath.cli.zip"
$zipFilePath = Join-Path $cliDir $zipFileName # Store the zip temporarily in the target dir

Write-Host "Starting UiPath CLI download and setup from GitHub Releases..."
Write-Host "Dynamic Target directory for CLI: $cliDir"
Write-Host "Download URL: $cliDownloadUrl"

try {
    # --- Step 1: Guaranteed Clean-up of any existing CLI folder by this dynamic name ---
    Write-Host "Performing cleanup for dynamic CLI directory: $cliDir (should be clean initially)"
    if (Test-Path $cliDir -PathType Container) {
        Remove-Item -Path $cliDir -Recurse -Force -ErrorAction Stop
        Write-Host "Removed existing dynamic CLI directory: $cliDir"
    }

    # Create the dynamic CLI directory where the unzipped files will go
    New-Item -ItemType Directory -Path $cliDir -Force | Out-Null
    Write-Host "Created dynamic CLI directory: $cliDir"

    # --- Step 2: Download the ZIP file ---
    Write-Host "Downloading UiPath CLI zip..."
    # Added -Verbose for more detailed logging during download
    Invoke-WebRequest -Uri $cliDownloadUrl -OutFile $zipFilePath -UseBasicParsing -ErrorAction Stop -Verbose
    Write-Host "Successfully downloaded UiPath CLI to $zipFilePath."

    # --- Step 3: Extract the ZIP directly into the $cliDir ---
    Write-Host "Extracting UiPath CLI directly into $cliDir..."
    Expand-Archive -Path $zipFilePath -DestinationPath $cliDir -Force -ErrorAction Stop
    Write-Host "Successfully extracted UiPath CLI."

    # --- Step 4: Dynamically Find the actual uipath.exe and set its containing directory to PATH ---
    $uipathExe = Get-ChildItem -Path $cliDir -Filter "uipath.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

    if (-not $uipathExe) {
        Write-Error "CRITICAL ERROR: Could not find 'uipath.exe' in '$cliDir' or its subfolders after extraction."
        Write-Host "Contents of '$cliDir' after extraction:"
        Get-ChildItem -Path $cliDir -Recurse | ForEach-Object { Write-Host $_.FullName }
        exit 1
    }

    $cliExecutablePath = $uipathExe.DirectoryName # This is the directory where uipath.exe resides
    $cliExecutableName = $uipathExe.Name # This will always be "uipath.exe"
    $cliFullPath = $uipathExe.FullName # This is the full path to uipath.exe

    Write-Host "Found 'uipath.exe' at: $cliFullPath"
    Write-Host "Directory containing 'uipath.exe' (to be added to PATH): $cliExecutablePath"

    # Add the directory containing the executable to the PATH for the current job
    $env:Path += ";$cliExecutablePath"
    Write-Host "Added '$cliExecutablePath' to PATH for this session."

    # Expose the full executable path and its containing directory to subsequent steps
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_FULL_PATH=$cliFullPath"
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_EXECUTABLE_NAME=$cliExecutableName"
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_DIR=$cliExecutablePath"

    Write-Host "Set UIPATH_CLI_FULL_PATH to '$cliFullPath' in GITHUB_ENV."
    Write-Host "Set UIPATH_CLI_DIR to '$cliExecutablePath' in GITHUB_ENV."

    # --- NEW: Check file size immediately within this script ---
    Write-Host "--- Post-Download Check within DownloadUiPathCli.ps1 ---"
    $downloaded_fileInfo = Get-Item $cliFullPath
    Write-Host "Downloaded UiPath CLI executable path: $($downloaded_fileInfo.FullName)"
    Write-Host "Downloaded File Size: $($downloaded_fileInfo.Length) bytes"
    Write-Host "Downloaded Last Write Time: $($downloaded_fileInfo.LastWriteTime)" # CORRECTED LINE: Added missing closing quote
    Write-Host "----------------------------------------------------"

    $expectedMinSize = 9000000 # Minimum expected size for the new CLI
    $expectedMaxSize = 11000000 # Maximum expected size for the new CLI

    if ($downloaded_fileInfo.Length -lt $expectedMinSize -or $downloaded_fileInfo.Length -gt $expectedMaxSize) {
        Write-Error "CRITICAL ERROR: UiPath CLI executable size is unexpected within download script! Expected between $expectedMinSize and $expectedMaxSize bytes, but found $($downloaded_fileInfo.Length) bytes. This indicates an issue with the downloaded CLI version or corruption. Failing this step."
        # FAIL THE STEP if the size is wrong, as this indicates the old CLI was downloaded
        exit 1
    } else {
        Write-Host "UiPath CLI executable size is within expected range within download script. ($($downloaded_fileInfo.Length) bytes)"
    }

    # --- Step 5: Clean up the downloaded zip file ---
    Write-Host "Cleaning up downloaded zip file..."
    Remove-Item -Path $zipFilePath -Force -ErrorAction SilentlyContinue
    Write-Host "Cleanup complete."

} catch {
    # Catch any errors during the process and exit with a non-zero code to fail the step.
    Write-Error ("FATAL ERROR: Failed to download or setup UiPath CLI: " + $_.Exception.Message)
    exit 1
}

Write-Host "UiPath CLI Setup completed successfully."
