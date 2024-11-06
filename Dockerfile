FROM alpine:3.21.3

ENV \
    TERM=xterm-256color          \
    TIME_ZONE=Etc/GMT-5          \
    APP_USER=app                 \
    APP_UID=1001                 \
    DOCKER_GID=999               \
    APP_PASSWORD=""

COPY files/scripts/nop.sh /usr/bin/nop.sh
COPY files/scripts/app.sh /usr/bin/app.sh
COPY files/scripts/pong.sh /usr/bin/pong.sh
COPY files/init.sh /init.sh
COPY files/init-root.sh /init-root.sh

RUN \
    chmod +x /usr/bin/nop.sh /usr/bin/app.sh /usr/bin/pong.sh /init.sh /init-root.sh && \
    apk add --no-cache --update su-exec tzdata curl ca-certificates shared-mime-info dumb-init && \
    ln -s /sbin/su-exec /usr/local/bin/gosu && \
    adduser -s /bin/sh -D -u $APP_UID $APP_USER && \
    delgroup ping && addgroup -g 998 ping && \
    addgroup -g ${DOCKER_GID} docker && addgroup ${APP_USER} docker && \
    mkdir -p /srv && chown -R $APP_USER:$APP_USER /srv && \
    cp /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime && \
    echo "${TIME_ZONE}" > /etc/timezone && date && \
    ln -s /usr/bin/dumb-init /sbin/dinit && \
    # Install Tailscale
    apk add --no-cache tailscale wget && \
    # Download and install Headscale
    wget https://github.com/juanfont/headscale/releases/download/v0.23.0/headscale_0.23.0_linux_amd64 -O /usr/local/bin/headscale && \
    chmod +x /usr/local/bin/headscale && \
    # Cleanup
    rm -rf /var/cache/apk/*

ENTRYPOINT ["/init.sh"]