#!/bin/bash

# Source global definitions
if [ -f /etc/bashrc ]; then
      . /etc/bashrc
fi

# setup path variable to work with rustup
export PATH="${HOME}/.cargo/bin:${PATH}"
export LESS+=' -r'


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



if [[ -f "${HOME}/projects/dotfiles/git-completion.bash" ]]; then
    source "${HOME}/projects/dotfiles/git-completion.bash"
fi

if [[ -f "${HOME}/projects/dotfiles/invoke-maven.sh" ]]; then
    alias mvn="${HOME}/projects/dotfiles/invoke-maven.sh"
fi

# Git Prompt stuff
function git_branch() {
    # -- Finds and outputs the current branch name by parsing the list of
    #    all branches
    # -- Current branch is identified by an asterisk at the beginning
    # -- If not in a Git repository, error message goes to /dev/null and
    #    no output is produced
    git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

function git_status() {
    # Outputs a series of indicators based on the status of the
    # working directory:
    # + changes are staged and ready to commit
    # ! unstaged changes are present
    # ? untracked files are present
    # S changes have been stashed
    # P local commits need to be pushed to the remote
    local status="$(git status --porcelain 2>/dev/null)"
    local output=''
    [[ -n $(egrep '^[MADRC]' <<<"$status") ]] && output="$output+"
    [[ -n $(egrep '^.[MD]' <<<"$status") ]] && output="$output!"
    [[ -n $(egrep '^\?\?' <<<"$status") ]] && output="$output?"
    [[ -n $(git stash list) ]] && output="${output}S"
    [[ -n $(git log --branches --not --remotes) ]] && output="${output}P"
    [[ -n $output ]] && output="|$output"  # separate from branch name
    echo $output
}

function git_color() {
    # Receives output of git_status as argument; produces appropriate color
    # code based on status of working directory:
    # - White if everything is clean
    # - Green if all changes are staged
    # - Red if there are uncommitted changes with nothing staged
    # - Yellow if there are both staged and unstaged changes
    local staged=$([[ $1 =~ \+ ]] && echo yes)
    local dirty=$([[ $1 =~ [!\?] ]] && echo yes)
    if [[ -n $staged ]] && [[ -n $dirty ]]; then
        echo -e '\033[1;33m'  # bold yellow
    elif [[ -n $staged ]]; then
        echo -e '\033[1;32m'  # bold green
    elif [[ -n $dirty ]]; then
        echo -e '\033[1;31m'  # bold red
    else
        echo -e '\033[1;37m'  # bold white
    fi
}

function git_prompt() {
    # First, get the branch name...
    local branch=$(git_branch)
    # Empty output? Then we're not in a Git repository, so bypass the rest
    # of the function, producing no output
    if [[ -n $branch ]]; then
        local state=$(git_status)
        local color=$(git_color $state)
        # Now output the actual code to insert the branch and status
        echo -e "\x01$color\x02[$branch$state]\x01\033[00m\x02"  # last bit resets color
    fi
}

export PS1='\[\033[1;33m\]\w\[\033[0m\]$(git_prompt)\$ '

# if kubectl is installed, then source the extra goodies
command -v kubectl 2>&1>/dev/null && source "$HOME/projects/dotfiles/kube_bashrc"

