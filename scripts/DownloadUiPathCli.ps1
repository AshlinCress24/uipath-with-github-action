param(
    [string]$WorkspacePath
)

# Update this URL to the official latest working UiPath CLI release with auth command support
$cliDownloadUrl = "https://download.uipath.com/cli/uipathcli-win-x64.zip"

$cliFileName = "uipathcli-win-x64.zip"
$cliDirName = "uipathcli_" + (Get-Random -Maximum 99999)
$cliDir = Join-Path $WorkspacePath $cliDirName
$zipFilePath = Join-Path $cliDir $cliFileName

Write-Host "Starting UiPath CLI download and setup from: $cliDownloadUrl"
Write-Host "Target CLI directory: $cliDir"

try {
    if (Test-Path $cliDir -PathType Container) {
        Remove-Item -Path $cliDir -Recurse -Force -ErrorAction Stop
        Write-Host "Removed existing CLI directory: $cliDir"
    }
    New-Item -ItemType Directory -Path $cliDir -Force | Out-Null

    Invoke-WebRequest -Uri $cliDownloadUrl -OutFile $zipFilePath -UseBasicParsing -ErrorAction Stop -Verbose
    Write-Host "Successfully downloaded UiPath CLI to $zipFilePath."

    Expand-Archive -Path $zipFilePath -DestinationPath $cliDir -Force -ErrorAction Stop
    Write-Host "Extracted UiPath CLI."

    # Search for either uipathcli.exe or uipath.exe
    $possibleExecutables = @("uipathcli.exe", "uipath.exe")
    $cliExePath = $null
    foreach ($exeName in $possibleExecutables) {
        $cliExePath = Get-ChildItem -Path $cliDir -Filter $exeName -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($cliExePath) { break }
    }

    if (-not $cliExePath) {
        Write-Error "Could not find UiPath CLI executable in extracted files."
        exit 1
    }
    $cliExecutablePath = $cliExePath.DirectoryName
    $cliFullPath = $cliExePath.FullName
    Write-Host "Found CLI executable at: $cliFullPath"

    $env:Path += ";$cliExecutablePath"
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_FULL_PATH=$cliFullPath"
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_EXECUTABLE_NAME=$($cliExePath.Name)"
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_DIR=$cliExecutablePath"

    Remove-Item -Path $zipFilePath -Force -ErrorAction SilentlyContinue

} catch {
    Write-Error ("Failed to download or setup UiPath CLI: " + $_.Exception.Message)
    exit 1
}

Write-Host "UiPath CLI Setup completed successfully."
