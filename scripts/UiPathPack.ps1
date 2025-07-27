param(
    [Parameter(Mandatory=$true)]
    [string]$project_path,

    [Parameter(Mandatory=$true)]
    [string]$output_path
)

Write-Host "Starting UiPath Pack Script..."

# UPDATED PATH: The UiPath CLI executable path from the UiPath.Automation.Cloud.Activities package when installed with -ExcludeVersion
$uipathCliExecutable = "$env:GITHUB_WORKSPACE\uipathcli\UiPath.Automation.Cloud.Activities\tools\uipcli.exe"

Write-Host "UiPath CLI Executable Path: $uipathCliExecutable"

# Verify CLI existence
if (-not (Test-Path $uipathCliExecutable)) {
    Write-Error "UiPath CLI executable not found at $uipathCliExecutable. Exiting."
    exit 1
}

# Ensure output directory exists
Write-Host "Ensuring output directory exists: $output_path"
if (-not (Test-Path $output_path)) {
    New-Item -ItemType Directory -Path $output_path -Force | Out-Null
}

Write-Host "Packing UiPath project: $project_path"
Write-Host "Output path: $output_path"

# Execute uipcli.exe to pack the project
# Use the full path to the executable
$packResult = & $uipathCliExecutable package pack `
    --project-path "$project_path" `
    --output "$output_path" `
    --serverless

if ($LASTEXITCODE -ne 0) {
    Write-Error "UiPath CLI 'package pack' command failed with exit code $LASTEXITCODE."
    exit $LASTEXITCODE
} else {
    Write-Host "UiPath project packed successfully."
}

Write-Host "Finished UiPath Pack Script."
