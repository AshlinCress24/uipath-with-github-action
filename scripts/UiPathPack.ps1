param(
    [Parameter(Mandatory=$true)]
    [string]$project_path,

    [Parameter(Mandatory=$true)]
    [string]$output_path,

    [Parameter(Mandatory=$true)]
    [string]$cli_executable_name # This will now always be "uipath.cli.exe"
)

Write-Host "Starting UiPath Pack Script (using $cli_executable_name)..."

# The CLI executable should be in PATH
$uipathCliExecutable = $cli_executable_name

Write-Host "UiPath CLI Executable: $uipathCliExecutable"

# Verify CLI existence in PATH
try {
    Get-Command $uipathCliExecutable -ErrorAction Stop | Out-Null
    Write-Host "$uipathCliExecutable found in PATH."
} catch {
    Write-Error "$uipathCliExecutable not found in PATH. Make sure the setup process successfully installed it and added it to PATH."
    exit 1
}

# Ensure output directory exists
Write-Host "Ensuring output directory exists: $output_path"
if (-not (Test-Path $output_path)) {
    New-Item -ItemType Directory -Path $output_path -Force | Out-Null
}

Write-Host "Packing UiPath project: $project_path"
Write-Host "Output path: $output_path"

# Execute CLI to pack the project (using v2.x CLI syntax)
Write-Host "Using uipath.cli.exe (v2) syntax for 'project pack'..."
$packResult = & $uipathCliExecutable project pack `
    --file "$project_path" `
    --output "$output_path"

if ($LASTEXITCODE -ne 0) {
    Write-Error "UiPath CLI 'project pack' command failed with exit code $LASTEXITCODE."
    exit $LASTEXITCODE
} else {
    Write-Host "UiPath project packed successfully using $uipathCliExecutable."
}

Write-Host "Finished UiPath Pack Script."
