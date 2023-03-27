#!/bin/bash
apt-get update && apt-get upgrade -y
apt-get install wget git proot -y
cd ~
git clone https://github.com/MFDGaming/ubuntu-in-termux.git
cd ubuntu-in-termux
chmod +x ubuntu.sh
./ubuntu.sh -y
echo  -e "\n\n输入 ./ubuntu-in-termux/startubuntu.sh 运行，安装zsh后在startubuntu.sh中更改默认shell"
