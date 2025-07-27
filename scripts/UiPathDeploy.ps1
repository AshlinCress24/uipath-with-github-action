# scripts/UiPathDeploy.ps1

param(
    [string]$packages_path,
    [string]$orchestrator_url,
    [string]$organization_name,
    [string]$orchestrator_tenant,
    [string]$client_id,
    [string]$client_secret,
    [string]$folder_organization_unit
)

$cli_executable_name = $env:UIPATH_CLI_EXECUTABLE_NAME

Write-Host "Starting UiPath Deploy Script (using $cli_executable_name)..."

$cli_path = Get-Command $cli_executable_name -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
if (-not $cli_path) {
    Write-Error "UiPath CLI executable '$cli_executable_name' not found in PATH for deployment."
    exit 1
}
Write-Host "UiPath CLI Executable: $cli_path"

try {
    # 1. Login using OAuth client credentials
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

    $package_file = Get-ChildItem -Path $packages_path -Filter "*.nupkg" | Select-Object -First 1 -ExpandProperty FullName
    if (-not $package_file) {
        Write-Error "No .nupkg file found in '$packages_path'."
        exit 1
    }

    # 3. Deploy the package
    $folder_arg = ""
    if (![string]::IsNullOrEmpty($folder_organization_unit)) {
        $folder_arg = "--folder-path `"$folder_organization_unit`""
    }

    Write-Host "Publishing package to Orchestrator..."
    # Use CLI v2 syntax for publishing
    & $cli_executable_name package deploy `
        --path "$package_file" `
        $folder_arg

    if ($LASTEXITCODE -ne 0) {
        Write-Error "UiPath CLI package deploy failed with exit code $LASTEXITCODE."
        exit 1
    }
    Write-Host "Successfully deployed package."

} catch {
    Write-Error ("Error deploying UiPath project: " + $_.Exception.Message)
    exit 1
} finally {
    Write-Host "Attempting to logout from UiPath Orchestrator..."
    & $cli_executable_name auth logout -Force
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "UiPath CLI logout command failed with exit code $LASTEXITCODE, but deployment process completed."
    } else {
        Write-Host "Successfully logged out."
    }
}

Write-Host "UiPath Deploy Script completed."
