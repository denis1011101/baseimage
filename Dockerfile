FROM alpine:3.20

ENV \
    TERM=xterm-256color  \
    TIME_ZONE=Etc/GMT-5  \
    APP_USER=app         \
    APP_UID=1001         \
    DOCKER_GID=999         

COPY files/scripts/nop.sh /usr/bin/nop.sh
COPY files/scripts/app.sh /usr/bin/app.sh
COPY files/scripts/pong.sh /usr/bin/pong.sh
COPY files/init.sh /init.sh
COPY files/init-root.sh /init-root.sh

RUN \
    chmod +x /usr/bin/nop.sh /usr/bin/app.sh /init.sh /init-root.sh && \
    apk add --no-cache --update su-exec tzdata curl ca-certificates shared-mime-info dumb-init make && \
    ln -s /sbin/su-exec /usr/local/bin/gosu && \
    mkdir -p /home/$APP_USER && \
    adduser -s /bin/sh -D -u $APP_UID $APP_USER && chown -R $APP_USER:$APP_USER /home/$APP_USER && \
    delgroup ping && addgroup -g 998 ping && \
    addgroup -g ${DOCKER_GID} docker && addgroup ${APP_USER} docker && \
    mkdir -p /srv && chown -R $APP_USER:$APP_USER /srv && \
    cp /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime && \
    echo "${TIME_ZONE}" > /etc/timezone && date && \
    ln -s /usr/bin/dumb-init /sbin/dinit && \
    # Install Ruby (specific version) and Bundler
    apk add --no-cache ruby=3.3.3-r1 ruby-dev=3.3.3-r1 && \
    gem install bundler && \
    # Install Python and pip
    apk add --no-cache python3=3.12.7-r0 py3-pip=24.0-r2 && \
    # Install Node.js and npm
    apk add --no-cache nodejs=20.15.1-r0 npm=10.8.0-r0 && \
    # Install PostgreSQL client
    apk add --no-cache postgresql16-client=16.4-r0 && \
    # Install Tailscale
    apk add --no-cache tailscale && \
    # Add edge/testing repository and install Headscale
    echo "@edge http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk add --no-cache headscale@edge && \
    rm -rf /var/cache/apk/*

ENTRYPOINT ["/init.sh"]
