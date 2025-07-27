param(
    [string]$WorkspacePath
)

$cliDownloadUrl = "https://github.com/UiPath/uipathcli/releases/latest/download/uipathcli-windows-amd64.zip"
$cliFileName = "uipathcli-windows-amd64.zip"
$cliDirName = "uipathcli_" + (Get-Random -Maximum 99999)
$cliDir = Join-Path $WorkspacePath $cliDirName
$zipFilePath = Join-Path $WorkspacePath $cliFileName

Write-Host "Starting UiPath CLI download and setup from: $cliDownloadUrl"
Write-Host "Target CLI directory: $cliDir"

try {
    if (Test-Path $cliDir -PathType Container) {
        Remove-Item -Path $cliDir -Recurse -Force -ErrorAction Stop
        Write-Host "Removed existing CLI directory: $cliDir"
    }
    New-Item -ItemType Directory -Path $cliDir -Force | Out-Null

    Write-Host "Downloading UiPath CLI zip..."
    Invoke-WebRequest -Uri $cliDownloadUrl -OutFile $zipFilePath -UseBasicParsing -ErrorAction Stop -Verbose
    Write-Host "Download completed: $zipFilePath"

    Write-Host "Extracting UiPath CLI..."
    Expand-Archive -Path $zipFilePath -DestinationPath $cliDir -Force -ErrorAction Stop
    Write-Host "Extraction completed into $cliDir"

    Write-Host "Listing files after extraction to diagnose:"
    Get-ChildItem -Path $cliDir -Recurse | ForEach-Object { Write-Host $_.FullName }

    # Try to find the executable with sensitivity to possible casing and locations
    $cliExePath = Get-ChildItem -Path $cliDir -Recurse -File |
                  Where-Object { $_.Name -match "^uipathcli\.exe$" } |
                  Select-Object -First 1

    if (-not $cliExePath) {
        Write-Error "Could not find 'uipathcli.exe' in extracted files."
        exit 1
    }

    $cliExecutablePath = $cliExePath.DirectoryName
    $cliFullPath = $cliExePath.FullName
    Write-Host "Found CLI executable at: $cliFullPath"

    $env:Path = "$cliExecutablePath;$env:Path"

    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_FULL_PATH=$cliFullPath"
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_EXECUTABLE_NAME=uipathcli.exe"
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_DIR=$cliExecutablePath"

    Remove-Item -Path $zipFilePath -Force -ErrorAction SilentlyContinue

    Write-Host "UiPath CLI setup completed successfully."

} catch {
    Write-Error ("Failed to download or setup UiPath CLI: " + $_.Exception.Message)
    exit 1
}
