#!/bin/bash
set -euo pipefail

echo "=== Linux Mint Dev Environment Setup ==="

# Update system
# sudo apt update && sudo apt upgrade -y

# --- Dependencies & basic tools ---
sudo apt install -y \
  git curl wget unzip build-essential cmake gettext \
  ninja-build pkg-config autoconf automake libtool libtool-bin \
  ripgrep fd-find kitty vim python3-pip

# fd is installed as fdfind on Debian/Ubuntu-based distros — create symlink
if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
  sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
fi

# --- NVM & Node 25 ---
echo "Installing nvm..."
export NVM_DIR="$HOME/.nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
# Load nvm immediately
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

echo "Installing Node.js 25..."
nvm install 25
nvm use 25
nvm alias default 25

# --- Claude Code ---
echo "Installing Claude Code..."
npm install -g @anthropic-ai/claude-code

# --- Podman & podman-compose ---
echo "Installing Podman..."
sudo apt install -y podman
pip3 install --user --break-system-packages podman-compose

# --- Neovim >= 0.11.2 (built with LuaJIT) ---
echo "Building Neovim from source..."
NVIM_VERSION="v0.11.2"
cd /tmp
rm -rf neovim
git clone --depth 1 --branch "$NVIM_VERSION" https://github.com/neovim/neovim.git
cd neovim
make CMAKE_BUILD_TYPE=Release
sudo make install
cd ~

# --- fzf (latest) ---
echo "Installing fzf..."
rm -rf ~/.fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all --no-bash --no-zsh --no-fish 2>/dev/null || ~/.fzf/install --all

# --- lazygit ---
echo "Installing lazygit..."
LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
cd /tmp
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/
cd ~

# --- Nerd Font (JetBrainsMono) ---
echo "Installing JetBrainsMono Nerd Font..."
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
cd /tmp
curl -Lo jetbrains.zip "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
unzip -o jetbrains.zip -d "$FONT_DIR/JetBrainsMono"
fc-cache -fv
cd ~

# --- Google Chrome ---
echo "Installing Google Chrome..."
cd /tmp
curl -Lo google-chrome.deb "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
sudo apt install -y ./google-chrome.deb
cd ~

# --- Summary ---
echo ""
echo "=== Done! ==="
echo "Restart your terminal (or run 'source ~/.bashrc') to pick up nvm/fzf."
echo ""
echo "Installed:"
command -v nvim && nvim --version | head -1
command -v git && git --version
command -v node && echo "Node $(node -v)"
command -v podman && podman --version
command -v lazygit && lazygit --version 2>&1 | head -1
command -v fzf && echo "fzf $(fzf --version)"
command -v rg && echo "ripgrep $(rg --version | head -1)"
command -v kitty && echo "kitty $(kitty --version)"
command -v google-chrome-stable && google-chrome-stable --version
command -v vim && echo "vim $(vim --version | head -1)"
command -v claude && echo "Claude Code $(claude --version)"
echo "Nerd Font: JetBrainsMono installed in $FONT_DIR"
