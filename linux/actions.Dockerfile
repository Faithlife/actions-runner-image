FROM ghcr.io/actions/actions-runner:latest

ARG TARGETPLATFORM=linux/amd64
ARG DOCKER_VERSION=27.5.1
ARG DOCKER_COMPOSE_VERSION=v2.32.2
ARG CHANNEL=stable

RUN set -vx; \
    export ARCH=$(echo ${TARGETPLATFORM} | cut -d / -f2) \
    && if [ "$ARCH" = "arm64" ]; then export ARCH=aarch64 ; fi \
    && if [ "$ARCH" = "amd64" ] || [ "$ARCH" = "i386" ]; then export ARCH=x86_64 ; fi \
    && curl -fLo /tmp/docker.tgz https://download.docker.com/linux/static/${CHANNEL}/${ARCH}/docker-${DOCKER_VERSION}.tgz \
    && cd /tmp \
    && tar zxvf docker.tgz \
    && sudo install -o root -g root -m 755 docker/docker /usr/bin/docker \
    && rm -rf docker docker.tgz

RUN export ARCH=$(echo ${TARGETPLATFORM} | cut -d / -f2) \
    && if [ "$ARCH" = "arm64" ]; then export ARCH=aarch64 ; fi \
    && if [ "$ARCH" = "amd64" ] || [ "$ARCH" = "i386" ]; then export ARCH=x86_64 ; fi \
    && sudo mkdir -p /usr/libexec/docker/cli-plugins \
    && curl -fLo /tmp/docker-compose https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-${ARCH} \
    && sudo mv /tmp/docker-compose /usr/libexec/docker/cli-plugins/docker-compose \
    && sudo chmod +x /usr/libexec/docker/cli-plugins/docker-compose \
    && sudo rm -f /usr/bin/docker-compose \
    && sudo ln -s /usr/libexec/docker/cli-plugins/docker-compose /usr/bin/docker-compose

RUN sudo mkdir -p /etc/apt/keyrings \
  && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
  && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo apt-get update \
  && sudo apt-get install -y gh \
  && sudo rm -rf /var/lib/apt/lists/*

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash \
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
