# Shadowsocks-libev Dockerfile
This Dockerfile builds an image for [shadowsocks-libev](https://github.com/shadowsocks/shadowsocks-libev/) with [v2ray-plugin](https://github.com/shadowsocks/v2ray-plugin) based on Alpine Linux.

Current version:
- shadowsocks-libev: v3.3.5
- v2ray-plugin: v1.3.2

```
docker build -t bakabtw/shadowsocks-libev .
```

## Quick Start

Get the docker image by running the following commands:

```bash
docker pull bakabtw/shadowsocks-libev
```

Start an instance:

```bash
docker run -d --name=shadowsocks-libev -p 8388:8388/tcp -p 8388:8388/udp \
--restart=always bakabtw/shadowsocks-libev
```
or

```
docker run -d \
-e METHOD=aes-256-gcm \
-e PASSWORD=YourPassword \
--name=shadowsocks-libev \
-p 8388:8388/tcp \
-p 8388:8388/udp \
--restart=always \
bakabtw/shadowsocks-libev:3.3.0
```

You can also use a bash script for launching shadowsocks-libev container:

```
## Create a container named shadowsocks-8080 with port 8080 published
./easyss.sh --port 8080 --password your_password --method aes-256-gcm

## Stop the container
docker kill shadowsocks-8080
```

## Setting a specific configration

You can use environment variables for specific configration.

For example, start a container with encrypt method `aes-256-gcm` and password `YourPassword`:

```bash
docker run -d \
-e METHOD=aes-256-gcm \
-e PASSWORD=YourPassword \
--name=shadowsocks-libev \
-p 8388:8388/tcp \
-p 8388:8388/udp \
--restart=always \
bakabtw/shadowsocks-libev
```

Available environment variables and default values:

- `SERVER_ADDRS`: Host name or ip address of your remote server, default value is `0.0.0.0`.
- `SERVER_PORT`: Port number of your remote server, default value is `8388`.
- `PASSWORD`: Password of your remote server, default value is `ChangeMe!!!`.
- `METHOD`: Encrypt method, default value is `chacha20-ietf-poly1305`.
- `TIMEOUT`: Socket timeout in seconds, default value is `600`.
- `DNS_ADDRS`: Setup name servers for internal DNS resolver, default value is `8.8.8.8`.
- `ARGS`: Additional arguments supported by `ss-server`, default value is `-u`, to enable UDP relay.


## Enable v2ray-plugin
By default, v2ray-plugin is disabled, use `ARGS` environment variable with `--plugin`, `--plugin-opts` arguments to enable it.

For example, if you want to enable v2ray-plugin with QUIC mode:
```sh
docker run -d \
-e "ARGS=--plugin v2ray-plugin --plugin-opts server;mode=quic;host=yourdomain.com" \
-e PASSWORD=YourPassword \
-v /home/username/.acme.sh:/root/.acme.sh \
--name=shadowsocks-libev \
-p 8388:8388/tcp \
-p 8388:8388/udp \
--restart=always \
bakabtw/shadowsocks-libev
```

*Attention: if you want to enable v2ray-plugin QUIC mode, you must disable the UDP relay of ss-server by launching it without `-u` argument in `ARGS`.*

Enable v2ray-plugin with TLS mode and enable UDP relay:
```sh
docker run -d \
-e "ARGS=--plugin v2ray-plugin --plugin-opts server;tls;host=yourdomain.com -u" \
-e PASSWORD=YourPassword \
-v /home/username/.acme.sh:/root/.acme.sh \
--name=shadowsocks-libev \
-p 8388:8388/tcp \
-p 8388:8388/udp \
--restart=always \
bakabtw/shadowsocks-libev
```

Remember mount your certs to container

### Issue a cert for TLS and QUIC

v2ray-plugin will look for TLS certificates signed by [acme.sh](https://github.com/Neilpang/acme.sh) by default.
Here's some sample commands for issuing a certificate using CloudFlare.
You can find commands for issuing certificates for other DNS providers at acme.sh.

```sh
curl https://get.acme.sh | sh
~/.acme.sh/acme.sh --issue --dns dns_cf -d mydomain.me
```

For more v2ray-plugin configrations please go to [v2ray plugin docs](https://github.com/shadowsocks/v2ray-plugin/blob/master/README.md)


## With docker-compose
docker-compose.yml:
```yml
version: "3.7"
services:
  shadowsocks-libev:
    container_name: shadowsocks-libev
    image: bakabtw/shadowsocks-libev
    ports:
      - "8388:8388/tcp"
      - "8388:8388/udp"
    volumes:
      - /home/username/.acme.sh:/root/.acme.sh:ro
    environment:
      - PASSWORD=YourPassword
      - ARGS=--plugin v2ray-plugin --plugin-opts server;tls;host=yourdomain.com -u
    restart: always
```
