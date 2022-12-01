#!/bin/bash
cd ~/speedtest/cloudflare
git fetch --all
git reset --hard origin/master
git pull
cat * > all.txt
cd ../OpenBullet2

# 需要修改配置路径
echo | dotnet OpenBullet2.Console.dll --bots 100 --config ../cf.opk -v -w ../cloudflare/all.txt --wltype Default | grep -o "[0-9].*$" > ../output.txt
cd ..

# 修改测速网址
./CloudflareST -t 7 -dt 7 -f ip.txt -dn 10 -o best.csv -allip -t 7 -p 10 -url https://cloudflaremirrors.com/archlinux/images/latest/Arch-Linux-x86_64-basic.qcow2
rm output.txt