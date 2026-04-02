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
    HarnessRoot         = $HarnessRoot
    PatcherExitCode     = $patcherExitCode
    ComplianceExitCode  = $complianceExitCode
    PatcherOutput       = $patcherOutput.Trim()
    ComplianceOutput    = $complianceOutput.Trim()
    BackupFilesCreated  = $backupMatches.Count
}