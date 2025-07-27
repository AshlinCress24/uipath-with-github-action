param(
    [Parameter(Mandatory = $true)]
    [string]$packages_path,

    [Parameter(Mandatory = $true)]
    [string]$orchestrator_url,

    [Parameter(Mandatory = $true)]
    [string]$organization_name,

    [Parameter(Mandatory = $true)]
    [string]$orchestrator_tenant,

    [Parameter(Mandatory = $true)]
    [string]$client_id,

    [Parameter(Mandatory = $true)]
    [string]$client_secret,

    [Parameter(Mandatory = $false)]
    [string]$folder_organization_unit = ""
)

Write-Host "Starting UiPath Deploy Script (using uipathcli)..."

# Verify 'uipathcli' is available
if (-not (Get-Command "uipathcli" -ErrorAction SilentlyContinue)) {
    Write-Error "UiPath CLI 'uipathcli' executable not found in PATH."
    exit 1
}

if (-not (Test-Path $packages_path -PathType Container)) {
    Write-Error "Packages folder not found at path: $packages_path"
    exit 1
}

# Find the latest package file (.nupkg)
$packageFile = Get-ChildItem -Path $packages_path -Filter "*.nupkg" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $packageFile) {
    Write-Error "No .nupkg package files found in $packages_path"
    exit 1
}

Write-Host "Using package file: $($packageFile.FullName)"

# Login to UiPath Orchestrator
Write-Host "Logging into UiPath Orchestrator..."
$loginArgs = @(
    "orchestrator", "login",
    "--client-id", $client_id,
    "--client-secret", $client_secret,
    "--tenant-name", $orchestrator_tenant,
    "--url", $orchestrator_url
)

$loginProcess = Start-Process -FilePath "uipathcli" -ArgumentList $loginArgs -NoNewWindow -Wait -PassThru

if ($loginProcess.ExitCode -ne 0) {
    Write-Error "UiPath CLI login failed with exit code $($loginProcess.ExitCode)"
    exit $loginProcess.ExitCode
}

# Publish the package
Write-Host "Publishing package to Orchestrator..."
$publishArgs = @(
    "studio", "package", "publish",
    "--path", $packageFile.FullName,
    "--folder", $folder_organization_unit
)

$publishProcess = Start-Process -FilePath "uipathcli" -ArgumentList $publishArgs -NoNewWindow -Wait -PassThru

if ($publishProcess.ExitCode -ne 0) {
    Write-Error "UiPath CLI package publish failed with exit code $($publishProcess.ExitCode)"
    exit $publishProcess.ExitCode
}

Write-Host "Package deployed successfully to Orchestrator."
