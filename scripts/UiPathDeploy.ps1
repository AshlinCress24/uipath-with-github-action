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

# Retrieve the CLI executable name from environment variable
$cliExe = $env:UIPATH_CLI_EXECUTABLE_NAME

if (-not $cliExe) {
    Write-Error "Environment variable 'UIPATH_CLI_EXECUTABLE_NAME' is not set. Cannot proceed."
    exit 1
}

Write-Host "Starting UiPath Deploy Script (using $cliExe)..."

if (-not (Get-Command $cliExe -ErrorAction SilentlyContinue)) {
    Write-Error "UiPath CLI executable '$cliExe' not found in PATH."
    exit 1
}

if (-not (Test-Path $packages_path -PathType Container)) {
    Write-Error "Packages folder not found at path: $packages_path"
    exit 1
}

# Find the first .nupkg package (you can adjust if you want to deploy multiple or specific package)
$packageFile = Get-ChildItem -Path $packages_path -Filter "*.nupkg" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $packageFile) {
    Write-Error "No .nupkg package files found in $packages_path"
    exit 1
}

Write-Host "Using package file: $($packageFile.FullName)"

# Prepare CLI login arguments
$loginArgs = @(
    "login",
    "--client-id", "`"$client_id`"",
    "--client-secret", "`"$client_secret`"",
    "--tenant-name", "`"$orchestrator_tenant`"",
    "--url", "`"$orchestrator_url`""

)

Write-Host "Logging into UiPath Orchestrator..."

$loginProcess = Start-Process -FilePath $cliExe -ArgumentList $loginArgs -NoNewWindow -Wait -PassThru -ErrorAction Stop

if ($loginProcess.ExitCode -ne 0) {
    Write-Error "UiPath CLI login failed with exit code $($loginProcess.ExitCode)"
    exit $loginProcess.ExitCode
}

# Deploy (publish) the package
$publishArgs = @(
    "package",
    "publish",
    "--path", "`"$($packageFile.FullName)`"",
    "--folder", "`"$folder_organization_unit`""
)

Write-Host "Publishing package to Orchestrator..."

$publishProcess = Start-Process -FilePath $cliExe -ArgumentList $publishArgs -NoNewWindow -Wait -PassThru -ErrorAction Stop

if ($publishProcess.ExitCode -ne 0) {
    Write-Error "UiPath CLI package publish failed with exit code $($publishProcess.ExitCode)"
    exit $publishProcess.ExitCode
}

Write-Host "Package deployed successfully to Orchestrator."
