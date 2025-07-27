param(
    [Parameter(Mandatory=$true)]
    [string]$packages_path,

    [Parameter(Mandatory=$true)]
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

Write-Host "Starting UiPath Deploy Script..."

# UPDATED PATH: The directory where uipcli.exe resides after extraction from UiPath.Automation.Cloud.Activities
$uipathCliDir = "$env:GITHUB_WORKSPACE\uipathcli\UiPath.Automation.Cloud.Activities\tools"
$uipathCliExecutable = Join-Path $uipathCliDir "uipcli.exe"

Write-Host "UiPath CLI Directory: $uipathCliDir"
Write-Host "UiPath CLI Executable Path: $uipathCliExecutable"

# Verify CLI existence
if (-not (Test-Path $uipathCliExecutable)) {
    Write-Error "UiPath CLI executable not found at $uipathCliExecutable. Exiting."
    exit 1
}

# Change directory to where uipcli.exe is located for direct execution
Write-Host "Changing directory to $uipathCliDir"
Set-Location $uipathCliDir

# 1. Login to Orchestrator using v1.x CLI syntax
Write-Host "Attempting to login to Orchestrator at $orchestrator_url..."

$loginArgs = @(
    "orchestrator",
    "login",
    "--url", $orchestrator_url,
    "--organization-name", $organization_name,
    "--tenant-name", $orchestrator_tenant,
    "--client-id", $client_id,
    "--client-secret", $client_secret
)

& ".\uipcli.exe" $loginArgs # Execute from current directory

if ($LASTEXITCODE -ne 0) {
    Write-Error "UiPath CLI 'orchestrator login' command failed with exit code $LASTEXITCODE."
    exit $LASTEXITCODE
} else {
    Write-Host "Successfully logged in to UiPath Orchestrator."
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

Write-Host "Attempting to publish package to folder: $folder_organization_unit"

$publishArgs = @(
    "orchestrator",
    "publish",
    "--package-path", $packagePath,
    "--folder", $folder_organization_unit
)

& ".\uipcli.exe" $publishArgs # Execute from current directory

if ($LASTEXITCODE -ne 0) {
    Write-Error "UiPath CLI 'orchestrator publish' command failed with exit code $LASTEXITCODE."
    exit $LASTEXITCODE
} else {
    Write-Host "UiPath package published successfully."
}

# 3. Logout (optional, but good practice)
Write-Host "Logging out from UiPath Orchestrator..."
& ".\uipcli.exe" orchestrator logout

if ($LASTEXITCODE -ne 0) {
    Write-Warning "UiPath CLI 'orchestrator logout' command failed with exit code $LASTEXITCODE. Proceeding anyway."
} else {
    Write-Host "Successfully logged out from UiPath Orchestrator."
}

Write-Host "Finished UiPath Deploy Script."
