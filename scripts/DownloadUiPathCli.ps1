param([string]$WorkspacePath)

$nugetPackageName = "UiPath.CLI"
$nugetVersion = "latest"

$packageDownloadPath = Join-Path $WorkspacePath "UiPathCliNuGet"

if (Test-Path $packageDownloadPath -PathType Container) {
    Remove-Item -Path $packageDownloadPath -Recurse -Force
}

New-Item -ItemType Directory -Path $packageDownloadPath | Out-Null

Write-Host "Downloading UiPath CLI NuGet package..."

$nugetUrl = "https://api.nuget.org/v3-flatcontainer/uipath.cli/index.json"

try {
    $versionsJson = Invoke-RestMethod -Uri $nugetUrl -UseBasicParsing

    # Choose latest version
    $latestVersion = $versionsJson.versions[-1]

    Write-Host "Latest UiPath CLI version: $latestVersion"

    $nupkgUrl = "https://api.nuget.org/v3-flatcontainer/uipath.cli/$latestVersion/uipath.cli.$latestVersion.nupkg"

    $nupkgPath = Join-Path $packageDownloadPath "uipath.cli.$latestVersion.nupkg"

    Invoke-WebRequest -Uri $nupkgUrl -OutFile $nupkgPath -UseBasicParsing

    # Extract the nupkg
    Expand-Archive -Path $nupkgPath -DestinationPath $packageDownloadPath -Force

    # The executable is usually under tools\ or root, check accordingly
    $exePath = Get-ChildItem -Path $packageDownloadPath -Filter "uipathcli.exe" -Recurse | Select-Object -First 1

    if (-not $exePath) {
        Write-Error "uipathcli.exe not found in extracted NuGet package."
        exit 1
    }

    $env:Path = "$($exePath.DirectoryName);$env:Path"
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_EXECUTABLE_NAME=uipathcli.exe"
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_FULL_PATH=$($exePath.FullName)"
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_DIR=$($exePath.DirectoryName)"

    Write-Host "UiPath CLI successfully downloaded and setup from NuGet package."
}
catch {
    Write-Error "Failed to download or setup UiPath CLI via NuGet: $_"
    exit 1
}
