Actions runner images for use with [actions-runner-controller](https://github.com/actions-runner-controller/actions-runner-controller) that include some additional tools.

## Available Images

### Linux

* Tags: `master`

This image is based on `summerwind/actions-runner:ubuntu-22.04` (which installs the latest GitHub Actions Runner tools on Ubuntu 22.04). It adds:

* az CLI
* PowerShell

### Windows

* Tags: `ltsc2019`, `ltsc2022`

The Windows Dockerfile was derived from the [instructions](https://github.com/actions-runner-controller/actions-runner-controller/blob/master/docs/detailed-docs.md#setting-up-windows-runners) and the example in [this PR](https://github.com/isarkis/actions-runner-controller/pull/1/files).
It is based on the `mcr.microsoft.com/dotnet/framework/sdk` image. It adds:

* [GitHub Actions Runner](https://github.com/actions/runner)
* [Azure CLI](https://community.chocolatey.org/packages/azure-cli)
* [Git for Windows](https://community.chocolatey.org/packages/git.install)
