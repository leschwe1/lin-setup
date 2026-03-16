#!/bin/bash

cp ~/.zshrc ./.zshrc
cp ~/.config/starship.toml ./starship.toml
cp -r ~/.oh-my-zsh/custom/* ./custom/
cp ~/.local/share/konsole/ls-std.profile ./ls-std.profile


git add .
git commit -m "Update config: $(date +'%Y-%m-%d %H:%M')"
git push origin master