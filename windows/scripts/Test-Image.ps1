<#
.SYNOPSIS
    Validates that the tools installed in the Windows runner image are present and functional.

.DESCRIPTION
    Intended to be run inside a built image (see the "Validate Docker image" step of the
    Docker (Windows) workflow):

        docker run --rm <image> pwsh -NoProfile -File C:\image-tests\Test-Image.ps1

    Every check is executed so that a single run reports all of the problems; the script exits
    with a non-zero exit code if any check fails.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$failures = @()

function Test-Tool {
    param(
        [Parameter(Mandatory = $true)] [string] $Name,
        [Parameter(Mandatory = $true)] [scriptblock] $Test
    )

    Write-Host "==> $Name"
    try {
        & $Test
        Write-Host "    PASS"
    }
    catch {
        Write-Host "    FAIL: $($_.Exception.Message)"
        $script:failures += "$Name`: $($_.Exception.Message)"
    }
}

function Invoke-Tool {
    param(
        [Parameter(Mandatory = $true)] [string] $Command,
        [Parameter(ValueFromRemainingArguments = $true)] [string[]] $Arguments
    )

    if (-not (Get-Command $Command -ErrorAction SilentlyContinue)) {
        throw "'$Command' was not found on the PATH."
    }

    $output = & $Command @Arguments 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) {
        throw "'$Command $($Arguments -join ' ')' exited with code $LASTEXITCODE`: $output"
    }

    Write-Host ($output.Trim())
    return $output
}

Test-Tool 'GitHub Actions runner' {
    foreach ($file in 'C:\actions-runner\config.cmd', 'C:\actions-runner\run.cmd') {
        if (-not (Test-Path -Path $file)) { throw "'$file' does not exist." }
    }
}

Test-Tool 'PowerShell' { Invoke-Tool 'pwsh' '--version' | Out-Null }

Test-Tool 'Chocolatey' { Invoke-Tool 'choco' '--version' | Out-Null }

Test-Tool 'Git' { Invoke-Tool 'git' '--version' | Out-Null }

Test-Tool 'Azure CLI' { Invoke-Tool 'az' 'version' | Out-Null }

Test-Tool '.NET SDKs' {
    # the .NET SDKs are installed to a specific directory, which isn't necessarily on the PATH
    $dotnet = 'dotnet'
    if (-not (Get-Command $dotnet -ErrorAction SilentlyContinue)) {
        $dotnet = Join-Path $env:ProgramFiles 'dotnet\dotnet.exe'
    }

    $sdks = Invoke-Tool $dotnet '--list-sdks'
    foreach ($version in '8.', '9.', '10.') {
        if (-not ($sdks -split '\r?\n' | Where-Object { $_.StartsWith($version) })) {
            throw "No .NET $($version.TrimEnd('.')) SDK is installed."
        }
    }
}

Test-Tool 'Arial font' {
    if (-not (Test-Path -Path 'C:\Windows\Fonts\arial.ttf')) {
        throw "'C:\Windows\Fonts\arial.ttf' does not exist."
    }
}

Test-Tool 'Visual C++ tools' {
    $vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
    if (-not (Test-Path -Path $vswhere)) { throw "'$vswhere' does not exist." }

    $msbuild = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -find 'MSBuild\**\Bin\MSBuild.exe'
    if ($LASTEXITCODE -ne 0) { throw "vswhere.exe exited with code $LASTEXITCODE." }
    if (-not $msbuild) { throw 'The Visual C++ build tools are not installed.' }

    Write-Host ($msbuild -join [Environment]::NewLine)
}

if ($failures) {
    Write-Host ''
    Write-Host "$($failures.Count) image validation check(s) failed:"
    $failures | ForEach-Object { Write-Host "  * $_" }
    exit 1
}

Write-Host ''
Write-Host 'All image validation checks passed.'
