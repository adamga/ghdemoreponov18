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