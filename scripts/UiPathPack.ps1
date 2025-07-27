param(
    [Parameter(Mandatory=$true)]
    [string]$project_json_path,
    [Parameter(Mandatory=$true)]
    [string]$destination_folder
)

Write-Host "Starting UiPath Package Build..."

# Define the full path to uipath.exe (CORRECTED NAME)
$uipathCliExecutable = "$env:GITHUB_WORKSPACE\uipathcli\uipath.exe" # <-- CHANGED TO uipath.exe

# Ensure the destination folder exists
if (-not (Test-Path $destination_folder)) {
    New-Item -ItemType Directory -Force -Path $destination_folder
}

Write-Host "Packaging project: $project_json_path"
Write-Host "Destination folder: $destination_folder"

# Execute the uipath.exe pack command using the full path
& $uipathCliExecutable package pack --source "$project_json_path" --destination "$destination_folder"

if ($LASTEXITCODE -ne 0) {
    Write-Error "UiPath CLI 'pack' command failed with exit code $LASTEXITCODE"
    exit 1
}

Write-Host "UiPath Package Build Completed."
