#!/bin/bash
sh -c "$(curl -fsSL https://github.com/Cabbagec/termux-ohmyzsh/raw/master/install.sh)"
sed -i '1 iexport PATH=$PATH:~/bin'  ~/.zshrc
