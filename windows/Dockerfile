# escape=`

ARG BASE
FROM mcr.microsoft.com/dotnet/framework/sdk:${BASE}

# latest values from https://github.com/actions/runner/releases for actions-runner-win-x64-N.N.N.zip
ARG RUNNER_VERSION=2.332.0
ARG RUNNER_DOWNLOAD_HASH=83e56e05b21eb58c9697f82e52c53b30867335ff039cd5d44d1a1a24d2149f4b

# VS commands adapted from https://github.com/microsoft/dotnet-framework-docker/blob/main/src/sdk/4.8.1/windowsservercore-ltsc2022/Dockerfile
SHELL [ "cmd.exe", "/S", "/C" ]

# Modify VS to add Desktop development with C++
# https://learn.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-build-tools?view=vs-2022#desktop-development-with-c
RUN `
    curl -fSLo vs_BuildTools.exe https://aka.ms/vs/17/release/vs_BuildTools.exe `
    && start /w vs_BuildTools modify ^ `
        --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\BuildTools" ^ `
        --add Microsoft.VisualStudio.Workload.VCTools ^ `
        --add Microsoft.VisualStudio.Component.VC.ATL ^ `
        --add Microsoft.VisualStudio.Component.VC.14.30.17.0.x86.x64 ^ `
        --add Microsoft.VisualStudio.Component.VC.14.30.17.0.ATL ^ `
        --add Microsoft.VisualStudio.Component.Windows10SDK.19041 ^ `
        --quiet --includeRecommended --norestart --nocache --wait `
    && powershell -Command "if ($err = dir $Env:TEMP -Filter dd_setup_*_errors.log | where Length -gt 0 | Get-Content) { throw $err }" `
    && del vs_BuildTools.exe `
    `
    # Cleanup
    && (for /D %i in ("%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\*") do rmdir /S /Q "%i") `
    && (for %i in ("%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\*") do if not "%~nxi" == "vswhere.exe" del "%~i") `
    && powershell Remove-Item -Force -Recurse "%TEMP%\*"

# Install supported .NET SDKs
RUN `
    curl -fSLO https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.ps1 `
    && powershell .\dotnet-install.ps1 -Channel 8.0 -InstallDir "\"C:\Program Files\dotnet\\"" `
    && powershell .\dotnet-install.ps1 -Channel 9.0 -InstallDir "\"C:\Program Files\dotnet\\"" `
    && powershell .\dotnet-install.ps1 -Channel 10.0 -InstallDir "\"C:\Program Files\dotnet\\"" `
    && del dotnet-install.ps1

WORKDIR /actions-runner

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';$ProgressPreference='silentlyContinue';"]

# install a font as per https://techcommunity.microsoft.com/t5/itops-talk-blog/adding-optional-font-packages-to-windows-containers/bc-p/3561988#messageview_0
ARG ARIAL_TTF_URL
RUN Invoke-WebRequest -Uri "$env:ARIAL_TTF_URL" -OutFile arial.ttf; `
   copy-item arial.ttf c:\windows\fonts\; `
   Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' -name 'Arial' -value 'arial.ttf' -type STRING; `
   Remove-Item arial.ttf;

RUN Invoke-WebRequest -Uri "https://github.com/actions/runner/releases/download/v$env:RUNNER_VERSION/actions-runner-win-x64-$env:RUNNER_VERSION.zip" -OutFile "actions-runner-win-x64-$env:RUNNER_VERSION.zip"

RUN if((Get-FileHash -Path actions-runner-win-x64-$env:RUNNER_VERSION.zip -Algorithm SHA256).Hash.ToUpper() -ne $env:RUNNER_DOWNLOAD_HASH){ throw 'Computed checksum did not match' }

RUN Add-Type -AssemblyName System.IO.Compression.FileSystem ; [System.IO.Compression.ZipFile]::ExtractToDirectory(""""actions-runner-win-x64-$env:RUNNER_VERSION.zip"""", $PWD)

RUN Invoke-WebRequest -Uri 'https://aka.ms/install-powershell.ps1' -OutFile install-powershell.ps1; ./install-powershell.ps1 -AddToPath

RUN powershell Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

RUN powershell choco install git.install --no-progress --params "'/GitAndUnixToolsOnPath'" -y

RUN powershell choco feature enable -n allowGlobalConfirmation

RUN powershell choco install azure-cli  --no-progress -y

# Disable dynamic port UDP/65330; Azure DNS resolution can fail once every 16,383 attempts using the default `NetUDPSetting`s.
CMD [ "pwsh", "-c", "netsh int ipv4 add excludedportrange udp 65330 1 persistent; ./config.cmd --name $env:RUNNER_NAME --url $env:GITHUB_URL$($env:RUNNER_ENTERPRISE ? 'enterprises/' + $env:RUNNER_ENTERPRISE : $env:RUNNER_ORG) --token $env:RUNNER_TOKEN --labels $env:RUNNER_LABELS --unattended --replace --ephemeral; ./run.cmd"]
