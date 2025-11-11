FROM ghcr.io/actions/actions-runner:latest

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash \
  && sudo rm -rf /var/lib/apt/lists/*

RUN sudo curl -sLO https://github.com/PowerShell/PowerShell/releases/download/v7.4.12/powershell_7.4.12-1.deb_amd64.deb \
  && (sudo dpkg -i powershell_7.4.12-1.deb_amd64.deb; sudo apt-get install -f) \
  && sudo rm powershell_7.4.12-1.deb_amd64.deb

RUN sudo add-apt-repository ppa:dotnet/backports \
  && sudo apt-get update \
  && sudo apt-get install -y \
    gettext-base \
    dotnet-sdk-8.0 \
    dotnet-runtime-9.0 \
  && sudo rm -rf /var/lib/apt/lists/*

ENV DOTNET_INSTALL_DIR=/home/runner/.dotnet
