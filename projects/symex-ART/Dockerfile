FROM ubuntu:24.04

SHELL ["/bin/bash", "-o", "pipefail", "-lc"]

ARG UBUNTU_MIRROR=http://archive.ubuntu.com/ubuntu
ARG UBUNTU_SECURITY_MIRROR=http://security.ubuntu.com/ubuntu

ARG INSTALL_CODEX=true
ARG ART_SUPPORT=true

ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_DISABLE_PIP_VERSION_CHECK=1

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
      build-essential \
      ca-certificates \
      cmake \
      curl \
      gdb \
      git \
      libffi-dev \
      libssl-dev \
      nodejs \
      npm \
      openssh-client \
      pkg-config \
      python3 \
      python3-dev \
      python3-pip \
      python3-venv \
      wget \
      z3; \
    if [ "${ART_SUPPORT}" = "true" ]; then \
      apt-get install -y --no-install-recommends \
        bison \
        ccache \
        flex \
        clang \
        fontconfig \
        rsync \
        gnupg \
        lib32z1-dev \
        libc6-dev-i386 \
        libgl1-mesa-dev \
        libx11-dev \
        libxml2-utils \
        openjdk-17-jdk \
        repo \
        unzip \
        x11proto-core-dev \
        xsltproc \
        zip \
        zlib1g-dev; \
    fi; \
    if [ "${INSTALL_CODEX}" = "true" ]; then \
      npm install -g @openai/codex; \
    fi; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

CMD ["bash"]
