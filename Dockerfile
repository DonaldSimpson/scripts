FROM maven:3.5.3-jdk-8-alpine

# Copy the local docker client archive to /tmp
COPY docker-18.03.1-ce.tgz /tmp/docker-ce.tgz
# Extract the docker client
RUN tar -xvzf /tmp/docker-ce.tgz --directory="/usr/local/bin" --strip-components=1 docker/docker &&\
  /bin/rm -rf /tmp/docker-ce.tgz
# Add a suitable user & group
RUN adduser -S -u 1000 jenkins &&\
    addgroup -S -g 977 docker &&\
    addgroup jenkins docker
# Create a file to show where we are
RUN touch /tmp/ThisIsMyAgentContainer
# Switch user
USER jenkins
