# scripts/UiPathPack.ps1

param(
    [string]$project_path,    # This will be the path to project.json, e.g., "...\project.json"
    [string]$output_path,
    [string]$cli_executable_name # This should now be "uipath.exe"
)

Write-Host "Starting UiPath Pack Script (using $cli_executable_name)..."

$cli_path = Get-Command $cli_executable_name -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
if (-not $cli_path) {
    Write-Error "UiPath CLI executable '$cli_executable_name' not found in PATH."
    exit 1
}
Write-Host "UiPath CLI Executable: $cli_path"
Write-Host "$cli_executable_name found in PATH."


# Ensure the output directory exists
Write-Host "Ensuring output directory exists: $output_path"
if (-not (Test-Path $output_path -PathType Container)) {
    New-Item -ItemType Directory -Path $output_path -Force | Out-Null
}

Write-Host "Packing UiPath project: $project_path"
Write-Host "Output path: $output_path"

# Extract the project folder from the project_path
$project_folder = Split-Path -Path $project_path -Parent

Write-Host "Using UiPath CLI v2 syntax for 'studio package pack'..."

# --- NEW DIAGNOSTIC LINES START ---
Write-Host "Checking contents of the project source folder: $project_folder"
Get-ChildItem -Path "$project_folder" -Force | Format-Table -AutoSize # This will show what's actually there
# --- NEW DIAGNOSTIC LINES END ---

try {
    # Execute the UiPath CLI command for packing
    # Command: uipath studio package pack --source <project_folder> --destination <output_folder>
    & $cli_executable_name studio package pack `
        --source "$project_folder" `
        --destination "$output_path" `
        # Optional: Add --version if your project requires a specific Studio compatibility version, e.g., --version "23.10"
        # Optional: Add --library if it's an automation library project

    if ($LASTEXITCODE -ne 0) {
        Write-Error "UiPath CLI 'studio package pack' command failed with exit code $LASTEXITCODE."
        exit 1
    }
    Write-Host "Successfully packed UiPath project."

} catch {
    Write-Error ("Error packing UiPath project: " + $_.Exception.Message)
    exit 1
}

Write-Host "UiPath Pack Script completed."
