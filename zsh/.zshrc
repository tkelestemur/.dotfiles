
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

if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
    export TERM=xterm-256color
fi

# Homebrew
export HOMEBREW_NO_ENV_HINTS=1
