export ZSH=/home/$(whoami)/.oh-my-zsh

ZSH_THEME="ys"

plugins=(git autojump bundler rails asdf)

source $ZSH/oh-my-zsh.sh

export PATH="$HOME/.rbenv/bin:$PATH"

# ASDF load
$HOME/.asdf/asdf.sh
$HOME/.asdf/completions/asdf.bash

# Rbenv load
eval "$(rbenv init -)"

if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
	source /etc/profile.d/vte.sh
fi
