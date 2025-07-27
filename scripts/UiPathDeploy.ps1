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

Write-Host "Starting UiPath Package Deployment (using older CLI version)..."

# Define the full path to uipcli.exe (note: no 'h' in uipcli for older versions)
$uipathCliDir = "$env:GITHUB_WORKSPACE\uipathcli"
$uipathCliExecutable = Join-Path $uipathCliDir "uipcli.exe"

# Get the latest .nupkg file in the packages_path
$nupkgFile = Get-ChildItem -Path $packages_path -Filter "*.nupkg" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $nupkgFile) {
    Write-Error "No .nupkg file found in $packages_path"
    exit 1
}

$nupkgFullPath = $nupkgFile.FullName
Write-Host "Found package: $nupkgFullPath"

Write-Host "Authenticating to Orchestrator using 'orchestrator login'..."
# For older CLI versions, 'orchestrator login' with client-credentials is common
# This might also implicitly handle the identity server URL.
# Ensure the URL is just the base cloud URL, not tenant-specific.
$loginArgs = @(
    "orchestrator", "login",
    "--url", "$orchestrator_url",
    "--organization-name", "$organization_name",
    "--tenant", "$orchestrator_tenant",
    "--client-id", "$client_id",
    "--client-secret", "$client_secret"
)

Write-Host "Login command string being passed: '$uipathCliExecutable $($loginArgs -join ' ')'"

$originalLocation = Get-Location
Set-Location $uipathCliDir

& ".\uipathcli.exe" $loginArgs # Use uipcli.exe

Set-Location $originalLocation

if ($LASTEXITCODE -ne 0) {
    Write-Error "UiPath CLI 'orchestrator login' command failed with exit code $LASTEXITCODE"
    exit 1
}

Write-Host "Publishing package to Orchestrator folder: $folder_organization_unit"
# The publish command syntax should be similar, just ensuring uipcli.exe is used
$publishArgs = @(
    "orchestrator", "publish",
    "--file", "$nupkgFullPath",
    "--folder-path", "$folder_organization_unit"
)

Write-Host "Publish command string being passed: '$uipathCliExecutable $($publishArgs -join ' ')'"

$originalLocation = Get-Location # Get again in case previous was skipped
Set-Location $uipathCliDir

& ".\uipathcli.exe" $publishArgs # Use uipcli.exe

Set-Location $originalLocation

if ($LASTEXITCODE -ne 0) {
    Write-Error "UiPath CLI 'orchestrator publish' command failed with exit code $LASTEXITCODE"
    exit 1
}

Write-Host "UiPath Package Deployment Completed."
