FROM summerwind/actions-runner:ubuntu-22.04

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash \
  && sudo rm -rf /var/lib/apt/lists/*

RUN sudo curl -sLO https://github.com/PowerShell/PowerShell/releases/download/v7.3.9/powershell_7.3.9-1.deb_amd64.deb \
  && (sudo dpkg -i powershell_7.3.9-1.deb_amd64.deb; sudo apt-get install -f) \
  && sudo rm powershell_7.3.9-1.deb_amd64.deb

RUN sudo apt-get update \
  && sudo apt-get install -y \
    gettext-base

RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo apt update \
  && sudo apt install gh -y

RUN sudo rm -rf /var/lib/apt/lists/*

COPY docker-system-prune /etc/arc/hooks/job-completed.d/

ENV DOTNET_INSTALL_DIR=/home/runner/.dotnet
