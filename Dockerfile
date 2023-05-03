FROM alpine

ENV SS_VER 3.3.5
ENV SS_URL https://github.com/shadowsocks/shadowsocks-libev/archive/v$SS_VER.tar.gz
ENV SS_DIR shadowsocks-libev-$SS_VER
ENV V2RAY_PLUGIN_VER 1.3.2
ENV V2RAY_PLUGIN_URL https://github.com/shadowsocks/v2ray-plugin/releases/download/v${V2RAY_PLUGIN_VER}/v2ray-plugin-linux-amd64-v${V2RAY_PLUGIN_VER}.tar.gz

RUN set -ex \
    && apk add --no-cache c-ares \
                          libressl \
                          libev \
                          libsodium \
                          mbedtls \
                          pcre \
    && apk add --no-cache \
               --virtual TMP autoconf \
                             automake \
                             build-base \
                             c-ares-dev \
                             curl \
                             gettext-dev \
                             libev-dev \
                             libsodium-dev \
                             libtool \
                             linux-headers \
                             mbedtls-dev \
                             openssl-dev \
                             pcre-dev \
                             tar \
    && curl -sSL $SS_URL | tar xz \
    && cd $SS_DIR \
        && curl -sSL https://github.com/shadowsocks/ipset/archive/shadowsocks.tar.gz | tar xz --strip 1 -C libipset \
        && curl -sSL https://github.com/shadowsocks/libcork/archive/shadowsocks.tar.gz | tar xz --strip 1 -C libcork \
        && curl -sSL https://github.com/shadowsocks/libbloom/archive/master.tar.gz | tar xz --strip 1 -C libbloom \
        && wget -cq -O v2ray-plugin.tar.gz $V2RAY_PLUGIN_URL \
        && tar xvzf v2ray-plugin.tar.gz \
        && mv v2ray-plugin_linux_amd64 /usr/local/bin/v2ray-plugin \
        && ./autogen.sh \
        && ./configure --disable-documentation \
        && make install \
        && cd .. \
        && rm -rf $SS_DIR \
    && apk del TMP

ENV SERVER_ADDR 0.0.0.0
ENV SERVER_PORT 8388
ENV METHOD      chacha20-ietf-poly1305
ENV PASSWORD=
ENV TIMEOUT     60
ENV DNS_ADDR    8.8.8.8
ENV ARGS        -u

EXPOSE $SERVER_PORT/tcp
EXPOSE $SERVER_PORT/udp

CMD ss-server -s "$SERVER_ADDR" \
              -p "$SERVER_PORT" \
              -m "$METHOD"      \
              -k "$PASSWORD"    \
              -t "$TIMEOUT"     \
              -d "$DNS_ADDR"    \
              --fast-open \
              $ARGS
