---
title: Setting my Ubuntu environment
date: 2018-08-19 17:47:38
tags:
- ubuntu
- setup
---

I reinstalled my Thinkpad X220i with Windows 10, Ubuntu 18.04, OSX 10.13.6 recently, reinstall OS is always tedious.

- Sogou pinyin
- wps office
- net connections
- firefox and chrome plugins
- vim and ycm
- anaconda with vscode
- web site accounts: github, coding, gitee, stackoverflow, dockerhub, edx, coursera, google
- setup git
-
-

```bash
# download required files into "download" directory

sudo sed -i 's#http://cn.archive.ubuntu.com/#https://mirrors.ustc.edu.cn/#g' /etc/apt/sources.list
sudo apt update

sudo apt purge ibus
sudo apt install firmware-b43-installer fcitx shadowsocks polipo vim git gcc g++ make cmake

sudo dpkg -i wps
sudo dpkg -i sogou
./Anaconda

git config --global user.email "foo@bar.com"
git config --global user.name "foo bar"
git config --global credential.helper store
```

