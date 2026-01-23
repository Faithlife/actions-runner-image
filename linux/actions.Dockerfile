FROM ghcr.io/actions/actions-runner:latest

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash \
  && sudo rm -rf /var/lib/apt/lists/*

RUN sudo mkdir -p /etc/apt/keyrings \
  && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
  && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo apt-get update \
  && sudo apt-get install -y gh \
  && sudo rm -rf /var/lib/apt/lists/*

RUN sudo curl -sLO https://github.com/PowerShell/PowerShell/releases/download/v7.4.12/powershell_7.4.12-1.deb_amd64.deb \
  && (sudo dpkg -i powershell_7.4.12-1.deb_amd64.deb; sudo apt-get install -f) \
  && sudo rm powershell_7.4.12-1.deb_amd64.deb

RUN sudo add-apt-repository ppa:dotnet/backports \
  && sudo apt-get update \
  && sudo apt-get install -y \
    ca-certificates \
    gettext-base \
    libc6 \
    libgcc-s1 \
    libgssapi-krb5-2 \
    libicu74 \
    libssl3t64 \
    libstdc++6 \
    tzdata \
    zlib1g \
  && sudo rm -rf /var/lib/apt/lists/*

ENV DOTNET_INSTALL_DIR=/home/runner/.dotnet

RUN curl -L https://dot.net/v1/dotnet-install.sh -o /home/runner/dotnet-install.sh && \
  chmod +x /home/runner/dotnet-install.sh && \
  /home/runner/dotnet-install.sh --install-dir $DOTNET_INSTALL_DIR --channel 8.0 && \
  /home/runner/dotnet-install.sh --install-dir $DOTNET_INSTALL_DIR --channel 9.0 && \
  /home/runner/dotnet-install.sh --install-dir $DOTNET_INSTALL_DIR --channel 10.0 && \
  rm /home/runner/dotnet-install.sh && \
  sudo ln -s /home/runner/.dotnet/ /usr/share/dotnet
