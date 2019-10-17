ARG JNLP_IMAGE_TAG=3.35-5-alpine

FROM jenkins/jnlp-slave:$JNLP_IMAGE_TAG
LABEL Maintainer "Josip Radic <josip.radic@gmail.com>"
LABEL Description="This is a base image, which allows connecting Jenkins agents via JNLP protocols and that provides following tools: j2cli, awscli, docker cli, docker-compose, kubectl and helm" Vendor="Josip Radic" Version=$JNLP_IMAGE_TAG

# switch to root
USER root

# docker env vars
ENV DOCKER_HOST=${DOCKER_HOST:-tcp://localhost:2376}
ENV DOCKER_DRIVER=${DOCKER_DRIVER:-overlay2}
ENV DOCKER_TLS_VERIFY=${DOCKER_TLS_VERIFY:-1}
ENV DOCKER_TLS_CERTDIR=${DOCKER_TLS_CERTDIR:-/usr/local/share/ca-certificates}
ENV DOCKER_CERT_PATH=${DOCKER_CERT_PATH:-$DOCKER_TLS_CERTDIR}

# debian env vars
ENV MUSL_LOCPATH=/usr/local/share/i18n/locales/musl
ENV LANG=en_US.UTF-8

# installation
RUN \
    echo "Installing dependencies ..." && \
        apk update && \
        DEBIAN_FRONTEND=noninteractive apk add --no-cache \
        curl cmake make musl-dev gcc gettext-dev libintl && \
    \
    echo "Installing locales ..." && \
        cd /tmp && git clone https://github.com/rilian-la-te/musl-locales.git && \
        cd /tmp/musl-locales && cmake . && make && make install && \
    \
    echo "Installing docker ..." && \
        curl -Ssl https://download.docker.com/linux/static/stable/x86_64/docker-19.03.3.tgz > /tmp/docker.tar.gz && \
        cd /tmp && tar xf docker.tar.gz && \
        chown -R root:root docker && \
        mv docker/* /usr/local/bin && \
        rm -rf docker* && \
    \
    echo "Installing docker-compose, awscli and j2cli ..." && \
        apk add --no-cache --virtual .build-deps \
        py-pip python-dev libffi-dev openssl-dev gcc libc-dev make && \
        pip install docker-compose && \
        pip install awscli && \
        pip install j2cli && \
        apk del --no-cache .build-deps && \
    \
    echo "Installing kubectl ..." && \
        curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
        chmod 755 kubectl && \
        mv kubectl /usr/local/bin/kubectl && \
    \
    echo "Installing helm ..." && \
        curl https://raw.githubusercontent.com/helm/helm/master/scripts/get > get_helm.sh && \
        chmod 700 get_helm.sh && \
        ./get_helm.sh && \
        rm -f get_helm.sh && \
    \
    echo "Installing kompose ..." && \
        curl -L https://github.com/kubernetes/kompose/releases/download/v1.19.0/kompose-linux-amd64 -o kompose && \
        chmod +x kompose && \
        mv ./kompose /usr/local/bin/kompose

# switch to jenkins
USER jenkins

ENTRYPOINT ["jenkins-slave"]