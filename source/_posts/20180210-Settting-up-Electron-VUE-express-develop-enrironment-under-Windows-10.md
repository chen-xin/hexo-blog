---
title: 'Settting up Electron, VUE, express develop enrironment under Windows 10'
date: 2018-02-10 18:24:45
categories:
- dev
tags:
- electron
- vue
- js
- windows
---

Native node modules
-------------------
Since the node version installed might be different from what electron uses, that prevents some local native codes run inside electron, e.g. sqlite3. it would be convinent to prepare native node module build toolsets.

### Steps

1. Refer to https://github.com/nodejs/node-gyp and follow the instructions to setup Visual C++ Build Environment and Python 2.7.
2. Config node-gyp to use installed build tools:
```
npm config set msvs_version 2015
npm config set python /path/to/executable/python2.7
```
3. Edit ~/.npmrc to setup npm mirrors:
```
registry=https://registry.npm.taobao.org/
sass_binary_site=https://npm.taobao.org/mirrors/node-sass/
phantomjs_cdnurl=http://npm.taobao.org/mirrors/phantomjs
ELECTRON_MIRROR=http://npm.taobao.org/mirrors/electron/
python=c:/Python27/python.exe
msvs_version=2015
```
We can see that the msvs_version and python config of the previous step was already there, this means we can edit this file directly to set these config parameters.

4. Clean install required modules:
```
cd <project directory>
yarn cache clean
yarn
yarn add sqlite3 electron electron-rebuild --dev
node_modules/.bin/electron-rebuild
node_modules/.bin/electron-rebuild -a ia32
```
For the network issue of cn, the `electron-rebuild` command might fail for several times, just restart to have all required packages downloaded to ~/.node-gyp.

5. Check build result: `ls -R node_modules/sqlite3/lib/binding` should show 3 directories like:
```
electron-v1.7-win32-ia32/
electron-v1.7-win32-x64/
node-v48-win32-x64/
```
6. Run & test

