# escape=`

ARG BASE=4.8.1-20251014-windowsservercore-ltsc2025
FROM mcr.microsoft.com/dotnet/framework/runtime:${BASE}

# latest values from https://github.com/actions/runner/releases for actions-runner-win-x64-N.N.N.zip
ARG RUNNER_VERSION=2.333.0
ARG RUNNER_DOWNLOAD_HASH=7176d0c4b674d4108b515503a53b4bc9eeab9339c645e274a97c142fe1c64b95

ENV `
    # Do not generate certificate
    DOTNET_GENERATE_ASPNET_CERTIFICATE=false `
    # Enable correct mode for dotnet watch (only mode supported in a container)
    DOTNET_USE_POLLING_FILE_WATCHER=true `
    # NuGet version to install
    NUGET_VERSION=7.3.0 `
    # Install location of Roslyn
    ROSLYN_COMPILER_LOCATION="C:\Program Files (x86)\Microsoft Visual Studio\18\BuildTools\MSBuild\Current\Bin\Roslyn"

SHELL [ "cmd.exe", "/S", "/C" ]

# Install NuGet CLI
RUN mkdir "%ProgramFiles%\NuGet\latest" `
    && curl -fSLo "%ProgramFiles%\NuGet\nuget.exe" https://dist.nuget.org/win-x86-commandline/v%NUGET_VERSION%/nuget.exe `
    && mklink "%ProgramFiles%\NuGet\latest\nuget.exe" "%ProgramFiles%\NuGet\nuget.exe"

# Install the VS18 SDK stack, then add Desktop development with C++.
RUN curl -fSLo vs_BuildTools.exe https://aka.ms/vs/stable/vs_BuildTools.exe `
    && start /w vs_BuildTools ^ `
        --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\18\BuildTools" ^ `
        --add Microsoft.Component.ClickOnce.MSBuild ^ `
        --add Microsoft.Net.Component.4.8.1.SDK ^ `
        --add Microsoft.NetCore.Component.Runtime.8.0 ^ `
        --add Microsoft.NetCore.Component.Runtime.9.0 ^ `
        --add Microsoft.NetCore.Component.Runtime.10.0 ^ `
        --add Microsoft.NetCore.Component.SDK ^ `
        --add Microsoft.VisualStudio.Component.NuGet.BuildTools ^ `
        --add Microsoft.VisualStudio.Component.TestTools.BuildTools ^ `
        --add Microsoft.VisualStudio.Component.VC.ATL ^ `
        --add Microsoft.VisualStudio.Component.WebDeploy ^ `
        --add Microsoft.VisualStudio.Web.BuildTools.ComponentGroup ^ `
        --add Microsoft.VisualStudio.Workload.MSBuildTools ^ `
        --add Microsoft.VisualStudio.Workload.VCTools ^ `
        --quiet --includeRecommended --norestart --nocache --wait `
    && powershell -Command "if ($err = dir $Env:TEMP -Filter dd_setup_*_errors.log | where Length -gt 0 | Get-Content) { throw $err }" `
    && del vs_BuildTools.exe `
    `
    # Trigger dotnet first run experience by running arbitrary cmd
    && "%ProgramFiles%\dotnet\dotnet" help `
    `
    # Workaround for issues with 64-bit ngen
    && %windir%\Microsoft.NET\Framework64\v4.0.30319\ngen uninstall "%ProgramFiles(x86)%\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8.1 Tools\SecAnnotate.exe" `
    && %windir%\Microsoft.NET\Framework64\v4.0.30319\ngen uninstall "%ProgramFiles(x86)%\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8.1 Tools\WinMDExp.exe" `
    `
    # ngen assemblies queued by VS installers
    && %windir%\Microsoft.NET\Framework64\v4.0.30319\ngen update `
    `
    # Cleanup
    && (for /D %i in ("%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\*") do rmdir /S /Q "%i") `
    && (for %i in ("%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\*") do if not "%~nxi" == "vswhere.exe" del "%~i") `
    && powershell Remove-Item -Force -Recurse "%TEMP%\*"

# Set PATH in one layer to keep image size down.
RUN powershell setx /M PATH $(${Env:PATH} `
    + \";${Env:ProgramFiles}\NuGet\" `
    + \";${Env:ProgramFiles(x86)}\Microsoft Visual Studio\18\BuildTools\MSBuild\Current\Bin\amd64\" `
    + \";${Env:ProgramFiles(x86)}\Microsoft Visual Studio\18\BuildTools\Common7\IDE\Extensions\TestPlatform\" `
    + \";${Env:ProgramFiles(x86)}\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8.1 Tools\" `
    + \";${Env:ProgramFiles(x86)}\Microsoft SDKs\ClickOnce\SignTool\")

# Install Targeting Packs
RUN powershell -Command "`
    $referenceAssembliesPath = \"${Env:ProgramFiles(x86)}\Reference Assemblies\Microsoft\Framework\"; `
    New-Item -ItemType Directory -Path ${referenceAssembliesPath}; `
    foreach ($version in @('net40', 'net45', 'net451', 'net452', 'net46', 'net461', 'net462', 'net47', 'net471', 'net472', 'net48', 'net481')) { `
        $package = \"Microsoft.NETFramework.ReferenceAssemblies.${version}\"; `
        nuget install \"${package}\" -DirectDownload -ExcludeVersion -Version 1.0.3 -OutputDirectory ${Env:TEMP}\Packages -Source https://pkgs.dev.azure.com/dnceng/public/_packaging/dotnet-public/nuget/v3/index.json; `
        $contents = \"${Env:TEMP}\Packages\${package}\build\.NETFramework\"; `
        Get-ChildItem -File -Recurse -Path \"${contents}\" | `
            Where-Object { $_.FullName -match '^(?!.*(PermissionSets|RedistList)).*\.xml$' } | `
            Remove-Item; `
        Copy-Item -Recurse -Force -Container -Path ${contents} -Destination ${referenceAssembliesPath}; `
    } `
    Remove-Item -Force -Recurse ${Env:TEMP}\\*;"

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

RUN powershell choco install azure-cli --no-progress -y

# Disable dynamic port UDP/65330; Azure DNS resolution can fail once every 16,383 attempts using the default `NetUDPSetting`s.
CMD [ "pwsh", "-c", "netsh int ipv4 add excludedportrange udp 65330 1 persistent; ./config.cmd --name $env:RUNNER_NAME --url $env:GITHUB_URL$($env:RUNNER_ENTERPRISE ? 'enterprises/' + $env:RUNNER_ENTERPRISE : $env:RUNNER_ORG) --token $env:RUNNER_TOKEN --labels $env:RUNNER_LABELS --unattended --replace --ephemeral; ./run.cmd"]
