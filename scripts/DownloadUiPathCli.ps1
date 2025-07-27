param([string]$WorkspacePath)

$packageId = "uipath.cli" # lowercase for URL usage
$packageDownloadPath = Join-Path $WorkspacePath "UiPathCliNuGet"

if (Test-Path $packageDownloadPath -PathType Container) {
    Remove-Item -Path $packageDownloadPath -Recurse -Force
}

New-Item -ItemType Directory -Path $packageDownloadPath | Out-Null

Write-Host "Downloading UiPath CLI NuGet package..."

$nugetIndexUrl = "https://api.nuget.org/v3-flatcontainer/$packageId/index.json"

try {
    $versionsJson = Invoke-RestMethod -Uri $nugetIndexUrl -UseBasicParsing

    # Pick the last version in the versions array (latest)
    $latestVersion = $versionsJson.versions[-1]

    Write-Host "Latest UiPath CLI version: $latestVersion"

    $nupkgUrl = "https://api.nuget.org/v3-flatcontainer/$packageId/$latestVersion/$packageId.$latestVersion.nupkg"

    Write-Host "Downloading nupkg from: $nupkgUrl"

    $nupkgPath = Join-Path $packageDownloadPath "$packageId.$latestVersion.nupkg"

    Invoke-WebRequest -Uri $nupkgUrl -OutFile $nupkgPath -UseBasicParsing

    Write-Host "Extracting NuGet package..."

    Expand-Archive -Path $nupkgPath -DestinationPath $packageDownloadPath -Force

    # Try finding the executable inside tools or root folder
    $exePath = Get-ChildItem -Path $packageDownloadPath -Recurse -Filter "uipathcli.exe" | Select-Object -First 1

    if (-not $exePath) {
        Write-Error "uipathcli.exe not found in extracted NuGet package."
        exit 1
    }

    Write-Host "Found UiPath CLI executable at: $($exePath.FullName)"

    $env:Path = "$($exePath.DirectoryName);$env:Path"

    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_EXECUTABLE_NAME=uipathcli.exe"
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_FULL_PATH=$($exePath.FullName)"
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_DIR=$($exePath.DirectoryName)"

    Write-Host "UiPath CLI successfully downloaded and setup."

} catch {
    Write-Error "Failed to download or setup UiPath CLI via NuGet: $_"
    exit 1
}
