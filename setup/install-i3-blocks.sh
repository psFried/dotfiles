#!/bin/bash -e

build_dir="$(mktemp -d -t i3blocks-XXXXXXXXXX)"
cd "$build_dir"
git clone https://github.com/vivien/i3blocks
cd i3blocks

./autogen.sh
./configure
make
sudo make install
