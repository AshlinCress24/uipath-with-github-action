# scripts/UiPathDeploy.ps1

param(
    [string]$packages_path,
    [string]$orchestrator_url,
    [string]$organization_name,
    [string]$orchestrator_tenant,
    [string]$client_id,
    [string]$client_secret,
    [string]$folder_organization_unit
    # $cli_executable_name parameter is explicitly REMOVED from the param block here.
)

# Define cli_executable_name directly from the environment variable set by DownloadUiPathCli.ps1
$cli_executable_name = $env:UIPATH_CLI_EXECUTABLE_NAME

Write-Host "Starting UiPath Deploy Script (using $cli_executable_name)..."
Write-Host "Packages Path: $packages_path"
Write-Host "Orchestrator URL: $orchestrator_url"
Write-Host "Organization Name: $organization_name"
Write-Host "Orchestrator Tenant: $orchestrator_tenant"
Write-Host "Deployment Folder (Orchestrator Unit): $folder_organization_unit"

# Validate CLI executable
$cli_path = Get-Command $cli_executable_name -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
if (-not $cli_path) {
    Write-Error "UiPath CLI executable '$cli_executable_name' not found in PATH for deployment."
    exit 1
}
Write-Host "UiPath CLI Executable: $cli_path"
Write-Host "$cli_executable_name found in PATH."

try {
    # 1. Login to UiPath Cloud Orchestrator
    Write-Host "Logging in to UiPath Orchestrator..."
    & $cli_executable_name auth login `
        --url "$orchestrator_url" `
        --organization-name "$organization_name" `
        --tenant-name "$orchestrator_tenant" `
        --client-id "$client_id" `
        --client-secret "$client_secret"

    if ($LASTEXITCODE -ne 0) {
        Write-Error "UiPath CLI login failed with exit code $LASTEXITCODE."
        exit 1
    }
    Write-Host "Successfully logged in to Orchestrator."

    # 2. Find the .nupkg package to deploy
    $package_file = Get-ChildItem -Path $packages_path -Filter "*.nupkg" | Select-Object -ExpandProperty FullName
    if (-not $package_file) {
        Write-Error "No .nupkg file found in '$packages_path'."
        exit 1
    }
    if ($package_file.Count -gt 1) {
        Write-Warning "More than one .nupkg file found in '$packages_path'. Deploying the first one found: $($package_file[0])"
        $package_file = $package_file[0]
    } else {
        Write-Host "Found package: $package_file"
    }

    # 3. Publish (Deploy) the package to the specified Orchestrator folder
    Write-Host "Publishing package '$package_file' to Orchestrator folder '$folder_organization_unit'..."
    & $cli_executable_name package deploy `
        --path "$package_file" `
        --folder-path "$folder_organization_unit"

    if ($LASTEXITCODE -ne 0) {
        Write-Error "UiPath CLI package deploy failed with exit code $LASTEXITCODE."
        exit 1
    }
    Write-Host "Successfully deployed package."

} catch {
    Write-Error ("Error deploying UiPath project: " + $_.Exception.Message)
    exit 1
} finally {
    # Always attempt to logout, even if deployment fails
    Write-Host "Attempting to logout from UiPath Orchestrator..."
    & $cli_executable_name auth logout -Force
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "UiPath CLI logout command failed with exit code $LASTEXITCODE, but deployment process completed."
    } else {
        Write-Host "Successfully logged out."
    }
}

Write-Host "UiPath Deploy Script completed."
