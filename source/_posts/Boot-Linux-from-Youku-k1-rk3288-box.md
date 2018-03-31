---
title: Boot Linux from Youku-k1 rk3288 box
date: 2018-02-14 19:43:31
tags:
---
```
# plugin sd card, find out which is it
lsblk
# assume we see /sdb here
```

It may be a rk3066 board..
```
cd kernel
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- rockchip_linux_defconfig
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j4
```
