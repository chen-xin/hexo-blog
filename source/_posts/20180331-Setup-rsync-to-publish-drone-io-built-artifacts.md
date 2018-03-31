---
title: Setup rsync to publish drone.io built artifacts
date: 2018-03-31 20:11:30
categories:
- dev
- tools
tags:
- rsync
- drone.io
---

In [This article](../../../2018/03/27/Integrate-all-self-hosted-drone-io-with-gitea/) we managed to setup drone to automate build and publish a project, but the publish part was inconvenient: using "cp" to publish artifacts means we have to mount target volume, which would not be accessable if we want to publish to remote host, and extra config to set the registry "trusted".

"rsync is an open source utility that provides fast incremental file transfer." With this incremental feather, we can omit redundant publish of unchanged resources, like pictures added to project long long ago.

In this article, we compose the following tasks:

- build the docker image for rsync publishing
- add rsync server to all-self-hosted develop environment with drone.io
- update the drone pipeline to use the new publish method

build the docker image for rsync publishing
===========================================

All we needed was 3 additional packages based the official Alpine image: rsync, openssh and sshpass. I'd post the foll Dockerfile here and explane the instructions below:

```Dockerfile
# vim:set ft=dockerfile:

FROM alpine
MAINTAINER Chen Xin chenxin.az@outlook.com

# set mirror if required
# use:
#   docker build -t chenxinaz/sshrsync --build-arg CN_MIRROR=1 .
# another mirror:
#   https://mirror.tuna.tsinghua.edu.cn/alpine/$OS_VER/main/ 

ARG CN_MIRROR=0
RUN if [ $CN_MIRROR = 1 ] ; \
  then OS_VER=$(grep main /etc/apk/repositories | sed 's#/#\n#g' | grep "v[0-9]\.[0-9]") \
    && echo "using mirrors for $OS_VER" \
    && echo https://mirrors.ustc.edu.cn/alpine/$OS_VER/main/ > /etc/apk/repositories; \
  fi \
  && apk add --no-cache rsync openssh sshpass\
  && sed -ri 's/^#PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config

COPY entrypoint.sh /

EXPOSE 873

CMD ["/entrypoint.sh"]
```
- *ARGCN_MIRROR:* set this argiment at image build time to accelerate build progress.
- *The "sed -ri..." line:* enable root login
- *CMD ["/entrypoint.sh"]:* `entrypoint.sh` starts sshd and rsync in daemon mode, I use `CMD` in Dockerfile so we can use this image as a rsync client without start the servers by specifying command in runtime.

In the `entrypoint.sh`, we configure rsync to use utf-8(this may not needed with ssh, not tested yet), generate host keys for sshd, set root password via environment arguments, then start the sshd and rsync servers. The `touch /inited` line is used to indicate that host key generation and root password setting should only run in for the first time. The full content is following:

```bash
#!/bin/sh

# sshpass -p ${ROOT_PASSWORD} rsync --progress -avz *  root@server:/data

cat <<EOF> /etc/rsyncd.conf
charset = utf-8
EOF

if [ ! -f /inited ]; then
  ssh-keygen -A
  if [ ${ROOT_PASSWORD} ]; then
    echo "root:${ROOT_PASSWORD}" | chpasswd
  fi
  touch /inited
fi

/usr/sbin/sshd

/usr/bin/rsync --daemon --no-detach --log-file /dev/stdout
```

**Security Note**

The above config allows rsync to write to **ANY** directory in server, thus should not use in production, and requires cautious with target directories.

add rsync server to all-self-hosted develop environment with drone.io
=============================================================

Add the following part to the docker-compose.yml file in [This article](../../../2018/03/27/Integrate-all-self-hosted-drone-io-with-gitea/), we need a rsync server for this all-self-hosted environment. To publish to remote server, you would not need this.

```yaml
  rsync:
    image: chenxinaz/sshrsync
    environment:
      - ROOT_PASSWORD=foofoo
    volumes:
      - www:/www
    networks:
      www:
```
What's in the above config:
- create a service using our rsync container
- setup root password with environment variable, this was defined in the image's entrypoint script. Since this container expose no port, it does not matter writing simple plan text password here
- mount target volume: www
- connect to network www, which drone's workspace connects to 

update the drone pipeline to use the new publish method
======================================================

The publish stage would be:

```
  publish:
    image: chenxinaz/sshrsync
    environment:
      - ROOT_PASSWORD=foofoo
    commands:
      - mkdir -p ~/.ssh
      - ssh-keyscan rsync > ~/.ssh/known_hosts
      - sshpass -p $${ROOT_PASSWORD} rsync -avz public/  root@rsync:/www/nginx/html/
```
In the above config, we:
- use the new image we built in client mode to do the publish work
- transport root password via environment vaiable. You can specify the password idrectly in the last line, while environment variable would be more explict, so we know what to change in next project.
- pre fetch host key with `ssh-keyscan`, so there would be no prompt on accepting esda keys.
- run rsync with sshpass, so no ssh login password would prompted.

Pitfalls on the rsync protocal
==============================
I first tried to run rsync without ssh, it do transfered, but with error message like "failed to set permission on .1.txt.AbcF1G" for each file, with a dot prefix and a base64 extension suffix of my original filename. I assume them temporary or partial files during transfer. It takes me a couple of days to getrid of them:

- run server as root: file transfered with correct permissions, but has errors and rsync return 1, which cause drone.io to decide build failed
- specify --partial-dir, --temp-dir: still have errors with different directory
- setup server to run as nobody with "fake super": will lost permissions on target

I googled a lot, few informations allocated, none satisfied my problem. Then I noticed **"Also note that the rsync daemon protocol does not currently provide any encryption of the data that is transferred over the connection. Only authentication is provided. Use ssh as the transport if you want encryption. "** in rsync.conf's manpage. We can hardly image some server allow data transfer unencrypted nowadays, so ssh was what we should use. 

The ssh login prompt and esda key prompt killed quit some time, finally I managed to resolved them with `ssh-keyscan` and `sshpass`. Thanks Google, StackOverflow, and rsync ofcause.

