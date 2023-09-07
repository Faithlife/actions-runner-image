# escape=`

ARG BASE
FROM ghcr.io/faithlife/actions-runner-image:${BASE}

SHELL [ "cmd.exe", "/S", "/C" ]

# Modify VS to add Xamarin Build Tools
RUN `
    curl -fSLo vs_BuildTools.exe https://aka.ms/vs/17/release/vs_BuildTools.exe `
    && start /w vs_BuildTools modify ^ `
        --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\BuildTools" ^ `
        --add Microsoft.VisualStudio.Workload.XamarinBuildTools ^ `
        --quiet --includeRecommended --norestart --nocache --wait `
    && powershell -Command "if ($err = dir $Env:TEMP -Filter dd_setup_*_errors.log | where Length -gt 0 | Get-Content) { throw $err }" `
    && del vs_BuildTools.exe `
    `
    # Cleanup
    && (for /D %i in ("%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\*") do rmdir /S /Q "%i") `
    && (for %i in ("%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\*") do if not "%~nxi" == "vswhere.exe" del "%~i") `
    && powershell Remove-Item -Force -Recurse "%TEMP%\*"

# Accept Android SDK licenses
COPY ["android-sdk-license", "C:\\Program Files (x86)\\Android\\android-sdk\\licenses\\android-sdk-license"]
COPY ["yes.txt", "C:\\yes.txt"]
RUN C:\Program^ Files^ ^(x86^)\Android\android-sdk\cmdline-tools\7.0\bin\sdkmanager.bat --licenses < C:\yes.txt

RUN C:\Program^ Files^ ^(x86^)\Android\android-sdk\cmdline-tools\7.0\bin\sdkmanager.bat --install "platforms;android-28" --sdk_root="C:\Program Files (x86)\Android\android-sdk"
