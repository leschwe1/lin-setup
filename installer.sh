
#!/usr/bin/env bash
set -Eeuo pipefail

# Always run relative to this repository
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

echo "Installing Fedora workstation configuration..."

# Install packages
sudo dnf install -y \
    zsh \
    starship \
    jetbrains-mono-fonts-all \
    curl \
    git \
    jq \
    coreutils

# Install Oh My Zsh if missing
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "Installing Oh My Zsh..."
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Create configuration directories
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/share/konsole"
mkdir -p "$HOME/.oh-my-zsh/custom/plugins"
mkdir -p "$HOME/.oh-my-zsh/custom/themes"

# Install Zsh configuration
install -Dm644 .zshrc "$HOME/.zshrc"

# Install Starship configuration
install -Dm644 config/starship.toml \
    "$HOME/.config/starship.toml"

# Install Konsole profile
install -Dm644 config/console/ls-std.profile \
    "$HOME/.local/share/konsole/ls-std.profile"

# Install custom Oh My Zsh plugins
cp -a oh-my-zsh/plugins/. "$HOME/.oh-my-zsh/custom/plugins/"

# Install custom Oh My Zsh themes and files
cp -a oh-my-zsh/themes/. "$HOME/.oh-my-zsh/custom/themes/"

# Install additional custom files, if present
if [[ -f oh-my-zsh/example.zsh ]]; then
    install -Dm644 oh-my-zsh/example.zsh \
        "$HOME/.oh-my-zsh/custom/example.zsh"
fi

# Set Zsh as default shell
ZSH_PATH="$(command -v zsh)"
if [[ "$SHELL" != "$ZSH_PATH" ]]; then
    sudo chsh -s "$ZSH_PATH" "$USER"
fi

# Install massCode
if [[ -f scripts/install-masscode.sh ]]; then
    echo
    read -r -p "Install massCode as well? [y/N] " INSTALL_MASSCODE
    if [[ "$INSTALL_MASSCODE" =~ ^[Yy]$ ]]; then
        ./scripts/install-masscode.sh
    fi
fi

echo
echo "Setup completed!"
echo "Restart your terminal session to use Zsh."

