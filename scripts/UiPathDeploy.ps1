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

# Define the full path to uipath.exe directory
$uipathCliDir = "$env:GITHUB_WORKSPACE\uipathcli"
$uipathCliExecutable = Join-Path $uipathCliDir "uipath.exe"

# Get the latest .nupkg file in the packages_path
$nupkgFile = Get-ChildItem -Path $packages_path -Filter "*.nupkg" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $nupkgFile) {
    Write-Error "No .nupkg file found in $packages_path"
    exit 1
}

$nupkgFullPath = $nupkgFile.FullName
Write-Host "Found package: $nupkgFullPath"

# --- NEW AUTHENTICATION STRATEGY: Create .uipath/config file ---
Write-Host "Attempting authentication by creating UiPath CLI config file..."

# Determine the correct home directory for the .uipath folder
# On Windows, $env:USERPROFILE is more reliable than $env:HOME
$uipathConfigDir = Join-Path $env:USERPROFILE ".uipath"

# Add a diagnostic check for the path
Write-Host "Resolved UiPath config directory path: $uipathConfigDir"

if (-not (Test-Path $uipathConfigDir)) {
    Write-Host "Creating .uipath configuration directory: $uipathConfigDir"
    New-Item -ItemType Directory -Path $uipathConfigDir | Out-Null
} else {
    Write-Host "UiPath configuration directory already exists: $uipathConfigDir"
}

# Construct the content for the config file.
# Using a here-string for multi-line content.
$configFileContent = @"
profiles:
  - name: default
    organization: "$organization_name"
    tenant: "$orchestrator_tenant"
    auth:
      clientId: "$client_id"
      clientSecret: "$client_secret"
"@

$configFilePath = Join-Path $uipathConfigDir "config"

# Write the config file
Write-Host "Writing UiPath CLI config file to: $configFilePath"
Set-Content -Path $configFilePath -Value $configFileContent -Force

# Verify config file creation (optional, but good for debugging)
if (Test-Path $configFilePath) {
    Write-Host "UiPath CLI config file created successfully."
    # For debugging, you can uncomment the next lines to see the content.
    # Be cautious with secrets in logs!
    # Write-Host "Config file content:"
    # Get-Content $configFilePath | Write-Host
} else {
    Write-Error "Failed to create UiPath CLI config file."
    exit 1
}

Write-Host "Proceeding with Orchestrator operations using configured credentials."
# --- END NEW AUTHENTICATION STRATEGY ---

Write-Host "Publishing package to Orchestrator folder: $folder_organization_unit"
$publishArgs = @(
    "orchestrator", "publish",
    "--file", "$nupkgFullPath",
    "--folder-path", "$folder_organization_unit"
)

Write-Host "Publish command string being passed: '$uipathCliExecutable $($publishArgs -join ' ')'"

# Temporarily change directory to where uipath.exe is located for execution robustness
$originalLocation = Get-Location
Set-Location $uipathCliDir

# Execute uipath.exe from its directory
& ".\uipath.exe" $publishArgs

# Change back to original location
Set-Location $originalLocation

if ($LASTEXITCODE -ne 0) {
    Write-Error "UiPath CLI 'orchestrator publish' command failed with exit code $LASTEXITCODE"
    exit 1
}

Write-Host "UiPath Package Deployment Completed."
