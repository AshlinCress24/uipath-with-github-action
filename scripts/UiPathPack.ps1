<#
.SYNOPSIS
    Pack project into a NuGet package

.DESCRIPTION
    This script is to pack a project into a NuGet package files (*.nupkg).

.PARAMETER project_path
    Required. Path to a project.json file or a folder containing project.json files.

.PARAMETER destination_folder
    Required. Destination folder.

.PARAMETER libraryOrchestratorUrl
    (Optional, useful only for libraries) The Orchestrator URL.

.PARAMETER libraryOrchestratorTenant
    (Optional, useful only for libraries) The Orchestrator tenant.

.PARAMETER libraryOrchestratorUsername
    (Optional, useful only for libraries) The Orchestrator password used for authentication. Must be used together with the username.

.PARAMETER libraryOrchestratorPassword
    (Optional, useful only for libraries) The Orchestrator username used for authentication. Must be used together with the password.

.PARAMETER libraryOrchestratorUserKey
    (Optional, useful only for libraries) The Orchestrator OAuth2 refresh token used for authentication. Must be used together with the account name and client id.

.PARAMETER libraryOrchestratorAccountName
    (Optional, useful only for libraries) The Orchestrator CloudRPA account name. Must be used together with the refresh token and client id.

.PARAMETER libraryOrchestratorFolder
    (Optional, useful only for libraries) The Orchestrator folder (organization unit).

.PARAMETER version
    Package version.

.PARAMETER autoVersion
    Auto-generate package version.

.PARAMETER outputType
    Force the output to a specific type. <Process|Library|Tests|Objects>

.PARAMETER language
    The orchestrator language.

.PARAMETER disableTelemetry
    Disable telemetry data.

.EXAMPLE
SYNTAX:
    .\UiPathPack.ps1 <project_path> -destination_folder <destination_folder> [-version <version>] [-autoVersion] [--outputType <Process|Library|Tests|Objects>] [--libraryOrchestratorUrl <orchestrator_url> --libraryOrchestratorTenant <orchestrator_tenant>] [--libraryOrchestratorUsername <orchestrator_user> --libraryOrchestratorPassword <orchestrator_pass>] [--libraryOrchestratorUserKey <UserKey> --libraryOrchestratorAccountName <account_name>] [--libraryOrchestratorFolder <folder>] [-language <language>]

Examples:
    package pack "C:\UiPath\Project\project.json" -destination_folder "C:\UiPath\Package"
    package pack "C:\UiPath\Project\project.json" -destination_folder "C:\UiPath\Package" -version 1.0.6820.22047
    package pack "C:\UiPath\Project\project.json" -destination_folder "C:\UiPath\Package" -autoVersion
    package pack "C:\UiPath\Project" -destination_folder "C:\UiPath\Package"
    package pack "C:\UiPath\Project\project.json" -destination_folder "C:\UiPath\Package" --outputType Tests -language en-US
#>
Param (
    #Required
    [string] $project_path = "", # Required. Path to a project.json file or a folder containing project.json files.
    [string] $destination_folder = "", #Required. Destination folder.
    [string] $libraryOrchestratorUrl = "", #Optional, useful only for libraries) The Orchestrator URL.
    [string] $libraryOrchestratorTenant = "", #(Optional, useful only for libraries) The Orchestrator tenant.

    #cloud - Required
    [string] $libraryOrchestratorAccountName = "", #(Optional, useful only for libraries) The Orchestrator URL.
    [string] $libraryOrchestratorUserKey = "", #Required. The Orchestrator OAuth2 refresh token used for authentication. Must be used together with the account name and client id.
    
    #On prem - Required
    [string] $libraryOrchestratorUsername = "", #Required. The Orchestrator username used for authentication. Must be used together with the password.
    [string] $libraryOrchestratorPassword = "", #Required. The Orchestrator password used for authentication. Must be used together with the username.
    
    [string] $libraryOrchestratorFolder = "", #Optional, useful only for libraries) The Orchestrator folder (organization unit).
    [string] $language = "", #The orchestrator language.
    [string] $version = "", #Package version.
    [switch] $autoVersion, #Auto-generate package version.
    [string] $outputType = "", #Force the output to a specific type.
    [switch] $disableTelemetry #Disable telemetry data. Changed to switch type for boolean flag
)

function WriteLog
{
    Param ($message, [switch] $err)
    
    $now = Get-Date -Format "G"
    $line = "$now`t$message"
    $line | Add-Content $debugLog -Encoding UTF8
    if ($err)
    {
        Write-Host $line -ForegroundColor red
    } else {
        Write-Host $line
    }
}

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$debugLog = "$scriptPath\orchestrator-package-pack.log"

# --- REMOVED MANUAL CLI DOWNLOAD LOGIC ---
# Rely on UiPath/setup-uipath-cli@v1 GitHub Action to install the CLI and add it to PATH.
$uipathCLI = "uipath" # Changed to just 'uipath' as it should be in PATH
WriteLog "-----------------------------------------------------------------------------"
WriteLog "uipath CLI will be invoked from PATH."

# --- Parameter Validation ---
if($project_path -eq "" -or $destination_folder -eq "")
{
    WriteLog "Error: Missing required parameters: project_path and destination_folder." -err
    exit 1
}

# Building uipath cli parameters
$ParamList = New-Object 'Collections.Generic.List[string]'
$ParamList.Add("package")
$ParamList.Add("pack")
$ParamList.Add($project_path)
$ParamList.Add("-o")
$ParamList.Add($destination_folder)

# Add optional parameters if they are provided
if ($libraryOrchestratorUrl -ne ""){
    $ParamList.Add("--libraryOrchestratorUrl")
    $ParamList.Add($libraryOrchestratorUrl)
}
if ($libraryOrchestratorTenant -ne ""){
    $ParamList.Add("--libraryOrchestratorTenant")
    $ParamList.Add($libraryOrchestratorTenant)
}
if ($libraryOrchestratorAccountName -ne ""){
    $ParamList.Add("--libraryOrchestratorAccountName")
    $ParamList.Add($libraryOrchestratorAccountName)
}
if ($libraryOrchestratorUserKey -ne ""){
    $ParamList.Add("--libraryOrchestratorAuthToken") # Corrected parameter name from UiPath docs
    $ParamList.Add($libraryOrchestratorUserKey)
}
if ($libraryOrchestratorUsername -ne ""){
    $ParamList.Add("--libraryOrchestratorUsername")
    $ParamList.Add($libraryOrchestratorUsername)
}
if ($libraryOrchestratorPassword -ne ""){
    $ParamList.Add("--libraryOrchestratorPassword")
    $ParamList.Add($libraryOrchestratorPassword)
}
if ($libraryOrchestratorFolder -ne ""){
    $ParamList.Add("--libraryOrchestratorFolder")
    $ParamList.Add($libraryOrchestratorFolder)
}
if ($language -ne ""){
    $ParamList.Add("-l") # Confirm if -l is supported for 'pack' command
    $ParamList.Add($language)
}
if ($version -ne ""){
    $ParamList.Add("-v")
    $ParamList.Add($version)
}
if ($PSBoundParameters.ContainsKey('autoVersion')) {
    $ParamList.Add("--autoVersion")
}
if ($outputType -ne ""){
    $ParamList.Add("--outputType")
    $ParamList.Add($outputType)
}
if ($PSBoundParameters.ContainsKey('disableTelemetry')) { # Check for switch parameter presence
    $ParamList.Add("--telemetry-opt-out") # Corrected telemetry flag
}

# Mask sensitive info before logging
$ParamMask = New-Object 'Collections.Generic.List[string]'
$ParamMask.AddRange($ParamList)
$secretIndex = $ParamMask.IndexOf("--libraryOrchestratorPassword")
if ($secretIndex -ge 0){
    $ParamMask[$secretIndex + 1] = ("*" * 8) # Mask just a generic 8 stars
}
$secretIndex = $ParamMask.IndexOf("--libraryOrchestratorAuthToken")
if ($secretIndex -ge 0){
    $ParamMask[$secretIndex + 1] = ("*" * 8) # Mask just a generic 8 stars
}

# Log cli call with parameters
WriteLog "Executing $uipathCLI $($ParamMask -join ' ')"

# Call uipath cli
& "$uipathCLI" $ParamList.ToArray()

if($LASTEXITCODE -eq 0)
{
    WriteLog "Done! Package(s) destination folder is : $destination_folder"
    Exit 0
} else {
    WriteLog "Unable to Pack project. Exit code $LASTEXITCODE" -err
    Exit 1
}
