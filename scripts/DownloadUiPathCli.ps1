param(
    [string]$WorkspacePath
)

# Use stable UiPath CLI release v2.0.44 for Windows x64
$cliDownloadUrl = "https://github.com/UiPath/uipathcli/releases/download/v2.0.44/uipathcli-windows-amd64.zip"

$cliFileName = "uipathcli-windows-amd64.zip"
$cliDirName = "uipathcli_" + (Get-Random -Maximum 99999)
$cliDir = Join-Path $WorkspacePath $cliDirName
$zipFilePath = Join-Path $WorkspacePath $cliFileName

Write-Host "Starting UiPath CLI download and setup from: $cliDownloadUrl"
Write-Host "Target CLI directory: $cliDir"

try {
    # Clean existing directory if present
    if (Test-Path $cliDir -PathType Container) {
        Remove-Item -Path $cliDir -Recurse -Force -ErrorAction Stop
        Write-Host "Removed existing CLI directory: $cliDir"
    }
    New-Item -ItemType Directory -Path $cliDir -Force | Out-Null

    # Download the CLI ZIP package
    Write-Host "Downloading UiPath CLI zip..."
    Invoke-WebRequest -Uri $cliDownloadUrl -OutFile $zipFilePath -UseBasicParsing -ErrorAction Stop -Verbose
    Write-Host "Download completed: $zipFilePath"

    # Extract the ZIP package
    Write-Host "Extracting UiPath CLI..."
    Expand-Archive -Path $zipFilePath -DestinationPath $cliDir -Force -ErrorAction Stop
    Write-Host "Extraction completed into $cliDir"

    Write-Host "Listing files after extraction for diagnostics:"
    Get-ChildItem -Path $cliDir -Recurse | ForEach-Object { Write-Host $_.FullName }

    # Locate required executable 'uipathcli.exe' ONLY (fail if missing)
    $cliExePath = Get-ChildItem -Path $cliDir -Filter "uipathcli.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

    if (-not $cliExePath) {
        Write-Error "Required executable 'uipathcli.exe' not found in extracted files. Please verify download URL and archive contents."
        exit 1
    }

    $cliExecutablePath = $cliExePath.DirectoryName
    $cliFullPath = $cliExePath.FullName
    Write-Host "Found CLI executable at: $cliFullPath"

    # Add CLI directory to PATH environment for current and future steps
    $env:Path = "$cliExecutablePath;$env:Path"
    Add-Content -Path $env:GITHUB_ENV -Value "PATH=$cliExecutablePath`;$env:PATH"

    # Set important environment variables for later steps
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_FULL_PATH=$cliFullPath"
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_EXECUTABLE_NAME=uipathcli.exe"
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_DIR=$cliExecutablePath"

    # Cleanup the downloaded ZIP file
    Remove-Item -Path $zipFilePath -Force -ErrorAction SilentlyContinue

    Write-Host "UiPath CLI setup completed successfully."
}
catch {
    Write-Error ("Failed to download or setup UiPath CLI: " + $_.Exception.Message)
    exit 1
}
