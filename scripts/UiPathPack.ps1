param(
    [Parameter(Mandatory=$true)]
    [string]$project_path,
    [Parameter(Mandatory=$true)]
    [string]$output_path
)

Write-Host "Starting UiPath Package Creation..."

# Define the full path to uipcli.exe (note: no 'h' in uipcli for older versions)
$uipathCliExecutable = "$env:GITHUB_WORKSPACE\uipathcli\uipcli.exe"

# Ensure the output directory exists
if (-not (Test-Path $output_path)) {
    Write-Host "Creating output directory: $output_path"
    New-Item -ItemType Directory -Path $output_path -Force | Out-Null
}

Write-Host "Packing UiPath project: $project_path"

# Use the older 'package pack' command syntax
& $uipathCliExecutable package pack `
    --project-path "$project_path" `
    --output "$output_path"

if ($LASTEXITCODE -ne 0) {
    Write-Error "UiPath CLI 'package pack' command failed with exit code $LASTEXITCODE"
    exit 1
}

Write-Host "UiPath Package Creation Completed."
