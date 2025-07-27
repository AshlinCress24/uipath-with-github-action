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
    [string]$folder_organization_unit,

    [Parameter(Mandatory=$true)]
    [string]$cli_executable_name # This will now always be "uipath.cli.exe"
)

Write-Host "Starting UiPath Deploy Script (using $cli_executable_name)..."

# The CLI executable should be in PATH
$uipathCliExecutable = $cli_executable_name

Write-Host "UiPath CLI Executable: $uipathCliExecutable"

# Verify CLI existence in PATH
try {
    Get-Command $uipathCliExecutable -ErrorAction Stop | Out-Null
    Write-Host "$uipathCliExecutable found in PATH."
} catch {
    Write-Error "$uipathCliExecutable not found in PATH. Make sure the setup process successfully installed it and added it to PATH."
    exit 1
}

# 1. Login to Orchestrator (using v2.x CLI syntax)
Write-Host "Attempting to login to Orchestrator at $orchestrator_url using $uipathCliExecutable..."

Write-Host "Using uipath.cli.exe (v2) syntax for 'orchestrator login'..."
$loginArgs = @(
    "orchestrator",
    "login",
    "--url", $orchestrator_url,
    "--organization-name", $organization_name,
    "--tenant-name", $orchestrator_tenant,
    "--client-id", $client_id,
    "--client-secret", $client_secret
)

& $uipathCliExecutable $loginArgs

if ($LASTEXITCODE -ne 0) {
    Write-Error "UiPath CLI 'orchestrator login' command failed with exit code $LASTEXITCODE."
    exit $LASTEXITCODE
} else {
    Write-Host "Successfully logged in to UiPath Orchestrator using $uipathCliExecutable."
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

Write-Host "Attempting to publish package to folder: $folder_organization_unit using $uipathCliExecutable..."

# Publish command syntax (using v2.x CLI syntax)
Write-Host "Using uipath.cli.exe (v2) syntax for 'orchestrator publish'..."
$publishArgs = @(
    "orchestrator",
    "publish",
    "--file", $packagePath,
    "--folder", $folder_organization_unit
)

& $uipathCliExecutable $publishArgs

if ($LASTEXITCODE -ne 0) {
    Write-Error "UiPath CLI 'orchestrator publish' command failed with exit code $LASTEXITCODE."
    exit $LASTEXITCODE
} else {
    Write-Host "UiPath package published successfully using $uipathCliExecutable."
}

# 3. Logout (optional, but good practice)
Write-Host "Logging out from UiPath Orchestrator using $uipathCliExecutable..."
& $uipathCliExecutable orchestrator logout

if ($LASTEXITCODE -ne 0) {
    Write-Warning "UiPath CLI 'orchestrator logout' command failed with exit code $LASTEXITCODE. Proceeding anyway."
} else {
    Write-Host "Successfully logged out from UiPath Orchestrator using $uipathCliExecutable."
}

Write-Host "Finished UiPath Deploy Script."
