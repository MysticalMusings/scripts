#!/bin/bash
sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/termux-packages-24 stable main@' $PREFIX/etc/apt/sources.list
apt-get update && apt-get upgrade -y
apt-get install wget git proot -y
cd ~
git clone https://github.com/MFDGaming/ubuntu-in-termux.git
cd ubuntu-in-termux
chmod +x ubuntu.sh
./ubuntu.sh -y
echo  -e "\n\n输入./ubuntu-in-termux/startubuntu.sh运行"
