##[debug]Evaluating condition for step: 'Verify UiPath CLI Contents and Version (Build Job)'
##[debug]Evaluating: success()
##[debug]Evaluating success:
##[debug]=> true
##[debug]Result: true
##[debug]Starting: Verify UiPath CLI Contents and Version (Build Job)
##[debug]Loading inputs
##[debug]Evaluating: format('Write-Host "Listing contents of UiPath CLI directory:"
##[debug]Get-ChildItem -Path "{0}\uipathcli" -Recurse -Force | Format-Table -AutoSize
##[debug]
##[debug]# Construct the full path to the executable explicitly
##[debug]$cli_dir = Join-Path "{1}" "uipathcli"
##[debug]$cli_full_path = Join-Path $cli_dir "uipath.exe" # Assuming uipath.exe is directly in uipathcli folder
##[debug]
##[debug]if (Test-Path $cli_full_path -PathType Leaf) {{ # Check if the file actually exists and is a file
##[debug]    Write-Host "UiPath CLI executable found at: $cli_full_path"
##[debug]    Write-Host "Running ''$cli_full_path --help'' to check commands..."
##[debug]    & "$cli_full_path" --help
##[debug]    Write-Host "Running ''$cli_full_path -v'' to check version..."
##[debug]    # The correct flag for version is often --version or -v in newer CLIs.
##[debug]    # Use a try-catch for -v as it previously indicated error.
##[debug]    try {{
##[debug]      & "$cli_full_path" -v
##[debug]    }} catch {{
##[debug]      Write-Host "Warning: ''$cli_full_path -v'' failed. Trying ''$cli_full_path --version''..."
##[debug]      & "$cli_full_path" --version
##[debug]    }}
##[debug]}} else {{
##[debug]    Write-Error "UiPath CLI executable ''uipath.exe'' not found at expected path: $cli_full_path"
##[debug]    exit 1
##[debug]}}
##[debug]', github.workspace, github.workspace)
##[debug]Evaluating format:
##[debug]..Evaluating String:
##[debug]..=> 'Write-Host "Listing contents of UiPath CLI directory:"
##[debug]Get-ChildItem -Path "{0}\uipathcli" -Recurse -Force | Format-Table -AutoSize
##[debug]
##[debug]# Construct the full path to the executable explicitly
##[debug]$cli_dir = Join-Path "{1}" "uipathcli"
##[debug]$cli_full_path = Join-Path $cli_dir "uipath.exe" # Assuming uipath.exe is directly in uipathcli folder
##[debug]
##[debug]if (Test-Path $cli_full_path -PathType Leaf) {{ # Check if the file actually exists and is a file
##[debug]    Write-Host "UiPath CLI executable found at: $cli_full_path"
##[debug]    Write-Host "Running ''$cli_full_path --help'' to check commands..."
##[debug]    & "$cli_full_path" --help
##[debug]    Write-Host "Running ''$cli_full_path -v'' to check version..."
##[debug]    # The correct flag for version is often --version or -v in newer CLIs.
##[debug]    # Use a try-catch for -v as it previously indicated error.
##[debug]    try {{
##[debug]      & "$cli_full_path" -v
##[debug]    }} catch {{
##[debug]      Write-Host "Warning: ''$cli_full_path -v'' failed. Trying ''$cli_full_path --version''..."
##[debug]      & "$cli_full_path" --version
##[debug]    }}
##[debug]}} else {{
##[debug]    Write-Error "UiPath CLI executable ''uipath.exe'' not found at expected path: $cli_full_path"
##[debug]    exit 1
##[debug]}}
##[debug]'
##[debug]..Evaluating Index:
##[debug]....Evaluating github:
##[debug]....=> Object
##[debug]....Evaluating String:
##[debug]....=> 'workspace'
##[debug]..=> 'D:\a\uipath-with-github-action\uipath-with-github-action'
##[debug]..Evaluating Index:
##[debug]....Evaluating github:
##[debug]....=> Object
##[debug]....Evaluating String:
##[debug]....=> 'workspace'
##[debug]..=> 'D:\a\uipath-with-github-action\uipath-with-github-action'
##[debug]=> 'Write-Host "Listing contents of UiPath CLI directory:"
##[debug]Get-ChildItem -Path "D:\a\uipath-with-github-action\uipath-with-github-action\uipathcli" -Recurse -Force | Format-Table -AutoSize
##[debug]
##[debug]# Construct the full path to the executable explicitly
##[debug]$cli_dir = Join-Path "D:\a\uipath-with-github-action\uipath-with-github-action" "uipathcli"
##[debug]$cli_full_path = Join-Path $cli_dir "uipath.exe" # Assuming uipath.exe is directly in uipathcli folder
##[debug]
##[debug]if (Test-Path $cli_full_path -PathType Leaf) { # Check if the file actually exists and is a file
##[debug]    Write-Host "UiPath CLI executable found at: $cli_full_path"
##[debug]    Write-Host "Running ''$cli_full_path --help'' to check commands..."
##[debug]    & "$cli_full_path" --help
##[debug]    Write-Host "Running ''$cli_full_path -v'' to check version..."
##[debug]    # The correct flag for version is often --version or -v in newer CLIs.
##[debug]    # Use a try-catch for -v as it previously indicated error.
##[debug]    try {
##[debug]      & "$cli_full_path" -v
##[debug]    } catch {
##[debug]      Write-Host "Warning: ''$cli_full_path -v'' failed. Trying ''$cli_full_path --version''..."
##[debug]      & "$cli_full_path" --version
##[debug]    }
##[debug]} else {
##[debug]    Write-Error "UiPath CLI executable ''uipath.exe'' not found at expected path: $cli_full_path"
##[debug]    exit 1
##[debug]}
##[debug]'
##[debug]Result: 'Write-Host "Listing contents of UiPath CLI directory:"
##[debug]Get-ChildItem -Path "D:\a\uipath-with-github-action\uipath-with-github-action\uipathcli" -Recurse -Force | Format-Table -AutoSize
##[debug]
##[debug]# Construct the full path to the executable explicitly
##[debug]$cli_dir = Join-Path "D:\a\uipath-with-github-action\uipath-with-github-action" "uipathcli"
##[debug]$cli_full_path = Join-Path $cli_dir "uipath.exe" # Assuming uipath.exe is directly in uipathcli folder
##[debug]
##[debug]if (Test-Path $cli_full_path -PathType Leaf) { # Check if the file actually exists and is a file
##[debug]    Write-Host "UiPath CLI executable found at: $cli_full_path"
##[debug]    Write-Host "Running ''$cli_full_path --help'' to check commands..."
##[debug]    & "$cli_full_path" --help
##[debug]    Write-Host "Running ''$cli_full_path -v'' to check version..."
##[debug]    # The correct flag for version is often --version or -v in newer CLIs.
##[debug]    # Use a try-catch for -v as it previously indicated error.
##[debug]    try {
##[debug]      & "$cli_full_path" -v
##[debug]    } catch {
##[debug]      Write-Host "Warning: ''$cli_full_path -v'' failed. Trying ''$cli_full_path --version''..."
##[debug]      & "$cli_full_path" --version
##[debug]    }
##[debug]} else {
##[debug]    Write-Error "UiPath CLI executable ''uipath.exe'' not found at expected path: $cli_full_path"
##[debug]    exit 1
##[debug]}
##[debug]'
##[debug]Loading env
Run Write-Host "Listing contents of UiPath CLI directory:"
##[debug]C:\Program Files\PowerShell\7\pwsh.EXE -command ". 'D:\a\_temp\25ed4946-42b4-44e7-9619-d419c5583bf6.ps1'"
Listing contents of UiPath CLI directory:

    Directory: D:\a\uipath-with-github-action\uipath-with-github-action\uipathcli

Mode        LastWriteTime   Length Name
----        -------------   ------ ----
-a---  7/27/2025 10:59 AM  9952177 uipath.cli.zip
-a---  6/24/2025  2:41 PM 20114944 uipath.exe

UiPath CLI executable found at: D:\a\uipath-with-github-action\uipath-with-github-action\uipathcli\uipath.exe
Running 'D:\a\uipath-with-github-action\uipath-with-github-action\uipathcli\uipath.exe --help' to check commands...
NAME:
   uipath - Command-Line Interface for UiPath Services

USAGE:
   uipath <service> <operation> --<argument> <value>

COMMANDS:
   du            Document Understanding
   identity      Identity Server
   orchestrator  UiPath Orchestrator
   studio        UiPath Studio
   autocomplete  Autocompletion
   config        Interactive Configuration

GLOBAL OPTIONS:
   --debug                  Enable debug output (default: false) [%UIPATH_DEBUG%]
   --profile value          Config profile to use (default: "default") [%UIPATH_PROFILE%]
   --uri value              Server Base-URI [%UIPATH_URI%]
   --organization value     Organization name [%UIPATH_ORGANIZATION%]
   --tenant value           Tenant name [%UIPATH_TENANT%]
   --insecure               Disable HTTPS certificate check (default: false) [%UIPATH_INSECURE%]
   --output value           Set output format: json (default), text [%UIPATH_OUTPUT%]
   --query value            Perform JMESPath query on output
   --wait value             Waits for the provided condition (JMESPath expression)
   --wait-timeout value     Time to wait in seconds for condition (default: 30)
   --file value             Provide input from file (use - for stdin)
   --identity-uri value     Identity Server URI [%UIPATH_IDENTITY_URI%]
   --service-version value  Specific service version [%UIPATH_SERVICE_VERSION%]
   --help, -h               show help
Running 'D:\a\uipath-with-github-action\uipath-with-github-action\uipathcli\uipath.exe -v' to check version...
Incorrect usage: flag provided but not defined: -v
Error: Process completed with exit code 1.
##[debug]Finishing: Verify UiPath CLI Contents and Version (Build Job)
