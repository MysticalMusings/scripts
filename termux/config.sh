#!/bin/bash
curl -fsSL https://github.com/Cabbagec/termux-ohmyzsh/raw/master/install.sh | bash
sed -i '1 iexport PATH=$PATH:~/bin' ~/.zshrc
