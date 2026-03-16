FROM ubuntu:24.04

SHELL ["/bin/bash", "-lc"]

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    bison \
    build-essential \
    curl \
    flex \
    fontconfig \
    git-core \
    gnupg \
    lib32z1-dev \
    rsync \
    libc6-dev-i386 \
    libgl1-mesa-dev \
    libx11-dev \
    libxml2-utils \
    openjdk-17-jdk \
    openssh-client \
    python3 \
    repo \
    unzip \
    x11proto-core-dev \
    xsltproc \
    zip \
    zlib1g-dev \
 && git config --system user.name "Env Recipes" \
 && git config --system user.email "env-recipes@local" \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

CMD ["bash"]
