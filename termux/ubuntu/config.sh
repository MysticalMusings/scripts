#!/bin/bash
apt update && apt upgrade -y
apt install zsh curl git vim ssh -y
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

sed -i '1 iexport PATH=$PATH:~/bin' ~/.zshrc
export PATH=$PATH:~/bin
cat << EOF > ~/.ssh/config
Host github.com
Hostname ssh.github.com
Port 443
User git
EOF