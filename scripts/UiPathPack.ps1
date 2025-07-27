param(
    [Parameter(Mandatory = $true)]
    [string]$project_path,

    [Parameter(Mandatory = $true)]
    [string]$output_path
)

# Retrieve the CLI executable name from environment variable
$cliExe = $env:UIPATH_CLI_EXECUTABLE_NAME

if (-not $cliExe) {
    Write-Error "Environment variable 'UIPATH_CLI_EXECUTABLE_NAME' is not set. Cannot proceed."
    exit 1
}

Write-Host "Starting UiPath Pack Script (using $cliExe)..."

if (-not (Get-Command $cliExe -ErrorAction SilentlyContinue)) {
    Write-Error "UiPath CLI executable '$cliExe' not found in PATH."
    exit 1
}

if (-not (Test-Path $project_path)) {
    Write-Error "Project file not found at path: $project_path"
    exit 1
}

# Ensure output directory exists
if (-not (Test-Path $output_path)) {
    Write-Host "Output directory does not exist. Creating: $output_path"
    New-Item -ItemType Directory -Path $output_path -Force | Out-Null
}

# Build the pack command arguments
$packArgs = @(
    "pack",
    "--file", "`"$project_path`"",
    "--output", "`"$output_path`""
)

# Run the CLI pack command
Write-Host "Running: $cliExe $($packArgs -join ' ')"

$packProcess = Start-Process -FilePath $cliExe -ArgumentList $packArgs -NoNewWindow -Wait -PassThru -ErrorAction Stop

if ($packProcess.ExitCode -ne 0) {
    Write-Error "UiPath Pack command failed with exit code $($packProcess.ExitCode)"
    exit $packProcess.ExitCode
} else {
    Write-Host "UiPath project packed successfully."
}
