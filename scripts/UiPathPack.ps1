param(
    [Parameter(Mandatory = $true)]
    [string]$project_path,

    [Parameter(Mandatory = $true)]
    [string]$output_path
)

Write-Host "Starting UiPath Pack Script (using uipathcli)..."

# Verify uipathcli command is available
if (-not (Get-Command "uipathcli" -ErrorAction SilentlyContinue)) {
    Write-Error "UiPath CLI 'uipathcli' executable not found in PATH."
    exit 1
}

if (-not (Test-Path $project_path)) {
    Write-Error "Project file not found at path: $project_path"
    exit 1
}

if (-not (Test-Path $output_path)) {
    Write-Host "Output directory does not exist. Creating: $output_path"
    New-Item -ItemType Directory -Path $output_path -Force | Out-Null
}

Write-Host "Running: uipathcli pack --file `"$project_path`" --output `"$output_path`""

# Run the pack command
$process = Start-Process -FilePath "uipathcli" -ArgumentList @("pack", "--file", "`"$project_path`"", "--output", "`"$output_path`"") -NoNewWindow -Wait -PassThru

if ($process.ExitCode -ne 0) {
    Write-Error "uipathcli pack command failed with exit code $($process.ExitCode)"
    exit $process.ExitCode
}

Write-Host "UiPath project packed successfully."
