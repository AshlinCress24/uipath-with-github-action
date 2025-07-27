# scripts/DownloadUiPathCli.ps1

param(
    [string]$WorkspacePath
)

# !! IMPORTANT: This URL needs to be updated to a currently valid UiPath CLI download !!
# The version 23.4.1 was giving a 404. You need to find a working version from UiPath.
# Example (YOU MUST VERIFY THIS VERSION IS AVAILABLE). As of my last update, 23.10.8 was a common LTS.
$cliDownloadUrl = "https://download.uipath.com/versions/23.10.8/UiPathStudioCli.zip" 
# Or a newer version like 2024.4.x if available. Please check UiPath's official downloads.
# You can typically find these by navigating UiPath's download page for Studio/Assistant or documentation.
# As of July 2025, newer versions like 24.4.x might be available. Verify on download.uipath.com.

$cliZipPath = Join-Path $WorkspacePath "UiPathStudioCli.zip"
$cliExtractDir = Join-Path $WorkspacePath "uipathcli"
$cliExePath = Join-Path $cliExtractDir "uipath.cli.exe" # This is the expected executable name inside the zip

Write-Host "Creating CLI extraction directory: $cliExtractDir"
New-Item -ItemType Directory -Path $cliExtractDir -Force | Out-Null

Write-Host "Attempting to download UiPath CLI from: $cliDownloadUrl"
try {
    Invoke-WebRequest -Uri $cliDownloadUrl -OutFile $cliZipPath -UseBasicParsing -TimeoutSec 300
    Write-Host "Successfully downloaded UiPath CLI to $cliZipPath"
} catch {
    # Corrected syntax using string concatenation for Write-Error
    Write-Error ("Failed to download UiPath CLI from " + $cliDownloadUrl + ": " + $_.Exception.Message)
    exit 1
}

Write-Host "Extracting UiPath CLI to: $cliExtractDir"
try {
    Expand-Archive -Path $cliZipPath -DestinationPath $cliExtractDir -Force
    Write-Host "Successfully extracted UiPath CLI to $cliExtractDir"
} catch {
    Write-Error ("Failed to extract UiPath CLI from " + $cliZipPath + ": " + $_.Exception.Message)
    exit 1
}

Write-Host "Adding UiPath CLI directory to PATH: $cliExtractDir"
Add-Content -Path $env:GITHUB_PATH -Value $cliExtractDir

Write-Host "Verifying uipath.cli.exe presence and version..."
if (Test-Path $cliExePath) {
    Write-Host "uipath.cli.exe found at: $cliExePath"
    & $cliExePath --version # Verify version
    & $cliExePath help # Use 'help' for v2 CLI
} else {
    Write-Error "uipath.cli.exe not found after extraction! Expected at: $cliExePath"
    Write-Host "Listing contents of ${cliExtractDir}:" 
    Get-ChildItem -Path $cliExtractDir -Recurse -Force | Format-Table -AutoSize
    exit 1
}

# Set the CLI executable name for subsequent steps (always uipath.cli.exe now)
echo "UIPATH_CLI_EXECUTABLE_NAME=uipath.cli.exe" | Out-File -FilePath $env:GITHUB_ENV -Append
