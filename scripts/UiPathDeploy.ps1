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

Write-Host "Starting UiPath Package Deployment..."

# Define the full path to uipath.exe
$uipathCliExecutable = "$env:GITHUB_WORKSPACE\uipathcli\uipath.exe"

# Get the latest .nupkg file in the packages_path
$nupkgFile = Get-ChildItem -Path $packages_path -Filter "*.nupkg" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $nupkgFile) {
    Write-Error "No .nupkg file found in $packages_path"
    exit 1
}

$nupkgFullPath = $nupkgFile.FullName
Write-Host "Found package: $nupkgFullPath"

Write-Host "Authenticating to Orchestrator..."
# Pass arguments as an array for robust parsing
$authArgs = @(
    "identity", "auth", "client-credentials",
    "--url", "$orchestrator_url",
    "--organization-name", "$organization_name",
    "--tenant", "$orchestrator_tenant",
    "--client-id", "$client_id",
    "--client-secret", "$client_secret"
)
& $uipathCliExecutable $authArgs # Execute with array of arguments

if ($LASTEXITCODE -ne 0) {
    Write-Error "UiPath CLI authentication failed with exit code $LASTEXITCODE"
    exit 1
}

Write-Host "Publishing package to Orchestrator folder: $folder_organization_unit"
# Pass arguments as an array for robust parsing
$publishArgs = @(
    "orchestrator", "publish",
    "--file", "$nupkgFullPath",
    "--folder-path", "$folder_organization_unit"
)
& $uipathCliExecutable $publishArgs # Execute with array of arguments

if ($LASTEXITCODE -ne 0) {
    Write-Error "UiPath CLI 'orchestrator publish' command failed with exit code $LASTEXITCODE"
    exit 1
}

Write-Host "UiPath Package Deployment Completed."
