if [ "$1" != 'o' ] ; then
~/ubuntu-in-termux/startubuntu.sh
else
cd /sdcard/obsidian
git fetch --all
git reset --hard origin/master
git pull
fi
