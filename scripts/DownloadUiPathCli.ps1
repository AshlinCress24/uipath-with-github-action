# scripts/DownloadUiPathCli.ps1

param(
    [string]$WorkspacePath
)

# Define a dynamic target directory for the UiPath CLI to avoid potential caching/conflicts
# A random suffix is added to ensure a unique directory name for each run.
$cliDirName = "uipathcli_" + (Get-Random -Maximum 99999)
$cliDir = Join-Path $WorkspacePath $cliDirName

# Define the UiPath CLI download URL from GitHub releases
$cliDownloadUrl = "https://github.com/UiPath/uipathcli/releases/latest/download/uipathcli-windows-amd64.zip"
$zipFileName = "uipath.cli.zip"
$zipFilePath = Join-Path $cliDir $zipFileName # Store the zip temporarily in the target dir

Write-Host "Starting UiPath CLI download and setup from GitHub Releases..."
Write-Host "Dynamic Target directory for CLI: $cliDir"
Write-Host "Download URL: $cliDownloadUrl"

try {
    # --- Step 1: Guaranteed Clean-up of any existing CLI folder by this dynamic name ---
    # This specifically removes the dynamic directory if it somehow already exists (e.g., from a previous partial run).
    # For a fresh run, it generally won't exist.
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
    Invoke-WebRequest -Uri $cliDownloadUrl -OutFile $zipFilePath -UseBasicParsing -ErrorAction Stop
    Write-Host "Successfully downloaded UiPath CLI to $zipFilePath."

    # --- Step 3: Extract the ZIP directly into the $cliDir ---
    # This handles both cases: if uipath.exe is at the root of the zip, or if it's in a single subfolder.
    Write-Host "Extracting UiPath CLI directly into $cliDir..."
    Expand-Archive -Path $zipFilePath -DestinationPath $cliDir -Force -ErrorAction Stop
    Write-Host "Successfully extracted UiPath CLI."

    # --- Step 4: Dynamically Find the actual uipath.exe and set its containing directory to PATH ---
    # This is crucial for robustness, as the exact extraction path might vary slightly.
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
    # This makes 'uipath.exe' directly callable in subsequent steps without specifying full path.
    $env:Path += ";$cliExecutablePath"
    Write-Host "Added '$cliExecutablePath' to PATH for this session."

    # Expose the full executable path and its containing directory to subsequent steps
    # These environment variables are crucial for other steps to correctly locate and use the CLI.
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_FULL_PATH=$cliFullPath"
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_EXECUTABLE_NAME=$cliExecutableName"
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_DIR=$cliExecutablePath"

    Write-Host "Set UIPATH_CLI_FULL_PATH to '$cliFullPath' in GITHUB_ENV."
    Write-Host "Set UIPATH_CLI_DIR to '$cliExecutablePath' in GITHUB_ENV."

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
