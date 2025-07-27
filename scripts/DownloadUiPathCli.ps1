# scripts/DownloadUiPathCli.ps1

param(
    [string]$WorkspacePath
)

# !! IMPORTANT: YOU MUST UPDATE THIS URL !!
# As of today, Sunday, July 27, 2025, you need to find a currently valid direct download link
# for 'UiPathStudioCli.zip' from UiPath's official website.
#
# How to find it:
# 1. Go to UiPath's official download site (e.g., https://download.uipath.com/ or their documentation).
# 2. Look for releases or enterprise installers. The CLI is typically part of or available alongside UiPath Studio.
# 3. Find a stable version, preferably an LTS (Long Term Support) version, like a recent 2024.x.x or 2023.x.x release.
# 4. The URL should generally follow the pattern:
#    "https://download.uipath.com/versions/<ACTUAL_VERSION_NUMBER>/UiPathStudioCli.zip"
#
# EXAMPLE (DO NOT USE WITHOUT VERIFICATION - THIS IS JUST AN EXAMPLE OF WHAT IT MIGHT LOOK LIKE):
# $cliDownloadUrl = "https://download.uipath.com/versions/2024.4.1/UiPathStudioCli.zip"
# $cliDownloadUrl = "https://download.uipath.com/versions/23.10.8/UiPathStudioCli.zip"
#
# REPLACE THE FOLLOWING PLACEHOLDER URL WITH THE ACTUAL, WORKING URL YOU FIND:
$cliDownloadUrl = "https://download.uipath.com/versions/PUT_YOUR_VERIFIED_UI_PATH_CLI_VERSION_HERE/UiPathStudioCli.zip" 


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
    # Corrected syntax for Write-Error using string concatenation
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
# This line adds the extracted CLI directory to the PATH for subsequent steps in the same job
Add-Content -Path $env:GITHUB_PATH -Value $cliExtractDir

Write-Host "Verifying uipath.cli.exe presence and version..."
if (Test-Path $cliExePath) {
    Write-Host "uipath.cli.exe found at: $cliExePath"
    # Use the call operator '&' to execute the command directly if path contains spaces
    & $cliExePath --version # Verify CLI version
    & $cliExePath help     # Use 'help' for v2 CLI, 'commands' for v1 CLI if you are using an older one
} else {
    Write-Error "uipath.cli.exe not found after extraction! Expected at: $cliExePath"
    Write-Host "Listing contents of ${cliExtractDir} for debugging:" 
    Get-ChildItem -Path $cliExtractDir -Recurse -Force | Format-Table -AutoSize
    exit 1 # Exit with a non-zero code to indicate failure
}

# Set the CLI executable name as an environment variable for subsequent steps/jobs
# This assumes the executable name is always uipath.cli.exe within the zip.
echo "UIPATH_CLI_EXECUTABLE_NAME=uipath.cli.exe" | Out-File -FilePath $env:GITHUB_ENV -Append

Write-Host "UiPath CLI setup complete."
