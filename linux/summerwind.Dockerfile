FROM summerwind/actions-runner:ubuntu-22.04

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

COPY docker-system-prune /etc/arc/hooks/job-completed.d/

ENV DOTNET_INSTALL_DIR=/home/runner/.dotnet
