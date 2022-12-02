#!/bin/bash
apt-get update && apt-get upgrade -y
apt-get install wget unzip libicu-dev -y

# dotnet
wget https://download.visualstudio.microsoft.com/download/pr/67ca3f83-3769-4cd8-882a-27ab0c191784/bf631a0229827de92f5c026055218cc0/dotnet-sdk-6.0.403-linux-arm64.tar.gz
mkdir -p $HOME/dotnet && tar zxf dotnet-sdk* -C $HOME/dotnet
rm dotnet-sdk*
sed -i '1 iexport DOTNET_ROOT=$HOME/dotnet\nexport PATH=$PATH:~/bin:$HOME/dotnet' ~/.zshrc
export DOTNET_ROOT=$HOME/dotnet
export PATH=$PATH:~/bin:$HOME/dotnet

# speedtest
mkdir speedtest
wget -P ./speedtest https://github.com/XIU2/CloudflareSpeedTest/releases/download/v2.1.0/CloudflareST_linux_arm64.tar.gz
cd speedtest
tar xfv CloudflareST_linux_arm64*
rm CloudflareST_linux_arm64*

# cloudflare ip地址
git clone git@github.com:ip-scanner/cloudflare.git

# openbullet
mkdir OpenBullet2
cd OpenBullet2
wget https://github.com/openbullet/OpenBullet2/releases/download/0.2.4/OpenBullet2.Console.zip
unzip OpenBullet2*
rm OpenBullet2.Console.zip

# 测速脚本
wget -P ~/bin https://raw.githubusercontent.com/luminislight/scripts/main/termux/ubuntu/speedtest/speedtest.sh
mv ~/bin/speedtest.sh ~/bin/a
chmod +x ~/bin/a
