# scripts/UiPathPack.ps1

param(
    [string]$project_path,
    [string]$output_path
    # The $cli_executable_name parameter has been removed from here.
)

# Define cli_executable_name directly from the environment variable set by DownloadUiPathCli.ps1
$cli_executable_name = $env:UIPATH_CLI_EXECUTABLE_NAME


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
# The --source argument for 'studio package pack' expects the project *folder*, not the project.json file itself.
$project_folder = Split-Path -Path $project_path -Parent

Write-Host "Using UiPath CLI v2 syntax for 'studio package pack' with source: $project_folder"

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
