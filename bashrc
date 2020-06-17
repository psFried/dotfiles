#!/bin/bash


export LESS+=' -r'

# set default editor to neovim ;)
export EDITOR=nvim

# emulate these useful commands from osx
alias pbcopy='xclip -selection clipboard -i'
alias pbpaste='xclip -selection clipboard -o'

alias st='git status'
alias co='git checkout'
alias cb='git checkout -b'
alias db='git branch -d'
alias gcmsg='git commit -m'
alias lg='git lg'
alias pull='git pull --rebase'
alias gap='git add -p'
alias gaa='git add .'

alias l="ls -l"
alias ll="ls -al"

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

function take() {
    mkdir -p "$1" && cd "$1"
}

# if kubectl is installed, then source the extra goodies
command -v kubectl 2>&1>/dev/null && source "$HOME/projects/dotfiles/kube_bashrc"

# added by travis gem
[ -f "$HOME/.travis/travis.sh" ] && source "$HOME/.travis/travis.sh"

