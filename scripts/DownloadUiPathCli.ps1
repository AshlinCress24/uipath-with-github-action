param(
    [string]$WorkspacePath
)

# Define GitHub repository and API URL for UiPath CLI releases
$repoOwner = "UiPath"
$repoName = "cli"
$githubApiLatestRelease = "https://api.github.com/repos/$repoOwner/$repoName/releases/latest"

Write-Host "Fetching the latest UiPath CLI release info from GitHub..."

try {
    $releaseInfo = Invoke-RestMethod -Uri $githubApiLatestRelease -Headers @{ 'User-Agent' = 'PowerShell' } -ErrorAction Stop

    # Find the asset with Windows 64-bit CLI zip (look for "win-x64.zip" in asset name)
    $asset = $releaseInfo.assets | Where-Object { $_.name -match "win-x64\.zip$" } | Select-Object -First 1

    if (-not $asset) {
        Write-Error "Could not find Windows x64 zip asset in latest release."
        exit 1
    }

    $cliDownloadUrl = $asset.browser_download_url

    Write-Host "Latest CLI Zip URL: $cliDownloadUrl"

    $cliFileName = $asset.name
    $cliDirName = "uipathcli_" + (Get-Random -Maximum 99999)
    $cliDir = Join-Path $WorkspacePath $cliDirName
    $zipFilePath = Join-Path $WorkspacePath $cliFileName

    if (Test-Path $cliDir -PathType Container) {
        Remove-Item -Path $cliDir -Recurse -Force -ErrorAction Stop
        Write-Host "Removed existing CLI directory: $cliDir"
    }
    New-Item -ItemType Directory -Path $cliDir -Force | Out-Null

    Write-Host "Downloading UiPath CLI zip..."
    Invoke-WebRequest -Uri $cliDownloadUrl -OutFile $zipFilePath -UseBasicParsing -ErrorAction Stop -Verbose

    Write-Host "Extracting UiPath CLI..."
    Expand-Archive -Path $zipFilePath -DestinationPath $cliDir -Force -ErrorAction Stop

    # Find executable: try 'uipathcli.exe' first, then 'uipath.exe'
    $possibleExecutables = @("uipathcli.exe", "uipath.exe")
    $cliExePath = $null
    foreach ($exeName in $possibleExecutables) {
        $cliExePath = Get-ChildItem -Path $cliDir -Filter $exeName -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($cliExePath) { break }
    }

    if (-not $cliExePath) {
        Write-Error "Could not locate UiPath CLI executable after extraction."
        exit 1
    }

    $cliExecutablePath = $cliExePath.DirectoryName
    $cliFullPath = $cliExePath.FullName
    Write-Host "Found CLI executable at: $cliFullPath"

    # Add CLI directory to PATH environment variable for current session
    $env:Path = "$cliExecutablePath;$env:Path"

    # Persist environment variables for subsequent GitHub Actions steps
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_FULL_PATH=$cliFullPath"
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_EXECUTABLE_NAME=$($cliExePath.Name)"
    Add-Content -Path $env:GITHUB_ENV -Value "UIPATH_CLI_DIR=$cliExecutablePath"

    Remove-Item -Path $zipFilePath -Force -ErrorAction SilentlyContinue

    Write-Host "UiPath CLI setup completed successfully."
}
catch {
    Write-Error ("Failed to download or setup UiPath CLI: " + $_.Exception.Message)
    exit 1
}
