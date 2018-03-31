# vim:set ft=dockerfile:
# docker build . -t chenxinaz/node:8-alpine

FROM node:8-alpine

RUN  sed -i "s#http://dl-cdn.alpinelinux.org#https://mirrors.tuna.tsinghua.edu.cn#g" /etc/apk/repositories \
  && echo -e "  \n\
    registry=https://registry.npm.taobao.org/ \n\
    NVM_NODEJS_ORG_MIRROR=http://npm.taobao.org/mirrors/node \n\
    NVM_IOJS_ORG_MIRROR=http://npm.taobao.org/mirrors/iojs \n\
    PHANTOMJS_CDNURL=https://npm.taobao.org/dist/phantomjs \n\
    ELECTRON_MIRROR=http://npm.taobao.org/mirrors/electron/ \n\
    SASS_BINARY_SITE=http://npm.taobao.org/mirrors/node-sass \n\
    SQLITE3_BINARY_SITE=http://npm.taobao.org/mirrors/sqlite3 \n\
    PYTHON_MIRROR=http://npm.taobao.org/mirrors/python" >> ~/.npmrc

