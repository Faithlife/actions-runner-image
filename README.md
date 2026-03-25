Actions runner images for use with [actions-runner-controller](https://github.com/actions-runner-controller/actions-runner-controller) that include some additional tools.

## Available Images

### Linux

#### Tags: `master`

This image is based on `summerwind/actions-runner:ubuntu-22.04` (which installs the latest GitHub Actions Runner tools on Ubuntu 22.04). It adds:

* az CLI
* PowerShell
* .NET 8 SDK, .NET 9 SDK, .NET 10 SDK

#### Tags: `ubuntu-logos`

This image is based on `ghcr.io/actions/actions-runner:latest` (which installs the latest GitHub Actions Runner tools on Ubuntu 24.04). It adds:

* az CLI
* gh CLI
* git-lfs
* PowerShell
* .NET 8 SDK, .NET 9 SDK, .NET 10 SDK

### Windows

#### Tags: `ltsc2022`

The Windows Dockerfile was derived from the [instructions](https://github.com/actions-runner-controller/actions-runner-controller/blob/master/docs/detailed-docs.md#setting-up-windows-runners) and the example in [this PR](https://github.com/isarkis/actions-runner-controller/pull/1/files).
It is based on the `mcr.microsoft.com/dotnet/framework/sdk` image. It adds:

* [GitHub Actions Runner](https://github.com/actions/runner)
* [Azure CLI](https://community.chocolatey.org/packages/azure-cli)
* [Git for Windows](https://community.chocolatey.org/packages/git.install)
* [Visual C++ Tools](https://learn.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-build-tools?view=vs-2022#desktop-development-with-c)

#### Tags: `vs2026`

The `windows/vs2026.Dockerfile` image starts from the .NET Framework 4.8.1 LTSC 2025 runtime image, installs the Visual Studio 2026 / VS18 SDK stack, and adds Desktop development with C++. It also adds the same runner/tooling stack as the standard Windows image:

* [GitHub Actions Runner](https://github.com/actions/runner)
* [PowerShell](https://learn.microsoft.com/powershell/)
* [Azure CLI](https://community.chocolatey.org/packages/azure-cli)
* [Git for Windows](https://community.chocolatey.org/packages/git.install)
* [.NET 8 SDK, .NET 9 SDK, .NET 10 SDK](https://dotnet.microsoft.com/)
* [Visual C++ Tools](https://learn.microsoft.com/visualstudio/install/workload-component-id-vs-build-tools?view=visualstudio#desktop-development-with-c++)

#### Building Locally

To build the Windows images locally, install Docker Desktop and switch it to Windows containers.

The Windows images require a font to be installed.
`ARIAL_TTF_URL` can be constructed by opening asset 15079750 in Amber and getting a CDN URL.
It's also stored as a repository secret.

Then run:

```powershell
cd actions-runner-image\windows
$env:DOCKER_BUILDKIT = '0'
tar.exe -cf context.tar Dockerfile vs2026.Dockerfile yes.txt android-sdk-license
Get-Content .\context.tar -AsByteStream | docker build --pull -t actions-runner-image:vs2026 -f vs2026.Dockerfile --build-arg BASE=4.8.1-windowsservercore-ltsc2025 --build-arg "ARIAL_TTF_URL=https://SECRET_VALUE_HERE" -
del .\context.tar
```

The steps above avoid the following error that may occur when just running `docker build`:

```
unable to prepare context: unable to evaluate symlinks in context path: EvalSymlinks: too many links
```
