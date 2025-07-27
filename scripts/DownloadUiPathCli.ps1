param(
    [string]$WorkspacePath
)

$cliDirName = "uipathcli_" + (Get-Random -Maximum 99999)
$cliDir = Join-Path $WorkspacePath $cliDirName
$cliDownloadUrl = "https://github.com/UiPath/uipathcli/releases/latest/download/uipathcli-windows-amd64.zip"
$zipFileName = "uipath.cli.zip"
$zipFilePath = Join-Path $cliDir $zipFileName

Write-Host "Starting UiPath CLI download and setup from GitHub Releases..."
Write-Host "Target directory for CLI: $cliDir"
Write-Host "Download URL: $cliDownloadUrl"

try {
    if (Test-Path $cliDir -PathType Container) {
        Remove-Item -Path $cliDir -Recurse -Force -ErrorAction Stop
        Write-Host "Removed existing CLI directory: $cliDir"
    }
    New-Item -ItemType Directory -Path $cliDir -Force | Out-Null
    Write-Host "Created dynamic CLI directory: $cliDir"

    Write-Host "Downloading UiPath CLI zip..."
    Invoke-WebRequest -Uri $cliDownloadUrl -OutFile $zipFilePath -UseBasicParsing -ErrorAction Stop -Verbose
    Write-Host "Successfully downloaded UiPath CLI to $zipFilePath."

    Write-Host "Extracting UiPath CLI..."
    Expand-Archive -Path $zipFilePath -DestinationPath $cliDir -Force -ErrorAction Stop
    Write-Host "Successfully extracted UiPath CLI."

    $uipathExe = Get-ChildItem -Path $cliDir -Filter "uipath.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $uipathExe) {
        Write-Error "ERROR: Could not find 'uipath.exe' in '$cliDir' after extraction."
        exit 1
    }
    $cliExecutablePath = $uipathExe.DirectoryName
    $cliFullPath = $uipathExe.FullName

    Write-Host "Found 'uipath.exe' at: $cliFullPath"

    $env:Path += ";$cliExecutablePath"
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_FULL_PATH=$cliFullPath"
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_EXECUTABLE_NAME=uipath.exe"
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_DIR=$cliExecutablePath"

    $downloaded_fileInfo = Get-Item $cliFullPath
    $expectedMinSize = 19000000
    $expectedMaxSize = 21000000

    if ($downloaded_fileInfo.Length -lt $expectedMinSize -or $downloaded_fileInfo.Length -gt $expectedMaxSize) {
        Write-Error "ERROR: UiPath CLI executable size is unexpected!"
        exit 1
    }
    Remove-Item -Path $zipFilePath -Force -ErrorAction SilentlyContinue

} catch {
    Write-Error ("FATAL ERROR: Failed to download or setup UiPath CLI: " + $_.Exception.Message)
    exit 1
}

Write-Host "UiPath CLI Setup completed successfully."
