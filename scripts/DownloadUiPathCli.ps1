param(
    [string]$WorkspacePath
)

$cliDirName = "uipathcli_" + (Get-Random -Maximum 99999)
$cliDir = Join-Path $WorkspacePath $cliDirName
$cliDownloadUrl = "https://github.com/UiPath/uipathcli/releases/latest/download/uipathcli-windows-amd64.zip"
$zipFileName = "uipath.cli.zip"
$zipFilePath = Join-Path $cliDir $zipFileName

Write-Host "Starting UiPath CLI download and setup..."

try {
    if (Test-Path $cliDir) {
        Remove-Item -Path $cliDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $cliDir -Force | Out-Null

    Invoke-WebRequest -Uri $cliDownloadUrl -OutFile $zipFilePath -UseBasicParsing -Verbose

    Expand-Archive -Path $zipFilePath -DestinationPath $cliDir -Force

    $uipathExe = Get-ChildItem -Path $cliDir -Filter "uipath.exe" -Recurse | Select-Object -First 1
    if (-not $uipathExe) {
        Write-Error "Cannot find uipath.exe"
        exit 1
    }

    $cliExecutablePath = $uipathExe.DirectoryName
    $cliFullPath = $uipathExe.FullName

    $env:Path += ";$cliExecutablePath"
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_FULL_PATH=$cliFullPath"
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_EXECUTABLE_NAME=uipath.exe"
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_DIR=$cliExecutablePath"

    Remove-Item -Path $zipFilePath -Force

} catch {
    Write-Error "Failed to download or setup UiPath CLI: $_"
    exit 1
}

Write-Host "UiPath CLI Setup completed successfully."
