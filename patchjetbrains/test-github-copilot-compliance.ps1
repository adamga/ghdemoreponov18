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