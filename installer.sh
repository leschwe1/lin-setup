#!/bin/bash
# get zsh, starship and hetbrains font
sudo dnf install zsh starship jetbrains-mono-fonts-all -y

# get oh my zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

mkdir -p ~/.config
mkdir -p ~/.local/share/konsole

# copy config files
cp ./.zshrc ~/.zshrc
cp ./starship.toml ~/.config/starship.toml
cp -r ./custom/* ~/.oh-my-zsh/custom/
cp ./ls-std.profile ~/.local/share/konsole/


# use zsh as std
sudo chsh -s $(which zsh) $USER

echo "Setup completed, restart console"
