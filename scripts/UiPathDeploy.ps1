param(
    [Parameter(Mandatory=$true)]
    [string]$packages_path,

    [Parameter(Mandary=$true)]
    [string]$orchestrator_url,

    [Parameter(Mandatory=$true)]
    [string]$organization_name,

    [Parameter(Mandatory=$true)]
    [string]$orchestrator_tenant,

    [Parameter(Mandatory=$true)]
    [string]$client_id,

    [Parameter(Mandatory=$true)]
    [string]$client_secret,

    [Parameter(Mandatory=$true)]
    [string]$folder_organization_unit
)

Write-Host "Starting UiPath Deploy Script (using uipath.cli.exe)..."

# UPDATED: Directory where uipath.cli.exe resides
$uipathCliDir = "$env:GITHUB_WORKSPACE\uipathcli\UiPath.CLI\tools"
$uipathCliExecutable = Join-Path $uipathCliDir "uipath.cli.exe" # <-- IMPORTANT: Changed to uipath.cli.exe

Write-Host "UiPath CLI Directory: $uipathCliDir"
Write-Host "UiPath CLI Executable Path: $uipathCliExecutable"

# Verify CLI existence
if (-not (Test-Path $uipathCliExecutable)) {
    Write-Error "UiPath CLI executable not found at $uipathCliExecutable. Exiting."
    exit 1
}

# Change directory to where uipath.cli.exe is located for direct execution
Write-Host "Changing directory to $uipathCliDir"
Set-Location $uipathCliDir

# 1. Login to Orchestrator using v2.x CLI syntax
Write-Host "Attempting to login to Orchestrator at $orchestrator_url using uipath.cli.exe..."

# UPDATED COMMAND SYNTAX FOR UIPATH.CLI.EXE (v2.x) login
# The v2 CLI uses a more direct 'login' command, sometimes preferring interactive login or
# simpler client-credentials directly at the top level.
# Let's use the 'orchestrator' sub-command if available, which it should be.
$loginArgs = @(
    "orchestrator",
    "login",
    "--url", $orchestrator_url,
    "--organization-name", $organization_name,
    "--tenant-name", $orchestrator_tenant,
    "--client-id", $client_id,
    "--client-secret", $client_secret
)

# If the above fails, you might need to use a simpler `login` for the v2 CLI
# depending on its exact version and capabilities. The v2 CLI is designed to be more
# context-aware, so `orchestrator login` is common.

& ".\uipath.cli.exe" $loginArgs # Execute from current directory

if ($LASTEXITCODE -ne 0) {
    Write-Error "UiPath CLI 'orchestrator login' command failed with exit code $LASTEXITCODE."
    exit $LASTEXITCODE
} else {
    Write-Host "Successfully logged in to UiPath Orchestrator using uipath.cli.exe."
}

# 2. Publish the NuGet package
Write-Host "Searching for packages in: $packages_path"
$packageFile = Get-ChildItem -Path $packages_path -Filter "*.nupkg" | Select-Object -First 1

if ($null -eq $packageFile) {
    Write-Error "No .nupkg file found in $packages_path. Exiting."
    exit 1
}

$packagePath = $packageFile.FullName
Write-Host "Found package: $packagePath"

Write-Host "Attempting to publish package to folder: $folder_organization_unit using uipath.cli.exe..."

# UPDATED COMMAND SYNTAX FOR UIPATH.CLI.EXE (v2.x) publish
# The 'publish' command in v2 CLI is typically 'uipath.cli.exe orchestrator publish'
$publishArgs = @(
    "orchestrator",
    "publish",
    "--file", $packagePath, # Changed from --package-path to --file
    "--folder", $folder_organization_unit
)

& ".\uipath.cli.exe" $publishArgs # Execute from current directory

if ($LASTEXITCODE -ne 0) {
    Write-Error "UiPath CLI 'orchestrator publish' command failed with exit code $LASTEXITCODE."
    exit $LASTEXITCODE
} else {
    Write-Host "UiPath package published successfully using uipath.cli.exe."
}

# 3. Logout (optional, but good practice)
Write-Host "Logging out from UiPath Orchestrator using uipath.cli.exe..."
& ".\uipath.cli.exe" orchestrator logout

if ($LASTEXITCODE -ne 0) {
    Write-Warning "UiPath CLI 'orchestrator logout' command failed with exit code $LASTEXITCODE. Proceeding anyway."
} else {
    Write-Host "Successfully logged out from UiPath Orchestrator using uipath.cli.exe."
}

Write-Host "Finished UiPath Deploy Script."
