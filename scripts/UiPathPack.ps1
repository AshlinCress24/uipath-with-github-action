param(
    [string]$project_path,
    [string]$output_path
)

$cli_executable_name = $env:UIPATH_CLI_EXECUTABLE_NAME

Write-Host "Starting UiPath Pack Script (using $cli_executable_name)..."

if ([string]::IsNullOrEmpty($cli_executable_name)) {
    Write-Error "Environment variable UIPATH_CLI_EXECUTABLE_NAME is not set."
    exit 1
}

$cli_path = Get-Command $cli_executable_name -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
if (-not $cli_path) {
    Write-Error "UiPath CLI executable '$cli_executable_name' not found in PATH."
    exit 1
}

Write-Host "UiPath CLI Executable: $cli_path"

if (-not (Test-Path $output_path -PathType Container)) {
    New-Item -ItemType Directory -Path $output_path -Force | Out-Null
}
Write-Host "Packing UiPath project: $project_path"
Write-Host "Output path: $output_path"

$project_folder = Split-Path -Path $project_path -Parent
Write-Host "Using source: $project_folder"

try {
    & $cli_executable_name studio package pack `
        --source "$project_folder" `
        --destination "$output_path"

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
