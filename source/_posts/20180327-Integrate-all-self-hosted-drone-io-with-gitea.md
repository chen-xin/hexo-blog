---
title: Integrate all-self-hosted drone.io with gitea
date: 2018-03-27 08:30:55
categories:
- dev
- tools
tags:
- drone.io
- gitea
- ci
---

"[Drone.io](https://drone.io) is an open source Continuous Delivery platform that automates your testing and release workflows". Drone has built in integration with many source code management systems, like Github, Gitlabs, Gogs and Gitea, Coding has an integration instruction in drone's document too. Drone is docker based, size of the two required image(drone/server, drone/agent) sum up to only 50MB and less, it has pretty modern ui, which attached me at the firet grance.

[Gitea](https://gitea.io) is forked from [Gogs](https://gogs.io), they are almost identical, even the "A painless self-hosted git service" annoncement. They both actually are what they annonced, Gogs is small(less then 160MB docker image), while Gitea is even smaller(70MB), that's why I perfer Gitea.

This article is about how to setup an all selfhosted continuous delivery environment with drone.io and gitea.

The site map
============

We have at least a gitea server and a drone server, for convinent, a web server should be included. We shall access all the services from the host machine, and the servers able connect to each other. 

For host machine's access to the serivces, we can expose all service ports to host machine, then we can visit them via "localhost:3000", "localhost:5000", etc, that's ugly. I tried to mount services under sub directories like "localhost/gitea", "localhost/drone", but end up with that drone does not support mounnting to a sub directory. Subdomain is the rescure. I hacked my hosts file and setup nginx reverse proxy to archive this.

the hosts file of the host machine:

> 127.0.0.1       www.xin.me
> 127.0.0.1       xin.me
> 127.0.0.1       gogs.xin.me
> 127.0.0.1       gitea.xin.me
> 127.0.0.1       jenkins.xin.me
> 127.0.0.1       drone.xin.me
> 127.0.0.1       demo.xin.me


the nginx conf of the nginx container, which exposes port 80:
```nginx
# vim:set ft=nginx:
server {
    listen 80;
    server_name xin.local www.xin.local _; # your_server_ip

    # Prevent ipv6 resolve in docker
    resolver 127.0.0.1 ipv6=off;
    access_log /var/log/nginx/www.access.log main;
    error_log /var/log/nginx/www.error.log warn;

    location / {
        root   /www/nginx/html;
        index  index.html index.htm;
    }
}

server {
    listen 80;
    server_name drone.xin.local;

    location / {
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Host $http_host;

        proxy_pass http://drone-server:8000;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_buffering off;

        chunked_transfer_encoding off;
    }
}

server {
    listen 80;
    server_name gitea.xin.local;

    # Prevent ipv6 resolve in docker
    resolver 127.0.0.1 ipv6=off;
    access_log /var/log/nginx/gitea.access.log main;
    error_log /var/log/nginx/gitea.error.log warn;

    location / {
        client_max_body_size 100m;
        proxy_pass http://gitea:3000/;
    }
}
```
Most above config were copied from drone and gitea's document, I am not going to discuss about them indepth here.

The compose file
================

Drone itself starts up with at lease 2 containers, one drone server and one or more drone agent, official document suggests run them by docker compose. With the same compose file we setup our nginx reverse proxy server and PostgreSQL(for gitea) together. 

Networks
--------

First we define two internal networks, a "www" network to connect all the exposed service, including nginx, gitea and drone, with the nginx server holding domain and subdomain names like "xin.local", "drone.xin.local", docker automaticlly assign a short host name to each service, like "gitea", "drone", so nginx can proxy to them by name instead of static assigned ip address. Part of the compose file looks like:

```yaml
networks:
  www:
services:
  www:
  image: nginx:alpine
  restart: always
  ports:
    - "80:80"
  volumes:
    - ./data/log/nginx:/var/log/nginx
    - ./conf/nginx/conf.d:/etc/nginx/conf.d
    - www:/www
  depends_on:
    - drone-server
    - gitea
  networks:
    www:
      aliases:
        - xin.local
        - gitea.xin.local
        - drone.xin.local

  drone:
    networks:
      www:
  gitea:
    networks:
      www:
```

In this config, when drone service want's access gitea, it visits "http://gitea.xin.local", which resolves to the nginx server, then nginx proxies the request to "http:gitea:3000" according to the previous nginx config, thus we make drone and gitea access each other through nginx reverse proxy, with the same domain name as the host machine. 
The above config also mounts host volumes for nginx log and config, we shall had created the log directory and put the nginx config we described in the first part of this articl into the config directory. And the named volume *www* is to persistantly hold static files, e.g. my hexo blog. We shall add named volumes to save persistant data for each service.

We also defined the dependicy for nginx, it should wait for drone-server and gitea start first, or nginx might complain site unaccessable and exit.

Drone service
-------------

Drone has a sample compose file for integrate with gitea, we can simply copy it and make some changes according to our environment. 

You should notice the `DRONE_NETWORK` line. If not explicitly defined, drone will create a new network for containers in pipeline, and that network will not be able to resolve our *gitea.xin.local* domain, that makes pipline fail on git clone stage. Thankfully we can assign one in compose file, as the following:

Another config option not in the drone's sample configure is the `DRONE_ADMIN`. If you need to mount volumes in pipline, e.g. cache build result, use copy to deploy, etc, you must set the repository to **Trusted** in repository setting, which only avaliable to drone admin user.

```yaml
  drone-server:
    image: drone/drone
    volumes:
      - drone:/var/lib/drone/
    restart: always
    environment:
      - DRONE_ADMIN=xin
      - DRONE_OPEN=true
      - DRONE_HOST=http://drone.xin.local
      - DRONE_GITEA=true
      - DRONE_GITEA_URL=http://gitea.xin.local
      - DRONE_SECRET=c676-9241-d916-3d6a
      - DRONE_NETWORK=devstack_www
    networks:
      www:
      postgres:

  drone-agent:
    image: drone/agent
    command: agent
    restart: always
    depends_on:
      - drone-server
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - DRONE_SERVER=drone-server:9000
      - DRONE_SECRET=c676-9241-d916-3d6a
    networks:
      www:
```

In the above config, we make drone use our *devstack_www* network, which is the *www* network in compose file's network section. Docker automatically append dirname to network name, in my case the directory holding my *docker-compose.yml* is *devstack*. We have to set the full name of the network so drone will use it for pipelines. If you are not sure what's the correct name of that network, you can run `docker network ls` after the compose up. Ofcause you can create an isolated network for pipelines, just make gitea connect to it with the same domain name.

Almost done, now what we should care about is all above. For the full docker compose file, see the end of this article.


the pipline 
===========

Let's create our first pipeline. First we copy the sample nodejs pipeline from drone's documents, then add npm and other required mirror configs to environment variables(Thanks to the greet fakking woll), mount our deploy target volume, and specify our build and deploy commands.

Note in the publish state I used `ls -alR public` to see what's actually generated, and `env | grep DRONE` to see what can we get from drone during pipeline.

```yaml
pipeline:
  build:
    image: node:8-alpine
    environment:
      - npm_config_registry=https://registry.npm.taobao.org/
      - SQLITE3_BINARY_SITE=http://npm.taobao.org/mirrors/sqlite3
      - ELECTRON_MIRROR=http://npm.taobao.org/mirrors/electron
      - SASS_BINARY_SITE=http://npm.taobao.org/mirrors/node-sass
      - phantomjs_cdnurl=https://npm.taobao.org/mirrors/phantomjs/
      - CHROMEDRIVER_CDNURL=http://npm.taobao.org/mirrors/chromedriver
      - SELENIUM_CDNURL=http://npm.taobao.org/mirrorss/selenium
    commands:
      - npm install
      - npm run build
  publish:
    image: alpine
    volumes:
      - devstack_www:/www
    commands:
      - mkdir -p /www/nginx/html
      - ls -alR public
      - env | grep DRONE
      - cp -ur public/* /www/nginx/html/
```

Up and test
==========

All done, it's time to test it out:

- `docker-compose up` to bring up the services
- configure gitea and add the first repo
- login to drone, and activate the repo
- goto gitea and see authorized application in account setting, and webhook in repository setting
- config the repo as **trusted**
- do webhook test from gitea, or push new commits to gitea.
- see what's going on in drone.

What's nest
===========

- cache to accelarate build
- build status notify
- build badges and reports
- common delever method(ssh/rsync/git release..etc)

The full docker-compose file
===========================

```yaml
version: '3'

volumes:
  gitea:
  pg:
  www:
  drone:
networks:
  www:
  postgres:

services:
  www:
    image: nginx:alpine
    restart: always
    ports:
      - "80:80"
    volumes:
      - ./data/log/nginx:/var/log/nginx
      - ./conf/nginx/conf.d:/etc/nginx/conf.d
      - www:/www
    depends_on:
      - drone-server
      - gitea
    networks:
      www:
        aliases:
          - xin.local
          - gitea.xin.local
          - drone.xin.local

  postgres:
    image: chenxinaz/pg_jieba:alpine
    environment:
      - POSTGRES_PASSWORD=asdfasdf123
    volumes:
      - pg:/var/lib/postgresql/data
      - ./conf/postgres/docker-entrypoint-initdb.d:/docker-entrypoint-initdb.d
    networks:
      postgres:

  gitea:
    image: gitea/gitea
    volumes:
      - gitea:/data
    depends_on:
      - postgres
    networks:
      www:
      postgres:

  drone-server:
    image: drone/drone
    volumes:
      - drone:/var/lib/drone/
    restart: always
    environment:
      - DRONE_ADMIN=xin
      - DRONE_OPEN=true
      - DRONE_HOST=http://drone.xin.local
      - DRONE_GITEA=true
      - DRONE_GITEA_URL=http://gitea.xin.local
      - DRONE_SECRET=c676-9241-d916-3d6a
      - DRONE_NETWORK=devstack_www
    networks:
      www:
      postgres:

  drone-agent:
    image: drone/agent
    command: agent
    restart: always
    depends_on:
      - drone-server
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - DRONE_SERVER=drone-server:9000
      - DRONE_SECRET=c676-9241-d916-3d6a
    networks:
      www:

```
