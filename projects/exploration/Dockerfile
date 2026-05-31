FROM ubuntu:24.04

SHELL ["/bin/bash", "-o", "pipefail", "-lc"]

ARG UBUNTU_MIRROR=http://archive.ubuntu.com/ubuntu
ARG UBUNTU_SECURITY_MIRROR=http://security.ubuntu.com/ubuntu
ARG INSTALL_CODEX=true

ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV CODEX_HOME=/root/.codex

RUN set -eux; \
    printf 'Acquire::Retries "5";\nAcquire::http::Timeout "30";\nAcquire::https::Timeout "30";\nAPT::Get::Fix-Missing "true";\n' \
      > /etc/apt/apt.conf.d/80-retries; \
    if [ -f /etc/apt/sources.list ]; then \
      sed -i "s|http://archive.ubuntu.com/ubuntu|${UBUNTU_MIRROR}|g" /etc/apt/sources.list; \
      sed -i "s|http://security.ubuntu.com/ubuntu|${UBUNTU_SECURITY_MIRROR}|g" /etc/apt/sources.list; \
    fi; \
    if [ -f /etc/apt/sources.list.d/ubuntu.sources ]; then \
      sed -i "s|http://archive.ubuntu.com/ubuntu|${UBUNTU_MIRROR}|g" /etc/apt/sources.list.d/ubuntu.sources; \
      sed -i "s|http://security.ubuntu.com/ubuntu|${UBUNTU_SECURITY_MIRROR}|g" /etc/apt/sources.list.d/ubuntu.sources; \
    fi; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      bash-completion \
      build-essential \
      ca-certificates \
      cmake \
      curl \
      fd-find \
      gdb \
      git \
      iputils-ping \
      jq \
      less \
      lsof \
      nano \
      nodejs \
      npm \
      openssh-client \
      pkg-config \
      procps \
      python3 \
      python3-dev \
      python3-pip \
      python3-venv \
      ripgrep \
      rsync \
      strace \
      sudo \
      unzip \
      vim-tiny \
      wget \
      xz-utils \
      zip; \
    npm config set audit false; \
    npm config set fund false; \
    if [ "${INSTALL_CODEX}" = "true" ]; then \
      npm install -g @openai/codex; \
    fi; \
    git config --system user.name "Env Recipes"; \
    git config --system user.email "env-recipes@local"; \
    git config --system --add safe.directory /workspace; \
    mkdir -p "${CODEX_HOME}" /workspace; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

CMD ["bash"]
