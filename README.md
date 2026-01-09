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
