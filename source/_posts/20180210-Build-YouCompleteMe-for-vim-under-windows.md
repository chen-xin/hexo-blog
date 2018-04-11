---
title: Build YouCompleteMe for vim under windows
date: 2018-02-10 20:20:09
categories:
- dev
- tools
tags:
- vim
- youcompleteme
- windows
---

I have get vim under git-bash work with python, now it's time to setup YouCompleteMe, the most powerful vim completion plugin ever. 
There is no binary packages for ycm under windows found, so install from source is the only option. 

Prerequists
=============

- vim with python, like [this](../Build-vim-with-python-lua-for-git-bash-under-windows)
- Visual C++ x64 Native Build Tools, from Misrosoft.

Get sources
===========

The following steps do clone ycm from github to some directory, I do this to figure out what is all required for my other computer, in which I shall not do the boring build steps again. Simply install it from vundle works enough.

``` Bash
# under git-bash

cd /d/downloads
mkdir vim_install
cd vim_install
git clone https://github.com/Valloric/YouCompleteMe.git
cd YouCompleteMe
# wait long time for the following command to finish
git submodule update --init --recursive

```

Build
=========

open "Visual C++ 2015 x64 Native Build Tools Command Prompt" and run the following commands, change msvc version as what is installed:

``` bash
cd d:\downloads\vim_install\YouCompleteMe
PATH=%PATH%;D:\downloads\vim_install\cmake-3.10.1-win64-x64\bin
set EXTERNAL_LIBCLANG_PATH=D:/downloads/vim_install/LLVM-5.0.0-win64
set EXTRA_CMAKE_ARGS=-DPATH_TO_LLVM_ROOT=d:/downloads/vim_install/LLVM-5.0.0-win64
# (we have set llvm_root in the above line) 
python install.py --msvc 14 --build-dir d:/downloads/vim_install/ycm_build --clang-completer --js-completer

# Another try 
cmake -G "Visual Studio 14 Win64" \
  -DPATH_TO_LLVM_ROOT=d:/downloads/vim_install/LLVM-5.0.0-win64 \
  -DPYTHON_EXECUTABLE:FILEPATH=c:/dev_tools/Python36/python.exe \
  -DPYTHON_LIBRARYS=C:/dev_tools/Python36/libs \
  -DPYTHON_INCLUDE_DIR=C:/dev_tools/Python36/include . ../YouCompleteMe/third_party/ycmd/cpp \
  && cmake --build . --target ycm_core --config Release

```

fix windows path under msys with Tern:
create a file `~/.vim/bundle/YouCompleteMe/third_party/ycmd/ycmd/completers/javascript/msys_path_fix.py` as follow:

``` python
import platform
import re

def fix_path (path):
    p = path
    if platform.system() == 'Windows' and re.match('^/[a-z]/.*', path, re.I):
        p = p[1] + ':' + p[2:]
    return p

if __name__ == '__main__':
    print(fix_path('/c/aa/bb.proj'))

    print(fix_path('c:\\aa\cc\\1.js'))

```

then edit the `tern_completer.py` in same folder, add line in header part:

```python
from . import msys_path_fix
```

add line to last of `_SetServerProjectFileAndWorkingDirectory`:

``` python
  def _SetServerProjectFileAndWorkingDirectory( self, request_data ):
    filepath = request_data[ 'filepath' ]
    self._server_project_file = FindTernProjectFile( filepath )
    if not self._server_project_file:
      _logger.warning( 'No .tern-project file detected: %s', filepath )
      self._server_working_dir = os.path.dirname( filepath )
    else:
      _logger.info( 'Detected Tern configuration file at: %s',
                    self._server_project_file )
      self._server_working_dir = os.path.dirname( self._server_project_file )
    # the next line add to fix path problem
    self._server_working_dir = msys_path_fix.fix_path(self._server_working_dir)
    _logger.info( 'Tern paths are relative to: %s', self._server_working_dir )

```


Save for future use:
===================
```bash
# under git-bash

tar zcvf ycm.bin.tar.gz YouCompleteMe/third_party/ycmd/ycm_core.pyd YouCompleteMe/third_party/ycmd/libclang.dll

```

~/.tern-config

```json
{
    "libs": [
        "browser",
        "underscore",
        "jquery"
            ],
        "plugins": {
          "node": {}
        }
}

```

~/.vimrc
=========
```vim
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
Plugin 'tpope/vim-fugitive'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'tomasiser/vim-code-dark'
Plugin 'sheerun/vim-polyglot'
" Plugin 'shougo/neocomplete.vim'
" Plugin 'pangloss/vim-javascript'
" Plugin 'posva/vim-vue'
Plugin 'scrooloose/nerdtree'
Plugin 'Valloric/YouCompleteMe'
" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append  to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append  to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append  to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
"
set number
set statusline+=%{StatuslineGit()}
syntax on
set t_Co=256
set t_ut=
colorscheme codedark
" let g:airline_theme = 'codedark'

" let g:neocomplete#enable_at_startup = 1
autocmd vimenter * NERDTree
set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab
let g:ycm_python_binary_path = 'python'

autocmd Filetype html setlocal ts=2 sts=2 sw=2
autocmd Filetype ruby setlocal ts=2 sts=2 sw=2
autocmd Filetype javascript setlocal ts=2 sts=2 sw=2

```
