#!/bin/bash

# =============================================================================
# Dotfiles Installation Script
# =============================================================================

set -euo pipefail  # Exit on error, undefined vars, pipe failures
IFS=$'\n\t'        # Better word splitting

# -----------------------------
# Configuration
# -----------------------------
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
NVIM_CONFIG="$XDG_CONFIG_HOME/nvim"
TMUX_CONFIG="$XDG_CONFIG_HOME/tmux"
FONT_DIR="$HOME/.local/share/fonts"

# Versions
NVM_VERSION="v0.40.3"
NODE_VERSION="v24"
RIPGREP_VERSION="14.1.1"
GO_VERSION="1.25.6"
NERD_FONT="3270"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# -----------------------------
# Helper Functions
# -----------------------------
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

command_exists() {
    command -v "$1" &>/dev/null
}

safe_link() {
    local src="$1"
    local dest="$2"
    local flags="${3:--sf}"
    
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        log_warn "File exists and is not a symlink: $dest"
        read -p "Overwrite? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Skipping: $dest"
            return
        fi
        rm -rf "$dest"
    fi
    
    ln $flags "$src" "$dest"
    log_info "Linked: $src -> $dest"
}

# -----------------------------
# Neovim Configuration
# -----------------------------
setup_neovim_config() {
    log_info "Setting up Neovim configuration..."
    
    mkdir -p "$NVIM_CONFIG/lua"
    
    safe_link "$DOTFILES_DIR/nvim/lazy-lock.json" "$NVIM_CONFIG/lazy-lock.json"
    safe_link "$DOTFILES_DIR/nvim/init.lua" "$NVIM_CONFIG/init.lua"
    safe_link "$DOTFILES_DIR/nvim/kickstart" "$NVIM_CONFIG/lua/kickstart" "-sfn"
    safe_link "$DOTFILES_DIR/nvim/custom" "$NVIM_CONFIG/lua/custom" "-sfn"
}

# -----------------------------
# Homebrew Installation
# -----------------------------
install_homebrew() {
    if command_exists brew; then
        log_info "Homebrew already installed"
        brew update
        return
    fi
    
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for this session
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" 2>/dev/null || true
}

# -----------------------------
# Neovim Installation
# -----------------------------
install_neovim() {
    if command_exists nvim; then
        log_info "Neovim already installed ($(nvim --version | head -n1))"
        return
    fi
    
    log_info "Installing Neovim..."
    brew install neovim
    nvim --version
}

# -----------------------------
# System Packages
# -----------------------------
install_system_packages() {
    log_info "Updating apt repositories..."
    sudo apt update
    
    local packages=("ripgrep" "tmux" "fontconfig")
    
    for package in "${packages[@]}"; do
        if dpkg -l | grep -q "^ii  $package "; then
            log_info "$package already installed"
        else
            log_info "Installing $package..."
            sudo apt install -y "$package"
        fi
    done
    
    log_info "Verifying installations..."
    rg --version
    tmux -V
}

# -----------------------------
# Tmux Configuration
# -----------------------------
setup_tmux_config() {
    log_info "Setting up tmux configuration..."
    
    mkdir -p "$TMUX_CONFIG"
    
    local TPM_DIR="$TMUX_CONFIG/plugins/tpm"
    
    if [ -d "$TPM_DIR" ]; then
        log_info "TPM already installed"
    else
        log_info "Installing TPM (Tmux Plugin Manager)..."
        git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    fi

    safe_link "$DOTFILES_DIR/tmux/tmux.conf" "$TMUX_CONFIG/tmux.conf"
    safe_link "$DOTFILES_DIR/tmux/tmux-powerline" "$TMUX_CONFIG/tmux-powerline" "-sfn"
    
    log_info "Remember to press 'prefix + I' in tmux to install plugins"
}

# -----------------------------
# Nerd Fonts Installation
# -----------------------------
install_nerd_fonts() {
    log_info "Installing Nerd Fonts..."
    mkdir -p "$FONT_DIR"
    
    if fc-list | grep -i $NERD_FONT; then
        log_info "Nerd Font already installed"
        return
    fi
    
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    log_info "Downloading font $NERD_FONT..."
    wget -q "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/$NERD_FONT.zip"
    
    log_info "Extracting fonts..."
    unzip -o "$NERD_FONT.zip" -d "$FONT_DIR"
    
    cd - > /dev/null
    rm -rf "$temp_dir"
    
    log_info "Rebuilding font cache..."
    fc-cache -fv > /dev/null
}

# -----------------------------
# NVM & Node Installation
# -----------------------------
install_nvm_node() {
    export NVM_DIR="$HOME/.nvm"
    
    if [ ! -s "$NVM_DIR/nvm.sh" ]; then
        log_info "Installing NVM..."
        curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" | bash
    else
        log_info "NVM already installed"
    fi
    
    # Load NVM
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    
    log_info "Installing Node $NODE_VERSION..."
    nvm install "$NODE_VERSION"
    nvm use "$NODE_VERSION"
    
    log_info "Node version: $(node -v)"
}

# -----------------------------
# Node Package Managers
# -----------------------------
install_node_package_managers() {
    log_info "Installing Yarn..."
    npm install -g yarn
    
    if ! command_exists pnpm; then
        log_info "Installing pnpm..."
        curl -fsSL https://get.pnpm.io/install.sh | sh -
        export PNPM_HOME="$HOME/.local/share/pnpm"
        export PATH="$PNPM_HOME:$PATH"
    else
        log_info "pnpm already installed"
    fi
    
    log_info "Updating npm to latest..."
    npm install -g npm@latest
}

# -----------------------------
# Go Installation
# -----------------------------
install_go() {
    if command_exists go; then
        log_info "Go already installed ($(go version))"
        return
    fi
    
    log_info "Installing Go $GO_VERSION..."
    
    # Detect architecture
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) GO_ARCH="amd64" ;;
        aarch64|arm64) GO_ARCH="arm64" ;;
        *) log_error "Unsupported architecture: $ARCH"; return 1 ;;
    esac
    
    wget -q "https://go.dev/dl/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz" -O /tmp/go.tar.gz
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf /tmp/go.tar.gz
    rm /tmp/go.tar.gz
    
    # Add to PATH for current session
    export PATH=$PATH:/usr/local/go/bin
    
    log_info "Go version: $(go version)"
}

# -----------------------------
# Post-Installation Messages
# -----------------------------
print_post_install_info() {
    echo ""
    log_info "Installation completed successfully! 🎉"
    echo ""
    echo "Please add the following to your ~/.bashrc or ~/.zshrc:"
    echo ""
    echo "# Homebrew"
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
    echo ""
    echo "# Go"
    echo 'export PATH=$PATH:/usr/local/go/bin'
    echo ""
    echo "# NVM"
    echo 'export NVM_DIR="$HOME/.nvm"'
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
    echo ""
    echo "# pnpm"
    echo 'export PNPM_HOME="$HOME/.local/share/pnpm"'
    echo 'export PATH="$PNPM_HOME:$PATH"'
    echo ""
    echo "Then run: source ~/.bashrc"
    echo ""
}

# -----------------------------
# Main Installation Flow
# -----------------------------
main() {
    log_info "Starting dotfiles installation..."
    log_info "Dotfiles directory: $DOTFILES_DIR"
    
    setup_neovim_config
    install_homebrew
    install_neovim
    install_system_packages
    setup_tmux_config
    install_nerd_fonts
    install_nvm_node
    install_node_package_managers
    install_go
    
    print_post_install_info
}

# Run main function
main "$@"
