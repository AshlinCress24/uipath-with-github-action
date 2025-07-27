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
# The command for packing is now 'uipath archive pack' or 'uipath app pack' depending on context.
# For generic project packing, 'archive pack' is common.

Write-Host "Using UiPath CLI v2 syntax for 'archive pack'..."
try {
    # Execute the UiPath CLI command for packing
    # Check 'uipath.exe archive pack --help' for all options.
    # Common options: -p (project path), -o (output path), --library (if it's a library)
    & $cli_executable_name archive pack `
        --project-path "$project_path" `
        --output "$output_path" `
        # Add --version for StudioX/Studio based projects if needed, e.g., --version "23.10"
        # If it's a library project, you might need '--library' argument
        # Example for a specific version: --version 23.10.8-preview (or other if required)
        # For simplicity, let's start with just project and output path.

    if ($LASTEXITCODE -ne 0) {
        Write-Error "UiPath CLI 'archive pack' command failed with exit code $LASTEXITCODE."
        exit 1
    }
    Write-Host "Successfully packed UiPath project."

} catch {
    Write-Error ("Error packing UiPath project: " + $_.Exception.Message)
    exit 1
}

Write-Host "UiPath Pack Script completed."
