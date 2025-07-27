# scripts/DownloadUiPathCli.ps1

param(
    [string]$WorkspacePath
)

# !! THIS IS THE UPDATED URL YOU PROVIDED !!
$cliDownloadUrl = "https://github.com/UiPath/uipathcli/releases/download/v2.0.44/uipathcli-windows-amd64.zip" 

$cliZipPath = Join-Path $WorkspacePath "UiPathStudioCli.zip"
$cliExtractDir = Join-Path $WorkspacePath "uipathcli"
# IMPORTANT: The executable name inside uipathcli-windows-amd64.zip is typically 'uipath.exe'
$cliExePath = Join-Path $cliExtractDir "uipath.exe" # Adjusted for GitHub releases ZIP

Write-Host "Creating CLI extraction directory: $cliExtractDir"
New-Item -ItemType Directory -Path $cliExtractDir -Force | Out-Null

Write-Host "Attempting to download UiPath CLI from: $cliDownloadUrl"
try {
    Invoke-WebRequest -Uri $cliDownloadUrl -OutFile $cliZipPath -UseBasicParsing -TimeoutSec 300
    Write-Host "Successfully downloaded UiPath CLI to $cliZipPath"
} catch {
    Write-Error ("Failed to download UiPath CLI from " + $cliDownloadUrl + ": " + $_.Exception.Message)
    exit 1 # Exit with a non-zero code to indicate failure
}

Write-Host "Extracting UiPath CLI to: $cliExtractDir"
try {
    Expand-Archive -Path $cliZipPath -DestinationPath $cliExtractDir -Force
    Write-Host "Successfully extracted UiPath CLI to $cliExtractDir"
} catch {
    Write-Error ("Failed to extract UiPath CLI from " + $cliZipPath + ": " + $_.Exception.Message)
    exit 1 # Exit with a non-zero code to indicate failure
}

Write-Host "Adding UiPath CLI directory to PATH: $cliExtractDir"
Add-Content -Path $env:GITHUB_PATH -Value $cliExtractDir

Write-Host "Verifying uipath.exe presence and version..." # Adjusted message
if (Test-Path $cliExePath) {
    Write-Host "uipath.exe found at: $cliExePath" # Adjusted message
    & $cliExePath --version # Verify CLI version
    & $cliExePath help     # Use 'help' for v2 CLI, 'commands' for v1 CLI if you are using an older one
} else {
    Write-Error "uipath.exe not found after extraction! Expected at: $cliExePath" # Adjusted message
    Write-Host "Listing contents of ${cliExtractDir} for debugging:" 
    Get-ChildItem -Path $cliExtractDir -Recurse -Force | Format-Table -AutoSize
    exit 1 # Exit with a non-zero code to indicate failure
}

# Set the CLI executable name as an environment variable for subsequent steps/jobs
# This is now confirmed to be 'uipath.exe' for the GitHub releases ZIP
echo "UIPATH_CLI_EXECUTABLE_NAME=uipath.exe" | Out-File -FilePath $env:GITHUB_ENV -Append

Write-Host "UiPath CLI setup complete."
