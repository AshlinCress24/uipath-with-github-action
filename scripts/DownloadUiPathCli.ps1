param(
    [string]$WorkspacePath
)

# Official URL for latest UiPath CLI Windows x64 ZIP release (GitHub Releases)
$cliDownloadUrl = "https://github.com/UiPath/uipathcli/releases/latest/download/uipathcli-windows-amd64.zip"

$cliFileName = "uipathcli-windows-amd64.zip"
$cliDirName = "uipathcli_" + (Get-Random -Maximum 99999)
$cliDir = Join-Path $WorkspacePath $cliDirName
$zipFilePath = Join-Path $WorkspacePath $cliFileName

Write-Host "Starting UiPath CLI download and setup from: $cliDownloadUrl"
Write-Host "Target CLI directory: $cliDir"

try {
    # Remove existing CLI directory if present
    if (Test-Path $cliDir -PathType Container) {
        Remove-Item -Path $cliDir -Recurse -Force -ErrorAction Stop
        Write-Host "Removed existing CLI directory: $cliDir"
    }
    New-Item -ItemType Directory -Path $cliDir -Force | Out-Null

    # Download the CLI ZIP
    Write-Host "Downloading UiPath CLI zip..."
    Invoke-WebRequest -Uri $cliDownloadUrl -OutFile $zipFilePath -UseBasicParsing -ErrorAction Stop -Verbose
    Write-Host "Download completed: $zipFilePath"

    # Extract the ZIP
    Write-Host "Extracting UiPath CLI..."
    Expand-Archive -Path $zipFilePath -DestinationPath $cliDir -Force -ErrorAction Stop
    Write-Host "Extraction completed into $cliDir"

    Write-Host "Listing files after extraction for diagnostics:"
    Get-ChildItem -Path $cliDir -Recurse | ForEach-Object { Write-Host $_.FullName }

    # Locate executable: first try 'uipathcli.exe', then 'uipath.exe'
    $possibleExecutables = @("uipathcli.exe", "uipath.exe")
    $cliExePath = $null

    foreach ($exeName in $possibleExecutables) {
        $cliExePath = Get-ChildItem -Path $cliDir -Filter $exeName -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($cliExePath) { break }
    }

    if (-not $cliExePath) {
        Write-Error "Could not find 'uipathcli.exe' or 'uipath.exe' in extracted files."
        exit 1
    }

    $cliExecutablePath = $cliExePath.DirectoryName
    $cliFullPath = $cliExePath.FullName
    Write-Host "Found CLI executable at: $cliFullPath"

    # Add CLI directory to PATH environment variable for current session and GitHub Actions
    $env:Path = "$cliExecutablePath;$env:Path"
    Add-Content -Path $env:GITHUB_ENV -Value "PATH=$cliExecutablePath`;$env:PATH"

    # Export environment variables for subsequent GitHub Actions steps
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_FULL_PATH=$cliFullPath"
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_EXECUTABLE_NAME=$($cliExePath.Name)"
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_DIR=$cliExecutablePath"

    # Remove ZIP to clean up
    Remove-Item -Path $zipFilePath -Force -ErrorAction SilentlyContinue

    Write-Host "UiPath CLI setup completed successfully."

} catch {
    Write-Error ("Failed to download or setup UiPath CLI: " + $_.Exception.Message)
    exit 1
}
