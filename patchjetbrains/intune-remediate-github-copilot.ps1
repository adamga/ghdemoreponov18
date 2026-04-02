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