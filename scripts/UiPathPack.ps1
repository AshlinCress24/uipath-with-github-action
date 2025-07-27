# scripts/UiPathPack.ps1

param(
    [string]$project_path,
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

# --- IMPORTANT CHANGE FOR UiPath CLI v2.0.44 ---
# The command for packing standard projects is typically 'uipath pack'.
# 'archive' is a separate command, and 'project pack' syntax is older.

Write-Host "Using UiPath CLI v2 syntax for 'pack'..." # Updated message
try {
    # Execute the UiPath CLI command for packing
    # Check 'uipath.exe pack --help' for all options.
    # Common options: --project-path, --output, --version, --library (if it's a library)
    & $cli_executable_name pack `
        --project-path "$project_path" `
        --output "$output_path" `
        # Add --version if your project requires a specific Studio compatibility version, e.g., --version "23.10"
        # Add --library if it's an automation library project
        # For simplicity, let's start with just project and output path.

    if ($LASTEXITCODE -ne 0) {
        Write-Error "UiPath CLI 'pack' command failed with exit code $LASTEXITCODE." # Updated message
        exit 1
    }
    Write-Host "Successfully packed UiPath project."

} catch {
    Write-Error ("Error packing UiPath project: " + $_.Exception.Message)
    exit 1
}

Write-Host "UiPath Pack Script completed."
