#!/bin/bash
# get zsh, starship and hetbrains font
sudo dnf install zsh starship jetbrains-mono-fonts-all -y

# get oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# copy conbfig files
cp ./zshrc ~/.zshrc
cp ./starship.toml ~/.config/starship.toml
cp ./custom ~/.oh-my-zsh
sudo cp -r ./ls-std.profile ~/.local/share/konsole


# use zsh as std
sudo chsh -s $(which zsh) $USER
