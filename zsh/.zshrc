
# Path to your Oh My Zsh installation.
export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="robbyrussell"

plugins=(git)

source $ZSH/oh-my-zsh.sh

# Google Cloud SDK
if [ -f "$HOME/code/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/code/google-cloud-sdk/path.zsh.inc"; fi
if [ -f "$HOME/code/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/code/google-cloud-sdk/completion.zsh.inc"; fi
export CLOUDSDK_PYTHON_SITEPACKAGES=1

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Local binaries (uv, claude, etc.)
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# Local API credentials (ignored by git)
if [ -f "$HOME/.dotfiles/.env" ]; then
    set -a
    . "$HOME/.dotfiles/.env"
    set +a
fi

# tab completions
fpath=(/opt/homebrew/share/zsh/site-functions $fpath)

if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
    export TERM=xterm-256color
fi

alias lg="lazygit"
alias auth_gc="gcloud auth login --update-adc"

# Homebrew
export HOMEBREW_NO_ENV_HINTS=1

export XLA_FLAGS="--xla_backend_extra_options=xla_cpu_disable_new_fusion_emitters=true"
export XLA_PYTHON_CLIENT_PREALLOCATE="false"

export GOOGLE_CLOUD_PROJECT="eka-robotics" 
export GOOGLE_CLOUD_LOCATION="global"
