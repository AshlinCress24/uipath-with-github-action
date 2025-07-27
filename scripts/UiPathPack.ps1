# scripts/UiPathPack.ps1

param(
    [string]$project_path,
    [string]$output_path,
    [string]$cli_executable_name # This should now be "uipath.exe"
)

# --- NEW DIAGNOSTIC LINE ---
Write-Host "DEBUG: Value of \$cli_executable_name upon script entry: '$cli_executable_name'"
# --- END NEW DIAGNOSTIC LINE ---

Write-Host "Starting UiPath Pack Script (using $cli_executable_name)..." # This line should now show the value correctly if the debug line above shows it.

$cli_path = Get-Command $cli_executable_name -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
if (-not $cli_path) {
    Write-Error "UiPath CLI executable '$cli_executable_name' not found in PATH."
    exit 1
}
Write-Host "UiPath CLI Executable: $cli_path"
Write-Host "$cli_executable_name found in PATH."

# ... (rest of your script remains the same)
