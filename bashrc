#!/bin/bash

# taken from: https://docs.npmjs.com/resolving-eacces-permissions-errors-when-installing-packages-globally
NPM_CONFIG_PREFIX="$HOME/.npm-packages"
export PATH="$PATH:$HOME/.npm-packages/bin:$HOME/.local/bin:$HOME/go/bin"

export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/rgconfig"

export LESS+=' -r'

# set default editor to neovim ;)
export EDITOR=nvim

if [[ "$(uname)" != "Darwin" ]]; then
    # emulate these useful commands from osx
    alias pbcopy='xclip -selection clipboard -i'
    alias pbpaste='xclip -selection clipboard -o'
fi

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

# Allow the user to edit a command before running it using eval
function edit_and_run() {
    local cmd="$1"

    # allow modifying the command. Note that -i is bash-specific
    read -e -p "Command: " -i "$cmd" cmd;
    history -s "$cmd"
    eval "$cmd"
}

# Use skim to find a command in the bash history and execute it
function hist() {
    # First write out any history that bash may have buffered
    history -w || true

    local hist_file="${HISTFILE:-"$HOME/.bash_history"}"
    local cmd="$(cat "$hist_file" | sort -u | sk --bind 'ctrl-y:execute-silent(echo {} | xclip -rmlastnl -selection clipboard -i)+abort' | sed 's/ *$//')"
    edit_and_run "$cmd"
}


alias k=kubectl
alias kubeshell='kubectl run phildebug --rm=true -it --image=digitalocean/doks-debug:latest --command=true -- bash'

function kns() {
    local ns="$1";
    local current_context="$(kubectl config current-context)"
    if [[ -z "$current_context" ]]; then
        echo "no kubernetes context set" 1>&2;
    else
        kubectl config set-context "$current_context" --namespace="$ns"
    fi
}

# Use skim to select a new kubernetes context
function kctx() {
    local new_ctx="$(kubectl config get-contexts -o name | sk --preview='kubectl config get-contexts {}' --preview-window='up:50%' | sed 's/ *$//')"
    if [[ -n "$new_ctx" ]]; then
        kubectl config use-context "$new_ctx"
    fi
}

# Interactively select a kubernetes resource of an arbitrary type. Returns the full resource name,
# including the type. For example, "pod/foo" or "service/bar"
function kselect() {
    local resource_type="$1"
    if [[ -n "$resource_type" ]]; then
        echo "$(kubectl get "$resource_type" -o name | sk --preview="kubectl describe {}" --preview-window='right:50%' | sed 's/ *$//')"
    else
        echo "kselect: missing resource type argument" 1>&2
    fi
}

# Interactively select a kubernetes resource before running the given command.
# "ki delete pod": select a pod, then delete it
# "ki edit svc": select a service, then edit it
# Prompts before actually doing anything, because I didn't really put a ton of thought into this ;)
function ki() {
    local kube_cmd="$1"
    local resource_type="$2"
    local args="${@:3}"

    local resource="$(kselect "$resource_type")"
    if [[ -n "$resource" ]]; then
        local cmd="kubectl ${kube_cmd} ${resource} ${args[@]}";
        edit_and_run "$cmd"
    else
        echo "ki: no resource selected" 1>&2
    fi
}

# if kubectl is installed, then source the extra goodies
#command -v kubectl 2>&1>/dev/null && source "$HOME/projects/dotfiles/kube_bashrc"

# added by travis gem
[ -f "$HOME/.travis/travis.sh" ] && source "$HOME/.travis/travis.sh"

