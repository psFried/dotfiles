#!/bin/bash

set -ex

sudo dnf install -y \
    acpi \
    autoconf \
    automake \
    clang \
    clang-tools-extra \
    cmake \
    dnf-plugins-core \
    freetype-devel \
    fontconfig-devel \
    gcc \
    g++ \
    git \
    jq \
    libxcb-devel \
    libxkbcommon-devel \
    libxcrypt-compat \
    lld \
    llvm \
    neovim \
    openssl-devel \
    pasystray \
    # perl-core required in order to build openssl
    perl-core \
    power-profiles-daemon \
    protobuf-compiler \
    protobuf-devel \
    rofi \
    snapd \
    xbacklight \
    xclip

sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io

# Do we need to setup the docker group?
if ! groups | grep docker >/dev/null; then
    echo "adding docker group"
    getent group docker >/dev/null || sudo groupadd docker
    sudo gpasswd -a ${USER} docker
    newgrp
fi

# The blueman package brings in a bunch of extra kde stuff unless this setopt is present
sudo dnf --setopt=install_weak_deps=False install -y blueman
sudo dnf groupinstall -y "Development Tools"

# node installs as a module
sudo dnf module install nodejs:14/development

if [[ -z "$(command -v go)" ]]; then
	echo "Installing Golang"

	GOLANG_VERSION=1.17.5
	GOLANG_SHA256=bd78114b0d441b029c8fe0341f4910370925a4d270a6a590668840675b0c653e
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

cargo install ripgrep skim polk bat jless git-delta

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
