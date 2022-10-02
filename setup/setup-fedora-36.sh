#!/bin/bash

set -ex

# repo for helix editor
sudo dnf copr enable varlad/helix
# libX11-devel is a dependency of nu shell
# perl-core required in order to build openssl
# snappy-devel lz4-devel bzip2-devel are all required for building Gazette
sudo dnf install -y \
    alacritty \
    autoconf \
    automake \
    bzip2-devel \
    clang \
    clang-tools-extra \
    curl \
    cmake \
    dnf-plugins-core \
    gcc \
    g++ \
    git \
    git-lfs \
    helix \
    jq \
    libX11-devel \
    libxcb-devel \
    libxkbcommon-devel \
    libxcrypt-compat \
    lld \
    llvm \
    lz4-devel \
    musl-gcc \
    neovim \
    openssl-devel \
    perl-core \
    protobuf-compiler \
    protobuf-devel \
    pv \
    snappy-devel \
    sqlite-devel

sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io

# Do we need to setup the docker group?
# if ! groups | grep docker >/dev/null; then
#     echo "adding docker group"
#     getent group docker >/dev/null || sudo groupadd docker
#     sudo usermod -a -G docker ${USER}
#     newgrp
# fi

sudo dnf groupinstall -y "Development Tools"

# node installs as a module
sudo dnf module install nodejs:16/development

if [[ -z "$(command -v go)" ]]; then
	echo "Installing Golang"

	GOLANG_VERSION=1.19.1
	GOLANG_SHA256=acc512fbab4f716a8f97a8b3fbaa9ddd39606a28be6c2515ef7c6c6311acffde
	echo 'export PATH=/usr/local/go/bin:$PATH' >> ~/.bashrc

	curl -L -o /tmp/golang.tgz https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz
	echo "${GOLANG_SHA256} /tmp/golang.tgz" | sha256sum -c - \
	 && sudo tar --extract \
	      --file /tmp/golang.tgz \
	      --directory /usr/local \
	 && rm /tmp/golang.tgz \
	 && /usr/local/go/bin/go version

fi

if [[ -z "$(command -v rustup)" ]]; then
	echo "Installing Rustup"

	# Install rust
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- \
		-c rust-docs \
		-c rustfmt \
		-c rust-analyzer \
		-c rust-std \
		-c clippy \
		-c rust-stc \
		-c rust-analysis \
		-c llvm-tools-preview \
		-t x86_64-unknown-linux-gnu \
		-t x86_64-unknown-linux-musl \
		--default-toolchain stable
fi

set +x

# source bashrc to get the new PATH, which should now include cargo
source ~/.bashrc || echo "sourcing bashrc failed"

set -x

rustc --version
cargo --version

# Just some nice tools that I use.
cargo install --locked ripgrep skim polk bat jless git-delta lsd fd-find starship

# Polk symlinks the dotfiles repo at ~/.dot, so this is just a way of checking whether polk setup
# has already run.
if [[ ! -d ~/.dot ]]; then
	polk setup https://github.com/psFried/dotfiles
fi

mkdir -p ~/projects

if [[ -z "$(command -v gcloud)" ]]; then
	echo "Installing gcloud"

sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-sdk]
name=Google Cloud SDK
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el8-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM

	sudo dnf install -y google-cloud-sdk
fi

if [[ -z "$(command -v kubectl)" ]]; then
	echo "Installing kubectl"
sudo tee -a /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

sudo dnf install -y kubectl
fi



echo -e "\nSetup complete"
