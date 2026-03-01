#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

link_file() {
    local src="$1"
    local dst="$2"
    local dst_dir
    dst_dir="$(dirname "$dst")"

    mkdir -p "$dst_dir"

    if [ -L "$dst" ]; then
        rm "$dst"
    elif [ -f "$dst" ]; then
        warn "Backing up existing $dst to ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi

    ln -s "$src" "$dst"
    info "Linked $src -> $dst"
}

# -------------------------------------------------------------------
# 1. Install Homebrew (both macOS and Linux)
# -------------------------------------------------------------------
install_homebrew() {
    if command -v brew &>/dev/null; then
        info "Homebrew already installed"
    else
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add to PATH for this session
        if [ "$OS" = "Darwin" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
    fi
}

# -------------------------------------------------------------------
# 2. Install packages via Homebrew
# -------------------------------------------------------------------
install_packages() {
    info "Installing packages via Homebrew..."

    local packages=(
        git
        git-lfs
        gh
        delta
        lazygit
        nvm
        uv
    )

    for pkg in "${packages[@]}"; do
        if brew list "$pkg" &>/dev/null; then
            info "$pkg already installed"
        else
            info "Installing $pkg..."
            brew install "$pkg"
        fi
    done

    # Cask apps (macOS only)
    if [ "$OS" = "Darwin" ]; then
        local casks=(
            ghostty
            visual-studio-code
            cursor
            zed
        )
        for cask in "${casks[@]}"; do
            if brew list --cask "$cask" &>/dev/null; then
                info "$cask already installed"
            else
                info "Installing $cask..."
                brew install --cask "$cask"
            fi
        done
    fi
}

# -------------------------------------------------------------------
# 3. Install Oh My Zsh
# -------------------------------------------------------------------
install_oh_my_zsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        info "Oh My Zsh already installed"
    else
        info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
}

# -------------------------------------------------------------------
# 4. Install NVM & Node.js
# -------------------------------------------------------------------
install_node() {
    export NVM_DIR="$HOME/.nvm"
    local nvm_sh
    nvm_sh="$(brew --prefix nvm)/nvm.sh"

    if [ -f "$nvm_sh" ]; then
        # shellcheck source=/dev/null
        . "$nvm_sh"

        if command -v node &>/dev/null; then
            info "Node.js already installed: $(node --version)"
        else
            info "Installing latest LTS Node.js..."
            nvm install --lts
        fi
    else
        warn "NVM not found, skipping Node.js setup"
    fi
}

# -------------------------------------------------------------------
# 5. Symlink config files
# -------------------------------------------------------------------
symlink_configs() {
    info "Creating symlinks..."

    # Zsh
    link_file "$DOTFILES_DIR/zsh/.zshrc"    "$HOME/.zshrc"
    link_file "$DOTFILES_DIR/zsh/.zprofile"  "$HOME/.zprofile"

    # Git
    link_file "$DOTFILES_DIR/git/.gitconfig"        "$HOME/.gitconfig"
    link_file "$DOTFILES_DIR/git/.gitignore_global"  "$HOME/.gitignore_global"

    # Ghostty
    link_file "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"

    # Lazygit
    if [ "$OS" = "Darwin" ]; then
        link_file "$DOTFILES_DIR/lazygit/config.yml" "$HOME/Library/Application Support/lazygit/config.yml"
    else
        link_file "$DOTFILES_DIR/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"
    fi

    # GitHub CLI
    link_file "$DOTFILES_DIR/gh/config.yml" "$HOME/.config/gh/config.yml"

    # VSCode
    if [ "$OS" = "Darwin" ]; then
        local vscode_dir="$HOME/Library/Application Support/Code/User"
    else
        local vscode_dir="$HOME/.config/Code/User"
    fi
    link_file "$DOTFILES_DIR/vscode/settings.json" "$vscode_dir/settings.json"

    # Cursor
    if [ "$OS" = "Darwin" ]; then
        local cursor_dir="$HOME/Library/Application Support/Cursor/User"
    else
        local cursor_dir="$HOME/.config/Cursor/User"
    fi
    link_file "$DOTFILES_DIR/cursor/settings.json"    "$cursor_dir/settings.json"
    link_file "$DOTFILES_DIR/cursor/keybindings.json"  "$cursor_dir/keybindings.json"

    # Zed
    if [ "$OS" = "Darwin" ]; then
        local zed_dir="$HOME/.config/zed"
    else
        local zed_dir="$HOME/.config/zed"
    fi
    link_file "$DOTFILES_DIR/zed/settings.json" "$zed_dir/settings.json"
}

# -------------------------------------------------------------------
# 6. Platform-specific git credential setup
# -------------------------------------------------------------------
setup_git_credentials() {
    if [ "$OS" = "Darwin" ]; then
        # macOS uses osxkeychain - already in .gitconfig as conditional
        git config --global credential.helper osxkeychain
    else
        # Linux: use gh auth or cache
        if command -v gh &>/dev/null; then
            info "Setting up gh as git credential helper on Linux..."
            gh auth setup-git
        else
            git config --global credential.helper cache
        fi
    fi

    # Setup gh credential helpers for GitHub
    if command -v gh &>/dev/null; then
        local gh_path
        gh_path="$(which gh)"
        git config --global "credential.https://github.com.helper" ""
        git config --global --add "credential.https://github.com.helper" "!${gh_path} auth git-credential"
        git config --global "credential.https://gist.github.com.helper" ""
        git config --global --add "credential.https://gist.github.com.helper" "!${gh_path} auth git-credential"
    fi

    # Init git-lfs
    git lfs install
}

# -------------------------------------------------------------------
# Main
# -------------------------------------------------------------------
main() {
    echo ""
    echo "========================================="
    echo "  Dotfiles Setup - $([ "$OS" = "Darwin" ] && echo "macOS" || echo "Linux")"
    echo "========================================="
    echo ""

    install_homebrew
    install_packages
    install_oh_my_zsh
    install_node
    symlink_configs
    setup_git_credentials

    echo ""
    info "Setup complete! Restart your terminal or run: source ~/.zshrc"
    echo ""
}

main "$@"
