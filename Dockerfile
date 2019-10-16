ARG JNLP_IMAGE_TAG=3.35-5-alpine
ARG DOCKER_VERSION=19.03.3
ARG DOCKER_CHANNEL=stable
ARG DOCKER_DRIVER=overlay2
ARG DOCKER_HOST=tcp://localhost:2376
ARG DOCKER_TLS_VERIFY=1
ARG DOCKER_TLS_CERTDIR=/usr/local/share/ca-certificates
ARG DOCKER_CERT_PATH=$DOCKER_TLS_CERTDIR

FROM jenkins/jnlp-slave:$JNLP_IMAGE_TAG
LABEL Maintainer "Josip Radic <josip.radic@gmail.com>"
LABEL Description="This is a base image, which allows connecting Jenkins agents via JNLP protocols and that provides following tools: j2cli, awscli, docker cli, docker-compose, kubectl and helm" Vendor="Josip Radic" Version=$JNLP_IMAGE_TAG

ENV DOCKER_VERSION=${DOCKER_VERSION:-19.03.3}
ENV DOCKER_CHANNEL=${DOCKER_CHANNEL:-stable}
ENV DOCKER_DRIVER=${DOCKER_DRIVER}
ENV DOCKER_HOST=${DOCKER_HOST}
ENV DOCKER_TLS_VERIFY=${DOCKER_TLS_VERIFY}
ENV DOCKER_TLS_CERTDIR=${DOCKER_TLS_CERTDIR}
ENV DOCKER_CERT_PATH=${DOCKER_CERT_PATH}

# switch to root
USER root

# debian packages
RUN apk update && \
    DEBIAN_FRONTEND=noninteractive apk add --no-cache \
    py2-pip groff

# debian, setting locales
ENV MUSL_LOCPATH=/usr/local/share/i18n/locales/musl
RUN apk add --update --no-cache --virtual .build-deps \
    git cmake make musl-dev gcc gettext-dev libintl && \
    cd /tmp && git clone https://github.com/rilian-la-te/musl-locales.git && \
    cd /tmp/musl-locales && cmake . && make && make install && \
    apk del .build-deps

ENV LANG=en_US.UTF-8

# installing required packages
RUN apk add --no-cache \
    curl iptables

# install docker cli
RUN curl -Ssl https://download.docker.com/linux/static/${DOCKER_CHANNEL}/x86_64/docker-${DOCKER_VERSION}.tgz > /tmp/docker.tar.gz && \
    cd /tmp && tar xf docker.tar.gz && \
    chown -R root:root docker && \
    mv docker/* /usr/local/bin && \
    rm -rf docker*

# install docker-compose
RUN apk add --no-cache \
    py-pip python-dev libffi-dev openssl-dev gcc libc-dev make && \
    pip install docker-compose

# install helm
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get > get_helm.sh && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh && \
    rm -f get_helm.sh

# install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod 755 kubectl && \
    mv kubectl /usr/local/bin/kubectl

# install kompose
RUN apk add --no-cache --virtual .build-deps \
    git go musl-dev && \
    GOPATH=/ go get -u github.com/kubernetes/kompose && \
    apk del .build-deps

# install aws cli and j2cli
RUN pip install awscli && \
    pip install j2cli

# switch to jenkins
USER jenkins

ENTRYPOINT ["jenkins-slave"]