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
    OutputPath    = $OutputPath
    StagedFiles   = $stagedFiles.ToArray()
    ManifestPath  = $manifestPath
    IncludedReadme = [bool]$IncludeReadme
}