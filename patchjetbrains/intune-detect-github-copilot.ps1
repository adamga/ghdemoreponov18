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