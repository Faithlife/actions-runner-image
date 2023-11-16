FROM summerwind/actions-runner:ubuntu-22.04

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash \
  && sudo rm -rf /var/lib/apt/lists/*

RUN sudo curl -sLO https://github.com/PowerShell/PowerShell/releases/download/v7.3.9/powershell_7.3.9-1.deb_amd64.deb \
  && (sudo dpkg -i powershell_7.3.9-1.deb_amd64.deb; sudo apt-get install -f) \
  && sudo rm powershell_7.3.9-1.deb_amd64.deb

RUN sudo apt-get update \
  && sudo apt-get install -y \
    gettext-base \
  && sudo rm -rf /var/lib/apt/lists/*

COPY docker-system-prune /etc/arc/hooks/job-completed.d/

ENV DOTNET_INSTALL_DIR=~/.dotnet
