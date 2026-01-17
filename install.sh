#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
NVIM_CONFIG="$XDG_CONFIG_HOME/nvim"

mkdir -p "$NVIM_CONFIG/lua"

ln -sf ~/repos/dotfiles/.bashrc ~/.bashrc
ln -sf ~/repos/dotfiles/.fancy-bash-prompt.sh ~/.fancy-bash-prompt.sh
ln -sf "$DOTFILES_DIR/nvim/lazy-lock.json" "$NVIM_CONFIG/lazy-lock.json"
ln -sf "$DOTFILES_DIR/nvim/init.lua" "$NVIM_CONFIG/init.lua"
ln -sfn "$DOTFILES_DIR/nvim/kickstart" "$NVIM_CONFIG/lua/kickstart"
ln -sfn "$DOTFILES_DIR/nvim/custom" "$NVIM_CONFIG/lua/custom"

sudo apt update

# -----------------------------
# Variables
# -----------------------------
NVM_VERSION="v0.40.3"
NODE_VERSION="v24"
RIPGREP_VERSION="14.1.1"
GO_VERSION="1.25.6"
NERD_FONT="3270.zip"
FONT_DIR="$HOME/.local/share/fonts"

# -----------------------------
# Homebrew Installation (Linux)
# -----------------------------
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew already installed"
fi

brew update

# -----------------------------
# Install Neovim
# -----------------------------
if ! command -v nvim &>/dev/null; then
    echo "Installing Neovim..."
    brew install neovim
else
    echo "Neovim already installed"
fi

nvim --version

# -----------------------------
# Install ripgrep
# -----------------------------
echo "Installing ripgrep..."
sudo apt install -y ripgrep

echo "Verifying installation..."
rg -V

# -----------------------------
# Install tmux
# -----------------------------
echo "Installing ripgrep..."
sudo apt install -y tmux

echo "Verifying installation..."
tmux -V

# -----------------------------
# Install Nerd Font
# -----------------------------
mkdir -p "$FONT_DIR"
cd "$FONT_DIR"
if [ ! -f "$NERD_FONT" ]; then
    wget -q "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/$NERD_FONT"
    unzip -o "$NERD_FONT"
    rm -f "$NERD_FONT"
fi
sudo apt install -y fontconfig
fc-cache -fv

# -----------------------------
# Install NVM & Node
# -----------------------------
export NVM_DIR="$HOME/.nvm"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    curl -qO- "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" | bash
fi

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

nvm install "$NODE_VERSION"
nvm use "$NODE_VERSION"
node -v

# -----------------------------
# Install Yarn and PNPM
# -----------------------------
npm install -g yarn
curl -fsSL https://get.pnpm.io/install.sh | sh
source "$HOME/.bashrc"

npm install -g npm@11.7.0

# -----------------------------
# Install Go
# -----------------------------
if ! command -v go &>/dev/null; then
    echo "Installing Go..."
    wget -q "https://go.dev/dl/go${GO_VERSION}.linux-arm64.tar.gz" -O /tmp/go.tar.gz
    sudo tar -C /usr/local -xzf /tmp/go.tar.gz
    rm /tmp/go.tar.gz
    export PATH=$PATH:/usr/local/go/bin
fi

go version

echo "Setup completed successfully!"
