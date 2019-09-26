FROM maven:3.5.3-jdk-8-alpine
ARG UID=1000
ARG GID=977
ARG DOCKER_VERSION=18.03.1-ce

RUN apk update && \
    apk add --update make && \
    apk -v --update add \
        git \
        && \
    pip install --upgrade awscli s3cmd==2.0.1 python-magic && \
    apk -v --purge del py-pip && \
    rm /var/cache/apk/* && \
    curl -fSL "https://download.docker.com/linux/static/stable/`uname -m`/docker-${DOCKER_VERSION}.tgz" -o /tmp/docker-ce.tgz && \
    tar -xvzf /tmp/docker-ce.tgz --directory="/usr/local/bin" --strip-components=1 docker/docker && \
    adduser -S -u $UID jenkins && \
    addgroup -S -g $GID docker && \
    addgroup jenkins docker
USER jenkins
