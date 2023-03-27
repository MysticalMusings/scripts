#!/bin/bash
sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/termux-packages-24 stable main@' $PREFIX/etc/apt/sources.list
apt update && apt upgrade -y
apt install openssh -y
sh -c "$(curl -fsSL https://github.com/Cabbagec/termux-ohmyzsh/raw/master/install.sh)"
sed -i '1 iexport PATH=$PATH:~/bin'  ~/.zshrc
cat << EOF > ~/.ssh/config
Host github.com
Hostname ssh.github.com
Port 443
User git
EOF
