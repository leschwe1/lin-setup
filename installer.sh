#!/bin/bash
# Stoppe das Skript bei Fehlern
set -e

echo "--- Starte Setup ---"

# 1. Zsh und Fonts installieren (Starship hier entfernt)
sudo dnf install zsh jetbrains-mono-fonts-all curl util-linux-user -y

sudo dnf install fastfetch -y


# 2. Starship installieren (Offizieller Weg für Fedora)
if ! command -v starship &> /dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# 3. Oh My Zsh installieren (unattended verhindert das automatische Starten der Zsh)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installiere Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 4. Verzeichnisse erstellen
mkdir -p ~/.config
mkdir -p ~/.local/share/konsole
mkdir -p ~/.oh-my-zsh/custom/

# 5. Config Files kopieren
echo "Kopiere Konfigurationen..."
cp ./.zshrc ~/.zshrc
cp ./starship.toml ~/.config/starship.toml

# Falls der Ordner ./custom/ existiert, Inhalt kopieren
if [ -d "./custom" ]; then
    cp -r ./custom/* ~/.oh-my-zsh/custom/
fi

if [ -f "./ls-std.profile" ]; then
    cp ./ls-std.profile ~/.local/share/konsole/
fi

# 6. Zsh als Standard-Shell setzen (OHNE sudo für den aktuellen User)
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Setze Zsh als Standard-Shell..."
    chsh -s $(which zsh)
fi

echo "--- Setup abgeschlossen! Bitte einmal aus- und einloggen. ---"
