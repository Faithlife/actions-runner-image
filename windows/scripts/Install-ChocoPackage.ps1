<#
.SYNOPSIS
    Installs a Chocolatey package, retrying transient failures and failing the build if the
    package cannot be installed.

.DESCRIPTION
    `choco install` regularly fails because of transient network errors. When it is invoked
    from a Dockerfile without checking its exit code, the build can succeed and produce an
    image that is missing the tool. This script checks the exit code, retries, and throws if
    every attempt fails.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $Name,

    [string[]] $ChocoArgs = @(),

    [int] $MaxAttempts = 3,

    [int] $RetryDelaySeconds = 30
)

$ErrorActionPreference = 'Stop'

# 0: success; 1641 and 3010: success, but a reboot was initiated or is required.
$successExitCodes = @(0, 1641, 3010)

for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
    Write-Host "Installing Chocolatey package '$Name' (attempt $attempt of $MaxAttempts)."

    & choco install $Name --no-progress --yes @ChocoArgs
    $exitCode = $LASTEXITCODE

    if ($successExitCodes -contains $exitCode) {
        Write-Host "Installed Chocolatey package '$Name' (exit code $exitCode)."
        exit 0
    }

    Write-Warning "'choco install $Name' failed with exit code $exitCode."

    if ($attempt -lt $MaxAttempts) {
        Write-Host "Retrying in $RetryDelaySeconds seconds."
        Start-Sleep -Seconds $RetryDelaySeconds
    }
}

throw "'choco install $Name' failed after $MaxAttempts attempts."
