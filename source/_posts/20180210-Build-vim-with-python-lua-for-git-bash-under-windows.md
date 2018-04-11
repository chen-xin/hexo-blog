---
title: 'Build vim with python, lua for git bash under windows'
date: 2018-02-10 20:14:50
categories:
- dev
- tools
tags:
- vim
- msys
- python
---

On how to build vim for git-bash with lua, python, python3 feathers.

Preface
=========

Git-bash comes with a set of commandline tool that ALMOST satisfy all my needs, it even has a up-to-date vim included, which says:


```
VIM - Vi IMproved 8.0 (2016 Sep 12, compiled Dec 14 2017 09:34:59)
包含补丁: 1-1305
编译者 chen_x@DESKTOP-S3M9UF8
巨型版本 无图形界面。  可使用(+)与不可使用(-)的功能:
+acl             +comments        +farsi           +langmap         +mouse_netterm   +printer         +tag_binary      +visual
+arabic          +conceal         +file_in_path    +libcall         +mouse_sgr       +profile         +tag_old_static  +visualextra
+autocmd         +cryptv          +find_in_path    +linebreak       -mouse_sysmouse  +python/dyn      -tag_any_white   +viminfo
-autoservername  +cscope          +float           +lispindent      +mouse_urxvt     +python3/dyn     -tcl             +vreplace
-balloon_eval    +cursorbind      +folding         +listcmds        +mouse_xterm     +quickfix        +termguicolors   +wildignore
-browse          +cursorshape     -footer          +localmap        +multi_byte      +reltime         +terminal        +wildmenu
++builtin_terms  +dialog_con      +fork()          +lua             +multi_lang      +rightleft       +terminfo        +windows
+byte_offset     +diff            +gettext         +menu            -mzscheme        +ruby/dyn        +termresponse    +writebackup
+channel         +digraphs        -hangul_input    +mksession       +netbeans_intg   +scrollbind      +textobjects     -X11
+cindent         -dnd             +iconv           +modify_fname    +num64           +signs           +timers          -xfontset
-clientserver    -ebcdic          +insert_expand   +mouse           +packages        +smartindent     +title           -xim
+clipboard       +emacs_tags      +job             -mouseshape      +path_extra      +startuptime     -toolbar         -xpm
+cmdline_compl   +eval            +jumplist        +mouse_dec       +perl/dyn        +statusline      +user_commands   -xsmp
+cmdline_hist    +ex_extra        +keymap          -mouse_gpm       +persistent_undo -sun_workshop    +vertsplit       -xterm_clipboard
+cmdline_info    +extra_search    +lambda          -mouse_jsbterm   +postscript      +syntax          +virtualedit     -xterm_save
     系统 vimrc 文件: "/etc/vimrc"
     用户 vimrc 文件: "$HOME/.vimrc"
 第二用户 vimrc 文件: "~/.vim/vimrc"
      用户 exrc 文件: "$HOME/.exrc"
       defaults file: "$VIMRUNTIME/defaults.vim"
         $VIM 预设值: "/usr/share/vim"
编译方式: gcc -c -I. -Iproto -DHAVE_CONFIG_H   -I/usr/include/ncursesw  -g -O2 -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=1
链接方式: gcc   -L. -pipe -fstack-protector  -L/usr/local/lib -Wl,--as-needed -o vim.exe        -lm    -lncursesw -liconv -lacl -lintl  -L/usr/local/l
ib -llua -Wl,--enable-auto-import -Wl,--export-all-symbols -Wl,--enable-auto-image-base -fstack-protector-strong  -L/usr/lib/perl5/core_perl/CORE -lpe
rl -lpthread -ldl -lcrypt
```

But according to [this issue](https://github.com/git-for-windows/git/issues/827), there would be no python in the official git-for-windows releases, it causes many popular plugins unable to work under git-bash vim. Some people [suggested](https://stackoverflow.com/questions/33519853/how-do-i-add-python-support-in-vim-in-git-bash) to use msys instead.

I tried, but encountered some other problem, like  [git-credential-cache](https://stackoverflow.com/questions/11693074/git-credential-cache-is-not-a-git-command). It bores me to get msysgit work as git-for-windows, then I tried to compile my vim for git-bash.

As a newbee, I struggled days to figure out that msys and mingw are quiet different things, finally make my way out to get my vim with python/python3/lua under git-bash. Here are the steps.

Install msys64
==============

Download msys2-x86_64-*yyyymmdd*.exe from [Msys2](http://www.msys2.org/) and install to `c:\msys64`.

We can make some convinent settings(optional):

Start the msys shell and enter the following lines:

```
cat <<EOF>> /etc/minttyrc
BoldAsFont=yes
Columns=150
Rows=50
Font=Source Code Pro
FontHeight=10
Transparency=off
OpaqueWhenFocused=no
CursorType=underscore
EOF

echo "alias ls='ls --color'" >> /etc/bash.bashrc

```

Associate msys shell in windows right-button menu(optional):

Create an `a.reg` file as following and import into the windows regestry:
```
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\Directory\Background\shell\msys]
@="Open MSYS64 here"
"Icon"="C:\\dev_tools\\msys64\\msys2.ico"

[HKEY_CLASSES_ROOT\Directory\Background\shell\msys\command]
@="C:\\dev_tools\\msys64\\msys2_shell.cmd -here"

```

Add pacman mirrors(optional):

In the msys shell, run the following commands:
```
sed -i '1i Server = http://mirrors.ustc.edu.cn/msys2/mingw/i686' /etc/pacman.d/mirrorlist.mingw32
sed -i '1i Server = http://mirrors.ustc.edu.cn/msys2/mingw/x86_64' /etc/pacman.d/mirrorlist.mingw64
sed -i '1i Server = http://mirrors.ustc.edu.cn/msys2/msys/$arch' /etc/pacman.d/mirrorlist.msys

```
Synchronize package databases with `pacman -Syu`. May need to kill the terminal and re-run `pacman -Su`.

Install dev packages:

```
pacman -S base-devel binutils python3 ruby ncurses-devel libcrypt-devel gcc
```

Build vim from source:
=======================

I choose to build from [Package scripts for MSYS2 ](https://github.com/Alexpux/MSYS2-packages/vim), for it is quit update-to-date and with patches to work friendly under msys.

```
# if you don't have msysgit, run the next command under git-bash
git clone https://github.com/Alexpux/MSYS2-packages.git

# the following comamnds run under msys
cd MSYS2-packages/vim
makepkg

```

Package vim:

The previous step do created a vim package for pacman, but git-bash dosn't have one. So pack for ourself:

```
cd MSYS2-packages/vim/src
make DESTDIR=/d/downloads/vim_install install
cd /d/downloads/vim_install
tar zcf vim_install.tar.gz ./ /usr/lib/python* /usr/bin/msys-python*.dll
```

Copy vim to git-bash
=====================
In git-bash, run the following:

```
tar zxvf /d/downloads/vim_install/vim_install.tar.gz -C /
```

Now start vim from git-bash and run simple test: 
```
:py3 print(2+1)
```

Next steps
===========
Configure vim, setup plugins like vundle, youcompleteme, etc.
