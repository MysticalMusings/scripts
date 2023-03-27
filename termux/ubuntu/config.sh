#!/bin/bash
apt update && apt upgrade -y
apt install zsh curl git vim -y
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

sed -i '1 iexport PATH=$PATH:~/bin' ~/.zshrc
export PATH=$PATH:~/bin
