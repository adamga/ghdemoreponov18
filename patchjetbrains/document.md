# JetBrains GitHub Copilot Configuration Enforcement

## Preface

This document is the customer-facing handoff copy of the solution. It is intended for environments where the source files themselves are not being delivered directly.

Use this document as the canonical reconstruction guide.

Each script is included below with:

1. The intended file name.
2. The purpose of the script.
3. The full PowerShell source to place into that file.

This document does not reproduce the README. It reproduces the operational scripts that the README refers to.

## Chapter 1: Solution Overview

The solution is composed of five operational scripts and one local validation harness.

1. `patch-github-copilot.ps1`
   The main XML patcher.
2. `test-github-copilot-compliance.ps1`
   The compliance evaluator.
3. `intune-detect-github-copilot.ps1`
   The Intune detection wrapper.
4. `intune-remediate-github-copilot.ps1`
   The Intune remediation wrapper.
5. `package-intune-content.ps1`
   The content staging helper for Intune packaging.
6. `invoke-local-test-harness.ps1`
   The local validation harness used during development and testing.

## Chapter 2: Main Patcher

### File Name

`patch-github-copilot.ps1`

### Purpose

This is the core engine. It discovers JetBrains profile directories, loads or creates the target GitHub Copilot XML file, enforces the required settings, writes a patch log beside the changed file, optionally creates backups, and can mark the resulting config as read-only.

### Script Contents

```powershell
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$RootPath,
    [string]$TargetFileName = 'github-copilot.xml',
    [string]$LogFileName = 'github-copilot-patch.log',
    [switch]$CreateIfMissing,
    [switch]$Backup,
    [switch]$SkipIfJetBrainsRunning,
    [switch]$SetReadOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:ExitCodes = [ordered]@{
    Success       = 0
    Failure       = 1
    JetBrainsBusy = 2
}

function Get-DefaultJetBrainsRoot {
    if ($IsWindows) {
        return Join-Path $env:APPDATA 'JetBrains'
    }

    if ($IsMacOS) {
        return Join-Path $HOME 'Library/Application Support/JetBrains'
    }

    return Join-Path $HOME '.config/JetBrains'
}

if (-not $RootPath) {
    $RootPath = Get-DefaultJetBrainsRoot
}

function Get-ManagedSettings {
    return [ordered]@{
        signinNotificationShown = 'true'
        terminalRulesVersion    = '1'
        toolConfirmAutoApprove  = 'false'
        trustToolAnnotations    = 'false'
    }
}

function New-ResultRecord {
    param(
        [string]$Path,
        [string]$Status,
        [string]$Message,
        [string[]]$Actions = @(),
        [string]$BackupPath = '',
        [string]$LogPath = ''
    )

    return [pscustomobject]@{
        Path       = $Path
        Status     = $Status
        Message    = $Message
        Actions    = $Actions
        BackupPath = $BackupPath
        LogPath    = $LogPath
    }
}

function New-ElementResult {
    param(
        [object]$Element,
        [bool]$Changed,
        [string]$Action = ''
    )

    return [pscustomobject]@{
        Element = $Element
        Changed = $Changed
        Action  = $Action
    }
}

function Get-JetBrainsProcessNameSet {
    return @(
        'aqua',
        'clion',
        'dataspell',
        'datagrip',
        'goland',
        'idea',
        'idea64',
        'phpstorm',
        'pycharm',
        'pycharm64',
        'rider',
        'rubymine',
        'rustrover',
        'webstorm',
        'webstorm64',
        'wstorm64'
    )
}

function Test-JetBrainsRunning {
    $processNames = Get-JetBrainsProcessNameSet

    try {
        $running = Get-Process -ErrorAction Stop | Where-Object {
            $processNames -contains $_.ProcessName.ToLowerInvariant()
        }
    }
    catch {
        Write-Verbose "Unable to query running processes: $($_.Exception.Message)"
        return $false
    }

    return (@($running).Count -gt 0)
}

function Get-CandidateConfigPaths {
    param(
        [string]$RootPath,
        [string]$TargetFileName,
        [switch]$CreateIfMissing
    )

    if (-not (Test-Path -LiteralPath $RootPath -PathType Container)) {
        Write-Warning "JetBrains root not found: $RootPath"
        return @()
    }

    $candidates = New-Object System.Collections.Generic.List[string]
    $productDirectories = Get-ChildItem -LiteralPath $RootPath -Directory | Sort-Object Name

    foreach ($productDirectory in $productDirectories) {
        $optionsPath = Join-Path $productDirectory.FullName 'options'
        if (-not (Test-Path -LiteralPath $optionsPath -PathType Container)) {
            Write-Verbose "Skipping $($productDirectory.FullName): options directory missing"
            continue
        }

        $candidatePath = Join-Path $optionsPath $TargetFileName
        if ((Test-Path -LiteralPath $candidatePath -PathType Leaf) -or $CreateIfMissing) {
            $candidates.Add($candidatePath)
        }
        else {
            Write-Verbose "Skipping ${candidatePath}: target file missing and CreateIfMissing not set"
        }
    }

    return $candidates
}

function Get-OrCreateApplicationElement {
    param([xml]$XmlDocument)

    if ($XmlDocument.DocumentElement -and $XmlDocument.DocumentElement.Name -eq 'application') {
        return (New-ElementResult -Element $XmlDocument.DocumentElement -Changed $false)
    }

    $applicationElement = $XmlDocument.CreateElement('application')

    if ($XmlDocument.DocumentElement) {
        [void]$XmlDocument.ReplaceChild($applicationElement, $XmlDocument.DocumentElement)
    }
    else {
        [void]$XmlDocument.AppendChild($applicationElement)
    }

    return (New-ElementResult -Element $applicationElement -Changed $true -Action 'Created application root element')
}

function Get-OrCreateComponentElement {
    param(
        [xml]$XmlDocument,
        [System.Xml.XmlElement]$ApplicationElement,
        [string]$ComponentName
    )

    foreach ($component in $ApplicationElement.SelectNodes('./component')) {
        if ($component.GetAttribute('name') -eq $ComponentName) {
            return (New-ElementResult -Element $component -Changed $false)
        }
    }

    $componentElement = $XmlDocument.CreateElement('component')
    [void]$componentElement.SetAttribute('name', $ComponentName)
    [void]$ApplicationElement.AppendChild($componentElement)
    return (New-ElementResult -Element $componentElement -Changed $true -Action "Created component '$ComponentName'")
}

function Set-OptionElement {
    param(
        [xml]$XmlDocument,
        [System.Xml.XmlElement]$ComponentElement,
        [string]$OptionName,
        [string]$OptionValue
    )

    foreach ($option in $ComponentElement.SelectNodes('./option')) {
        if ($option.GetAttribute('name') -eq $OptionName) {
            $currentValue = $option.GetAttribute('value')
            if ($currentValue -ne $OptionValue) {
                [void]$option.SetAttribute('value', $OptionValue)
                return (New-ElementResult -Element $option -Changed $true -Action "Set option '$OptionName' from '$currentValue' to '$OptionValue'")
            }

            return (New-ElementResult -Element $option -Changed $false)
        }
    }

    $optionElement = $XmlDocument.CreateElement('option')
    [void]$optionElement.SetAttribute('name', $OptionName)
    [void]$optionElement.SetAttribute('value', $OptionValue)
    [void]$ComponentElement.AppendChild($optionElement)
    return (New-ElementResult -Element $optionElement -Changed $true -Action "Added option '$OptionName' with value '$OptionValue'")
}

function Ensure-TerminalAutoApproveElement {
    param(
        [xml]$XmlDocument,
        [System.Xml.XmlElement]$ComponentElement
    )

    $terminalNode = $null

    foreach ($child in $ComponentElement.ChildNodes) {
        if ($child.NodeType -eq [System.Xml.XmlNodeType]::Element -and $child.Name -eq 'terminalAutoApprove') {
            $terminalNode = $child
            break
        }
    }

    if (-not $terminalNode) {
        $terminalNode = $XmlDocument.CreateElement('terminalAutoApprove')
        [void]$ComponentElement.AppendChild($terminalNode)
        $mapElement = $XmlDocument.CreateElement('map')
        [void]$terminalNode.AppendChild($mapElement)
        return (New-ElementResult -Element $terminalNode -Changed $true -Action 'Created terminalAutoApprove/map structure')
    }

    $existingMapNodes = @($terminalNode.SelectNodes('./map'))
    if ($existingMapNodes.Count -eq 1 -and $terminalNode.ChildNodes.Count -eq 1 -and -not $existingMapNodes[0].HasAttributes -and -not $existingMapNodes[0].HasChildNodes) {
        return (New-ElementResult -Element $terminalNode -Changed $false)
    }

    $terminalNode.RemoveAll()
    $mapElement = $XmlDocument.CreateElement('map')
    [void]$terminalNode.AppendChild($mapElement)
    return (New-ElementResult -Element $terminalNode -Changed $true -Action 'Reset terminalAutoApprove to an empty map')
}

function Save-XmlDocument {
    param(
        [xml]$XmlDocument,
        [string]$Path
    )

    $settings = New-Object System.Xml.XmlWriterSettings
    $settings.Indent = $true
    $settings.IndentChars = '  '
    $settings.NewLineChars = [Environment]::NewLine
    $settings.NewLineHandling = [System.Xml.NewLineHandling]::Replace
    $settings.OmitXmlDeclaration = $true
    $settings.Encoding = New-Object System.Text.UTF8Encoding($false)

    $writer = [System.Xml.XmlWriter]::Create($Path, $settings)
    try {
        $XmlDocument.Save($writer)
    }
    finally {
        $writer.Dispose()
    }
}

function Test-FileReadOnly {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $false
    }

    return (Get-Item -LiteralPath $Path).IsReadOnly
}

function Set-FileReadOnlyState {
    param(
        [string]$Path,
        [bool]$ReadOnly
    )

    $item = Get-Item -LiteralPath $Path
    $item.IsReadOnly = $ReadOnly
}

function Write-PatchLog {
    param(
        [string]$Path,
        [string]$LogFileName,
        [string]$Status,
        [string[]]$Actions,
        [string]$BackupPath
    )

    $directoryPath = Split-Path -Parent $Path
    $logPath = Join-Path $directoryPath $LogFileName
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ssK'
    $actionText = if ($Actions.Count -gt 0) { $Actions -join '; ' } else { 'No XML changes required' }
    $backupText = if ($BackupPath) { " backup=$BackupPath" } else { '' }
    $entry = "[$timestamp] status=$Status target=$Path actions=$actionText$backupText"

    if ($PSCmdlet.ShouldProcess($logPath, 'Append patch audit log entry')) {
        Add-Content -LiteralPath $logPath -Value $entry
    }

    return $logPath
}

function Update-CopilotConfigFile {
    param(
        [string]$Path,
        [string]$LogFileName,
        [switch]$CreateIfMissing,
        [switch]$Backup,
        [switch]$SetReadOnly
    )

    $fileExists = Test-Path -LiteralPath $Path -PathType Leaf
    $created = $false
    $actions = New-Object System.Collections.Generic.List[string]
    $backupPath = ''
    $logPath = ''

    if ($fileExists) {
        Write-Verbose "Loading $Path"
        $rawXml = Get-Content -LiteralPath $Path -Raw
        $xmlDocument = New-Object System.Xml.XmlDocument
        try {
            $xmlDocument.LoadXml($rawXml)
        }
        catch {
            throw "Malformed XML: $($_.Exception.Message)"
        }
    }
    elseif ($CreateIfMissing) {
        Write-Verbose "Creating $Path"
        $xmlDocument = New-Object System.Xml.XmlDocument
        $xmlDocument.LoadXml('<application />')
        $created = $true
        $actions.Add('Created new config file')
    }
    else {
        return (New-ResultRecord -Path $Path -Status 'Skipped' -Message 'File does not exist. Use CreateIfMissing to create it.')
    }

    $changed = $created
    $applicationResult = Get-OrCreateApplicationElement -XmlDocument $xmlDocument
    if ($applicationResult.Changed) {
        $changed = $true
        $actions.Add($applicationResult.Action)
    }

    $componentResult = Get-OrCreateComponentElement -XmlDocument $xmlDocument -ApplicationElement $applicationResult.Element -ComponentName 'github-copilot'
    if ($componentResult.Changed) {
        $changed = $true
        $actions.Add($componentResult.Action)
    }

    foreach ($entry in (Get-ManagedSettings).GetEnumerator()) {
        $optionResult = Set-OptionElement -XmlDocument $xmlDocument -ComponentElement $componentResult.Element -OptionName $entry.Key -OptionValue $entry.Value
        if ($optionResult.Changed) {
            $changed = $true
            $actions.Add($optionResult.Action)
        }
    }

    $terminalResult = Ensure-TerminalAutoApproveElement -XmlDocument $xmlDocument -ComponentElement $componentResult.Element
    if ($terminalResult.Changed) {
        $changed = $true
        $actions.Add($terminalResult.Action)
    }

    if (-not $changed) {
        return (New-ResultRecord -Path $Path -Status 'Unchanged' -Message 'Already compliant.')
    }

    $restoreReadOnly = $false
    if ($fileExists -and (Test-FileReadOnly -Path $Path)) {
        $restoreReadOnly = $true
        if ($PSCmdlet.ShouldProcess($Path, 'Clear read-only attribute for update')) {
            Set-FileReadOnlyState -Path $Path -ReadOnly $false
        }
    }

    if ($Backup -and $fileExists) {
        $backupPath = '{0}.{1}.bak' -f $Path, (Get-Date -Format 'yyyyMMddHHmmss')
        if ($PSCmdlet.ShouldProcess($Path, "Create backup $backupPath")) {
            Copy-Item -LiteralPath $Path -Destination $backupPath -Force
        }
        $actions.Add("Created backup '$backupPath'")
    }

    if ($PSCmdlet.ShouldProcess($Path, 'Write GitHub Copilot configuration')) {
        Save-XmlDocument -XmlDocument $xmlDocument -Path $Path
    }

    if ($SetReadOnly -or $restoreReadOnly) {
        if ($PSCmdlet.ShouldProcess($Path, 'Set read-only attribute')) {
            Set-FileReadOnlyState -Path $Path -ReadOnly $true
        }
        $actions.Add('Set file to read-only')
    }

    $status = if ($created) { 'Created' } else { 'Updated' }
    $message = if ($created) { 'Created and updated file.' } else { 'Updated existing file.' }
    $logPath = Write-PatchLog -Path $Path -LogFileName $LogFileName -Status $status -Actions $actions.ToArray() -BackupPath $backupPath

    return (New-ResultRecord -Path $Path -Status $status -Message $message -Actions $actions.ToArray() -BackupPath $backupPath -LogPath $logPath)
}

$results = New-Object System.Collections.Generic.List[object]
$exitCode = $script:ExitCodes.Success

if ($SkipIfJetBrainsRunning -and (Test-JetBrainsRunning)) {
    Write-Warning 'JetBrains IDE process detected. No files were modified.'
    $summary = [pscustomobject]@{
        RootPath       = $RootPath
        TargetFileName = $TargetFileName
        Scanned        = 0
        Created        = 0
        Updated        = 0
        Unchanged      = 0
        Skipped        = 0
        Failed         = 0
        ExitCode       = $script:ExitCodes.JetBrainsBusy
    }
    $summary
    exit $script:ExitCodes.JetBrainsBusy
}

$candidatePaths = Get-CandidateConfigPaths -RootPath $RootPath -TargetFileName $TargetFileName -CreateIfMissing:$CreateIfMissing

foreach ($candidatePath in $candidatePaths) {
    try {
        $results.Add((Update-CopilotConfigFile -Path $candidatePath -LogFileName $LogFileName -CreateIfMissing:$CreateIfMissing -Backup:$Backup -SetReadOnly:$SetReadOnly))
    }
    catch {
        $results.Add((New-ResultRecord -Path $candidatePath -Status 'Failed' -Message $_.Exception.Message))
    }
}

$failedCount = @($results | Where-Object Status -eq 'Failed').Count
if ($failedCount -gt 0) {
    $exitCode = $script:ExitCodes.Failure
}

$summary = [pscustomobject]@{
    RootPath        = $RootPath
    TargetFileName  = $TargetFileName
    Scanned         = $candidatePaths.Count
    Created         = @($results | Where-Object Status -eq 'Created').Count
    Updated         = @($results | Where-Object Status -eq 'Updated').Count
    Unchanged       = @($results | Where-Object Status -eq 'Unchanged').Count
    Skipped         = @($results | Where-Object Status -eq 'Skipped').Count
    Failed          = $failedCount
    ExitCode        = $exitCode
}

$results
$summary

exit $exitCode
```

## Chapter 3: Compliance Checker

### File Name

`test-github-copilot-compliance.ps1`

### Purpose

This script evaluates each discovered target file and returns a compliant or non-compliant result. It is the authoritative checker used by both the direct deployment flow and the Intune detection wrapper.

### Script Contents

```powershell
[CmdletBinding()]
param(
    [string]$RootPath,
    [string]$TargetFileName = 'github-copilot.xml'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-DefaultJetBrainsRoot {
    if ($IsWindows) {
        return Join-Path $env:APPDATA 'JetBrains'
    }

    if ($IsMacOS) {
        return Join-Path $HOME 'Library/Application Support/JetBrains'
    }

    return Join-Path $HOME '.config/JetBrains'
}

if (-not $RootPath) {
    $RootPath = Get-DefaultJetBrainsRoot
}

function Get-ManagedSettings {
    return [ordered]@{
        signinNotificationShown = 'true'
        terminalRulesVersion    = '1'
        toolConfirmAutoApprove  = 'false'
        trustToolAnnotations    = 'false'
    }
}

function New-ComplianceRecord {
    param(
        [string]$Path,
        [string]$Status,
        [string]$Message
    )

    return [pscustomobject]@{
        Path    = $Path
        Status  = $Status
        Message = $Message
    }
}

function Get-ExpectedConfigPaths {
    param(
        [string]$RootPath,
        [string]$TargetFileName
    )

    if (-not (Test-Path -LiteralPath $RootPath -PathType Container)) {
        Write-Warning "JetBrains root not found: $RootPath"
        return @()
    }

    $candidates = New-Object System.Collections.Generic.List[string]
    $productDirectories = Get-ChildItem -LiteralPath $RootPath -Directory | Sort-Object Name

    foreach ($productDirectory in $productDirectories) {
        $optionsPath = Join-Path $productDirectory.FullName 'options'
        if (-not (Test-Path -LiteralPath $optionsPath -PathType Container)) {
            continue
        }

        $candidates.Add((Join-Path $optionsPath $TargetFileName))
    }

    return $candidates
}

function Test-ConfigCompliance {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return (New-ComplianceRecord -Path $Path -Status 'NonCompliant' -Message 'Target file is missing.')
    }

    $xmlDocument = New-Object System.Xml.XmlDocument
    try {
        $xmlDocument.LoadXml((Get-Content -LiteralPath $Path -Raw))
    }
    catch {
        return (New-ComplianceRecord -Path $Path -Status 'NonCompliant' -Message "Malformed XML: $($_.Exception.Message)")
    }

    if (-not $xmlDocument.DocumentElement -or $xmlDocument.DocumentElement.Name -ne 'application') {
        return (New-ComplianceRecord -Path $Path -Status 'NonCompliant' -Message 'Root application element is missing.')
    }

    $component = $null
    foreach ($node in $xmlDocument.DocumentElement.SelectNodes('./component')) {
        if ($node.GetAttribute('name') -eq 'github-copilot') {
            $component = $node
            break
        }
    }

    if (-not $component) {
        return (New-ComplianceRecord -Path $Path -Status 'NonCompliant' -Message 'github-copilot component is missing.')
    }

    foreach ($entry in (Get-ManagedSettings).GetEnumerator()) {
        $matchingOption = $null
        foreach ($option in $component.SelectNodes('./option')) {
            if ($option.GetAttribute('name') -eq $entry.Key) {
                $matchingOption = $option
                break
            }
        }

        if (-not $matchingOption) {
            return (New-ComplianceRecord -Path $Path -Status 'NonCompliant' -Message "Missing option '$($entry.Key)'.")
        }

        if ($matchingOption.GetAttribute('value') -ne $entry.Value) {
            return (New-ComplianceRecord -Path $Path -Status 'NonCompliant' -Message "Option '$($entry.Key)' has value '$($matchingOption.GetAttribute('value'))' instead of '$($entry.Value)'.")
        }
    }

    $terminalNode = $component.SelectSingleNode('./terminalAutoApprove')
    if (-not $terminalNode) {
        return (New-ComplianceRecord -Path $Path -Status 'NonCompliant' -Message 'terminalAutoApprove node is missing.')
    }

    $mapNodes = @($terminalNode.SelectNodes('./map'))
    if ($mapNodes.Count -ne 1 -or $terminalNode.ChildNodes.Count -ne 1 -or $mapNodes[0].HasAttributes -or $mapNodes[0].HasChildNodes) {
        return (New-ComplianceRecord -Path $Path -Status 'NonCompliant' -Message 'terminalAutoApprove must contain exactly one empty map node.')
    }

    return (New-ComplianceRecord -Path $Path -Status 'Compliant' -Message 'File is compliant.')
}

$results = New-Object System.Collections.Generic.List[object]
$candidatePaths = Get-ExpectedConfigPaths -RootPath $RootPath -TargetFileName $TargetFileName

foreach ($candidatePath in $candidatePaths) {
    $results.Add((Test-ConfigCompliance -Path $candidatePath))
}

$nonCompliantCount = @($results | Where-Object Status -eq 'NonCompliant').Count
$exitCode = if ($nonCompliantCount -gt 0) { 1 } else { 0 }

$summary = [pscustomobject]@{
    RootPath       = $RootPath
    TargetFileName = $TargetFileName
    Evaluated      = $candidatePaths.Count
    Compliant      = @($results | Where-Object Status -eq 'Compliant').Count
    NonCompliant   = $nonCompliantCount
    ExitCode       = $exitCode
}

$results
$summary

exit $exitCode
```

## Chapter 4: Intune Detection Wrapper

### File Name

`intune-detect-github-copilot.ps1`

### Purpose

This is the small wrapper intended for the Intune detection slot. It delegates to the compliance checker and preserves the same exit code behavior.

### Script Contents

```powershell
[CmdletBinding()]
param(
    [string]$RootPath,
    [string]$TargetFileName = 'github-copilot.xml'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$complianceScript = Join-Path $PSScriptRoot 'test-github-copilot-compliance.ps1'

if (-not (Test-Path -LiteralPath $complianceScript -PathType Leaf)) {
    Write-Error "Compliance script not found: $complianceScript"
    exit 1
}

$parameters = @{
    TargetFileName = $TargetFileName
}

if ($RootPath) {
    $parameters.RootPath = $RootPath
}

& $complianceScript @parameters
exit $LASTEXITCODE
```

## Chapter 5: Intune Remediation Wrapper

### File Name

`intune-remediate-github-copilot.ps1`

### Purpose

This is the remediation wrapper intended for the Intune remediation slot. It checks compliance first, skips unnecessary patching when already compliant, invokes the main patcher only when needed, and then re-checks compliance before returning a final result.

### Script Contents

```powershell
[CmdletBinding()]
param(
    [string]$RootPath,
    [string]$TargetFileName = 'github-copilot.xml',
    [string]$LogFileName = 'github-copilot-patch.log',
    [switch]$CreateIfMissing,
    [switch]$Backup,
    [switch]$SkipIfJetBrainsRunning,
    [switch]$SetReadOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$complianceScript = Join-Path $PSScriptRoot 'test-github-copilot-compliance.ps1'
$patcherScript = Join-Path $PSScriptRoot 'patch-github-copilot.ps1'

if (-not (Test-Path -LiteralPath $complianceScript -PathType Leaf)) {
    Write-Error "Compliance script not found: $complianceScript"
    exit 1
}

if (-not (Test-Path -LiteralPath $patcherScript -PathType Leaf)) {
    Write-Error "Patcher script not found: $patcherScript"
    exit 1
}

$commonParameters = @{
    TargetFileName = $TargetFileName
}

if ($RootPath) {
    $commonParameters.RootPath = $RootPath
}

& $complianceScript @commonParameters
$initialComplianceExitCode = $LASTEXITCODE

if ($initialComplianceExitCode -eq 0) {
    Write-Host 'JetBrains GitHub Copilot config is already compliant. No remediation needed.'
    exit 0
}

$patchParameters = @{
    TargetFileName = $TargetFileName
    LogFileName = $LogFileName
    CreateIfMissing = $CreateIfMissing
    Backup = $Backup
    SkipIfJetBrainsRunning = $SkipIfJetBrainsRunning
    SetReadOnly = $SetReadOnly
}

if ($RootPath) {
    $patchParameters.RootPath = $RootPath
}

& $patcherScript @patchParameters
$patchExitCode = $LASTEXITCODE

if ($patchExitCode -eq 2) {
    Write-Error 'JetBrains IDE appears to be running. Remediation was skipped.'
    exit 2
}

if ($patchExitCode -ne 0) {
    Write-Warning "Patcher returned exit code $patchExitCode. Re-running compliance to determine final state."
}

& $complianceScript @commonParameters
$finalComplianceExitCode = $LASTEXITCODE

if ($finalComplianceExitCode -eq 0) {
    Write-Host 'JetBrains GitHub Copilot config is compliant after remediation.'
    exit 0
}

Write-Error 'JetBrains GitHub Copilot config remains non-compliant after remediation.'
exit 1
```

## Chapter 6: Packaging Helper

### File Name

`package-intune-content.ps1`

### Purpose

This helper stages the four deployment scripts into a clean Intune content folder and writes a manifest. It is meant for internal packaging and operational handoff, not for endpoint execution.

### Script Contents

```powershell
[CmdletBinding()]
param(
    [string]$OutputPath = (Join-Path $PSScriptRoot 'dist\intune-content'),
    [switch]$Clean,
    [switch]$IncludeReadme
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$filesToStage = @(
    'patch-github-copilot.ps1',
    'test-github-copilot-compliance.ps1',
    'intune-detect-github-copilot.ps1',
    'intune-remediate-github-copilot.ps1'
)

if ($Clean -and (Test-Path -LiteralPath $OutputPath)) {
    Remove-Item -LiteralPath $OutputPath -Recurse -Force
}

$null = New-Item -ItemType Directory -Path $OutputPath -Force

$stagedFiles = New-Object System.Collections.Generic.List[string]

foreach ($fileName in $filesToStage) {
    $sourcePath = Join-Path $PSScriptRoot $fileName
    if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
        throw "Required file not found: $sourcePath"
    }

    $destinationPath = Join-Path $OutputPath $fileName
    Copy-Item -LiteralPath $sourcePath -Destination $destinationPath -Force
    $stagedFiles.Add($destinationPath)
}

if ($IncludeReadme) {
    $readmeSource = Join-Path $PSScriptRoot 'README.md'
    if (Test-Path -LiteralPath $readmeSource -PathType Leaf) {
        Copy-Item -LiteralPath $readmeSource -Destination (Join-Path $OutputPath 'README.md') -Force
    }
}

$manifestPath = Join-Path $OutputPath 'package-manifest.txt'
$manifestLines = @(
    "Created: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ssK')",
    "Source: $PSScriptRoot",
    'Files:'
)

foreach ($fileName in $filesToStage) {
    $manifestLines += "- $fileName"
}

if ($IncludeReadme) {
    $manifestLines += '- README.md'
}

Set-Content -LiteralPath $manifestPath -Value $manifestLines

[pscustomobject]@{
    OutputPath     = $OutputPath
    StagedFiles    = $stagedFiles.ToArray()
    ManifestPath   = $manifestPath
    IncludedReadme = [bool]$IncludeReadme
}
```

## Chapter 7: Local Validation Harness

### File Name

`invoke-local-test-harness.ps1`

### Purpose

This is the internal validation harness used to prove the patcher and compliance flow against isolated local test data. It covers missing files, partial settings, malformed XML, backup creation, read-only enforcement, and compliance return codes.

### Script Contents

```powershell
[CmdletBinding()]
param(
    [string]$PatcherPath = (Join-Path $PSScriptRoot 'patch-github-copilot.ps1'),
    [string]$CompliancePath = (Join-Path $PSScriptRoot 'test-github-copilot-compliance.ps1'),
    [string]$HarnessRoot = (Join-Path $PSScriptRoot 'local-test\harness')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-Condition {
    param(
        [bool]$Condition,
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Get-XmlOptionValue {
    param(
        [string]$Path,
        [string]$OptionName
    )

    $xmlDocument = New-Object System.Xml.XmlDocument
    $xmlDocument.LoadXml((Get-Content -LiteralPath $Path -Raw))
    foreach ($option in $xmlDocument.SelectNodes('/application/component[@name="github-copilot"]/option')) {
        if ($option.GetAttribute('name') -eq $OptionName) {
            return $option.GetAttribute('value')
        }
    }

    return $null
}

if (Test-Path -LiteralPath $HarnessRoot) {
    Remove-Item -LiteralPath $HarnessRoot -Recurse -Force
}

$paths = @(
    (Join-Path $HarnessRoot 'PyCharm2025.1\options'),
    (Join-Path $HarnessRoot 'WebStorm2024.3\options'),
    (Join-Path $HarnessRoot 'GoLand2024.2\options'),
    (Join-Path $HarnessRoot 'Rider2025.1\options')
)

foreach ($path in $paths) {
    $null = New-Item -ItemType Directory -Path $path -Force
}

$partialFile = Join-Path $HarnessRoot 'WebStorm2024.3\options\github2.copilot.xml'
$backupFile = Join-Path $HarnessRoot 'GoLand2024.2\options\github2.copilot.xml'
$malformedFile = Join-Path $HarnessRoot 'Rider2025.1\options\github2.copilot.xml'

Set-Content -LiteralPath $partialFile -Value @'
<application>
  <component name="github-copilot">
    <option name="signinNotificationShown" value="false" />
  </component>
</application>
'@

Set-Content -LiteralPath $backupFile -Value @'
<application>
  <component name="github-copilot">
    <option name="signinNotificationShown" value="false" />
    <option name="terminalRulesVersion" value="2" />
  </component>
</application>
'@

Set-Content -LiteralPath $malformedFile -Value '<application><component name="github-copilot"></application>'

$patcherOutput = & pwsh -NoProfile -File $PatcherPath -RootPath $HarnessRoot -TargetFileName 'github2.copilot.xml' -CreateIfMissing -Backup -SetReadOnly 2>&1 | Out-String
$patcherExitCode = $LASTEXITCODE

$createdFile = Join-Path $HarnessRoot 'PyCharm2025.1\options\github2.copilot.xml'
$createdLog = Join-Path $HarnessRoot 'PyCharm2025.1\options\github-copilot-patch.log'
$updatedLog = Join-Path $HarnessRoot 'WebStorm2024.3\options\github-copilot-patch.log'
$backupLog = Join-Path $HarnessRoot 'GoLand2024.2\options\github-copilot-patch.log'

Assert-Condition ($patcherExitCode -eq 1) 'Patcher should return exit code 1 when at least one malformed file fails.'
Assert-Condition (Test-Path -LiteralPath $createdFile -PathType Leaf) 'Missing file test case was not created.'
Assert-Condition ((Get-XmlOptionValue -Path $createdFile -OptionName 'signinNotificationShown') -eq 'true') 'Created file is missing the required signinNotificationShown value.'
Assert-Condition ((Get-XmlOptionValue -Path $partialFile -OptionName 'toolConfirmAutoApprove') -eq 'false') 'Partial file was not normalized.'
Assert-Condition ((Get-Item -LiteralPath $createdFile).IsReadOnly) 'Created file was not marked read-only.'
Assert-Condition ((Get-Item -LiteralPath $partialFile).IsReadOnly) 'Updated file was not marked read-only.'
Assert-Condition ((Get-Item -LiteralPath $backupFile).IsReadOnly) 'Backup test target was not marked read-only.'
Assert-Condition (Test-Path -LiteralPath $createdLog -PathType Leaf) 'Patch log was not created beside the created file.'
Assert-Condition (Test-Path -LiteralPath $updatedLog -PathType Leaf) 'Patch log was not created beside the updated file.'
Assert-Condition (Test-Path -LiteralPath $backupLog -PathType Leaf) 'Patch log was not created beside the backup test file.'
Assert-Condition ((Get-Content -LiteralPath $backupLog -Raw) -match 'Created backup') 'Patch log does not record backup creation.'
Assert-Condition ((Get-Content -LiteralPath $createdLog -Raw) -match 'Set file to read-only') 'Patch log does not record read-only enforcement.'
Assert-Condition (-not (Test-Path -LiteralPath (Join-Path $HarnessRoot 'Rider2025.1\options\github-copilot-patch.log') -PathType Leaf)) 'Malformed XML case should not create a patch log.'

$backupMatches = @(Get-ChildItem -LiteralPath (Split-Path -Parent $backupFile) -Filter 'github2.copilot.xml.*.bak')
Assert-Condition ($backupMatches.Count -ge 1) 'Backup file was not created for the backup test case.'

$complianceOutput = & pwsh -NoProfile -File $CompliancePath -RootPath $HarnessRoot -TargetFileName 'github2.copilot.xml' 2>&1 | Out-String
$complianceExitCode = $LASTEXITCODE
Assert-Condition ($complianceExitCode -eq 1) 'Compliance script should report non-compliance because the malformed file remains.'

[pscustomobject]@{
    HarnessRoot        = $HarnessRoot
    PatcherExitCode    = $patcherExitCode
    ComplianceExitCode = $complianceExitCode
    PatcherOutput      = $patcherOutput.Trim()
    ComplianceOutput   = $complianceOutput.Trim()
    BackupFilesCreated = $backupMatches.Count
}
```

## Chapter 8: Reconstruction Order

For a customer rebuild, create the files in this order:

1. `patch-github-copilot.ps1`
2. `test-github-copilot-compliance.ps1`
3. `intune-detect-github-copilot.ps1`
4. `intune-remediate-github-copilot.ps1`
5. `package-intune-content.ps1`
6. `invoke-local-test-harness.ps1`

The Intune wrappers depend on the patcher and compliance script being in the same folder.

## Chapter 9: Customer Build Checklist

Use this checklist after copying the script contents from this document into individual `.ps1` files.

### Files To Create First

Create these files in the same working folder and use these exact file names:

1. `patch-github-copilot.ps1`
2. `test-github-copilot-compliance.ps1`
3. `intune-detect-github-copilot.ps1`
4. `intune-remediate-github-copilot.ps1`
5. `package-intune-content.ps1`
6. `invoke-local-test-harness.ps1`

### Initial Validation Commands

Run these commands from the folder that contains the recreated files.

1. Validate the local harness:

```powershell
pwsh -File .\invoke-local-test-harness.ps1
```

Expected result:

1. The harness creates an isolated local test tree.
2. The patcher runs against `github2.copilot.xml`, not the production file name.
3. The harness reports a nonzero patcher exit because the malformed XML test case is intentionally preserved.
4. The harness completes without throwing an assertion failure.

2. Stage the Intune deployment content:

```powershell
pwsh -File .\package-intune-content.ps1 -Clean -IncludeReadme
```

Expected result:

1. A `dist\intune-content` folder is created.
2. The four deployment scripts are copied into that folder.
3. A `package-manifest.txt` file is created.

3. Validate Intune detection/remediation flow against a safe local target:

```powershell
pwsh -File .\intune-detect-github-copilot.ps1 -RootPath .\local-test\intune -TargetFileName github2.copilot.xml
pwsh -File .\intune-remediate-github-copilot.ps1 -RootPath .\local-test\intune -TargetFileName github2.copilot.xml -CreateIfMissing -Backup -SetReadOnly
pwsh -File .\intune-detect-github-copilot.ps1 -RootPath .\local-test\intune -TargetFileName github2.copilot.xml
```

Expected result:

1. The first detection run reports non-compliance if the local test target is missing or incorrect.
2. The remediation run creates or patches only `github2.copilot.xml` in the local test tree.
3. The final detection run reports compliance.

### Production Readiness Check

Before customer rollout, confirm these items:

1. The scripts all exist in one folder.
2. The local harness ran successfully.
3. The packaging script produced the Intune content folder.
4. The remediation wrapper was tested with `github2.copilot.xml` before switching to `github-copilot.xml`.
5. Intune will run the scripts in user context, not system context.

## Chapter 10: Closing Notes

This document is designed so the customer can reconstruct the full script set without receiving the script files directly.

Operationally, the most important scripts are:

1. `patch-github-copilot.ps1`
2. `test-github-copilot-compliance.ps1`
3. `intune-detect-github-copilot.ps1`
4. `intune-remediate-github-copilot.ps1`

The packaging script and test harness are supporting tools for internal staging and validation.