FROM maven:3.5.3-jdk-8-alpine
ARG UID=1000
ARG GID=977
ARG DOCKER_VERSION=18.03.1-ce
COPY docker-18.03.1-ce.tgz /tmp/docker-ce.tgz

RUN tar -xvzf /tmp/docker-ce.tgz --directory="/usr/local/bin" --strip-components=1 docker/docker
RUN adduser -S -u $UID jenkins
RUN addgroup -S -g $GID docker
RUN addgroup jenkins docker
RUN touch /tmp/mycontainer
USER jenkins
