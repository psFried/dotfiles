#!/bin/bash

# Script for setting up a Flow dev environment in Debian 11 (bullseye)

set -ex

sudo apt-get update
sudo apt-get install -y \
      bash-completion \
      build-essential \
      ca-certificates \
      clang-11 \
      curl \
      docker-compose \
      docker.io \
      file \
      git \
      gnupg2 \
      iproute2 \
      jq \
      less \
      libclang-11-dev \
      libncurses5-dev \
      libreadline-dev \
      libssl-dev \
      lld-11 \
      locales \
      neovim \
      net-tools \
      netcat \
      npm \
      openssh-client  \
      pkg-config \
      postgresql-client \
      psmisc \
      sqlite3 \
      strace \
      sudo \
      tcpdump \
      unzip \
      vim-tiny \
      wget \
      zip

if [[ -z "$(command -v node)" ]]; then
	# "Add NodeSource keyring for more recent nodejs packages" \
	export NODE_KEYRING=/usr/share/keyrings/nodesource.gpg \
	 && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | gpg --dearmor | tee "$NODE_KEYRING" >/dev/null \
	 && gpg --no-default-keyring --keyring "$NODE_KEYRING" --list-keys \
	 && echo "deb [signed-by=$NODE_KEYRING] https://deb.nodesource.com/node_14.x bullseye main" | tee /etc/apt/sources.list.d/nodesource.list
	sudo apt-get update
	sudo apt-get install nodejs --no-install-recommends -y
fi

if [[ -z "$(command -v go)" ]]; then
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

# shource bashrc to get the new PATH, which should now include cargo
source ~/.bashrc

rustc --version
cargo --version

cargo install ripgrep skim polk bat

# Polk symlinks the dotfiles repo at ~/.dot, so this is just a way of checking whether polk setup
# has already run.
if [[ ! -d ~/.dot ]]; then
	polk setup https://github.com/psFried/dotfiles
fi

mkdir -p ~/projects

