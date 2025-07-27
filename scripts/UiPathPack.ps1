param(
    [Parameter(Mandatory=$true)]
    [string]$project_path,

    [Parameter(Mandatory=$true)]
    [string]$output_path
)

Write-Host "Starting UiPath Pack Script (using uipath.cli.exe)..."

# UPDATED: Path to the modern UiPath CLI executable
$uipathCliExecutable = "$env:GITHUB_WORKSPACE\uipathcli\UiPath.CLI\tools\uipath.cli.exe"

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

# UPDATED COMMAND SYNTAX FOR UIPATH.CLI.EXE (v2.x)
# The 'pack' command for v2 CLI is typically 'uipath.cli.exe project pack'
$packResult = & $uipathCliExecutable project pack `
    --file "$project_path" ` # Changed from --project-path to --file
    --output "$output_path" 

# Note: The '--serverless' flag is not directly available or necessary for 'project pack' in uipath.cli.exe (v2)
# If it was used for a specific purpose, you might need to find an equivalent v2 command or remove it if not critical.

if ($LASTEXITCODE -ne 0) {
    Write-Error "UiPath CLI 'project pack' command failed with exit code $LASTEXITCODE."
    exit $LASTEXITCODE
} else {
    Write-Host "UiPath project packed successfully using uipath.cli.exe."
}

Write-Host "Finished UiPath Pack Script."
