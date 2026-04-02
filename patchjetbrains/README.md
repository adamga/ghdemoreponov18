# JetBrains GitHub Copilot Intune Deployment

This folder contains a small PowerShell-based deployment set for enforcing GitHub Copilot XML settings across JetBrains IDE profiles.

Customer handoff note:

If you are delivering this solution as documentation instead of shipping the script files directly, all operational scripts in this README are reproduced in `document.md`. The customer can recreate the files from that document.

Files

1. `patch-github-copilot.ps1`
   Main patcher. Discovers JetBrains profile directories, updates the target XML, optionally creates backups, writes a per-folder audit log, and can mark the config file read-only.
2. `test-github-copilot-compliance.ps1`
   Core compliance check. Evaluates all discovered target files and exits `0` when compliant or `1` when any target is missing, malformed, or mismatched.
3. `intune-detect-github-copilot.ps1`
   Intune detection wrapper. Calls the compliance script and returns the same exit code.
4. `intune-remediate-github-copilot.ps1`
   Intune remediation wrapper. Runs compliance first, exits immediately if already compliant, otherwise runs the patcher and rechecks compliance before returning.
5. `package-intune-content.ps1`
   Packaging helper. Stages the four deployment PowerShell files into a clean Intune content folder and writes a simple manifest.

For documentation-only delivery, see `document.md` for the full source of each script.

## Intune Assignment Model

Use Intune Remediations, not Settings Catalog.

Why:

1. This is not a native Windows policy-backed setting.
2. The target is an app-owned XML file inside each user profile.
3. The deployment needs discovery, compliance logic, remediation, and retry behavior.

Recommended Intune model:

1. Create one Remediations package.
2. Assign `intune-detect-github-copilot.ps1` as the detection script.
3. Assign `intune-remediate-github-copilot.ps1` as the remediation script.
4. Run the package in user context.
5. Scope it to users who use JetBrains IDEs and GitHub Copilot.
6. Schedule it to rerun periodically so drift is corrected.

## User Context Requirement

This must run in user context.

Reason:

1. The target files live under `%APPDATA%\JetBrains\...\options`.
2. System-context execution will resolve to the wrong profile and will not patch the signed-in user’s JetBrains configuration.
3. On shared devices, each user must be evaluated and remediated independently.

Recommended Intune execution settings:

1. Run this script using the logged-on credentials: `Yes`
2. Enforce script signature check: `No`, unless you separately sign and trust these scripts
3. Run script in 64-bit PowerShell: `Yes`

## Recommended Production Parameters

Detection script:

```powershell
.\intune-detect-github-copilot.ps1 -TargetFileName github-copilot.xml
```

Remediation script:

```powershell
.\intune-remediate-github-copilot.ps1 -TargetFileName github-copilot.xml -CreateIfMissing -Backup -SetReadOnly
```

Recommended parameter meanings:

1. `-TargetFileName github-copilot.xml`
   Use the real production target file.
2. `-CreateIfMissing`
   Creates the target file when the JetBrains `options` directory exists but the GitHub Copilot config file does not.
3. `-Backup`
   Creates timestamped `.bak` copies before rewriting an existing target file.
4. `-SetReadOnly`
   Marks the resulting file read-only after patching. The patcher can temporarily clear the attribute on later remediation runs if another update is required.

Optional production parameter:

```powershell
-SkipIfJetBrainsRunning
```

Use this only if you prefer retry-later behavior over patching while the IDE is open. If enabled, the patcher exits with code `2` when JetBrains appears to be running, and the remediation wrapper will treat that as a deferred remediation rather than success.

## Recommended Intune Script Bodies

If you package the scripts together, use wrapper invocations like these inside Intune.

Detection:

```powershell
Set-Location $PSScriptRoot
.\intune-detect-github-copilot.ps1 -TargetFileName github-copilot.xml
exit $LASTEXITCODE
```

Remediation:

```powershell
Set-Location $PSScriptRoot
.\intune-remediate-github-copilot.ps1 -TargetFileName github-copilot.xml -CreateIfMissing -Backup -SetReadOnly
exit $LASTEXITCODE
```

If you want JetBrains-open protection, use:

```powershell
Set-Location $PSScriptRoot
.\intune-remediate-github-copilot.ps1 -TargetFileName github-copilot.xml -CreateIfMissing -Backup -SetReadOnly -SkipIfJetBrainsRunning
exit $LASTEXITCODE
```

## Exit Code Model

Compliance and Intune detection:

1. `0`
   All discovered target files are compliant.
2. `1`
   At least one discovered target file is missing, malformed, or non-compliant.

Patcher:

1. `0`
   No failures occurred.
2. `1`
   One or more target files failed to patch.
3. `2`
   JetBrains was running and patching was skipped because `-SkipIfJetBrainsRunning` was enabled.

Remediation wrapper:

1. `0`
   Already compliant, or remediation succeeded and the final compliance check passed.
2. `1`
   The device remains non-compliant after remediation, or a required script was missing.
3. `2`
   JetBrains was running and remediation was skipped due to `-SkipIfJetBrainsRunning`.

## Logging Behavior

Each patched location gets a sibling log file named `github-copilot-patch.log` by default.

Example path:

`%APPDATA%\JetBrains\<product><version>\options\github-copilot-patch.log`

Each log entry records:

1. Date and time
2. Patch status
3. Target file path
4. Actions performed
5. Backup path, if a backup was created

This is local per-profile audit logging. If you also want centralized collection, ingest these logs through your existing endpoint telemetry or collection tooling.

## Packaging Notes

Use the packaging script to stage the deployable Intune content folder:

```powershell
.\package-intune-content.ps1 -Clean -IncludeReadme
```

Default output folder:

```text
.\dist\intune-content
```

The packaging script stages these required PowerShell files into that folder:

1. `patch-github-copilot.ps1`
2. `test-github-copilot-compliance.ps1`
3. `intune-detect-github-copilot.ps1`
4. `intune-remediate-github-copilot.ps1`

Optional packaging behavior:

1. `-Clean`
   Deletes the existing output folder before staging the new package.
2. `-IncludeReadme`
   Copies this README into the staged output folder.

The packager also writes `package-manifest.txt` into the staged folder so you can confirm what was included.

The Intune wrappers rely on the compliance and patcher scripts being present in the same directory, so the staged folder preserves that layout.

Typical staged folder contents:

```text
dist\intune-content\
  intune-detect-github-copilot.ps1
  intune-remediate-github-copilot.ps1
  patch-github-copilot.ps1
  test-github-copilot-compliance.ps1
  package-manifest.txt
  README.md              # only when -IncludeReadme is used
```

## Local Validation Before Production

Use the local test target first:

```powershell
.\intune-detect-github-copilot.ps1 -RootPath .\local-test\intune -TargetFileName github2.copilot.xml
.\intune-remediate-github-copilot.ps1 -RootPath .\local-test\intune -TargetFileName github2.copilot.xml -CreateIfMissing -Backup -SetReadOnly
```

This lets you verify wrapper flow without touching a real `github-copilot.xml` under `%APPDATA%`.

## Operational Notes

1. If no JetBrains profile directories exist, detection will evaluate zero targets and return compliant.
2. If malformed XML exists, detection will report non-compliance and remediation will leave that target failed unless the file is manually corrected or deleted.
3. If you enable `-SetReadOnly`, future remediation runs can still update the file because the patcher temporarily clears the attribute before writing and reapplies it afterward.
4. If you are piloting this rollout, start with a small user group before broad assignment.