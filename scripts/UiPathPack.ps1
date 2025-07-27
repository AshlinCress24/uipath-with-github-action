param(
    [Parameter(Mandatory=$true)]
    [string]$project_path,

    [Parameter(Mandatory=$true)]
    [string]$output_path,

    [Parameter(Mandatory=$true)] # New parameter to receive CLI executable name
    [string]$cli_executable_name 
)

Write-Host "Starting UiPath Pack Script (using $cli_executable_name)..."

# The CLI executable should be in PATH, so we just use its name
$uipathCliExecutable = $cli_executable_name

Write-Host "UiPath CLI Executable: $uipathCliExecutable"

# Verify CLI existence in PATH (PowerShell's Get-Command should find it if in PATH)
try {
    Get-Command $uipathCliExecutable -ErrorAction Stop | Out-Null
    Write-Host "$uipathCliExecutable found in PATH."
} catch {
    Write-Error "$uipathCliExecutable not found in PATH. Make sure the setup-uipcli action successfully installed it and added it to PATH."
    exit 1
}


# Ensure output directory exists
Write-Host "Ensuring output directory exists: $output_path"
if (-not (Test-Path $output_path)) {
    New-Item -ItemType Directory -Path $output_path -Force | Out-Null
}

Write-Host "Packing UiPath project: $project_path"
Write-Host "Output path: $output_path"

# Execute CLI to pack the project
# Command syntax depends on whether it's uipcli.exe (v1) or uipath.cli.exe (v2)
if ($cli_executable_name -eq "uipath.cli.exe") {
    Write-Host "Using uipath.cli.exe (v2) syntax for 'project pack'..."
    $packResult = & $uipathCliExecutable project pack `
        --file "$project_path" ` # v2 uses --file
        --output "$output_path"
} elseif ($cli_executable_name -eq "uipcli.exe") {
    Write-Host "Using uipcli.exe (v1) syntax for 'package pack'..."
    $packResult = & $uipathCliExecutable package pack `
        --project-path "$project_path" ` # v1 uses --project-path
        --output "$output_path" `
        --serverless # --serverless is typical for v1
} else {
    Write-Error "Unknown CLI executable name: $cli_executable_name. Cannot determine pack syntax."
    exit 1
}


if ($LASTEXITCODE -ne 0) {
    Write-Error "UiPath CLI '$uipathCliExecutable pack' command failed with exit code $LASTEXITCODE."
    exit $LASTEXITCODE
} else {
    Write-Host "UiPath project packed successfully using $uipathCliExecutable."
}

Write-Host "Finished UiPath Pack Script."
